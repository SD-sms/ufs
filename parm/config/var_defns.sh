# [metadata]
description='config for Online-CMAQ, AQM_NA_13km, real-time, NCO mode on WCOSS2'
version='1.0'

# [user]
RUN_ENVIR='nco'
MACHINE='WCOSS2'
ACCOUNT='AQM-DEV'
export HOMEaqm='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0'
export USHdir='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/ush'
export SCRIPTSdir='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/scripts'
export JOBSdir='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/jobs'
export SORCdir='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/sorc'
export PARMdir='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm'
export FIXdir='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/fix'
export FIXaqm='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/fix'
export MODULESdir='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/modulefiles'
export EXECdir='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/exec'
VX_CONFIG_DIR='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm'
METPLUS_CONF='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/metplus'
MET_CONFIG='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/met'
UFS_WTHR_MDL_DIR='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/sorc/ufs-weather-model'
ARL_NEXUS_DIR='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/sorc/arl_nexus'

# [platform]
WORKFLOW_MANAGER='ecflow'
NCORES_PER_NODE='128'
TASKTHROTTLE='1000'
BUILD_MOD_FN='build_wcoss2_intel'
WFLOW_MOD_FN='wflow_wcoss2'
BUILD_VER_FN='build.ver.wcoss2'
RUN_VER_FN='run.ver.wcoss2'
SCHED='pbspro'
PARTITION_DEFAULT=''
QUEUE_DEFAULT='dev'
PARTITION_HPSS=''
QUEUE_HPSS='dev_transfer'
PARTITION_FCST=''
QUEUE_FCST='dev'
RUN_CMD_SERIAL='time'
RUN_CMD_UTILS='mpiexec -n ${nprocs}'
RUN_CMD_FCST='mpiexec -n ${PE_MEMBER01} -ppn ${PPN_RUN_FCST} --cpu-bind core -depth ${OMP_NUM_THREADS_RUN_FCST}'
RUN_CMD_POST='mpiexec -n ${nprocs}'
RUN_CMD_PRDGEN='mpiexec -n ${nprocs} --cpu-bind core cfp'
RUN_CMD_AQM='mpiexec -n ${nprocs} -ppn ${ppn_run_aqm} --cpu-bind core -depth ${omp_num_threads_run_aqm}'
RUN_CMD_AQMLBC='mpiexec -n ${NUMTS}'
SCHED_NATIVE_CMD='-l place=excl'
MET_INSTALL_DIR='/apps/ops/para/libs/intel/19.1.3.304/met/10.1.1'
MET_BIN_EXEC='bin'
METPLUS_PATH='/apps/ops/para/libs/intel/19.1.3.304/metplus/4.1.1'
CCPA_OBS_DIR=''
MRMS_OBS_DIR=''
NDAS_OBS_DIR=''
FIXaqm_sav='/lfs/h2/emc/physics/noscrub/UFS_SRW_App/aqm.v7/fix'
DOMAIN_PREGEN_BASEDIR='${FIXaqm}/ufs/FV3LAM_pregen'
PRE_TASK_CMDS='{ ulimit -s unlimited; ulimit -a; }'
TEST_EXTRN_MDL_SOURCE_BASEDIR=''
TEST_PREGEN_BASEDIR=''
TEST_ALT_EXTRN_MDL_SYSBASEDIR_ICS=''
TEST_ALT_EXTRN_MDL_SYSBASEDIR_LBCS=''
TEST_VX_FCST_INPUT_BASEDIR=''
FIXgsm='/lfs/h2/emc/physics/noscrub/UFS_SRW_App/aqm.v7/fix/fix_am'
FIXaer='/lfs/h2/emc/physics/noscrub/UFS_SRW_App/aqm.v7/fix/fix_aer'
FIXlut='/lfs/h2/emc/physics/noscrub/UFS_SRW_App/aqm.v7/fix/fix_lut'
FIXorg='/lfs/h2/emc/physics/noscrub/UFS_SRW_App/aqm.v7/fix/fix_orog'
FIXsfc='/lfs/h2/emc/physics/noscrub/UFS_SRW_App/aqm.v7/fix/fix_sfc_climo'
FIXshp='/lfs/h2/emc/physics/noscrub/UFS_SRW_App/aqm.v7/fix/ufs/NaturalEarth'
EXTRN_MDL_DATA_STORES='hpss aws nomads'

# [workflow]
WORKFLOW_ID='id_1697644234'
RELATIVE_LINK_FLAG='--relative'
USE_CRON_TO_RELAUNCH='TRUE'
#### CRON_RELAUNCH_INTVL_MNTS='3'
#### CRONTAB_LINE='*/3 * * * * cd /lfs/h2/emc/ptmp/lin.gan/ecflow_aqm/para/output/prod/today && ./launch_FV3LAM_wflow.sh called_from_cron="TRUE" >> ./log.launch_FV3LAM_wflow 2>&1'
LOAD_MODULES_RUN_TASK_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/ush/load_modules_run_task.sh'
EXPT_BASEDIR='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/config'
#### EXPT_SUBDIR='aqm_nco_aqmna13km'
EXEC_SUBDIR='exec'
EXPTDIR='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/config'
DOT_OR_USCORE='_'
EXPT_CONFIG_FN='config.yaml'
CONSTANTS_FN='constants.yaml'
RGNL_GRID_NML_FN='regional_grid.nml'
FV3_NML_BASE_SUITE_FN='input.nml.FV3'
FV3_NML_YAML_CONFIG_FN='FV3.input.yml'
FV3_NML_BASE_ENS_FN='input.nml.base_ens'
FV3_NML_FN='input.nml'
FV3_EXEC_FN='ufs_model'
DATA_TABLE_FN='data_table'
DIAG_TABLE_FN='diag_table'
FIELD_TABLE_FN='field_table'
DIAG_TABLE_TMPL_FN='diag_table_aqm.FV3_GFS_v16'
FIELD_TABLE_TMPL_FN='field_table_aqm.FV3_GFS_v16'
MODEL_CONFIG_FN='model_configure'
NEMS_CONFIG_FN='nems.configure'
AQM_RC_FN='aqm.rc'
AQM_RC_TMPL_FN='aqm.rc'
FV3_NML_BASE_SUITE_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/input.nml.FV3'
FV3_NML_YAML_CONFIG_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/FV3.input.yml'
FV3_NML_BASE_ENS_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/config/input.nml.base_ens'
DATA_TABLE_TMPL_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/data_table'
DIAG_TABLE_TMPL_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/diag_table_aqm.FV3_GFS_v16'
FIELD_TABLE_TMPL_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/field_table_aqm.FV3_GFS_v16'
MODEL_CONFIG_TMPL_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/model_configure'
NEMS_CONFIG_TMPL_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/nems.configure'
AQM_RC_TMPL_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/aqm.rc'
DATA_TABLE_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/config/data_table'
FIELD_TABLE_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/config/field_table'
NEMS_CONFIG_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/config/nems.configure'
FV3_NML_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/config/input.nml'
FCST_MODEL='ufs-weather-model'
WFLOW_XML_FN='FV3LAM_wflow.xml'
GLOBAL_VAR_DEFNS_FN='var_defns.sh'
EXTRN_MDL_VAR_DEFNS_FN='extrn_mdl_var_defns'
WFLOW_LAUNCH_SCRIPT_FN='launch_FV3LAM_wflow.sh'
WFLOW_LAUNCH_LOG_FN='log.launch_FV3LAM_wflow'
export GLOBAL_VAR_DEFNS_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/config/var_defns.sh'
WFLOW_LAUNCH_SCRIPT_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/ush/launch_FV3LAM_wflow.sh'
WFLOW_LAUNCH_LOG_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/config/log.launch_FV3LAM_wflow'
FIXdir='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/fix'
FIXam='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/fix/fix_am'
FIXclim='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/fix/fix_clim'
FIXlam='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/fix/fix_lam'
THOMPSON_MP_CLIMO_FN='Thompson_MP_MONTHLY_CLIMO.nc'
THOMPSON_MP_CLIMO_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/fix/fix_am/Thompson_MP_MONTHLY_CLIMO.nc'
CCPP_PHYS_SUITE='FV3_GFS_v16'
CCPP_PHYS_SUITE_FN='suite_FV3_GFS_v16.xml'
CCPP_PHYS_SUITE_IN_CCPP_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/sorc/ufs-weather-model/FV3/ccpp/suites/suite_FV3_GFS_v16.xml'
CCPP_PHYS_SUITE_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/config/suite_FV3_GFS_v16.xml'
FIELD_DICT_FN='fd_nems.yaml'
FIELD_DICT_IN_UWM_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/sorc/ufs-weather-model/tests/parm/fd_nems.yaml'
FIELD_DICT_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/config/fd_nems.yaml'
GRID_GEN_METHOD='ESGgrid'
PREDEF_GRID_NAME='AQM_NA_13km'
DATE_FIRST_CYCL='202310180000'
DATE_LAST_CYCL='209910181800'
INCR_CYCL_FREQ='6'
FCST_LEN_HRS='-1'
FCST_LEN_CYCL=( "6" "72" "72" "6" )
PREEXISTING_DIR_METHOD='rename'
VERBOSE='TRUE'
DEBUG='TRUE'
COMPILER='intel'
SYMLINK_FIX_FILES='FALSE'
DO_REAL_TIME='TRUE'
COLDSTART='FALSE'
WARMSTART_CYCLE_DIR='/lfs/h2/emc/ptmp/lin.gan/ecflow_aqm/para/com/aqm/v7.0/aqm.20231017/18'
RES_IN_FIXLAM_FILENAMES='793'
CRES='C793'
SDF_USES_RUC_LSM='FALSE'
SDF_USES_THOMPSON_MP='FALSE'

