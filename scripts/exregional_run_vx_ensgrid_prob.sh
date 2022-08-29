#!/bin/bash

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${GLOBAL_VAR_DEFNS_FP}
. $USHrrfs/source_util_funcs.sh
#
#-----------------------------------------------------------------------
#
# Save current shell options (in a global array).  Then set new options
# for this script/function.
#
#-----------------------------------------------------------------------
#
{ save_shell_opts; . $USHrrfs/preamble.sh; } > /dev/null 2>&1
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

This is the ex-script for the task that runs METplus for grid-stat on
the UPP output files by initialization time for all forecast hours for 
gridded data.
========================================================================"

#-----------------------------------------------------------------------
#
# Begin grid-to-grid vx on ensemble output.
#
#-----------------------------------------------------------------------
#
print_info_msg "$VERBOSE" "Starting grid-stat verification"

#
#-----------------------------------------------------------------------
#
# Get the cycle date and hour (in formats of yyyymmdd and hh, respect-
# ively) from CDATE. Also read in FHR and create a comma-separated list
# for METplus to run over.
#
#-----------------------------------------------------------------------
#
yyyymmdd=${CDATE:0:8}
hh=${CDATE:8:2}
cyc=$hh
export CDATE
export hh

fhr_last=`echo ${FHR}  | awk '{ print $NF }'`
export fhr_last

fhr_list=`echo ${FHR} | $SED "s/ /,/g"`
export fhr_list

#
#-----------------------------------------------------------------------
#
# Create INPUT_BASE and LOG_SUFFIX to read into METplus conf files.
#
#-----------------------------------------------------------------------
#
INPUT_BASE=${EXPTDIR}/${CDATE}/metprd/ensemble_stat

if [ ${VAR} == "APCP" ]; then
  LOG_SUFFIX=ensgrid_prob_${CDATE}_${VAR}_${ACCUM}h
else
  LOG_SUFFIX=ensgrid_prob_${CDATE}_${VAR}
fi

#
#-----------------------------------------------------------------------
#
# Make sure directory in which output files will be placed exist.
#
#-----------------------------------------------------------------------
#
mkdir_vrfy -p "${EXPTDIR}/${CDATE}/metprd/ensemble_stat_prob"  # Output directory for grid_stat tool.

#
#-----------------------------------------------------------------------
#
# Check for existence of top-level OBS_DIR 
#
#-----------------------------------------------------------------------
#
if [[ ! -d "$OBS_DIR" ]]; then
  print_err_msg_exit "\
  Exiting: OBS_DIR does not exist."
fi

#
#-----------------------------------------------------------------------
#
# Export some environment variables passed in by the XML 
#
#-----------------------------------------------------------------------
#
export SCRIPTSrrfs
export INPUT_BASE
export EXPTDIR
export MET_INSTALL_DIR
export MET_BIN_EXEC
export METPLUS_PATH
export METPLUS_CONF
export MET_CONFIG
export MODEL
export NET
export POST_OUTPUT_DOMAIN_NAME
export LOG_SUFFIX

#
#-----------------------------------------------------------------------
#
# Run METplus 
#
#-----------------------------------------------------------------------
#
if [ ${VAR} == "APCP" ]; then
  export acc="${ACCUM}h"
  ${METPLUS_PATH}/ush/run_metplus.py \
    -c ${METPLUS_CONF}/common.conf \
    -c ${METPLUS_CONF}/GridStat_${VAR}${acc}_prob.conf
else
  ${METPLUS_PATH}/ush/run_metplus.py \
    -c ${METPLUS_CONF}/common.conf \
    -c ${METPLUS_CONF}/GridStat_${VAR}_prob.conf
fi

#
#-----------------------------------------------------------------------
#
# Print message indicating successful completion of script.
#
#-----------------------------------------------------------------------
#
print_info_msg "
========================================================================
METplus grid-stat completed successfully.

Exiting script:  \"${scrfunc_fn}\"
In directory:    \"${scrfunc_dir}\"
========================================================================"
#
#-----------------------------------------------------------------------
#
# Restore the shell options saved at the beginning of this script/func-
# tion.
#
#-----------------------------------------------------------------------
#
{ restore_shell_opts; } > /dev/null 2>&1
