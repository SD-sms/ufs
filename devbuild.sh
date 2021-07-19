#!/bin/bash

# usage instructions
usage () {
cat << EOF_USAGE
Usage: $0 [OPTIONS]...

OPTIONS
  -h, --help
      show this help guide
  --platform=PLATFORM
      name of machine you are building on; defauts to hostname
      (e.g. cheyenne | hera | jet | orion | wcoss)
  --compiler=COMPILER
      compiler to use; default depends on platform
      (e.g. intel | gnu | cray | gccgfortran)
  --app=APPLICATION
      weather model application to build
      (e.g. ATM | ATMW | S2S | S2SW)
  --ccpp="CCPP_SUITE1,CCPP_SUITE2..."
      CCCP suites to include in build; delimited with ','
  --components="COMPONENT1,COMPONENT2..."
      additional components to include in build; delimited with ','
      supported components are found in src/ufs-weather-model/CMakeLists.txt
      (e.g. UFS_GOCART | MOM6 | CICE6 | WW3 | CDEPS | CMEPS)
  --continue
      continue with existing build
  --clean
      removes existing build; overrides --continue
  --build-dir=BUILD_DIR
      build directory
  --install-dir=INSTALL_DIR
      installation prefix
  --build-type=BUILD_TYPE
      build type; defaults to RELEASE
      (e.g. DEBUG | RELEASE | RELWITHDEBINFO)
  --build-jobs=BUILD_JOBS
      number of build jobs; defaults to 4
  -v, --verbose
      build with verbose output

NOTE: This script is for internal developer use only;
See User's Guide for detailed build instructions

EOF_USAGE
}

# print settings
settings () {
cat << EOF_SETTINGS
Settings:

  SRC_DIR=${SRC_DIR}
  BUILD_DIR=${BUILD_DIR}
  INSTALL_DIR=${INSTALL_DIR}
  PLATFORM=${PLATFORM}
  COMPILER=${COMPILER}
  APP=${APPLICATION}
  CCPP=${CCPP}
  COMPONENTS=${COMPONENTS}
  CLEAN=${CLEAN}
  CONTINUE=${CONTINUE}
  BUILD_TYPE=${BUILD_TYPE}
  BUILD_JOBS=${BUILD_JOBS}
  VERBOSE=${VERBOSE}

EOF_SETTINGS
}

# print usage error and exit
usage_error () {
  printf "ERROR: $1\n" >&2
  usage >&2
  exit 1
}

# find system name
find_system () {
  if [ -f $1 ]; then
    source $1
    local sysname=$target
  else
    local sysname=`hostname`
    sysname="${sysname//[[:digit:]]/}"
    if [ "${sysname}" = "fe" ]; then
      sysname="jet"
    elif [ "${sysname}" = "hfe" ]; then
      sysname="hera"
    fi
  fi
  echo "$sysname"
}

# default settings
LCL_PID=$$
SRC_DIR=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )" && pwd -P)
MACHINE_SETUP=${SRC_DIR}/src/UFS_UTILS/sorc/machine-setup.sh
BUILD_DIR=${SRC_DIR}/build
INSTALL_DIR=${SRC_DIR}
PLATFORM=""
COMPILER=""
APPLICATION=""
CCPP=""
COMPONENTS=""
BUILD_TYPE="RELEASE"
BUILD_JOBS=4
CLEAN=false
CONTINUE=false
VERBOSE=false

# process arguments
while :; do
  case $1 in
    --help|-h) usage; exit 0 ;;
    --platform=?*) PLATFORM=${1#*=} ;;
    --platform|--platform=) usage_error "$1 requires argument." ;;
    --compiler=?*) COMPILER=${1#*=} ;;
    --compiler|--compiler=) usage_error "$1 requires argument." ;;
    --app=?*) APPLICATION=${1#*=} ;;
    --app|--app=) usage_error "$1 requires argument." ;;
    --ccpp=?*) CCPP=${1#*=} ;;
    --ccpp|--ccpp=) usage_error "$1 requires argument." ;;
    --components=?*) COMPONENTS=${1#*=} ;;
    --components|--components=) usage_error "$1 requires argument." ;;
    --clean) CLEAN=true ;;
    --clean=?*|--clean=) usage_error "$1 argument ignored." ;;
    --continue) CONTINUE=true ;;
    --continue=?*|--continue=) usage_error "$1 argument ignored." ;;
    --build-dir=?*) BUILD_DIR=${1#*=} ;;
    --build-dir|--build-dir=) usage_error "$1 requires argument." ;;
    --install-dir=?*) INSTALL_DIR=${1#*=} ;;
    --install-dir|--install-dir=) usage_error "$1 requires argument." ;;
    --build-type=?*) BUILD_TYPE=${1#*=} ;;
    --build-type|--build-type=) usage_error "$1 requires argument." ;;
    --build-jobs=?*) BUILD_JOBS=$((${1#*=})) ;;
    --build-jobs|--build-jobs=) usage_error "$1 requires argument." ;;
    --verbose|-v) VERBOSE=true ;;
    --verbose=?*|--verbose=) usage_error "$1 argument ignored." ;;
    -?*) usage_error "Unknown option $1" ;;
    *) break
  esac
  shift