# [nco]
envir_dfv='prod'
NET_dfv='aqm'
RUN_dfv='aqm'
model_ver_dfv='v7.0'
OPSROOT_dfv='/lfs/h2/emc/ptmp/lin.gan/ecflow_aqm/para'
COMROOT_dfv='/lfs/h2/emc/ptmp/lin.gan/ecflow_aqm/para/com'
COMIN_BASEDIR='/lfs/h2/emc/ptmp/lin.gan/ecflow_aqm/para/com/aqm/v7.0'
COMOUT_BASEDIR='/lfs/h2/emc/ptmp/lin.gan/ecflow_aqm/para/com/aqm/v7.0'
DATAROOT_dfv='/lfs/h2/emc/ptmp/lin.gan/ecflow_aqm/para/tmp'
DCOMROOT_dfv='/lfs/h2/emc/ptmp/lin.gan/ecflow_aqm/para/dcom'
LOGBASEDIR_dfv='/lfs/h2/emc/ptmp/lin.gan/ecflow_aqm/para/output'
DBNROOT_dfv=''
SENDECF_dfv='FALSE'
SENDDBN_dfv='FALSE'
SENDDBN_NTC_dfv='FALSE'
SENDCOM_dfv='FALSE'
SENDWEB_dfv='FALSE'
KEEPDATA_dfv='FALSE'
MAILTO_dfv=''
MAILCC_dfv=''

# [workflow_switches]
RUN_TASK_MAKE_GRID='FALSE'
RUN_TASK_MAKE_OROG='FALSE'
RUN_TASK_MAKE_SFC_CLIMO='FALSE'
RUN_TASK_GET_EXTRN_ICS='TRUE'
RUN_TASK_GET_EXTRN_LBCS='TRUE'
RUN_TASK_MAKE_ICS='TRUE'
RUN_TASK_MAKE_LBCS='TRUE'
RUN_TASK_RUN_FCST='TRUE'
RUN_TASK_RUN_POST='TRUE'
RUN_TASK_RUN_PRDGEN='FALSE'
RUN_TASK_GET_OBS_CCPA='FALSE'
RUN_TASK_GET_OBS_MRMS='FALSE'
RUN_TASK_GET_OBS_NDAS='FALSE'
RUN_TASK_VX_GRIDSTAT='FALSE'
RUN_TASK_VX_POINTSTAT='FALSE'
RUN_TASK_VX_ENSGRID='FALSE'
RUN_TASK_VX_ENSPOINT='FALSE'
RUN_TASK_PLOT_ALLVARS='FALSE'
RUN_TASK_AQM_ICS='TRUE'
RUN_TASK_AQM_LBCS='TRUE'
RUN_TASK_NEXUS_GFS_SFC='TRUE'
RUN_TASK_NEXUS_EMISSION='TRUE'
RUN_TASK_FIRE_EMISSION='TRUE'
RUN_TASK_POINT_SOURCE='TRUE'
RUN_TASK_PRE_POST_STAT='TRUE'
RUN_TASK_POST_STAT_O3='TRUE'
RUN_TASK_POST_STAT_PM25='TRUE'
RUN_TASK_BIAS_CORRECTION_O3='TRUE'
RUN_TASK_BIAS_CORRECTION_PM25='TRUE'

# [task_make_grid]
TN_MAKE_GRID='make_grid'
NNODES_MAKE_GRID='1'
PPN_MAKE_GRID='24'
WTIME_MAKE_GRID='00:20:00'
MAXTRIES_MAKE_GRID='2'
GRID_DIR='/lfs/h2/emc/physics/noscrub/UFS_SRW_App/aqm.v7/fix/aqm/DOMAIN_DATA/AQM_NA_13km'
ESGgrid_LON_CTR='-118.0'
ESGgrid_LAT_CTR='50.0'
ESGgrid_DELX='13000.0'
ESGgrid_DELY='13000.0'
ESGgrid_NX='800'
ESGgrid_NY='544'
ESGgrid_WIDE_HALO_WIDTH='6'
ESGgrid_PAZI='0.0'
GFDLgrid_LON_T6_CTR=''
GFDLgrid_LAT_T6_CTR=''
GFDLgrid_NUM_CELLS=''
GFDLgrid_STRETCH_FAC=''
GFDLgrid_REFINE_RATIO=''
GFDLgrid_ISTART_OF_RGNL_DOM_ON_T6G=''
GFDLgrid_IEND_OF_RGNL_DOM_ON_T6G=''
GFDLgrid_JSTART_OF_RGNL_DOM_ON_T6G=''
GFDLgrid_JEND_OF_RGNL_DOM_ON_T6G=''
GFDLgrid_USE_NUM_CELLS_IN_FILENAMES=''

# [task_make_orog]
TN_MAKE_OROG='make_orog'
NNODES_MAKE_OROG='1'
PPN_MAKE_OROG='24'
WTIME_MAKE_OROG='00:20:00'
MAXTRIES_MAKE_OROG='2'
KMP_AFFINITY_MAKE_OROG='disabled'
OMP_NUM_THREADS_MAKE_OROG='6'
OMP_STACKSIZE_MAKE_OROG='2048m'
OROG_DIR='/lfs/h2/emc/physics/noscrub/UFS_SRW_App/aqm.v7/fix/aqm/DOMAIN_DATA/AQM_NA_13km'

