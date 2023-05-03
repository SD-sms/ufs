#!/usr/bin/env bash
#
# A test script for running the SRW application unittest tests that
# should be tested on-prem.
#
set -e -u -x

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)"

# Get repository root from Jenkins WORKSPACE variable if set, otherwise,
# set relative to script directory.
declare workspace
if [[ -n "${WORKSPACE:-}" ]]; then
  workspace="${WORKSPACE}"
else
  workspace="$(cd -- "${script_dir}/../.." && pwd)"
fi

cd $workspace
# Only run this on machines with hpss access
hpss_machines=( jet hera )
if [[ ${hpss_machines[@]} =~ ${SRW_PLATFORM} ]] ; then

  source ${workspace}/ush/load_modules_wflow.sh ${SRW_PLATFORM}
  module load hpss

  export PYTHONPATH=${workspace}/ush
  python -m unittest $workspace/tests/test_python/test_retrieve_data.py

fi
