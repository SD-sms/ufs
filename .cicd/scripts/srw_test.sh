#!/bin/bash
set -e -u -x

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Ensure required variables are set
: "${WORKSPACE:?WORKSPACE is not set}"
: "${SRW_PLATFORM:?SRW_PLATFORM is not set}"

# Set workspace directory
if [ -d "${WORKSPACE}/${SRW_PLATFORM}" ]; then
    workspace="${WORKSPACE}/${SRW_PLATFORM}"
else
    workspace="$(cd "${script_dir}" && pwd)"
fi

# Normalize SRW platform value
if [[ "${SRW_PLATFORM}" == wcoss || "${SRW_PLATFORM}" == noaa ]]; then
    platform=wcosscloud
else
    platform="${SRW_PLATFORM}"
fi

# Test directories
export w2e2_experiment_base_dir="${workspace}/tests/WE2E"
export w2e2_test_dir="${workspace}/tests/WE2E"

# Clean any stale test logs
[ -d "${workspace}/tests/WE2E/log" ] && rm -f "${workspace}/tests/WE2E/log/*"
[ -d "${w2e2_experiment_base_dir}/log" ] && rm -f "${w2e2_experiment_base_dir}/log/WE2E_summary.txt"

# Run the end-to-end tests.
if "${SRW_WE2E_COMPREHENSIVE_TESTS}"; then
    export test_type="comprehensive"
else
    export test_type=${SRW_WE2E_SINGLE_TEST:-"coverage"}
    if [[ "${test_type}" = skill-score ]]; then
        export test_type="grid_SUBCONUS_Ind_3km_ics_FV3GFS_lbcs_FV3GFS_suite_WoFS_v0"
    fi
fi

cd ${we2e_test_dir}
# Progress file
progress_file="${workspace}/we2e_test_results-${SRW_PLATFORM}-${SRW_COMPILER}.txt"
/usr/bin/time -p -f '{\n  "cpu": "%P"\n, "memMax": "%M"\n, "mem": {"text": "%X", "data": "%D", "swaps": "%W", "context": "%c", "waits": "%w"}\n, "pagefaults": {"major": "%F", "minor": "%R"}\n, "filesystem": {"inputs": "%I", "outputs": "%O"}\n, "time": {"real": "%e", "user": "%U", "sys": "%S"}\n}' -o ${WORKSPACE}/${SRW_PLATFORM}-${SRW_COMPILER}-time-srw_test.json \
    ./setup_WE2E_tests.sh ${platform} ${SRW_PROJECT} ${SRW_COMPILER} ${test_type} \
    --expt_basedir=${we2e_experiment_base_dir} | tee ${progress_file}; \
    [[ -f ${we2e_experiment_base_dir}/grid_SUBCONUS_Ind_3km_ics_FV3GFS_lbcs_FV3GFS_suite_WoFS_v0/log.generate_FV3LAM_wflow ]] && ${workspace}/.cicd/scripts/srw_metric.sh run_stat_anly

# Set exit code to number of failures
set +e
failures=$(grep " DEAD    " ${progress_file} | wc -l)
if [[ $failures -ne 0 ]]; then
    failures=1
fi
set -e
exit ${failures}