# [task_make_sfc_climo]
TN_MAKE_SFC_CLIMO='make_sfc_climo'
NNODES_MAKE_SFC_CLIMO='2'
PPN_MAKE_SFC_CLIMO='24'
WTIME_MAKE_SFC_CLIMO='00:20:00'
MAXTRIES_MAKE_SFC_CLIMO='2'
KMP_AFFINITY_MAKE_SFC_CLIMO='scatter'
OMP_NUM_THREADS_MAKE_SFC_CLIMO='1'
OMP_STACKSIZE_MAKE_SFC_CLIMO='1024m'
SFC_CLIMO_DIR='/lfs/h2/emc/physics/noscrub/UFS_SRW_App/aqm.v7/fix/aqm/DOMAIN_DATA/AQM_NA_13km'

# [task_get_extrn_ics]
TN_GET_EXTRN_ICS='get_extrn_ics'
NNODES_GET_EXTRN_ICS='1'
PPN_GET_EXTRN_ICS='1'
MEM_GET_EXTRN_ICS='2G'
WTIME_GET_EXTRN_ICS='00:45:00'
MAXTRIES_GET_EXTRN_ICS='1'
EXTRN_MDL_NAME_ICS='FV3GFS'
EXTRN_MDL_ICS_OFFSET_HRS='6'
FV3GFS_FILE_FMT_ICS='netcdf'
EXTRN_MDL_SYSBASEDIR_ICS='compath.py ${envir}/gfs/${gfs_ver}/gfs.${PDYext}/${cycext}/atmos'
USE_USER_STAGED_EXTRN_FILES='FALSE'
EXTRN_MDL_SOURCE_BASEDIR_ICS=''
EXTRN_MDL_FILES_ICS=''

# [task_get_extrn_lbcs]
TN_GET_EXTRN_LBCS='get_extrn_lbcs'
NNODES_GET_EXTRN_LBCS='1'
PPN_GET_EXTRN_LBCS='1'
MEM_GET_EXTRN_LBCS='2G'
WTIME_GET_EXTRN_LBCS='02:00:00'
MAXTRIES_GET_EXTRN_LBCS='1'
EXTRN_MDL_NAME_LBCS='FV3GFS'
LBC_SPEC_INTVL_HRS='6'
EXTRN_MDL_LBCS_OFFSET_HRS='6'
FV3GFS_FILE_FMT_LBCS='netcdf'
EXTRN_MDL_SYSBASEDIR_LBCS='compath.py ${envir}/gfs/${gfs_ver}/gfs.${PDYext}/${cycext}/atmos'
USE_USER_STAGED_EXTRN_FILES='FALSE'
EXTRN_MDL_SOURCE_BASEDIR_LBCS=''
EXTRN_MDL_FILES_LBCS=''

# [task_make_ics]
TN_MAKE_ICS='make_ics'
NNODES_MAKE_ICS='4'
PPN_MAKE_ICS='12'
WTIME_MAKE_ICS='00:30:00'
MAXTRIES_MAKE_ICS='1'
KMP_AFFINITY_MAKE_ICS='scatter'
OMP_NUM_THREADS_MAKE_ICS='1'
OMP_STACKSIZE_MAKE_ICS='1024m'
USE_FVCOM='FALSE'
FVCOM_WCSTART='cold'
FVCOM_DIR=''
FVCOM_FILE='fvcom.nc'

# [task_make_lbcs]
TN_MAKE_LBCS='make_lbcs'
NNODES_MAKE_LBCS='1'
PPN_MAKE_LBCS='128'
WTIME_MAKE_LBCS='00:30:00'
MAXTRIES_MAKE_LBCS='1'
KMP_AFFINITY_MAKE_LBCS='scatter'
OMP_NUM_THREADS_MAKE_LBCS='1'
OMP_STACKSIZE_MAKE_LBCS='1024m'

# [task_run_fcst]
TN_RUN_FCST='run_fcst'
NNODES_RUN_FCST='14'
PPN_RUN_FCST='128'
WTIME_RUN_FCST='04:00:00'
MAXTRIES_RUN_FCST='1'
FV3_EXEC_FP='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/exec/ufs_model'
KMP_AFFINITY_RUN_FCST='scatter'
OMP_NUM_THREADS_RUN_FCST='1'
OMP_STACKSIZE_RUN_FCST='512m'
DT_ATMOS='180'
FHROT='0'
RESTART_INTERVAL='6 24 42 60'
WRITE_DOPOST='FALSE'
LAYOUT_X='50'
LAYOUT_Y='34'
BLOCKSIZE='16'
QUILTING='TRUE'
PRINT_ESMF='FALSE'
PE_MEMBER01='1792'
WRTCMP_write_groups='2'
WRTCMP_write_tasks_per_group='46'
WRTCMP_output_grid='rotated_latlon'
WRTCMP_cen_lon='-118.0'
WRTCMP_cen_lat='50.0'
WRTCMP_lon_lwr_left='-45.25'
WRTCMP_lat_lwr_left='-28.5'
WRTCMP_lon_upr_rght='45.25'
WRTCMP_lat_upr_rght='28.5'
WRTCMP_dlon='0.116908139'
WRTCMP_dlat='0.116908139'
WRTCMP_stdlat1=''
WRTCMP_stdlat2=''
WRTCMP_nx=''
WRTCMP_ny=''
WRTCMP_dx=''
WRTCMP_dy=''
USE_MERRA_CLIMO='FALSE'
DO_FCST_RESTART='TRUE'

# [task_run_post]
TN_RUN_POST='run_post'
NNODES_RUN_POST='2'
PPN_RUN_POST='24'
WTIME_RUN_POST='00:15:00'
MAXTRIES_RUN_POST='2'
KMP_AFFINITY_RUN_POST='scatter'
OMP_NUM_THREADS_RUN_POST='1'
OMP_STACKSIZE_RUN_POST='1024m'
SUB_HOURLY_POST='FALSE'
DT_SUBHOURLY_POST_MNTS='0'
USE_CUSTOM_POST_CONFIG_FILE='FALSE'
CUSTOM_POST_CONFIG_FP=''
POST_OUTPUT_DOMAIN_NAME='793'
TESTBED_FIELDS_FN=''

# [task_run_prdgen]
TN_RUN_PRDGEN='run_prdgen'
NNODES_RUN_PRDGEN='1'
PPN_RUN_PRDGEN='22'
WTIME_RUN_PRDGEN='00:30:00'
MAXTRIES_RUN_PRDGEN='1'
KMP_AFFINITY_RUN_PRDGEN='scatter'
OMP_NUM_THREADS_RUN_PRDGEN='1'
OMP_STACKSIZE_RUN_PRDGEN='1024m'
DO_PARALLEL_PRDGEN='FALSE'
ADDNL_OUTPUT_GRIDS=( "" )

# [task_plot_allvars]
TN_PLOT_ALLVARS='plot_allvars'
NNODES_PLOT_ALLVARS='1'
PPN_PLOT_ALLVARS='24'
WTIME_PLOT_ALLVARS='01:00:00'
MAXTRIES_PLOT_ALLVARS='1'
COMOUT_REF=''
PLOT_FCST_START='0'
PLOT_FCST_INC='3'
PLOT_FCST_END=''
PLOT_DOMAINS=( "conus" )

# [task_get_obs_ccpa]
TN_GET_OBS_CCPA='get_obs_ccpa'
NNODES_GET_OBS_CCPA='1'
PPN_GET_OBS_CCPA='1'
MEM_GET_OBS_CCPA='2G'
WTIME_GET_OBS_CCPA='00:45:00'
MAXTRIES_GET_OBS_CCPA='1'

# [task_get_obs_mrms]
TN_GET_OBS_MRMS='get_obs_mrms'
NNODES_GET_OBS_MRMS='1'
PPN_GET_OBS_MRMS='1'
MEM_GET_OBS_MRMS='2G'
WTIME_GET_OBS_MRMS='00:45:00'
MAXTRIES_GET_OBS_MRMS='1'

