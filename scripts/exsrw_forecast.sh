#!/usr/bin/env bash


#
#-----------------------------------------------------------------------
#
# This ex-script is responsible for running the FV3 regional forecast.
#
# Run-time environment variables:
#
#    CDATE
#    COMIN
#    COMOUT
#    COMROOT
#    DATA
#    DBNROOT
#    GLOBAL_VAR_DEFNS_FP
#    INPUT_DATA
#    NET
#    PDY
#    REDIRECT_OUT_ERR
#    RUN
#    SENDDBN
#    SLASH_ENSMEM_SUBDIR
#
# Experiment variables
#
#  user:
#    MACHINE
#    PARMdir
#    RUN_ENVIR
#    USHdir
#
#  platform:
#    PRE_TASK_CMDS
#    RUN_CMD_FCST
#
#  workflow:
#    CCPP_PHYS_DIR
#    CCPP_PHYS_SUITE
#    COLDSTART
#    CRES
#    DATA_TABLE_FN
#    DATA_TABLE_FP
#    DATE_FIRST_CYCL
#    DOT_OR_USCORE
#    EXPTDIR
#    FCST_LEN_CYCL
#    FCST_LEN_HRS
#    FIELD_DICT_FP
#    FIELD_DICT_FN
#    FIELD_TABLE_FN
#    FIELD_TABLE_FP
#    FIXam
#    FIXclim
#    FIXlam
#    FV3_NML_FN
#    FV3_NML_FP
#    FV3_NML_STOCH_FP
#    INCR_CYCL_FREQ
#    PREDEF_GRID_NAME
#    SYMLINK_FIX_FILES
#    VERBOSE
#
#  task_get_extrn_lbcs:
#    LBC_SPEC_INTVL_HRS
#
#  task_run_fcst:
#    DO_FCST_RESTART
#    DT_ATMOS
#    FV3_EXEC_FP
#    KMP_AFFINITY_RUN_FCST
#    OMP_NUM_THREADS_RUN_FCST
#    OMP_STACKSIZE_RUN_FCST
#    PRINT_ESMF
#    RESTART_INTERVAL
#    USE_MERRA_CLIMO
#    WRITE_DOPOST
#
#  task_run_post:
#    CUSTOM_POST_CONFIG_FP
#    DT_SUBHOURLY_POST_MNTS
#    POST_OUTPUT_DOMAIN_NAME
#    SUB_HOURLY_POST
#    USE_CUSTOM_POST_CONFIG_FILE
#
#  global:
#    DO_ENSEMBLE
#    DO_LSM_SPP
#    DO_SHUM
#    DO_SKEB
#    DO_SPP
#    DO_SPPT
#
#  cpl_aqm_parm:
#    AQM_RC_PRODUCT_FN
#    CPL_AQM
#
#  constants:
#    NH0
#    NH3
#    NH4
#    TILE_RGNL
#
#  fixed_files:
#    CYCLEDIR_LINKS_TO_FIXam_FILES_MAPPING
#
#-----------------------------------------------------------------------
#

#
#-----------------------------------------------------------------------
#
# Source the variable definitions file and the bash utility functions.
#
#-----------------------------------------------------------------------
#
. ${USHsrw}/source_util_funcs.sh
for sect in user nco platform workflow global cpl_aqm_parm smoke_dust_parm constants fixed_files \
  task_get_extrn_lbcs task_run_fcst task_run_post ; do
  source_yaml ${GLOBAL_VAR_DEFNS_FP} ${sect}
done
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

This is the ex-script for the task that runs a forecast with FV3 for the
specified cycle.
========================================================================"
#
#-----------------------------------------------------------------------
#
# Set environment variables.
#
#-----------------------------------------------------------------------
#
export KMP_AFFINITY=${KMP_AFFINITY_RUN_FCST}
export OMP_NUM_THREADS=${OMP_NUM_THREADS_RUN_FCST}
export OMP_STACKSIZE=${OMP_STACKSIZE_RUN_FCST}
export MPI_TYPE_DEPTH=20
export ESMF_RUNTIME_COMPLIANCECHECK=OFF:depth=4
if [ $(boolify "${PRINT_ESMF}") = "TRUE" ]; then
  export ESMF_RUNTIME_PROFILE=ON
  export ESMF_RUNTIME_PROFILE_OUTPUT="SUMMARY"