done

set -eu

# automatically determine system
if [ -z "${PLATFORM}" ] ; then
  PLATFORM=$(find_system "$MACHINE_SETUP")
fi

# automatically determine compiler
if [ -z "${COMPILER}" ] ; then
  case ${PLATFORM} in
    jet|hera) COMPILER=intel ;;
    orion) COMPILER=intel ;;
    wcoss) COMPILER=cray_intel ;;
    cheyenne) COMPILER=intel ;;
    macos) COMPILER=gccgfortran ;;
    *) printf "ERROR: Unknown platform ${PLATFORM}\n" >&2; usage >&2; exit 1 ;;
  esac
fi

# print settings
if [ "${VERBOSE}" = true ] ; then
  settings
fi

# set ENV_FILE for this platform/compiler combination
ENV_FILE="${SRC_DIR}/env/build_${PLATFORM}_${COMPILER}.env"
if [ ! -f "${ENV_FILE}" ]; then
  printf "ERROR: environment file does not exist for platform/compiler\n" >&2
  printf "  ENV_FILE=${ENV_FILE}\n" >&2
  printf "  PLATFORM=${PLATFORM}\n" >&2
  printf "  COMPILER=${COMPILER}\n\n" >&2
  usage >&2
  exit 64
fi

# if build directory already exists then exit
if [ "${CLEAN}" = true ]; then
  printf "Remove build directory\n"
  printf "  BUILD_DIR=${BUILD_DIR}\n\n"
  rm -rf ${BUILD_DIR}
elif [ "${CONTINUE}" = true ]; then
  printf "Continue build in directory\n"
  printf "  BUILD_DIR=${BUILD_DIR}\n\n"
else
  if [ -d "${BUILD_DIR}" ]; then
    while true; do
      if [[ $(ps -o stat= -p ${LCL_PID}) != *"+"* ]] ; then
        printf "ERROR: Build directory already exists\n" >&2
        printf "  BUILD_DIR=${BUILD_DIR}\n\n" >&2
        usage >&2
        exit 64
      fi
      # interactive selection
      printf "Build directory (${BUILD_DIR}) already exists\n"
      printf "Please choose what to do:\n\n"
      printf "[R]emove the existing directory\n"
      printf "[C]ontinue building in the existing directory\n"
      printf "[Q]uit this build script\n"
      read -p "Choose an option (R/C/Q):" choice
      case ${choice} in
        [Rr]* ) rm -rf ${BUILD_DIR}; break ;;
        [Cc]* ) break ;;
        [Qq]* ) exit ;;
        * ) printf "Invalid option selected.\n" ;;
      esac
    done
  fi
fi

# cmake settings
CMAKE_SETTINGS="-DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}"
CMAKE_SETTINGS="${CMAKE_SETTINGS} -DCMAKE_BUILD_TYPE=${BUILD_TYPE}"
if [ ! -z "${APPLICATION}" ]; then
  CMAKE_SETTINGS="${CMAKE_SETTINGS} -DAPP=${APPLICATION}"
fi
if [ ! -z "${CCPP}" ]; then
  CMAKE_SETTINGS="${CMAKE_SETTINGS} -DCCPP=${CCPP}"
fi
if [ ! -z "${COMPONENTS}" ]; then
  CMAKE_SETTINGS="${CMAKE_SETTINGS} -DINCLUDE_COMPONENTS=${COMPONENTS}"
fi

# make settings
MAKE_SETTINGS="-j ${BUILD_JOBS}"
if [ "${VERBOSE}" = true ]; then
  MAKE_SETTINGS="${MAKE_SETTINGS} VERBOSE=1"
fi

# source the README file for this platform/compiler combination, then build the code
. ${ENV_FILE}
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
cmake ${SRC_DIR} ${CMAKE_SETTINGS} 2>&1 | tee log.cmake
make ${MAKE_SETTINGS} 2>&1 | tee log.make

exit 0