# [task_get_obs_ndas]
TN_GET_OBS_NDAS='get_obs_ndas'
NNODES_GET_OBS_NDAS='1'
PPN_GET_OBS_NDAS='1'
MEM_GET_OBS_NDAS='2G'
WTIME_GET_OBS_NDAS='02:00:00'
MAXTRIES_GET_OBS_NDAS='1'

# [task_tn_run_met_pb2nc_obs]
TN_RUN_MET_PB2NC_OBS='run_MET_Pb2nc_obs'
NNODES_RUN_MET_PB2NC_OBS='1'
PPN_RUN_MET_PB2NC_OBS='1'
MEM_RUN_MET_PB2NC_OBS='2G'
WTIME_RUN_MET_PB2NC_OBS='00:30:00'
MAXTRIES_RUN_MET_PB2NC_OBS='2'

# [task_tn_run_met_pcpcombine]
TN_RUN_MET_PCPCOMBINE='run_MET_PcpCombine'
NNODES_RUN_MET_PCPCOMBINE_OBS='1'
PPN_RUN_MET_PCPCOMBINE_OBS='1'
MEM_RUN_MET_PCPCOMBINE_OBS='2G'
WTIME_RUN_MET_PCPCOMBINE_OBS='00:30:00'
MAXTRIES_RUN_MET_PCPCOMBINE_OBS='2'
NNODES_RUN_MET_PCPCOMBINE_FCST='1'
PPN_RUN_MET_PCPCOMBINE_FCST='1'
MEM_RUN_MET_PCPCOMBINE_FCST='2G'
WTIME_RUN_MET_PCPCOMBINE_FCST='00:30:00'
MAXTRIES_RUN_MET_PCPCOMBINE_FCST='2'

# [task_run_met_gridstat_vx_apcp01h]
TN_RUN_MET_GRIDSTAT_VX_APCP01H='run_MET_GridStat_vx_APCP01h'
NNODES_RUN_MET_GRIDSTAT_VX_APCP01H='1'
PPN_RUN_MET_GRIDSTAT_VX_APCP01H='1'
MEM_RUN_MET_GRIDSTAT_VX_APCP01H='2G'
WTIME_RUN_MET_GRIDSTAT_VX_APCP01H='02:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_APCP01H='2'

# [task_run_met_gridstat_vx_apcp03h]
TN_RUN_MET_GRIDSTAT_VX_APCP03H='run_MET_GridStat_vx_APCP03h'
NNODES_RUN_MET_GRIDSTAT_VX_APCP03H='1'
PPN_RUN_MET_GRIDSTAT_VX_APCP03H='1'
MEM_RUN_MET_GRIDSTAT_VX_APCP03H='2G'
WTIME_RUN_MET_GRIDSTAT_VX_APCP03H='02:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_APCP03H='2'

# [task_run_met_gridstat_vx_apcp06h]
TN_RUN_MET_GRIDSTAT_VX_APCP06H='run_MET_GridStat_vx_APCP06h'
NNODES_RUN_MET_GRIDSTAT_VX_APCP06H='1'
PPN_RUN_MET_GRIDSTAT_VX_APCP06H='1'
MEM_RUN_MET_GRIDSTAT_VX_APCP06H='2G'
WTIME_RUN_MET_GRIDSTAT_VX_APCP06H='02:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_APCP06H='2'

# [task_run_met_gridstat_vx_apcp24h]
TN_RUN_MET_GRIDSTAT_VX_APCP24H='run_MET_GridStat_vx_APCP24h'
NNODES_RUN_MET_GRIDSTAT_VX_APCP24H='1'
PPN_RUN_MET_GRIDSTAT_VX_APCP24H='1'
MEM_RUN_MET_GRIDSTAT_VX_APCP24H='2G'
WTIME_RUN_MET_GRIDSTAT_VX_APCP24H='02:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_APCP24H='2'

# [task_run_met_gridstat_vx_refc]
TN_RUN_MET_GRIDSTAT_VX_REFC='run_MET_GridStat_vx_REFC'
NNODES_RUN_MET_GRIDSTAT_VX_REFC='1'
PPN_RUN_MET_GRIDSTAT_VX_REFC='1'
MEM_RUN_MET_GRIDSTAT_VX_REFC='2G'
WTIME_RUN_MET_GRIDSTAT_VX_REFC='02:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_REFC='2'

# [task_run_met_gridstat_vx_retop]
TN_RUN_MET_GRIDSTAT_VX_RETOP='run_MET_GridStat_vx_RETOP'
NNODES_RUN_MET_GRIDSTAT_VX_RETOP='1'
PPN_RUN_MET_GRIDSTAT_VX_RETOP='1'
MEM_RUN_MET_GRIDSTAT_VX_RETOP='2G'
WTIME_RUN_MET_GRIDSTAT_VX_RETOP='02:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_RETOP='2'

# [task_run_met_pointstat_vx_sfc]
TN_RUN_MET_POINTSTAT_VX_SFC='run_MET_PointStat_vx_SFC'
NNODES_RUN_MET_POINTSTAT_VX_SFC='1'
PPN_RUN_MET_POINTSTAT_VX_SFC='1'
MEM_RUN_MET_POINTSTAT_VX_SFC='2G'
WTIME_RUN_MET_POINTSTAT_VX_SFC='01:00:00'
MAXTRIES_RUN_MET_POINTSTAT_VX_SFC='2'

# [task_run_met_pointstat_vx_upa]
TN_RUN_MET_POINTSTAT_VX_UPA='run_MET_PointStat_vx_UPA'
NNODES_RUN_MET_POINTSTAT_VX_UPA='1'
PPN_RUN_MET_POINTSTAT_VX_UPA='1'
MEM_RUN_MET_POINTSTAT_VX_UPA='2G'
WTIME_RUN_MET_POINTSTAT_VX_UPA='01:00:00'
MAXTRIES_RUN_MET_POINTSTAT_VX_UPA='2'

# [task_run_met_ensemblestat_vx_apcp01h]
TN_RUN_MET_ENSEMBLESTAT_VX_APCP01H='run_MET_EnsembleStat_vx_APCP01h'
NNODES_RUN_MET_ENSEMBLESTAT_VX_APCP01H='1'
PPN_RUN_MET_ENSEMBLESTAT_VX_APCP01H='1'
MEM_RUN_MET_ENSEMBLESTAT_VX_APCP01H='2G'
WTIME_RUN_MET_ENSEMBLESTAT_VX_APCP01H='01:00:00'
MAXTRIES_RUN_MET_ENSEMBLESTAT_VX_APCP01H='2'

# [task_run_met_ensemblestat_vx_apcp03h]
TN_RUN_MET_ENSEMBLESTAT_VX_APCP03H='run_MET_EnsembleStat_vx_APCP03h'
NNODES_RUN_MET_ENSEMBLESTAT_VX_APCP03H='1'
PPN_RUN_MET_ENSEMBLESTAT_VX_APCP03H='1'
MEM_RUN_MET_ENSEMBLESTAT_VX_APCP03H='2G'
WTIME_RUN_MET_ENSEMBLESTAT_VX_APCP03H='01:00:00'
MAXTRIES_RUN_MET_ENSEMBLESTAT_VX_APCP03H='2'

