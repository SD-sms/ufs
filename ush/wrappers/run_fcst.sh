#!/bin/sh
export GLOBAL_VAR_DEFNS_FP="${EXPTDIR}/var_defns.sh"
set -x
source ${GLOBAL_VAR_DEFNS_FP}
export CDATE=${DATE_FIRST_CYCL}${CYCL_HRS}
export CYCLE_DIR=${EXPTDIR}/${CDATE}
export SLASH_ENSMEM_SUBDIR=""
export ENSMEM_INDX=""

${JOBSdir}/JREGIONAL_RUN_FCST

