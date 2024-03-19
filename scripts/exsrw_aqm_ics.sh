#!/usr/bin/env bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${USHsrw}/source_util_funcs.sh
source_config_for_task "task_aqm_ics" ${GLOBAL_VAR_DEFNS_FP}
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; set -xue; } > /dev/null 2>&1
#
#-----------------------------------------------------------------------
#
# Get the full path to the file in which this script/function is located 
# (scrfunc_fp), the name of that file (scrfunc_fn), and the directory in
# which the file is located (scrfunc_dir).
#
#-----------------------------------------------------------------------
#
scrfunc_fp=$( $READLINK -f "${BASH_SOURCE[0]}" )
scrfunc_fn=$( basename "${scrfunc_fp}" )
scrfunc_dir=$( dirname "${scrfunc_fp}" )
#
#-----------------------------------------------------------------------
#
# Print message indicating entry into script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Entering script:  \"${scrfunc_fn}\"
In directory:     \"${scrfunc_dir}\"

This is the ex-script for the task that copies/fetches to a local direc-
tory (either from disk or HPSS) the external model files from which ini-
tial or boundary condition files for the FV3 will be generated.
========================================================================"
#
#-----------------------------------------------------------------------
#
# Check if restart file exists
#
#-----------------------------------------------------------------------
#
rst_dir="${PREV_CYCLE_DIR}/RESTART"
rst_file="fv_tracer.res.tile1.nc"
fv_tracer_file="${rst_dir}/${PDY}.${cyc}0000.${rst_file}"
print_info_msg "Looking for tracer restart file: \"${fv_tracer_file}\""
if [ ! -r ${fv_tracer_file} ]; then
  if [ -r ${rst_dir}/coupler.res ]; then
    rst_info=( $( tail -n 1 ${rst_dir}/coupler.res ) )
    # Remove leading zeros from ${rst_info[1]}
    month="${rst_info[1]#"${rst_info[1]%%[!0]*}"}"
    # Remove leading zeros from ${rst_info[2]}
    day="${rst_info[2]#"${rst_info[2]%%[!0]*}"}"
    # Format the date without leading zeros
    rst_date=$(printf "%04d%02d%02d%02d" ${rst_info[0]} $((10#$month)) $((10#$day)) ${rst_info[3]})
    print_info_msg "
  Tracer file not found. Checking available restart date:
    requested date: \"${PDY}${cyc}\"
    available date: \"${rst_date}\""
    if [ "${rst_date}" = "${PDY}${cyc}" ] ; then
      fv_tracer_file="${rst_dir}/${rst_file}"
      if [ -r ${fv_tracer_file} ]; then
        print_info_msg "Tracer file found: \"${fv_tracer_file}\""
      else
        message_txt="FATAL ERROR No suitable tracer restart file ${rst_dir}/${rst_file} found."
        err_exit "${message_txt}"
        print_err_msg_exit "${message_txt}"
      fi
    fi
  fi
fi
#
#-----------------------------------------------------------------------
#
# Add air quality tracer variables from previous cycle's restart output
# to atmosphere's initial condition file according to the steps below:
#
# a. Python script to manipulate the files (see comments inside for details)
# b. Remove checksum attribute to prevent overflow
# c. Rename reulting file as the expected atmospheric IC file
#
#-----------------------------------------------------------------------
#
gfs_ic_fn="${NET}.${cycle}${dot_ensmem}.gfs_data.tile${TILE_RGNL}.halo${NH0}.nc"
gfs_ic_fp="${DATA_SHARE}/${gfs_ic_fn}"
wrk_ic_fp="${DATA}/gfs.nc"

print_info_msg "
  Adding air quality tracers to atmospheric initial condition file:
    tracer file: \"${fv_tracer_file}\"
    FV3 IC file: \"${gfs_ic_fp}\""

cpreq ${gfs_ic_fp} ${wrk_ic_fp}
${USHsrw}/aqm_utils_python/add_aqm_ics.py --fv_tracer_file "${fv_tracer_file}" --wrk_ic_file "${wrk_ic_fp}"
export err=$?
if [ $err -ne 0 ]; then
  message_txt="Call to python script \"add_aqm_ics.py\" failed."
  err_exit "${message_txt}"
  print_err_msg_exit "${message_txt}"
fi

ncatted -a checksum,,d,s, tmp1.nc
export err=$?
if [ $err -ne 0 ]; then
  message_txt="Call to NCATTED returned with nonzero exit code."
  err_exit "${message_txt}"
  print_err_msg_exit "${message_txt}"
fi

mv tmp1.nc ${gfs_ic_fn}

cpreq -p ${gfs_ic_fn} ${COMOUT}
cpreq -p "${DATA_SHARE}/${NET}.${cycle}${dot_ensmem}.sfc_data.tile${TILE_RGNL}.halo${NH0}.nc" ${COMOUT}
cpreq -p "${DATA_SHARE}/${NET}.${cycle}${dot_ensmem}.gfs_ctrl.nc" ${COMOUT}
cpreq -p "${DATA_SHARE}/${NET}.${cycle}${dot_ensmem}.gfs_bndy.tile${TILE_RGNL}.f000.nc" ${COMOUT}

unset fv_tracer_file
unset wrk_ic_file
#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
Successfully added air quality tracers to atmospheric IC file!!!

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/function.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1