# [task_run_met_ensemblestat_vx_apcp06h]
TN_RUN_MET_ENSEMBLESTAT_VX_APCP06H='run_MET_EnsembleStat_vx_APCP06h'
NNODES_RUN_MET_ENSEMBLESTAT_VX_APCP06H='1'
PPN_RUN_MET_ENSEMBLESTAT_VX_APCP06H='1'
MEM_RUN_MET_ENSEMBLESTAT_VX_APCP06H='2G'
WTIME_RUN_MET_ENSEMBLESTAT_VX_APCP06H='01:00:00'
MAXTRIES_RUN_MET_ENSEMBLESTAT_VX_APCP06H='2'

# [task_run_met_ensemblestat_vx_apcp24h]
TN_RUN_MET_ENSEMBLESTAT_VX_APCP24H='run_MET_EnsembleStat_vx_APCP24h'
NNODES_RUN_MET_ENSEMBLESTAT_VX_APCP24H='1'
PPN_RUN_MET_ENSEMBLESTAT_VX_APCP24H='1'
MEM_RUN_MET_ENSEMBLESTAT_VX_APCP24H='2G'
WTIME_RUN_MET_ENSEMBLESTAT_VX_APCP24H='01:00:00'
MAXTRIES_RUN_MET_ENSEMBLESTAT_VX_APCP24H='2'

# [task_run_met_ensemblestat_vx_refc]
TN_RUN_MET_ENSEMBLESTAT_VX_REFC='run_MET_EnsembleStat_vx_REFC'
NNODES_RUN_MET_ENSEMBLESTAT_VX_REFC='1'
PPN_RUN_MET_ENSEMBLESTAT_VX_REFC='1'
MEM_RUN_MET_ENSEMBLESTAT_VX_REFC='2G'
WTIME_RUN_MET_ENSEMBLESTAT_VX_REFC='01:00:00'
MAXTRIES_RUN_MET_ENSEMBLESTAT_VX_REFC='2'

# [task_run_met_ensemblestat_vx_retop]
TN_RUN_MET_ENSEMBLESTAT_VX_RETOP='run_MET_EnsembleStat_vx_RETOP'
NNODES_RUN_MET_ENSEMBLESTAT_VX_RETOP='1'
PPN_RUN_MET_ENSEMBLESTAT_VX_RETOP='1'
MEM_RUN_MET_ENSEMBLESTAT_VX_RETOP='2G'
WTIME_RUN_MET_ENSEMBLESTAT_VX_RETOP='01:00:00'
MAXTRIES_RUN_MET_ENSEMBLESTAT_VX_RETOP='2'

# [task_run_met_ensemblestat_vx_sfc]
TN_RUN_MET_ENSEMBLESTAT_VX_SFC='run_MET_EnsembleStat_vx_SFC'
NNODES_RUN_MET_ENSEMBLESTAT_VX_SFC='1'
PPN_RUN_MET_ENSEMBLESTAT_VX_SFC='1'
MEM_RUN_MET_ENSEMBLESTAT_VX_SFC='2G'
WTIME_RUN_MET_ENSEMBLESTAT_VX_SFC='01:00:00'
MAXTRIES_RUN_MET_ENSEMBLESTAT_VX_SFC='2'

# [task_run_met_ensemblestat_vx_upa]
TN_RUN_MET_ENSEMBLESTAT_VX_UPA='run_MET_EnsembleStat_vx_UPA'
NNODES_RUN_MET_ENSEMBLESTAT_VX_UPA='1'
PPN_RUN_MET_ENSEMBLESTAT_VX_UPA='1'
MEM_RUN_MET_ENSEMBLESTAT_VX_UPA='2G'
WTIME_RUN_MET_ENSEMBLESTAT_VX_UPA='01:00:00'
MAXTRIES_RUN_MET_ENSEMBLESTAT_VX_UPA='2'

# [task_run_met_gridstat_vx_ensmean_apcp01h]
TN_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP01H='run_MET_GridStat_vx_ensmean_APCP01h'
NNODES_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP01H='1'
PPN_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP01H='1'
MEM_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP01H='2G'
WTIME_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP01H='01:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP01H='2'

# [task_run_met_gridstat_vx_ensmean_apcp03h]
TN_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP03H='run_MET_GridStat_vx_ensmean_APCP03h'
NNODES_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP03H='1'
PPN_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP03H='1'
MEM_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP03H='2G'
WTIME_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP03H='01:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP03H='2'

# [task_run_met_gridstat_vx_ensmean_apcp06h]
TN_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP06H='run_MET_GridStat_vx_ensmean_APCP06h'
NNODES_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP06H='1'
PPN_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP06H='1'
MEM_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP06H='2G'
WTIME_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP06H='01:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP06H='2'

# [task_run_met_gridstat_vx_ensmean_apcp24h]
TN_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP24H='run_MET_GridStat_vx_ensmean_APCP24h'
NNODES_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP24H='1'
PPN_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP24H='1'
MEM_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP24H='2G'
WTIME_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP24H='01:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_ENSMEAN_APCP24H='2'

# [task_run_met_pointstat_vx_ensmean_sfc]
TN_RUN_MET_POINTSTAT_VX_ENSMEAN_SFC='run_MET_PointStat_vx_ensmean_SFC'
NNODES_RUN_MET_POINTSTAT_VX_ENSMEAN_SFC='1'
PPN_RUN_MET_POINTSTAT_VX_ENSMEAN_SFC='1'
MEM_RUN_MET_POINTSTAT_VX_ENSMEAN_SFC='2G'
WTIME_RUN_MET_POINTSTAT_VX_ENSMEAN_SFC='01:00:00'
MAXTRIES_RUN_MET_POINTSTAT_VX_ENSMEAN_SFC='2'

# [task_run_met_pointstat_vx_ensmean_upa]
TN_RUN_MET_POINTSTAT_VX_ENSMEAN_UPA='run_MET_PointStat_vx_ensmean_UPA'
NNODES_RUN_MET_POINTSTAT_VX_ENSMEAN_UPA='1'
PPN_RUN_MET_POINTSTAT_VX_ENSMEAN_UPA='1'
MEM_RUN_MET_POINTSTAT_VX_ENSMEAN_UPA='2G'
WTIME_RUN_MET_POINTSTAT_VX_ENSMEAN_UPA='01:00:00'
MAXTRIES_RUN_MET_POINTSTAT_VX_ENSMEAN_UPA='2'

# [task_run_met_gridstat_vx_ensprob_apcp01h]
TN_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP01H='run_MET_GridStat_vx_ensprob_APCP01h'
NNODES_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP01H='1'
PPN_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP01H='1'
MEM_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP01H='2G'
WTIME_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP01H='01:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP01H='2'

# [task_run_met_gridstat_vx_ensprob_apcp03h]
TN_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP03H='run_MET_GridStat_vx_ensprob_APCP03h'
NNODES_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP03H='1'
PPN_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP03H='1'
MEM_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP03H='2G'
WTIME_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP03H='01:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP03H='2'

# [task_run_met_gridstat_vx_ensprob_apcp06h]
TN_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP06H='run_MET_GridStat_vx_ensprob_APCP06h'
NNODES_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP06H='1'
PPN_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP06H='1'
MEM_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP06H='2G'
WTIME_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP06H='01:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP06H='2'

# [task_run_met_gridstat_vx_ensprob_apcp24h]
TN_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP24H='run_MET_GridStat_vx_ensprob_APCP24h'
NNODES_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP24H='1'
PPN_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP24H='1'
MEM_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP24H='2G'
WTIME_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP24H='01:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_ENSPROB_APCP24H='2'

# [task_run_met_gridstat_vx_ensprob_refc]
TN_RUN_MET_GRIDSTAT_VX_ENSPROB_REFC='run_MET_GridStat_vx_ensprob_REFC'
NNODES_RUN_MET_GRIDSTAT_VX_ENSPROB_REFC='1'
PPN_RUN_MET_GRIDSTAT_VX_ENSPROB_REFC='1'
MEM_RUN_MET_GRIDSTAT_VX_ENSPROB_REFC='2G'
WTIME_RUN_MET_GRIDSTAT_VX_ENSPROB_REFC='01:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_ENSPROB_REFC='2'

