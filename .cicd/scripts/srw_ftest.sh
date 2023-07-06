#!/usr/bin/env bash
#
# A unified test script for the SRW application. This script is expected to
# test the SRW application for all supported platforms.
# The goal is to perform some basic setup and execution of the initial few workflow tasks,
# as described in the user documentation section: "Run the Workflow Using Stand-Alone Scripts".
# We want this following a normal SRW build in an attempt to exercise environment setup, modules,
# data sets, and workflow scripts, without using too much time nor account resources.
# We hope to catch any snags that might prevent WE2E fundamental testing, which follows this gate.
# NOTE: At this time, this script is a placeholder for functional test framework.
# At this time, we are leaving the exercise of graphical plotting for a later stage, perhaps WE2E state.
#
# Required:
#    WORKSPACE=</full/path/to/ufs-srweather-app>
#    SRW_PLATFORM=<supported_platform_host>
#    SRW_COMPILER=<intel|gnu>
#
# Optional:
[[ -n ${ACCOUNT} ]] || ACCOUNT="no_account"
[[ -n ${BRANCH} ]] || BRANCH="develop"
[[ -n ${TASKS} ]] || TASKS=""
[[ -n ${TASK_DEPTH} ]] || TASK_DEPTH=4
[[ -n ${FORGIVE_CONDA} ]] || FORGIVE_CONDA=true
set -e -u -x

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"

# Get repository root from Jenkins WORKSPACE variable if set, otherwise, set
# relative to script directory.
declare workspace
if [[ -n "${WORKSPACE}" ]]; then
    workspace="${WORKSPACE}"
else
    workspace="$(cd -- "${script_dir}/../.." && pwd)"
fi

# Normalize Parallel Works cluster platform value.
declare platform
if [[ "${SRW_PLATFORM}" =~ ^(az|g|p)clusternoaa ]]; then
    platform='noaacloud'
else
    platform="${SRW_PLATFORM}"
fi

# Test directories
we2e_experiment_base_dir="${workspace}/expt_dirs"
we2e_test_dir="${workspace}/tests/WE2E"
nco_dir="${workspace}/nco_dirs"

pwd

# The following essentially sets up and performs tasks described in the user documentation section:
#     "Run the Workflow Using Stand-Alone Scripts".
echo "BRANCH=${BRANCH}"

# Set the ACCOUNT to use for this PLATFORM ...
sed "s|^  ACCOUNT: \"\"|  ACCOUNT: \"${ACCOUNT}\"|1" -i ush/config_defaults.yaml
sed "s|hera|${platform,,}|1" ush/config.community.yaml | sed "s|an_account|${ACCOUNT}|1" > ush/config.yaml

# Set directory paths ...
export EXPTDIR=${workspace}/expt_dirs/test_community
echo "EXPTDIR=${EXPTDIR}"
sed "s|^workflow:|workflow:\n  EXPT_BASEDIR: ${workspace}/expt_dirs|1" -i ush/config.yaml
sed "s|^workflow:|workflow:\n  EXEC_SUBDIR: ${workspace}/install_${SRW_COMPILER}/exec|1" -i ush/config.yaml

# DATA_LOCATION differs on each platform ... find it.
export DATA_LOCATION=$(grep TEST_EXTRN_MDL_SOURCE_BASEDIR ${workspace}/ush/machine/${SRW_PLATFORM,,}.yaml | awk '{printf "%s", $2}')
echo "DATA_LOCATION=${DATA_LOCATION}"

# Configure a default test ...
sed "s|^task_get_extrn_ics:|task_get_extrn_ics:\n  EXTRN_MDL_SOURCE_BASEDIR_ICS: ${DATA_LOCATION}/FV3GFS/grib2/2019061518|1" -i ush/config.yaml
sed "s|^task_get_extrn_lbcs:|task_get_extrn_lbcs:\n  EXTRN_MDL_SOURCE_BASEDIR_LBCS: ${DATA_LOCATION}/FV3GFS/grib2/2019061518|1" -i ush/config.yaml

hpss_machines=( jet hera )

# Use staged data for HPSS supported machines
if [[ ${hpss_machines[@]} =~ ${platform,,} ]] ; then
    sed 's|^task_get_extrn_ics:|task_get_extrn_ics:\n  USE_USER_STAGED_EXTRN_FILES: true|g' -i ush/config.yaml
    sed 's|^task_get_extrn_lbcs:|task_get_extrn_lbcs:\n  USE_USER_STAGED_EXTRN_FILES: true|g' -i ush/config.yaml
fi

# Activate the workflow environment ...
source etc/lmod-setup.sh ${platform,,}
module use modulefiles
module load build_${platform,,}_${SRW_COMPILER}
module load wflow_${platform,,}

# Load more modules on machines with hpss access
if [[ ${hpss_machines[@]} =~ ${platform,,} ]] ; then
  source ${workspace}/ush/load_modules_wflow.sh ${SRW_PLATFORM}
  module load hpss
  export PYTHONPATH=${workspace}/ush
fi

[[ ${FORGIVE_CONDA} == true ]] && set +e +u    # Some platforms have incomplete python3 or conda support, but wouldn't necessarily block workflow tests
conda activate workflow_tools
set -e -u

cd ${workspace}/ush
        # Consistency check ...
        ./config_utils.py -c ./config.yaml -v ./config_defaults.yaml -k "(\!rocoto\b)"
        # Generate workflow files ...
        ./generate_FV3LAM_wflow.py
cd ${workspace}

cd ${EXPTDIR}
pwd
cp ${workspace}/ush/wrappers/* .

# Set parameters that the task scripts require ...
export JOBSdir=${workspace}/jobs
export USHdir=${workspace}/ush
export PDY=20190615
export cyc=18
export subcyc=0
export OMP_NUM_THREADS=1

[[ -n ${TASKS} ]] || TASKS=(
                run_make_grid
                # Tasks below here require Data Sets from DATA_LOCATION
                run_get_ics
                run_get_lbcs
                run_make_orog
                # Tasks below here require a valid ACCOUNT
                run_make_sfc_climo
                run_make_ics
                run_make_lbcs
                run_fcst
                run_post
)
set +x

results_file=${workspace}/functional_test_results_${SRW_PLATFORM}_${SRW_COMPILER}.txt
rm -f ${results_file}

status=0

# Limit to machines that are fully ready
deny_machines=( hera gaea )
if [[ ${deny_machines[@]} =~ ${platform,,} ]] ; then
    echo "# Deny ${platform} - incomplete configuration." | tee -a ${results_file}
else
    echo "# Try ${platform} with the first few simple SRW tasks ..." | tee -a ${results_file}
    for task in ${TASKS[@]:0:${TASK_DEPTH}} ; do
                echo -n "./$task.sh ... "
                ./$task.sh > $task-log.txt 2>&1 && echo "COMPLETE" || echo "FAIL rc=$(( status+=$? ))"
                # stop at the first sign of trouble ...
                [[ 0 != ${status} ]] && echo "$task: FAIL" >> ${results_file} && break || echo "$task: COMPLETE" >> ${results_file}
    done
fi

# Set exit code to number of failures
set +e
failures=$(grep ": FAIL" ${results_file} | wc -l)
if [[ $failures -ne 0 ]]; then
    failures=1
fi
cd ${workspace}
set -e
exit ${failures}