fi
#
#-----------------------------------------------------------------------
#
# Load modules.
#
#-----------------------------------------------------------------------
#
eval ${PRE_TASK_CMDS}

if [ -z "${RUN_CMD_FCST:-}" ] ; then
  print_err_msg_exit "\
  Run command was not set in machine file. \
  Please set RUN_CMD_FCST for your platform"
else
  print_info_msg "$VERBOSE" "
  All executables will be submitted with command \'${RUN_CMD_FCST}\'."
fi

if [ ${#FCST_LEN_CYCL[@]} -gt 1 ]; then
  cyc_mod=$(( ${cyc} - ${DATE_FIRST_CYCL:8:2} ))
  CYCLE_IDX=$(( ${cyc_mod} / ${INCR_CYCL_FREQ} ))
  FCST_LEN_HRS=${FCST_LEN_CYCL[$CYCLE_IDX]}
fi
# Set CDATE
export CDATE="${PDY}${cyc}"
# Create RESTART directory in the working directory DATA
mkdir -p ${DATA}/RESTART
#
#-----------------------------------------------------------------------
#
# Create and set up INPUT subdirectory of the current working directory
# to run the ufs weather model
#
#-----------------------------------------------------------------------
#
print_info_msg "$VERBOSE" "
Creating links with names that FV3 looks for in the INPUT subdirectory
of the current working directory (DATA), where
  DATA = \"${DATA}\"
..."

# Create and set up INPUT directory for ufs-weather-model.
mkdir -p ${DATA}/INPUT
cd ${DATA}/INPUT

# Symlink to mosaic file with a completely different name.
target="${FIXlam}/${CRES}${DOT_OR_USCORE}mosaic.halo${NH3}.nc"
symlink="grid_spec.nc"
ln -nsf $target $symlink

# Symlink to halo-3 grid file with "halo3" stripped from name.
mosaic_fn="grid_spec.nc"
grid_fn=$( get_charvar_from_netcdf "${mosaic_fn}" "gridfiles" )
target="${FIXlam}/${grid_fn}"
symlink="${grid_fn}"
ln -nsf $target $symlink

# Symlink to halo-4 grid file with "${CRES}_" stripped from name.
target="${FIXlam}/${CRES}${DOT_OR_USCORE}grid.tile${TILE_RGNL}.halo${NH4}.nc"
symlink="grid.tile${TILE_RGNL}.halo${NH4}.nc"
ln -nsf $target $symlink

# Symlink to halo-0 orography file with "${CRES}_" and "halo0" stripped from name.
target="${FIXlam}/${CRES}${DOT_OR_USCORE}oro_data.tile${TILE_RGNL}.halo${NH0}.nc"
symlink="oro_data.nc"
ln -nsf $target $symlink

# Symlink to halo-4 orography file with "${CRES}_" stripped from name.
target="${FIXlam}/${CRES}${DOT_OR_USCORE}oro_data.tile${TILE_RGNL}.halo${NH4}.nc"
symlink="oro_data.tile${TILE_RGNL}.halo${NH4}.nc"
ln -nsf $target $symlink
#
# When using some specific physics suite, there are two files (that contain 
# statistics of the orography) that are needed by the gravity wave drag 
# parameterization in that suite.
#
suites=( "FV3_RAP" "FV3_HRRR" "FV3_HRRR_gf" "FV3_GFS_v15_thompson_mynn_lam3km" "FV3_GFS_v17_p8" )
if [[ ${suites[@]} =~ "${CCPP_PHYS_SUITE}" ]] ; then
  file_ids=( "ss" "ls" )
  for file_id in "${file_ids[@]}"; do
    target="${FIXlam}/${CRES}${DOT_OR_USCORE}oro_data_${file_id}.tile${TILE_RGNL}.halo${NH0}.nc"
    symlink="oro_data_${file_id}.nc"
    ln -nsf $target $symlink
  done
fi

target="${COMIN}/${NET}.${cycle}${dot_ensmem}.gfs_data.tile${TILE_RGNL}.halo${NH0}.nc"
symlink="gfs_data.nc"
ln -nsf $target $symlink

target="${COMIN}/${NET}.${cycle}${dot_ensmem}.sfc_data.tile${TILE_RGNL}.halo${NH0}.nc"
symlink="sfc_data.nc"
ln -nsf $target $symlink

target="${COMIN}/${NET}.${cycle}${dot_ensmem}.gfs_ctrl.nc"
symlink="gfs_ctrl.nc"
ln -nsf $target $symlink

for fhr in $(seq -f "%03g" 0 ${LBC_SPEC_INTVL_HRS} ${FCST_LEN_HRS}); do
  target="${COMIN}/${NET}.${cycle}${dot_ensmem}.gfs_bndy.tile${TILE_RGNL}.f${fhr}.nc"
  symlink="gfs_bndy.tile${TILE_RGNL}.${fhr}.nc"
  ln -nsf $target $symlink
done

if [ $(boolify "${CPL_AQM}") = "TRUE" ]; then
  target="${COMIN}/${NET}.${cycle}${dot_ensmem}.NEXUS_Expt.nc"
  symlink="NEXUS_Expt.nc"
  ln -nsf $target $symlink

  # create symlink to PT for point source in SRW-AQM
  target="${COMIN}/${NET}.${cycle}${dot_ensmem}.PT.nc"
  if [ -f ${target} ]; then
    symlink="PT.nc"
    ln -nsf $target $symlink
  fi
fi
if [ $(boolify "${DO_SMOKE_DUST}") = "TRUE" ]; then
  ln -nsf ${FIXsmoke}/${PREDEF_GRID_NAME}/dust12m_data.nc .
  ln -nsf ${FIXsmoke}/${PREDEF_GRID_NAME}/emi_data.nc .

  smokefile="${COMIN}/${SMOKE_DUST_FILE_PREFIX}_${PDY}${cyc}00.nc"
  if [ -f ${smokefile} ]; then
    ln -nsf ${smokefile} ${SMOKE_DUST_FILE_PREFIX}.nc
  else
    if [ "${EBB_DCYCLE}" = "1" ]; then
      ln -nsf ${FIXsmoke}/${PREDEF_GRID_NAME}/dummy_24hr_smoke_ebbdc1.nc ${SMOKE_DUST_FILE_PREFIX}.nc
      echo "WARNING: Smoke file is not available, use dummy_24hr_smoke_ebbdc1.nc instead"
    else
      ln -nsf ${FIXsmoke}/${PREDEF_GRID_NAME}/dummy_24hr_smoke.nc ${SMOKE_DUST_FILE_PREFIX}.nc
      echo "WARNING: Smoke file is not available, use dummy_24hr_smoke.nc instead"
    fi
  fi
fi
#
#-----------------------------------------------------------------------
#
# Create links in the current working directory to fixed (i.e. static) files
# in the FIXam directory.  These links have names that are set to the
# names of files that the forecast model expects to exist in the current
# working directory when the forecast model executable is called.
#
#-----------------------------------------------------------------------
#
cd ${DATA}

print_info_msg "$VERBOSE" "
Creating links in the current run directory (DATA) to fixed (i.e.
static) files in the FIXam directory:
  FIXam = \"${FIXam}\"
  DATA = \"${DATA}\""

regex_search="^[ ]*([^| ]+)[ ]*[|][ ]*([^| ]+)[ ]*$"
num_symlinks=${#CYCLEDIR_LINKS_TO_FIXam_FILES_MAPPING[@]}
for (( i=0; i<${num_symlinks}; i++ )); do

  mapping="${CYCLEDIR_LINKS_TO_FIXam_FILES_MAPPING[$i]}"
  symlink=$( printf "%s\n" "$mapping" | \
             $SED -n -r -e "s/${regex_search}/\1/p" )
  target=$( printf "%s\n" "$mapping" | \
            $SED -n -r -e "s/${regex_search}/\2/p" )

  symlink="${DATA}/$symlink"
  target="$FIXam/$target"
  ln -nsf $target $symlink

done
#
#-----------------------------------------------------------------------
#
# Create links in the current working directory to the MERRA2 aerosol 
# climatology data files and lookup table for optics properties.
#
#-----------------------------------------------------------------------
#
if [ $(boolify "${USE_MERRA_CLIMO}") = "TRUE" ]; then
  for f_nm_path in ${FIXclim}/*; do
    f_nm=$( basename "${f_nm_path}" )
    pre_f="${f_nm%%.*}"

    if [ "${pre_f}" = "merra2" ]; then
      mnth=$( printf "%s\n" "${f_nm}" | grep -o -P '(?<=2014.m).*(?=.nc)' )
      symlink="${DATA}/aeroclim.m${mnth}.nc"
    else
      symlink="${DATA}/${pre_f}.dat"
    fi
    target="${f_nm_path}"
    ln -nsf $target $symlink
  done
fi
#
#-----------------------------------------------------------------------
#
# Create links in the current working directory to cycle-independent (and
# ensemble-member-independent) model input files in the main experiment
# directory.
#
#-----------------------------------------------------------------------
#
print_info_msg "$VERBOSE" "
Creating links in the current run directory to cycle-independent model
input files in the main experiment directory..."

ln -nsf ${DATA_TABLE_FP} ${DATA}/${DATA_TABLE_FN}

ln -nsf ${FIELD_TABLE_FP} ${DATA}/${FIELD_TABLE_FN}

ln -nsf ${FIELD_DICT_FP} ${DATA}/${FIELD_DICT_FN}

if [ $(boolify ${WRITE_DOPOST}) = "TRUE" ]; then
  cp -p ${PARMdir}/upp/nam_micro_lookup.dat ./eta_micro_lookup.dat
  if [ $(boolify ${USE_CUSTOM_POST_CONFIG_FILE}) = "TRUE" ]; then
    post_config_fp="${CUSTOM_POST_CONFIG_FP}"
    print_info_msg "
====================================================================
  CUSTOM_POST_CONFIG_FP = \"${CUSTOM_POST_CONFIG_FP}\"
===================================================================="
  else
    if [ $(boolify "${CPL_AQM}") = "TRUE" ]; then
      post_config_fp="${PARMdir}/upp/postxconfig-NT-AQM.txt"
    else
      post_config_fp="${PARMdir}/upp/postxconfig-NT-fv3lam.txt"
    fi
    print_info_msg "
====================================================================
  post_config_fp = \"${post_config_fp}\"
===================================================================="
  fi
  cp -p ${post_config_fp} ./postxconfig-NT_FH00.txt
  cp -p ${post_config_fp} ./postxconfig-NT.txt
  cp -p ${PARMdir}/upp/params_grib2_tbl_new .
  # Set itag for inline-post:
  if [ $(boolify "${CPL_AQM}") = "TRUE" ]; then
    post_itag_add="aqf_on=.true.,"
  else
    post_itag_add=""
  fi
cat > itag <<EOF
&MODEL_INPUTS
 MODELNAME='FV3R'
/
&NAMPGB
 KPO=47,PO=1000.,975.,950.,925.,900.,875.,850.,825.,800.,775.,750.,725.,700.,675.,650.,625.,600.,575.,550.,525.,500.,475.,450.,425.,400.,375.,350.,325.,300.,275.,250.,225.,200.,175.,150.,125.,100.,70.,50.,30.,20.,10.,7.,5.,3.,2.,1.,${post_itag_add}
/
EOF
fi
#
#----------------------------------------------------------------------
#
# NOAHMP table copied from CCPP physics directory into $DATA directory.
# This is a temporary solution that will need to be changed once NOAHMP
# is included as a submodule in the weather model.
#
#----------------------------------------------------------------------
#
cp -p ${CCPP_PHYS_DIR}/noahmptable.tbl .
#
#-----------------------------------------------------------------------
#
# Choose namelist file to use
#
#-----------------------------------------------------------------------
#
STOCH="FALSE"
if ([ $(boolify "${DO_SPP}") = "TRUE" ] || \
    [ $(boolify "${DO_SPPT}") = "TRUE" ] || \
    [ $(boolify "${DO_SHUM}") = "TRUE" ] || \
    [ $(boolify "${DO_SKEB}") = "TRUE" ] || \
    [ $(boolify "${DO_LSM_SPP}") =  "TRUE" ]); then
     STOCH="TRUE"
fi
if [ "${STOCH}" = "TRUE" ]; then
  cp -p ${FV3_NML_STOCH_FP} ${DATA}/${FV3_NML_FN}
 else
  ln -nsf ${FV3_NML_FP} ${DATA}/${FV3_NML_FN}
fi
#
#-----------------------------------------------------------------------
#
# Set stochastic physics seeds
#
#-----------------------------------------------------------------------
#
if ([ "$STOCH" == "TRUE" ] && [ $(boolify "${DO_ENSEMBLE}") = "TRUE" ]); then
  ${USHsrw}/set_fv3nml_ens_stoch_seeds.py \
      --path-to-defns ${GLOBAL_VAR_DEFNS_FP} \
      --cdate "$CDATE" || print_err_msg_exit "\
Call to function to create the ensemble-based namelist for the current
cycle's (cdate) run directory (DATA) failed:
  cdate = \"${CDATE}\"
  DATA = \"${DATA}\""
fi
#
#-----------------------------------------------------------------------
#
# Replace parameter values for air quality modeling using AQM_NA_13km 
# in FV3 input.nml and model_configure.
#
#-----------------------------------------------------------------------
#
if [ $(boolify "${CPL_AQM}") = "TRUE" ] && [ "${PREDEF_GRID_NAME}" = "AQM_NA_13km" ]; then
  ${USHsrw}/update_input_nml.py \
    --namelist "${DATA}/${FV3_NML_FN}" \
    --aqm_na_13km || print_err_msg_exit "\
Call to function to update the FV3 input.nml file for air quality modeling
using AQM_NA_13km for the current cycle's (cdate) run directory (DATA) failed:
  cdate = \"${CDATE}\"
  DATA = \"${DATA}\""
fi
#
#-----------------------------------------------------------------------
#
# Replace parameter values for restart in FV3 input.nml and model_configure.
# Add restart files to INPUT directory.
#
#-----------------------------------------------------------------------
#
flag_fcst_restart="FALSE"
if [ $(boolify "${DO_FCST_RESTART}") = "TRUE" ] && [ "$(ls -A ${DATA}/RESTART )" ]; then
  cp -p input.nml input.nml_orig
  cp -p model_configure model_configure_orig
  if [ $(boolify "${CPL_AQM}") = "TRUE" ]; then
    cp -p aqm.rc aqm.rc_orig
  fi
  flag_fcst_restart="TRUE"

  # Update FV3 input.nml for restart
  ${USHsrw}/update_input_nml.py \
    --namelist "${DATA}/${FV3_NML_FN}" \
    --restart
  export err=$?
  if [ $err -ne 0 ]; then
    message_txt="Call to function to update the FV3 input.nml file for restart 
for the current cycle's (cdate) run directory (DATA) failed:
  cdate = \"${CDATE}\"
  DATA = \"${DATA}\""
    err_exit "${message_txt}"
    print_err_msg_exit "${message_txt}"
  fi

  # Check that restart files exist at restart_interval
  file_ids=( "coupler.res" "fv_core.res.nc" "fv_core.res.tile1.nc" "fv_srf_wnd.res.tile1.nc" "fv_tracer.res.tile1.nc" "phy_data.nc" "sfc_data.nc" )
  num_file_ids=${#file_ids[*]}
  IFS=' '
  read -a restart_hrs <<< "${RESTART_INTERVAL}"
  num_restart_hrs=${#restart_hrs[*]}
  
  for (( ih_rst=${num_restart_hrs}-1; ih_rst>=0; ih_rst-- )); do
    cdate_restart_hr=$( $DATE_UTIL --utc --date "${PDY} ${cyc} UTC + ${restart_hrs[ih_rst]} hours" "+%Y%m%d%H" )
    rst_yyyymmdd="${cdate_restart_hr:0:8}"
    rst_hh="${cdate_restart_hr:8:2}"

    num_rst_files=0
    for file_id in "${file_ids[@]}"; do
      if [ -e "${DATA}/RESTART/${rst_yyyymmdd}.${rst_hh}0000.${file_id}" ]; then
        (( num_rst_files=num_rst_files+1 ))
      fi
    done
    if [ "${num_rst_files}" = "${num_file_ids}" ]; then
      FHROT="${restart_hrs[ih_rst]}"
      break
    fi
  done

  # Create soft-link of restart files in INPUT directory
  cd ${DATA}/INPUT
  for file_id in "${file_ids[@]}"; do
    rm "${file_id}"
    target="${DATA}/RESTART/${rst_yyyymmdd}.${rst_hh}0000.${file_id}"
    symlink="${file_id}"
    ln -nsf $target $symlink
  done
  cd ${DATA}   
fi
#
#-----------------------------------------------------------------------
#
# Setup air quality model cold/warm start
#
#-----------------------------------------------------------------------
#
if [ $(boolify "${CPL_AQM}") = "TRUE" ]; then
    if [ $(boolify "${COLDSTART}") = "TRUE" ] && \
       [ "${PDY}${cyc}" = "${DATE_FIRST_CYCL:0:10}" ] && \
       [ $(boolify "${flag_fcst_restart}") = "FALSE" ]; then
    init_concentrations="true"
  else
    init_concentrations="false"
  fi
#
#-----------------------------------------------------------------------
#
# Call the function that creates the aqm.rc file within each
# cycle directory.
#
#-----------------------------------------------------------------------
#
  ${USHsrw}/create_aqm_rc_file.py \
    --path-to-defns ${GLOBAL_VAR_DEFNS_FP} \
    --cdate "$CDATE" \
    --run-dir "${DATA}" \
    --init_concentrations "${init_concentrations}"
  export err=$?
  if [ $err -ne 0 ]; then
    message_txt="Call to function to create an aqm.rc file for the current
cycle's (cdate) run directory (DATA) failed:
  cdate = \"${CDATE}\"
  DATA = \"${DATA}\""
    err_exit "${message_txt}"
    print_err_msg_exit "${message_txt}"
  fi
fi
#
#-----------------------------------------------------------------------
#
# Call the function that creates the model configuration file within each
# cycle directory.
#
#-----------------------------------------------------------------------
#
${USHsrw}/create_model_configure_file.py \
  --path-to-defns ${GLOBAL_VAR_DEFNS_FP} \
  --cdate "$CDATE" \
  --fcst_len_hrs "${FCST_LEN_HRS}" \
  --fhrot "${FHROT}" \
  --run-dir "${DATA}" \
  --sub-hourly-post "${SUB_HOURLY_POST}" \
  --dt-subhourly-post-mnts "${DT_SUBHOURLY_POST_MNTS}" \
  --dt-atmos "${DT_ATMOS}"
export err=$?
if [ $err -ne 0 ]; then
  message_txt="Call to function to create a model configuration file 
for the current cycle's (cdate) run directory (DATA) failed:
  cdate = \"${CDATE}\"
  DATA = \"${DATA}\""
  err_exit "${message_txt}"
  print_err_msg_exit "${message_txt}"
fi
#
#-----------------------------------------------------------------------
#
# Call the function that creates the diag_table file within each cycle 
# directory.
#
#-----------------------------------------------------------------------
#
${USHsrw}/create_diag_table_file.py \
  --path-to-defns ${GLOBAL_VAR_DEFNS_FP} \
  --run-dir "${DATA}"
export err=$?
if [ $err -ne 0 ]; then
  message_txt="Call to function to create a diag table file for the current 
cycle's (cdate) run directory (DATA) failed:
  DATA = \"${DATA}\""
  err_exit "${message_txt}"
  print_err_msg_exit "${message_txt}"
fi
#
#-----------------------------------------------------------------------
#
# Pre-generate symlink to forecast RESTART in DATA for early start of 
# the next cycle in SRW-AQM
#
#-----------------------------------------------------------------------
#
if [ $(boolify "${CPL_AQM}") = "TRUE" ] || [ $(boolify "${DO_SMOKE_DUST}") = "TRUE" ]; then
  ln -nsf "${DATA}/RESTART" "${DATA_SHARE}/RESTART"
fi
#
#-----------------------------------------------------------------------
#
# Call the function that creates the NEMS configuration file within each
# cycle directory.
#
#-----------------------------------------------------------------------
#
${USHsrw}/create_ufs_configure_file.py \
  --path-to-defns ${GLOBAL_VAR_DEFNS_FP} \
  --run-dir "${DATA}"
export err=$?
if [ $err -ne 0 ]; then
  message_txt="Call to function to create a NEMS configuration file for 
the current cycle's (cdate) run directory (DATA) failed:
  DATA = \"${DATA}\""
  err_exit "${message_txt}"
  print_err_msg_exit "${message_txt}"
fi
#
#-----------------------------------------------------------------------
#
# Run the FV3-LAM model. 
#
#-----------------------------------------------------------------------
#
export pgm="${FV3_EXEC_FN}"

. prep_step
eval ${RUN_CMD_FCST} ${EXECsrw}/$pgm >>$pgmout 2>errfile
export err=$?; err_chk
#
#-----------------------------------------------------------------------
#
# Copy RESTART directory to COMOUT.
# Move dyn and phy files to COMOUT. 
# Copy AQM output product file to COMOUT only for AQM.
#
#-----------------------------------------------------------------------
#
if [ $(boolify "${CPL_AQM}") = "TRUE" ] || [ $(boolify "${DO_SMOKE_DUST}") = "TRUE" ]; then
  cp -rp RESTART ${COMOUT}

  fhr=0
  while [ $fhr -le ${FCST_LEN_HRS} ]; do
    fhr_ct=$(printf "%03d" $fhr)
    source_dyn="${DATA}/dynf${fhr_ct}.nc"
    source_phy="${DATA}/phyf${fhr_ct}.nc"
    target_dyn="${COMIN}/${NET}.${cycle}${dot_ensmem}.dyn.f${fhr_ct}.${POST_OUTPUT_DOMAIN_NAME}.nc"
    target_phy="${COMIN}/${NET}.${cycle}${dot_ensmem}.phy.f${fhr_ct}.${POST_OUTPUT_DOMAIN_NAME}.nc"
    [ -f ${source_dyn} ] && mv ${source_dyn} ${target_dyn}
    [ -f ${source_phy} ] && mv ${source_phy} ${target_phy}
    (( fhr=fhr+1 ))
  done

  if [ $(boolify "${CPL_AQM}") = "TRUE" ]; then
    cp -p ${DATA}/${AQM_RC_PRODUCT_FN} ${COMOUT}/${NET}.${cycle}${dot_ensmem}.${AQM_RC_PRODUCT_FN}
  fi
fi
#
#-----------------------------------------------------------------------
#
# If doing inline post, create the directory in which the post-processing 
# output will be stored (postprd_dir).
#
#-----------------------------------------------------------------------
#
if [ $(boolify ${WRITE_DOPOST}) = "TRUE" ]; then

  yyyymmdd=${PDY}
  hh=${cyc}
  fmn="00"

  if [ "${RUN_ENVIR}" != "nco" ]; then
    export COMOUT="${DATA}/postprd"
  fi
  mkdir -p "${COMOUT}"

  cd ${COMOUT}

  for fhr in $(seq -f "%03g" 0 ${FCST_LEN_HRS}); do

    if [ ${fhr:0:1} = "0" ]; then
      fhr_d=${fhr:1:2}
    else
      fhr_d=${fhr}
    fi

    post_time=$( $DATE_UTIL --utc --date "${yyyymmdd} ${hh} UTC + ${fhr_d} hours + ${fmn} minutes" "+%Y%m%d%H%M" )
    post_mn=${post_time:10:2}
    post_mn_or_null=""
    post_fn_suffix="GrbF${fhr_d}"
    post_renamed_fn_suffix="f${fhr}${post_mn_or_null}.${POST_OUTPUT_DOMAIN_NAME}.grib2"

    if [ $(boolify "${CPL_AQM}") = "TRUE" ]; then
      fids=( "cmaq" )
    else
      fids=( "prslev" "natlev" )
    fi

    for fid in "${fids[@]}"; do
      FID=$(echo_uppercase $fid)
      post_orig_fn="${FID}.${post_fn_suffix}"
      post_renamed_fn="${NET}.${cycle}${dot_ensmem}.${fid}.${post_renamed_fn_suffix}"
 
      mv ${DATA}/${post_orig_fn} ${post_renamed_fn}
      if [ $RUN_ENVIR != "nco" ]; then
        basetime=$( $DATE_UTIL --date "$yyyymmdd $hh" +%y%j%H%M )
        symlink_suffix="_${basetime}f${fhr}${post_mn}"
        ln -nsf ${post_renamed_fn} ${FID}${symlink_suffix}
      fi
      # DBN alert
      if [ "$SENDDBN" = "YES" ]; then
        $DBNROOT/bin/dbn_alert MODEL rrfs_post ${job} ${COMOUT}/${post_renamed_fn}
      fi
    done

    if [ $(boolify "${CPL_AQM}") = "TRUE" ]; then
      mv ${DATA}/dynf${fhr}.nc ${COMIN}/${NET}.${cycle}${dot_ensmem}.dyn.f${fhr}.${POST_OUTPUT_DOMAIN_NAME}.nc
      mv ${DATA}/phyf${fhr}.nc ${COMIN}/${NET}.${cycle}${dot_ensmem}.phy.f${fhr}.${POST_OUTPUT_DOMAIN_NAME}.nc
    fi
  done

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
FV3 forecast completed successfully!!!

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