# [task_run_met_gridstat_vx_ensprob_retop]
TN_RUN_MET_GRIDSTAT_VX_ENSPROB_RETOP='run_MET_GridStat_vx_ensprob_RETOP'
NNODES_RUN_MET_GRIDSTAT_VX_ENSPROB_RETOP='1'
PPN_RUN_MET_GRIDSTAT_VX_ENSPROB_RETOP='1'
MEM_RUN_MET_GRIDSTAT_VX_ENSPROB_RETOP='2G'
WTIME_RUN_MET_GRIDSTAT_VX_ENSPROB_RETOP='01:00:00'
MAXTRIES_RUN_MET_GRIDSTAT_VX_ENSPROB_RETOP='2'

# [task_run_met_pointstat_vx_ensprob_sfc]
TN_RUN_MET_POINTSTAT_VX_ENSPROB_SFC='run_MET_PointStat_vx_ensprob_SFC'
NNODES_RUN_MET_POINTSTAT_VX_ENSPROB_SFC='1'
PPN_RUN_MET_POINTSTAT_VX_ENSPROB_SFC='1'
MEM_RUN_MET_POINTSTAT_VX_ENSPROB_SFC='2G'
WTIME_RUN_MET_POINTSTAT_VX_ENSPROB_SFC='01:00:00'
MAXTRIES_RUN_MET_POINTSTAT_VX_ENSPROB_SFC='2'

# [task_run_met_pointstat_vx_ensprob_upa]
TN_RUN_MET_POINTSTAT_VX_ENSPROB_UPA='run_MET_PointStat_vx_ensprob_UPA'
NNODES_RUN_MET_POINTSTAT_VX_ENSPROB_UPA='1'
PPN_RUN_MET_POINTSTAT_VX_ENSPROB_UPA='1'
MEM_RUN_MET_POINTSTAT_VX_ENSPROB_UPA='2G'
WTIME_RUN_MET_POINTSTAT_VX_ENSPROB_UPA='01:00:00'
MAXTRIES_RUN_MET_POINTSTAT_VX_ENSPROB_UPA='2'

# [task_aqm_ics]
TN_AQM_ICS='aqm_ics'
NNODES_AQM_ICS='1'
PPN_AQM_ICS='1'
WTIME_AQM_ICS='00:30:00'
MAXTRIES_AQM_ICS='2'

# [task_aqm_lbcs]
TN_AQM_LBCS='aqm_lbcs'
NNODES_AQM_LBCS='1'
PPN_AQM_LBCS='128'
WTIME_AQM_LBCS='01:00:00'
MAXTRIES_AQM_LBCS='1'

# [task_nexus_gfs_sfc]
TN_NEXUS_GFS_SFC='nexus_gfs_sfc'
NNODES_NEXUS_GFS_SFC='1'
PPN_NEXUS_GFS_SFC='1'
MEM_NEXUS_GFS_SFC='2G'
WTIME_NEXUS_GFS_SFC='00:30:00'
MAXTRIES_NEXUS_GFS_SFC='2'
NEXUS_GFS_SFC_OFFSET_HRS='6'

# [task_nexus_emission]
TN_NEXUS_EMISSION='nexus_emission'
NNODES_NEXUS_EMISSION='4'
PPN_NEXUS_EMISSION='64'
WTIME_NEXUS_EMISSION='01:00:00'
MAXTRIES_NEXUS_EMISSION='2'
KMP_AFFINITY_NEXUS_EMISSION='scatter'
OMP_NUM_THREADS_NEXUS_EMISSION='2'
OMP_STACKSIZE_NEXUS_EMISSION='1024m'

# [task_nexus_post_split]
TN_NEXUS_POST_SPLIT='nexus_post_split'
NNODES_NEXUS_POST_SPLIT='1'
PPN_NEXUS_POST_SPLIT='1'
WTIME_NEXUS_POST_SPLIT='00:30:00'
MAXTRIES_NEXUS_POST_SPLIT='2'

# [task_fire_emission]
TN_FIRE_EMISSION='fire_emission'
NNODES_FIRE_EMISSION='1'
PPN_FIRE_EMISSION='1'
MEM_FIRE_EMISSION='24G'
WTIME_FIRE_EMISSION='00:30:00'
MAXTRIES_FIRE_EMISSION='2'
AQM_FIRE_FILE_OFFSET_HRS='0'

# [task_point_source]
TN_POINT_SOURCE='point_source'
NNODES_POINT_SOURCE='1'
PPN_POINT_SOURCE='1'
WTIME_POINT_SOURCE='01:00:00'
MAXTRIES_POINT_SOURCE='2'

# [task_pre_post_stat]
TN_PRE_POST_STAT='pre_post_stat'
NNODES_PRE_POST_STAT='1'
PPN_PRE_POST_STAT='1'
WTIME_PRE_POST_STAT='00:30:00'
MAXTRIES_PRE_POST_STAT='2'

# [task_post_stat_o3]
TN_POST_STAT_O3='post_stat_o3'
NNODES_POST_STAT_O3='1'
PPN_POST_STAT_O3='1'
MEM_POST_STAT_O3='120G'
WTIME_POST_STAT_O3='00:30:00'
MAXTRIES_POST_STAT_O3='2'
KMP_AFFINITY_POST_STAT_O3='scatter'
OMP_NUM_THREADS_POST_STAT_O3='1'
OMP_STACKSIZE_POST_STAT_O3='2056M'

# [task_post_stat_pm25]
TN_POST_STAT_PM25='post_stat_pm25'
NNODES_POST_STAT_PM25='1'
PPN_POST_STAT_PM25='1'
MEM_POST_STAT_PM25='120G'
WTIME_POST_STAT_PM25='00:30:00'
MAXTRIES_POST_STAT_PM25='2'
KMP_AFFINITY_POST_STAT_PM25='scatter'
OMP_NUM_THREADS_POST_STAT_PM25='1'
OMP_STACKSIZE_POST_STAT_PM25='2056M'

# [task_bias_correction_o3]
TN_BIAS_CORRECTION_O3='bias_correction_o3'
NNODES_BIAS_CORRECTION_O3='1'
PPN_BIAS_CORRECTION_O3='1'
MEM_BIAS_CORRECTION_O3='120G'
WTIME_BIAS_CORRECTION_O3='00:30:00'
MAXTRIES_BIAS_CORRECTION_O3='2'
KMP_AFFINITY_BIAS_CORRECTION_O3='scatter'
OMP_NUM_THREADS_BIAS_CORRECTION_O3='32'
OMP_STACKSIZE_BIAS_CORRECTION_O3='2056M'

# [task_bias_correction_pm25]
TN_BIAS_CORRECTION_PM25='bias_correction_pm25'
NNODES_BIAS_CORRECTION_PM25='1'
PPN_BIAS_CORRECTION_PM25='1'
MEM_BIAS_CORRECTION_PM25='120G'
WTIME_BIAS_CORRECTION_PM25='00:30:00'
MAXTRIES_BIAS_CORRECTION_PM25='2'
KMP_AFFINITY_BIAS_CORRECTION_PM25='scatter'
OMP_NUM_THREADS_BIAS_CORRECTION_PM25='32'
OMP_STACKSIZE_BIAS_CORRECTION_PM25='2056M'

# [global]
USE_CRTM='FALSE'
CRTM_DIR=''
DO_ENSEMBLE='FALSE'
NUM_ENS_MEMBERS='2'
ENSMEM_NAMES='mem%03d, " % m  "mem%03d, " % m'
FV3_NML_ENSMEM_FPS='{% for mem in ENSMEM_NAMES %}{{ [EXPTDIR, "%s_%s" % FV3_NML_FN, mem]|path_join }}{% endfor %}'
ENS_TIME_LAG_HRS=( "0" "0" )
DO_SHUM='FALSE'
DO_SPPT='FALSE'
DO_SKEB='FALSE'
ISEED_SPPT='1'
ISEED_SHUM='2'
ISEED_SKEB='3'
NEW_LSCALE='TRUE'
SHUM_MAG='-999.0'
SHUM_LSCALE='150000'
SHUM_TSCALE='21600'
SHUM_INT='3600'
SPPT_MAG='-999.0'
SPPT_LOGIT='TRUE'
SPPT_LSCALE='150000'
SPPT_TSCALE='21600'
SPPT_INT='3600'
SPPT_SFCLIMIT='TRUE'
SKEB_MAG='-999.0'
SKEB_LSCALE='150000'
SKEB_TSCALE='21600'
SKEB_INT='3600'
SKEBNORM='1'
SKEB_VDOF='10'
USE_ZMTNBLCK='FALSE'
DO_SPP='FALSE'
SPP_VAR_LIST=( \
"pbl" \
"sfc" \
"mp" \
"rad" \
"gwd" \
)
SPP_MAG_LIST=( \
"0.2" \
"0.2" \
"0.75" \
"0.2" \
"0.2" \
)
SPP_LSCALE=( \
"150000.0" \
"150000.0" \
"150000.0" \
"150000.0" \
"150000.0" \
)
SPP_TSCALE=( \
"21600.0" \
"21600.0" \
"21600.0" \
"21600.0" \
"21600.0" \
)
SPP_SIGTOP1=( \
"0.1" \
"0.1" \
"0.1" \
"0.1" \
"0.1" \
)
SPP_SIGTOP2=( \
"0.025" \
"0.025" \
"0.025" \
"0.025" \
"0.025" \
)
SPP_STDDEV_CUTOFF=( \
"1.5" \
"1.5" \
"2.5" \
"1.5" \
"1.5" \
)
ISEED_SPP=( \
"4" \
"5" \
"6" \
"7" \
"8" \
)
DO_LSM_SPP='FALSE'
LSM_SPP_TSCALE=( \
"21600" \
"21600" \
"21600" \
"21600" \
"21600" \
"21600" \
"21600" \
)
LSM_SPP_LSCALE=( \
"150000" \
"150000" \
"150000" \
"150000" \
"150000" \
"150000" \
"150000" \
)
ISEED_LSM_SPP=( "9" )
LSM_SPP_VAR_LIST=( \
"smc" \
"vgf" \
"alb" \
"sal" \
"emi" \
"zol" \
"stc" \
)
LSM_SPP_MAG_LIST=( \
"0.017" \
"0.001" \
"0.001" \
"0.001" \
"0.001" \
"0.001" \
"0.2" \
)
HALO_BLEND='0'
N_VAR_SPP='0'
N_VAR_LNDP='0'
LNDP_TYPE='0'
LNDP_MODEL_TYPE='0'
FHCYC_LSM_SPP_OR_NOT='0'

# [verification]
GET_OBS_LOCAL_MODULE_FN='get_obs'
OBS_CCPA_APCP01h_FN_TEMPLATE='{valid?fmt=%Y%m%d}/ccpa.t{valid?fmt=%H}z.01h.hrap.conus.gb2'
OBS_CCPA_APCPgt01h_FN_TEMPLATE='${OBS_CCPA_APCP01h_FN_TEMPLATE}_a${ACCUM_HH}h.nc'
OBS_NDAS_SFCorUPA_FN_TEMPLATE='prepbufr.ndas.{valid?fmt=%Y%m%d%H}'
OBS_NDAS_SFCorUPA_FN_METPROC_TEMPLATE='${OBS_NDAS_SFCorUPA_FN_TEMPLATE}.nc'
VX_LOCAL_MODULE_FN='run_vx'
RUN_TASKS_METVX_DET='FALSE'
RUN_TASKS_METVX_ENS='FALSE'
VX_FCST_MODEL_NAME='{{ nco.NET }}.793'
VX_FIELDS=( \
"APCP" \
"REFC" \
"RETOP" \
"SFC" \
"UPA" \
)
VX_APCP_ACCUMS_HH=( "01" "03" "06" "24" )
VX_FCST_INPUT_BASEDIR='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/config'
VX_OUTPUT_BASEDIR='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/parm/config'
FCST_SUBDIR_TEMPLATE='{init?fmt=%Y%m%d%H?shift=-${time_lag}}${SLASH_ENSMEM_SUBDIR_OR_NULL}/postprd'
FCST_FN_TEMPLATE='${NET}.t{init?fmt=%H?shift=-${time_lag}}z.prslev.f{lead?fmt=%HHH?shift=${time_lag}}.${POST_OUTPUT_DOMAIN_NAME}.grib2'
FCST_FN_METPROC_TEMPLATE='${NET}.t{init?fmt=%H}z.prslev.f{lead?fmt=%HHH}.${POST_OUTPUT_DOMAIN_NAME}_a${ACCUM_HH}h.nc'
NUM_MISSING_OBS_FILES_MAX='2'

# [cpl_aqm_parm]
CPL_AQM='TRUE'
DO_AQM_DUST='TRUE'
DO_AQM_CANOPY='FALSE'
DO_AQM_PRODUCT='TRUE'
DO_AQM_CHEM_LBCS='TRUE'
DO_AQM_GEFS_LBCS='TRUE'
DO_AQM_SAVE_AIRNOW_HIST='TRUE'
DO_AQM_SAVE_FIRE='FALSE'
AQM_BIO_FILE='BEIS_RRFScmaq_C775.ncf'
AQM_DUST_FILE_PREFIX='FENGSHA_p8_10km_inputs'
AQM_DUST_FILE_SUFFIX='.nc'
AQM_CANOPY_FILE_PREFIX='gfs.t12z.geo'
AQM_CANOPY_FILE_SUFFIX='.canopy_regrid.nc'
DCOMINfire='/lfs/h1/ops/dev/dcom'
AQM_FIRE_FILE_PREFIX='Hourly_Emissions_regrid_NA_13km'
AQM_FIRE_FILE_SUFFIX='_h72.nc'
#### AQM_FIRE_ARCHV_DIR='/path/to/archive/dir/for/RAVE/on/HPSS'
AQM_RC_FIRE_FREQUENCY='hourly'
AQM_RC_PRODUCT_FN='aqm.prod.nc'
AQM_RC_PRODUCT_FREQUENCY='hourly'
AQM_LBCS_FILES='am4_bndy.c793.2019<MM>.v1.nc'
COMINgefs='/lfs/h1/ops/prod/com/gefs/v12.3'
AQM_GEFS_FILE_PREFIX='geaer'
AQM_GEFS_FILE_CYC=''
COMINemis='/lfs/h2/emc/physics/noscrub/UFS_SRW_App/aqm.v7/emissions'
FIXaqmconfig='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/fix/aqm/epa/data'
FIXaqmfire='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/fix/fire'
FIXaqmbio='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/fix/bio'
FIXaqmdust='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/fix/FENGSHA'
FIXaqmcanopy='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/fix/canopy'
FIXaqmchem_lbcs='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/fix/chem_lbcs'
FIXaqmnexus='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/fix/nexus'
FIXaqmnexus_gfs_sfc='/lfs/h2/emc/global/noscrub/lin.gan/para/packages/aqm.v7.0/fix/gfs'
NEXUS_GRID_FN='grid_spec_793.nc'
NUM_SPLIT_NEXUS='6'
NEXUS_GFS_SFC_ARCHV_DIR='/NCEPPROD/hpssprod/runhistory'
COMINemispt='/lfs/h2/emc/physics/noscrub/UFS_SRW_App/aqm.v7/emissions/nei2016v1-pt'
DCOMINairnow='/lfs/h1/ops/prod/dcom'
COMINbicor='/lfs/h2/emc/ptmp/lin.gan/ecflow_aqm/para/com/aqm/v7.0'
COMOUTbicor='/lfs/h2/emc/ptmp/lin.gan/ecflow_aqm/para/com/aqm/v7.0'

# [constants]
PI_GEOM='3.141592653589793'
DEGS_PER_RADIAN='57.29577951308232'
RADIUS_EARTH='6371200.0'
SECS_PER_HOUR='3600.0'
GTYPE='regional'
TILE_RGNL='7'
NH0='0'
NH3='3'
NH4='4'
valid_vals_BOOLEAN=( \
"TRUE" \
"true" \
"YES" \
"yes" \
"FALSE" \
"false" \
"NO" \
"no" \
)

# [fixed_files]
FV3_NML_VARNAME_TO_SFC_CLIMO_FIELD_MAPPING=( \
"FNALBC  | snowfree_albedo" \
"FNALBC2 | facsf" \
"FNTG3C  | substrate_temperature" \
"FNVEGC  | vegetation_greenness" \
"FNVETC  | vegetation_type" \
"FNSOTC  | soil_type" \
"FNVMNC  | vegetation_greenness" \
"FNVMXC  | vegetation_greenness" \
"FNSLPC  | slope_type" \
"FNABSC  | maximum_snow_albedo" \
)
SFC_CLIMO_FIELDS=( \
"facsf" \
"maximum_snow_albedo" \
"slope_type" \
"snowfree_albedo" \
"soil_type" \
"substrate_temperature" \
"vegetation_greenness" \
"vegetation_type" \
)
FNGLAC='global_glacier.2x2.grb'
FNMXIC='global_maxice.2x2.grb'
FNTSFC='RTGSST.1982.2012.monthly.clim.grb'
FNSNOC='global_snoclim.1.875.grb'
FNZORC='igbp'
FNAISC='CFSR.SEAICE.1982.2012.monthly.clim.grb'
FNSMCC='global_soilmgldas.t126.384.190.grb'
FNMSKH='seaice_newland.grb'
FIXgsm_FILES_TO_COPY_TO_FIXam=( \
"global_glacier.2x2.grb" \
"global_maxice.2x2.grb" \
"RTGSST.1982.2012.monthly.clim.grb" \
"global_snoclim.1.875.grb" \
"CFSR.SEAICE.1982.2012.monthly.clim.grb" \
"global_soilmgldas.t126.384.190.grb" \
"seaice_newland.grb" \
"global_climaeropac_global.txt" \
"fix_co2_proj/global_co2historicaldata_2010.txt" \
"fix_co2_proj/global_co2historicaldata_2011.txt" \
"fix_co2_proj/global_co2historicaldata_2012.txt" \
"fix_co2_proj/global_co2historicaldata_2013.txt" \
"fix_co2_proj/global_co2historicaldata_2014.txt" \
"fix_co2_proj/global_co2historicaldata_2015.txt" \
"fix_co2_proj/global_co2historicaldata_2016.txt" \
"fix_co2_proj/global_co2historicaldata_2017.txt" \
"fix_co2_proj/global_co2historicaldata_2018.txt" \
"fix_co2_proj/global_co2historicaldata_2019.txt" \
"fix_co2_proj/global_co2historicaldata_2020.txt" \
"fix_co2_proj/global_co2historicaldata_2021.txt" \
"global_co2historicaldata_glob.txt" \
"co2monthlycyc.txt" \
"global_h2o_pltc.f77" \
"global_hyblev.l65.txt" \
"global_zorclim.1x1.grb" \
"global_sfc_emissivity_idx.txt" \
"global_tg3clim.2.6x1.5.grb" \
"global_solarconstant_noaa_an.txt" \
"global_albedo4.1x1.grb" \
"geo_em.d01.lat-lon.2.5m.HGT_M.nc" \
"HGT.Beljaars_filtered.lat-lon.30s_res.nc" \
"ozprdlos_2015_new_sbuvO3_tclm15_nuchem.f77" \
)
FV3_NML_VARNAME_TO_FIXam_FILES_MAPPING=( \
"FNGLAC | global_glacier.2x2.grb" \
"FNMXIC | global_maxice.2x2.grb" \
"FNTSFC | RTGSST.1982.2012.monthly.clim.grb" \
"FNSNOC | global_snoclim.1.875.grb" \
"FNAISC | CFSR.SEAICE.1982.2012.monthly.clim.grb" \
"FNSMCC | global_soilmgldas.t126.384.190.grb" \
"FNMSKH | seaice_newland.grb" \
)
CYCLEDIR_LINKS_TO_FIXam_FILES_MAPPING=( \
"aerosol.dat                | global_climaeropac_global.txt" \
"co2historicaldata_2010.txt | fix_co2_proj/global_co2historicaldata_2010.txt" \
"co2historicaldata_2011.txt | fix_co2_proj/global_co2historicaldata_2011.txt" \
"co2historicaldata_2012.txt | fix_co2_proj/global_co2historicaldata_2012.txt" \
"co2historicaldata_2013.txt | fix_co2_proj/global_co2historicaldata_2013.txt" \
"co2historicaldata_2014.txt | fix_co2_proj/global_co2historicaldata_2014.txt" \
"co2historicaldata_2015.txt | fix_co2_proj/global_co2historicaldata_2015.txt" \
"co2historicaldata_2016.txt | fix_co2_proj/global_co2historicaldata_2016.txt" \
"co2historicaldata_2017.txt | fix_co2_proj/global_co2historicaldata_2017.txt" \
"co2historicaldata_2018.txt | fix_co2_proj/global_co2historicaldata_2018.txt" \
"co2historicaldata_2019.txt | fix_co2_proj/global_co2historicaldata_2019.txt" \
"co2historicaldata_2020.txt | fix_co2_proj/global_co2historicaldata_2020.txt" \
"co2historicaldata_2021.txt | fix_co2_proj/global_co2historicaldata_2021.txt" \
"co2historicaldata_glob.txt | global_co2historicaldata_glob.txt" \
"co2monthlycyc.txt          | co2monthlycyc.txt" \
"global_h2oprdlos.f77       | global_h2o_pltc.f77" \
"global_albedo4.1x1.grb     | global_albedo4.1x1.grb" \
"global_zorclim.1x1.grb     | global_zorclim.1x1.grb" \
"global_tg3clim.2.6x1.5.grb | global_tg3clim.2.6x1.5.grb" \
"sfc_emissivity_idx.txt     | global_sfc_emissivity_idx.txt" \
"solarconstant_noaa_an.txt  | global_solarconstant_noaa_an.txt" \
"global_o3prdlos.f77        | ozprdlos_2015_new_sbuvO3_tclm15_nuchem.f77" \
)

# [grid_params]
LON_CTR='-118.0'
LAT_CTR='50.0'
NX='800'
NY='544'
PAZI='0.0'
NHW='6'
STRETCH_FAC='0.999'
DEL_ANGLE_X_SG='0.05845406938018506'
DEL_ANGLE_Y_SG='0.05845406938018506'
NEG_NX_OF_DOM_WITH_WIDE_HALO='-812'
NEG_NY_OF_DOM_WITH_WIDE_HALO='-556'

