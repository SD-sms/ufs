#!/usr/bin/env python3

import os
import sys
import platform
import subprocess
import unittest
import logging
from multiprocessing import Process
from textwrap import dedent
from datetime import datetime, timedelta

from python_utils import (
    print_info_msg,
    print_err_msg_exit,
    import_vars,
    cp_vrfy,
    cd_vrfy,
    rm_vrfy,
    ln_vrfy,
    mkdir_vrfy,
    mv_vrfy,
    run_command,
    date_to_str,
    define_macos_utilities,
    create_symlink_to_file,
    check_for_preexist_dir_file,
    cfg_to_yaml_str,
    find_pattern_in_str,
    set_env_var,
    get_env_var,
)

from setup import setup
from set_FV3nml_sfc_climo_filenames import set_FV3nml_sfc_climo_filenames
from get_crontab_contents import add_crontab_line
from fill_jinja_template import fill_jinja_template
from set_namelist import set_namelist


def python_error_handler():
    """Error handler for missing packages"""

    print_err_msg_exit(
        """
        Errors found: check your python environment

        Instructions for setting up python environments can be found on the web:
        https://github.com/ufs-community/ufs-srweather-app/wiki/Getting-Started
        """,
        stack_trace=False,
    )


# Check for non-standard python packages
try:
    import jinja2
    import yaml
    import f90nml
except ImportError as error:
    print_info_msg(error.__class__.__name__ + ": " + str(error))
    python_error_handler()


def generate_FV3LAM_wflow(USHdir, logfile: str = 'log.generate_FV3LAM_wflow') -> None:
    """Function to setup a forecast experiment and create a workflow
    (according to the parameters specified in the config file)

    Args:
        USHdir  (str): The full path of the ush/ directory where this script is located
        logfile (str): The name of the file where logging is written
    Returns:
        None
    """

    # Set up logging to write to screen and logfile
    setup_logging(logfile)

    logging.info(
        dedent(
            """
        ========================================================================
        Starting experiment generation...
        ========================================================================"""
        )
    )

    # check python version
    major, minor, patch = platform.python_version_tuple()
    if int(major) < 3 or int(minor) < 6:
        logging.error(
            f"""

            Error: python version must be 3.6 or higher
            python version: {major}.{minor}"""
        )
        raise

    # define utilities 
    define_macos_utilities()

    # The setup function reads the user configuration file and fills in 
    # non-user-specified values from config_defaults.yaml
    setup()

    # import all environment variables
    import_vars()

    #
    # -----------------------------------------------------------------------
    #
    # Set the full path to the experiment's rocoto workflow xml file.  This
    # file will be placed at the top level of the experiment directory and
    # then used by rocoto to run the workflow.
    #
    # -----------------------------------------------------------------------
    #
    WFLOW_XML_FP = os.path.join(EXPTDIR, WFLOW_XML_FN)

    #
    # -----------------------------------------------------------------------
    #
    # Create a multiline variable that consists of a yaml-compliant string
    # specifying the values that the jinja variables in the template rocoto
    # XML should be set to.  These values are set either in the user-specified
    # workflow configuration file (EXPT_CONFIG_FN) or in the setup.sh script
    # sourced above.  Then call the python script that generates the XML.
    #
    # -----------------------------------------------------------------------
    #
    if WORKFLOW_MANAGER == "rocoto":

        template_xml_fp = os.path.join(PARMdir, WFLOW_XML_FN)

        logging.info(
            f'''
            Creating rocoto workflow XML file (WFLOW_XML_FP) from jinja template XML
            file (template_xml_fp):
              template_xml_fp = \"{template_xml_fp}\"
              WFLOW_XML_FP = \"{WFLOW_XML_FP}\"'''
        )

        ensmem_indx_name = ""
        uscore_ensmem_name = ""
        slash_ensmem_subdir = ""
        if DO_ENSEMBLE:
            ensmem_indx_name = "mem"
            uscore_ensmem_name = f"_mem#{ensmem_indx_name}#"
            slash_ensmem_subdir = f"/mem#{ensmem_indx_name}#"

        # get time string
        d = DATE_FIRST_CYCL + timedelta(seconds=DT_ATMOS)
        time_str = d.strftime("%M:%S")

        # Dictionary of settings
        settings = {
            #
            # Parameters needed by the job scheduler.
            #
            "account": ACCOUNT,
            "sched": SCHED,
            "partition_default": PARTITION_DEFAULT,
            "queue_default": QUEUE_DEFAULT,
            "partition_hpss": PARTITION_HPSS,
            "queue_hpss": QUEUE_HPSS,
            "partition_fcst": PARTITION_FCST,
            "queue_fcst": QUEUE_FCST,
            "machine": MACHINE,
            "sched_native_cmd": SCHED_NATIVE_CMD,
            "workflow_id": WORKFLOW_ID,
            #
            # Run environment
            #
            "run_envir": RUN_ENVIR,
            "run": RUN,
            "net": NET,
            #
            # Workflow task names.
            #
            "make_grid_tn": MAKE_GRID_TN,
            "make_orog_tn": MAKE_OROG_TN,
            "make_sfc_climo_tn": MAKE_SFC_CLIMO_TN,
            "get_extrn_ics_tn": GET_EXTRN_ICS_TN,
            "get_extrn_lbcs_tn": GET_EXTRN_LBCS_TN,
            "make_ics_tn": MAKE_ICS_TN,
            "make_lbcs_tn": MAKE_LBCS_TN,
            "run_fcst_tn": RUN_FCST_TN,
            "run_post_tn": RUN_POST_TN,
            "get_obs_ccpa_tn": GET_OBS_CCPA_TN,
            "get_obs_ndas_tn": GET_OBS_NDAS_TN,
            "get_obs_mrms_tn": GET_OBS_MRMS_TN,
            "vx_tn": VX_TN,
            "vx_gridstat_tn": VX_GRIDSTAT_TN,
            "vx_gridstat_refc_tn": VX_GRIDSTAT_REFC_TN,
            "vx_gridstat_retop_tn": VX_GRIDSTAT_RETOP_TN,
            "vx_gridstat_03h_tn": VX_GRIDSTAT_03h_TN,
            "vx_gridstat_06h_tn": VX_GRIDSTAT_06h_TN,
            "vx_gridstat_24h_tn": VX_GRIDSTAT_24h_TN,
            "vx_pointstat_tn": VX_POINTSTAT_TN,
            "vx_ensgrid_tn": VX_ENSGRID_TN,
            "vx_ensgrid_refc_tn": VX_ENSGRID_REFC_TN,
            "vx_ensgrid_retop_tn": VX_ENSGRID_RETOP_TN,
            "vx_ensgrid_03h_tn": VX_ENSGRID_03h_TN,
            "vx_ensgrid_06h_tn": VX_ENSGRID_06h_TN,
            "vx_ensgrid_24h_tn": VX_ENSGRID_24h_TN,
            "vx_ensgrid_mean_tn": VX_ENSGRID_MEAN_TN,
            "vx_ensgrid_prob_tn": VX_ENSGRID_PROB_TN,
            "vx_ensgrid_mean_03h_tn": VX_ENSGRID_MEAN_03h_TN,
            "vx_ensgrid_prob_03h_tn": VX_ENSGRID_PROB_03h_TN,
            "vx_ensgrid_mean_06h_tn": VX_ENSGRID_MEAN_06h_TN,
            "vx_ensgrid_prob_06h_tn": VX_ENSGRID_PROB_06h_TN,
            "vx_ensgrid_mean_24h_tn": VX_ENSGRID_MEAN_24h_TN,
            "vx_ensgrid_prob_24h_tn": VX_ENSGRID_PROB_24h_TN,
            "vx_ensgrid_prob_refc_tn": VX_ENSGRID_PROB_REFC_TN,
            "vx_ensgrid_prob_retop_tn": VX_ENSGRID_PROB_RETOP_TN,
            "vx_enspoint_tn": VX_ENSPOINT_TN,
            "vx_enspoint_mean_tn": VX_ENSPOINT_MEAN_TN,
            "vx_enspoint_prob_tn": VX_ENSPOINT_PROB_TN,
            #
            # Entity used to load the module file for each GET_OBS_* task.
            #
            "get_obs": GET_OBS,
            #
            # Number of nodes to use for each task.
            #
            "nnodes_make_grid": NNODES_MAKE_GRID,
            "nnodes_make_orog": NNODES_MAKE_OROG,
            "nnodes_make_sfc_climo": NNODES_MAKE_SFC_CLIMO,
            "nnodes_get_extrn_ics": NNODES_GET_EXTRN_ICS,
            "nnodes_get_extrn_lbcs": NNODES_GET_EXTRN_LBCS,
            "nnodes_make_ics": NNODES_MAKE_ICS,
            "nnodes_make_lbcs": NNODES_MAKE_LBCS,
            "nnodes_run_fcst": NNODES_RUN_FCST,
            "nnodes_run_post": NNODES_RUN_POST,
            "nnodes_get_obs_ccpa": NNODES_GET_OBS_CCPA,
            "nnodes_get_obs_mrms": NNODES_GET_OBS_MRMS,
            "nnodes_get_obs_ndas": NNODES_GET_OBS_NDAS,
            "nnodes_vx_gridstat": NNODES_VX_GRIDSTAT,
            "nnodes_vx_pointstat": NNODES_VX_POINTSTAT,
            "nnodes_vx_ensgrid": NNODES_VX_ENSGRID,
            "nnodes_vx_ensgrid_mean": NNODES_VX_ENSGRID_MEAN,
            "nnodes_vx_ensgrid_prob": NNODES_VX_ENSGRID_PROB,
            "nnodes_vx_enspoint": NNODES_VX_ENSPOINT,
            "nnodes_vx_enspoint_mean": NNODES_VX_ENSPOINT_MEAN,
            "nnodes_vx_enspoint_prob": NNODES_VX_ENSPOINT_PROB,
            #
            # Number of cores used for a task
            #
            "ncores_run_fcst": PE_MEMBER01,
            "native_run_fcst": f"--cpus-per-task {OMP_NUM_THREADS_RUN_FCST} --exclusive",
            #
            # Number of OpenMP threads for the run_fcst task
            #
            "omp_num_threads_run_fcst": OMP_NUM_THREADS_RUN_FCST,
            #
            # Number of logical processes per node for each task.  If running without
            # threading, this is equal to the number of MPI processes per node.
            #
            "ppn_make_grid": PPN_MAKE_GRID,
            "ppn_make_orog": PPN_MAKE_OROG,
            "ppn_make_sfc_climo": PPN_MAKE_SFC_CLIMO,
            "ppn_get_extrn_ics": PPN_GET_EXTRN_ICS,
            "ppn_get_extrn_lbcs": PPN_GET_EXTRN_LBCS,
            "ppn_make_ics": PPN_MAKE_ICS,
            "ppn_make_lbcs": PPN_MAKE_LBCS,
            "ppn_run_fcst": PPN_RUN_FCST,
            "ppn_run_post": PPN_RUN_POST,
            "ppn_get_obs_ccpa": PPN_GET_OBS_CCPA,
            "ppn_get_obs_mrms": PPN_GET_OBS_MRMS,
            "ppn_get_obs_ndas": PPN_GET_OBS_NDAS,
            "ppn_vx_gridstat": PPN_VX_GRIDSTAT,
            "ppn_vx_pointstat": PPN_VX_POINTSTAT,
            "ppn_vx_ensgrid": PPN_VX_ENSGRID,
            "ppn_vx_ensgrid_mean": PPN_VX_ENSGRID_MEAN,
            "ppn_vx_ensgrid_prob": PPN_VX_ENSGRID_PROB,
            "ppn_vx_enspoint": PPN_VX_ENSPOINT,
            "ppn_vx_enspoint_mean": PPN_VX_ENSPOINT_MEAN,
            "ppn_vx_enspoint_prob": PPN_VX_ENSPOINT_PROB,
            #
            # Maximum wallclock time for each task.
            #
            "wtime_make_grid": WTIME_MAKE_GRID,
            "wtime_make_orog": WTIME_MAKE_OROG,
            "wtime_make_sfc_climo": WTIME_MAKE_SFC_CLIMO,
            "wtime_get_extrn_ics": WTIME_GET_EXTRN_ICS,
            "wtime_get_extrn_lbcs": WTIME_GET_EXTRN_LBCS,
            "wtime_make_ics": WTIME_MAKE_ICS,
            "wtime_make_lbcs": WTIME_MAKE_LBCS,
            "wtime_run_fcst": WTIME_RUN_FCST,
            "wtime_run_post": WTIME_RUN_POST,
            "wtime_get_obs_ccpa": WTIME_GET_OBS_CCPA,
            "wtime_get_obs_mrms": WTIME_GET_OBS_MRMS,
            "wtime_get_obs_ndas": WTIME_GET_OBS_NDAS,
            "wtime_vx_gridstat": WTIME_VX_GRIDSTAT,
            "wtime_vx_pointstat": WTIME_VX_POINTSTAT,
            "wtime_vx_ensgrid": WTIME_VX_ENSGRID,
            "wtime_vx_ensgrid_mean": WTIME_VX_ENSGRID_MEAN,
            "wtime_vx_ensgrid_prob": WTIME_VX_ENSGRID_PROB,
            "wtime_vx_enspoint": WTIME_VX_ENSPOINT,
            "wtime_vx_enspoint_mean": WTIME_VX_ENSPOINT_MEAN,
            "wtime_vx_enspoint_prob": WTIME_VX_ENSPOINT_PROB,
            #
            # Maximum number of tries for each task.
            #
            "maxtries_make_grid": MAXTRIES_MAKE_GRID,
            "maxtries_make_orog": MAXTRIES_MAKE_OROG,
            "maxtries_make_sfc_climo": MAXTRIES_MAKE_SFC_CLIMO,
            "maxtries_get_extrn_ics": MAXTRIES_GET_EXTRN_ICS,
            "maxtries_get_extrn_lbcs": MAXTRIES_GET_EXTRN_LBCS,
            "maxtries_make_ics": MAXTRIES_MAKE_ICS,
            "maxtries_make_lbcs": MAXTRIES_MAKE_LBCS,
            "maxtries_run_fcst": MAXTRIES_RUN_FCST,
            "maxtries_run_post": MAXTRIES_RUN_POST,
            "maxtries_get_obs_ccpa": MAXTRIES_GET_OBS_CCPA,
            "maxtries_get_obs_mrms": MAXTRIES_GET_OBS_MRMS,
            "maxtries_get_obs_ndas": MAXTRIES_GET_OBS_NDAS,
            "maxtries_vx_gridstat": MAXTRIES_VX_GRIDSTAT,
            "maxtries_vx_gridstat_refc": MAXTRIES_VX_GRIDSTAT_REFC,
            "maxtries_vx_gridstat_retop": MAXTRIES_VX_GRIDSTAT_RETOP,
            "maxtries_vx_gridstat_03h": MAXTRIES_VX_GRIDSTAT_03h,
            "maxtries_vx_gridstat_06h": MAXTRIES_VX_GRIDSTAT_06h,
            "maxtries_vx_gridstat_24h": MAXTRIES_VX_GRIDSTAT_24h,
            "maxtries_vx_pointstat": MAXTRIES_VX_POINTSTAT,
            "maxtries_vx_ensgrid": MAXTRIES_VX_ENSGRID,
            "maxtries_vx_ensgrid_refc": MAXTRIES_VX_ENSGRID_REFC,
            "maxtries_vx_ensgrid_retop": MAXTRIES_VX_ENSGRID_RETOP,
            "maxtries_vx_ensgrid_03h": MAXTRIES_VX_ENSGRID_03h,
            "maxtries_vx_ensgrid_06h": MAXTRIES_VX_ENSGRID_06h,
            "maxtries_vx_ensgrid_24h": MAXTRIES_VX_ENSGRID_24h,
            "maxtries_vx_ensgrid_mean": MAXTRIES_VX_ENSGRID_MEAN,
            "maxtries_vx_ensgrid_prob": MAXTRIES_VX_ENSGRID_PROB,
            "maxtries_vx_ensgrid_mean_03h": MAXTRIES_VX_ENSGRID_MEAN_03h,
            "maxtries_vx_ensgrid_prob_03h": MAXTRIES_VX_ENSGRID_PROB_03h,
            "maxtries_vx_ensgrid_mean_06h": MAXTRIES_VX_ENSGRID_MEAN_06h,
            "maxtries_vx_ensgrid_prob_06h": MAXTRIES_VX_ENSGRID_PROB_06h,
            "maxtries_vx_ensgrid_mean_24h": MAXTRIES_VX_ENSGRID_MEAN_24h,
            "maxtries_vx_ensgrid_prob_24h": MAXTRIES_VX_ENSGRID_PROB_24h,
            "maxtries_vx_ensgrid_prob_refc": MAXTRIES_VX_ENSGRID_PROB_REFC,
            "maxtries_vx_ensgrid_prob_retop": MAXTRIES_VX_ENSGRID_PROB_RETOP,
            "maxtries_vx_enspoint": MAXTRIES_VX_ENSPOINT,
            "maxtries_vx_enspoint_mean": MAXTRIES_VX_ENSPOINT_MEAN,
            "maxtries_vx_enspoint_prob": MAXTRIES_VX_ENSPOINT_PROB,
            #
            # Flags that specify whether to run the preprocessing or
            # verification-related tasks.
            #
            "run_task_make_grid": RUN_TASK_MAKE_GRID,
            "run_task_make_orog": RUN_TASK_MAKE_OROG,
            "run_task_make_sfc_climo": RUN_TASK_MAKE_SFC_CLIMO,
            "run_task_get_extrn_ics": RUN_TASK_GET_EXTRN_ICS,
            "run_task_get_extrn_lbcs": RUN_TASK_GET_EXTRN_LBCS,
            "run_task_make_ics": RUN_TASK_MAKE_ICS,
            "run_task_make_lbcs": RUN_TASK_MAKE_LBCS,
            "run_task_run_fcst": RUN_TASK_RUN_FCST,
            "run_task_run_post": RUN_TASK_RUN_POST,
            "run_task_get_obs_ccpa": RUN_TASK_GET_OBS_CCPA,
            "run_task_get_obs_mrms": RUN_TASK_GET_OBS_MRMS,
            "run_task_get_obs_ndas": RUN_TASK_GET_OBS_NDAS,
            "run_task_vx_gridstat": RUN_TASK_VX_GRIDSTAT,
            "run_task_vx_pointstat": RUN_TASK_VX_POINTSTAT,
            "run_task_vx_ensgrid": RUN_TASK_VX_ENSGRID,
            "run_task_vx_enspoint": RUN_TASK_VX_ENSPOINT,
            #
            # Number of physical cores per node for the current machine.
            #
            "ncores_per_node": NCORES_PER_NODE,
            #
            # Directories and files.
            #
            "exptdir": EXPTDIR,
            "jobsdir": JOBSdir,
            "logdir": LOGDIR,
            "scriptsdir": SCRIPTSdir,
            "comin_basedir": COMIN_BASEDIR,
            "comout_basedir": COMOUT_BASEDIR,
            "global_var_defns_fp": GLOBAL_VAR_DEFNS_FP,
            "load_modules_run_task_fp": LOAD_MODULES_RUN_TASK_FP,
            #
            # External model information for generating ICs and LBCs.
            #
            "extrn_mdl_name_ics": EXTRN_MDL_NAME_ICS,
            "extrn_mdl_name_lbcs": EXTRN_MDL_NAME_LBCS,
            #
            # Parameters that determine the set of cycles to run.
            #
            "date_first_cycl": date_to_str(DATE_FIRST_CYCL, format="%Y%m%d%H00"),
            "date_last_cycl": date_to_str(DATE_LAST_CYCL, format="%Y%m%d%H00"),
            "cdate_first_cycl": DATE_FIRST_CYCL,
            "cycl_freq": f"{INCR_CYCL_FREQ:02d}:00:00",
            #
            # Forecast length (same for all cycles).
            #
            "fcst_len_hrs": FCST_LEN_HRS,
            #
            # Inline post
            #
            "write_dopost": WRITE_DOPOST,
            #
            # METPlus-specific information
            #
            "model": MODEL,
            "met_install_dir": MET_INSTALL_DIR,
            "met_bin_exec": MET_BIN_EXEC,
            "metplus_path": METPLUS_PATH,
            "vx_config_dir": VX_CONFIG_DIR,
            "metplus_conf": METPLUS_CONF,
            "met_config": MET_CONFIG,
            "ccpa_obs_dir": CCPA_OBS_DIR,
            "mrms_obs_dir": MRMS_OBS_DIR,
            "ndas_obs_dir": NDAS_OBS_DIR,
            #
            # Ensemble-related parameters.
            #
            "do_ensemble": DO_ENSEMBLE,
            "num_ens_members": NUM_ENS_MEMBERS,
            "ndigits_ensmem_names": f"{NDIGITS_ENSMEM_NAMES}",
            "ensmem_indx_name": ensmem_indx_name,
            "uscore_ensmem_name": uscore_ensmem_name,
            "slash_ensmem_subdir": slash_ensmem_subdir,
            #
            # Parameters associated with subhourly post-processed output
            #
            "sub_hourly_post": SUB_HOURLY_POST,
            "delta_min": DT_SUBHOURLY_POST_MNTS,
            "first_fv3_file_tstr": f"000:{time_str}",
        }
        # End of "settings" variable.
        settings_str = cfg_to_yaml_str(settings)

        logging.info(
            dedent(
                f"""
                The variable \"settings\" specifying values of the rococo XML variables
                has been set as follows:
                #-----------------------------------------------------------------------
                settings =\n\n"""
            )
            + settings_str,
        )

        #
        # Call the python script to generate the experiment's actual XML file
        # from the jinja template file.
        #
        try:
            fill_jinja_template(
                ["-q", "-u", settings_str, "-t", template_xml_fp, "-o", WFLOW_XML_FP]
            )
        except:
            logging.exception(
                dedent(
                    f"""
                Call to python script fill_jinja_template.py to create a rocoto workflow
                XML file from a template file failed.  Parameters passed to this script
                are:
                  Full path to template rocoto XML file:
                    template_xml_fp = \"{template_xml_fp}\"
                  Full path to output rocoto XML file:
                    WFLOW_XML_FP = \"{WFLOW_XML_FP}\"
                  Namelist settings specified on command line:\n
                    settings =\n\n"""
                )
                + settings_str
            )
    #
    # -----------------------------------------------------------------------
    #
    # Create a symlink in the experiment directory that points to the workflow
    # (re)launch script.
    #
    # -----------------------------------------------------------------------
    #
    logging.info(
        f'''
        Creating symlink in the experiment directory (EXPTDIR) that points to the
        workflow launch script (WFLOW_LAUNCH_SCRIPT_FP):
          EXPTDIR = \"{EXPTDIR}\"
          WFLOW_LAUNCH_SCRIPT_FP = \"{WFLOW_LAUNCH_SCRIPT_FP}\"''',
    )

    create_symlink_to_file(
        WFLOW_LAUNCH_SCRIPT_FP, os.path.join(EXPTDIR, WFLOW_LAUNCH_SCRIPT_FN), False
    )
    #
    # -----------------------------------------------------------------------
    #
    # If USE_CRON_TO_RELAUNCH is set to TRUE, add a line to the user's cron
    # table to call the (re)launch script every CRON_RELAUNCH_INTVL_MNTS mi-
    # nutes.
    #
    # -----------------------------------------------------------------------
    #
    if USE_CRON_TO_RELAUNCH:
        add_crontab_line()
    #
    # -----------------------------------------------------------------------
    #
    # Create the FIXam directory under the experiment directory.  In NCO mode,
    # this will be a symlink to the directory specified in FIXgsm, while in
    # community mode, it will be an actual directory with files copied into
    # it from FIXgsm.
    #
    # -----------------------------------------------------------------------
    #

    #
    # Symlink fix files
    #
    if SYMLINK_FIX_FILES:

        logging.info(
            f'''
            Symlinking fixed files from system directory (FIXgsm) to a subdirectory (FIXam):
              FIXgsm = \"{FIXgsm}\"
              FIXam = \"{FIXam}\"''',
        )

        ln_vrfy(f'''-fsn "{FIXgsm}" "{FIXam}"''')
    #
    # Copy relevant fix files.
    #
    else:

        logging.info(
            f'''
            Copying fixed files from system directory (FIXgsm) to a subdirectory (FIXam):
              FIXgsm = \"{FIXgsm}\"
              FIXam = \"{FIXam}\"''',
        )

        check_for_preexist_dir_file(FIXam, "delete")
        mkdir_vrfy("-p", FIXam)
        mkdir_vrfy("-p", os.path.join(FIXam, "fix_co2_proj"))

        num_files = len(FIXgsm_FILES_TO_COPY_TO_FIXam)
        for i in range(num_files):
            fn = f"{FIXgsm_FILES_TO_COPY_TO_FIXam[i]}"
            cp_vrfy(os.path.join(FIXgsm, fn), os.path.join(FIXam, fn))
    #
    # -----------------------------------------------------------------------
    #
    # Copy MERRA2 aerosol climatology data.
    #
    # -----------------------------------------------------------------------
    #
    if USE_MERRA_CLIMO:
        logging.info(
            f'''
            Copying MERRA2 aerosol climatology data files from system directory
            (FIXaer/FIXlut) to a subdirectory (FIXclim) in the experiment directory:
              FIXaer = \"{FIXaer}\"
              FIXlut = \"{FIXlut}\"
              FIXclim = \"{FIXclim}\"''',
        )

        check_for_preexist_dir_file(FIXclim, "delete")
        mkdir_vrfy("-p", FIXclim)

        if SYMLINK_FIX_FILES:
            ln_vrfy("-fsn", os.path.join(FIXaer, "merra2.aerclim*.nc"), FIXclim)
            ln_vrfy("-fsn", os.path.join(FIXlut, "optics*.dat"), FIXclim)
        else:
            cp_vrfy(os.path.join(FIXaer, "merra2.aerclim*.nc"), FIXclim)
            cp_vrfy(os.path.join(FIXlut, "optics*.dat"), FIXclim)
    #
    # -----------------------------------------------------------------------
    #
    # Copy templates of various input files to the experiment directory.
    #
    # -----------------------------------------------------------------------
    #
    logging.info(
        f"""
        Copying templates of various input files to the experiment directory...""",
    )

    logging.info(
        f"""
        Copying the template data table file to the experiment directory...""",
    )
    cp_vrfy(DATA_TABLE_TMPL_FP, DATA_TABLE_FP)

    logging.info(
        f"""
        Copying the template field table file to the experiment directory...""",
    )
    cp_vrfy(FIELD_TABLE_TMPL_FP, FIELD_TABLE_FP)

    logging.info(
        f"""
        Copying the template NEMS configuration file to the experiment directory...""",
    )
    cp_vrfy(NEMS_CONFIG_TMPL_FP, NEMS_CONFIG_FP)
    #
    # Copy the CCPP physics suite definition file from its location in the
    # clone of the FV3 code repository to the experiment directory (EXPT-
    # DIR).
    #
    logging.info(
        f"""
        Copying the CCPP physics suite definition XML file from its location in
        the forecast model directory sturcture to the experiment directory...""",
    )
    cp_vrfy(CCPP_PHYS_SUITE_IN_CCPP_FP, CCPP_PHYS_SUITE_FP)
    #
    # Copy the field dictionary file from its location in the
    # clone of the FV3 code repository to the experiment directory (EXPT-
    # DIR).
    #
    logging.info(
        f"""
        Copying the field dictionary file from its location in the forecast
        model directory sturcture to the experiment directory...""",
    )
    cp_vrfy(FIELD_DICT_IN_UWM_FP, FIELD_DICT_FP)
    #
    # -----------------------------------------------------------------------
    #
    # Set parameters in the FV3-LAM namelist file.
    #
    # -----------------------------------------------------------------------
    #
    logging.info(
        f'''
        Setting parameters in weather model's namelist file (FV3_NML_FP):
        FV3_NML_FP = \"{FV3_NML_FP}\"'''
    )
    #
    # Set npx and npy, which are just NX plus 1 and NY plus 1, respectively.
    # These need to be set in the FV3-LAM Fortran namelist file.  They represent
    # the number of cell vertices in the x and y directions on the regional
    # grid.
    #
    npx = NX + 1
    npy = NY + 1
    #
    # For the physics suites that use RUC LSM, set the parameter kice to 9,
    # Otherwise, leave it unspecified (which means it gets set to the default
    # value in the forecast model).
    #
    # NOTE:
    # May want to remove kice from FV3.input.yml (and maybe input.nml.FV3).
    #
    kice = None
    if SDF_USES_RUC_LSM:
        kice = 9
    #
    # Set lsoil, which is the number of input soil levels provided in the
    # chgres_cube output NetCDF file.  This is the same as the parameter
    # nsoill_out in the namelist file for chgres_cube.  [On the other hand,
    # the parameter lsoil_lsm (not set here but set in input.nml.FV3 and/or
    # FV3.input.yml) is the number of soil levels that the LSM scheme in the
    # forecast model will run with.]  Here, we use the same approach to set
    # lsoil as the one used to set nsoill_out in exregional_make_ics.sh.
    # See that script for details.
    #
    # NOTE:
    # May want to remove lsoil from FV3.input.yml (and maybe input.nml.FV3).
    # Also, may want to set lsm here as well depending on SDF_USES_RUC_LSM.
    #
    lsoil = 4
    if (EXTRN_MDL_NAME_ICS == "HRRR" or EXTRN_MDL_NAME_ICS == "RAP") and (
        SDF_USES_RUC_LSM
    ):
        lsoil = 9
    #
    # Create a multiline variable that consists of a yaml-compliant string
    # specifying the values that the namelist variables that are physics-
    # suite-independent need to be set to.  Below, this variable will be
    # passed to a python script that will in turn set the values of these
    # variables in the namelist file.
    #
    # IMPORTANT:
    # If we want a namelist variable to be removed from the namelist file,
    # in the "settings" variable below, we need to set its value to the
    # string "null".  This is equivalent to setting its value to
    #    !!python/none
    # in the base namelist file specified by FV3_NML_BASE_SUITE_FP or the
    # suite-specific yaml settings file specified by FV3_NML_YAML_CONFIG_FP.
    #
    # It turns out that setting the variable to an empty string also works
    # to remove it from the namelist!  Which is better to use??
    #
    settings = {}
    settings["atmos_model_nml"] = {
        "blocksize": BLOCKSIZE,
        "ccpp_suite": CCPP_PHYS_SUITE,
    }
    settings["fv_core_nml"] = {
        "target_lon": LON_CTR,
        "target_lat": LAT_CTR,
        "nrows_blend": HALO_BLEND,
        #
        # Question:
        # For a ESGgrid type grid, what should stretch_fac be set to?  This depends
        # on how the FV3 code uses the stretch_fac parameter in the namelist file.
        # Recall that for a ESGgrid, it gets set in the function set_gridparams_ESGgrid(.sh)
        # to something like 0.9999, but is it ok to set it to that here in the
        # FV3 namelist file?
        #
        "stretch_fac": STRETCH_FAC,
        "npx": npx,
        "npy": npy,
        "layout": [LAYOUT_X, LAYOUT_Y],
        "bc_update_interval": LBC_SPEC_INTVL_HRS,
    }
    settings["gfs_physics_nml"] = {
        "kice": kice or None,
        "lsoil": lsoil or None,
        "do_shum": DO_SHUM,
        "do_sppt": DO_SPPT,
        "do_skeb": DO_SKEB,
        "do_spp": DO_SPP,
        "n_var_spp": N_VAR_SPP,
        "n_var_lndp": N_VAR_LNDP,
        "lndp_type": LNDP_TYPE,
        "fhcyc": FHCYC_LSM_SPP_OR_NOT,
    }
    #
    # Add to "settings" the values of those namelist variables that specify
    # the paths to fixed files in the FIXam directory.  As above, these namelist
    # variables are physcs-suite-independent.
    #
    # Note that the array FV3_NML_VARNAME_TO_FIXam_FILES_MAPPING contains
    # the mapping between the namelist variables and the names of the files
    # in the FIXam directory.  Here, we loop through this array and process
    # each element to construct each line of "settings".
    #
    dummy_run_dir = os.path.join(EXPTDIR, "any_cyc")
    if DO_ENSEMBLE:
        dummy_run_dir = os.path.join(dummy_run_dir, "any_ensmem")

    regex_search = "^[ ]*([^| ]+)[ ]*[|][ ]*([^| ]+)[ ]*$"
    num_nml_vars = len(FV3_NML_VARNAME_TO_FIXam_FILES_MAPPING)
    namsfc_dict = {}
    for i in range(num_nml_vars):

        mapping = f"{FV3_NML_VARNAME_TO_FIXam_FILES_MAPPING[i]}"
        tup = find_pattern_in_str(regex_search, mapping)
        nml_var_name = tup[0]
        FIXam_fn = tup[1]

        fp = '""'
        if FIXam_fn:
            fp = os.path.join(FIXam, FIXam_fn)
            #
            # If not in NCO mode, for portability and brevity, change fp so that it
            # is a relative path (relative to any cycle directory immediately under
            # the experiment directory).
            #
            if RUN_ENVIR != "nco":
                fp = os.path.relpath(os.path.realpath(fp), start=dummy_run_dir)
        #
        # Add a line to the variable "settings" that specifies (in a yaml-compliant
        # format) the name of the current namelist variable and the value it should
        # be set to.
        #
        namsfc_dict[nml_var_name] = fp
    #
    # Add namsfc_dict to settings
    #
    settings["namsfc"] = namsfc_dict
    #
    # Use netCDF4 when running the North American 3-km domain due to file size.
    #
    if PREDEF_GRID_NAME == "RRFS_NA_3km":
        settings["fms2_io_nml"] = {"netcdf_default_format": "netcdf4"}
    #
    # Add the relevant tendency-based stochastic physics namelist variables to
    # "settings" when running with SPPT, SHUM, or SKEB turned on. If running
    # with SPP or LSM SPP, set the "new_lscale" variable.  Otherwise only
    # include an empty "nam_stochy" stanza.
    #
    nam_stochy_dict = {}
    if DO_SPPT:
        nam_stochy_dict.update(
            {
                "iseed_sppt": ISEED_SPPT,
                "new_lscale": NEW_LSCALE,
                "sppt": SPPT_MAG,
                "sppt_logit": SPPT_LOGIT,
                "sppt_lscale": SPPT_LSCALE,
                "sppt_sfclimit": SPPT_SFCLIMIT,
                "sppt_tau": SPPT_TSCALE,
                "spptint": SPPT_INT,
                "use_zmtnblck": USE_ZMTNBLCK,
            }
        )

    if DO_SHUM:
        nam_stochy_dict.update(
            {
                "iseed_shum": ISEED_SHUM,
                "new_lscale": NEW_LSCALE,
                "shum": SHUM_MAG,
                "shum_lscale": SHUM_LSCALE,
                "shum_tau": SHUM_TSCALE,
                "shumint": SHUM_INT,
            }
        )

    if DO_SKEB:
        nam_stochy_dict.update(
            {
                "iseed_skeb": ISEED_SKEB,
                "new_lscale": NEW_LSCALE,
                "skeb": SKEB_MAG,
                "skeb_lscale": SKEB_LSCALE,
                "skebnorm": SKEBNORM,
                "skeb_tau": SKEB_TSCALE,
                "skebint": SKEB_INT,
                "skeb_vdof": SKEB_VDOF,
            }
        )

    if DO_SPP or DO_LSM_SPP:
        nam_stochy_dict.update({"new_lscale": NEW_LSCALE})

    settings["nam_stochy"] = nam_stochy_dict
    #
    # Add the relevant SPP namelist variables to "settings" when running with
    # SPP turned on.  Otherwise only include an empty "nam_sppperts" stanza.
    #
    nam_sppperts_dict = {}
    if DO_SPP:
        nam_sppperts_dict = {
            "iseed_spp": ISEED_SPP,
            "spp_lscale": SPP_LSCALE,
            "spp_prt_list": SPP_MAG_LIST,
            "spp_sigtop1": SPP_SIGTOP1,
            "spp_sigtop2": SPP_SIGTOP2,
            "spp_stddev_cutoff": SPP_STDDEV_CUTOFF,
            "spp_tau": SPP_TSCALE,
            "spp_var_list": SPP_VAR_LIST,
        }

    settings["nam_sppperts"] = nam_sppperts_dict
    #
    # Add the relevant LSM SPP namelist variables to "settings" when running with
    # LSM SPP turned on.
    #
    nam_sfcperts_dict = {}
    if DO_LSM_SPP:
        nam_sfcperts_dict = {
            "lndp_type": LNDP_TYPE,
            "lndp_model_type": LNDP_MODEL_TYPE,
            "lndp_tau": LSM_SPP_TSCALE,
            "lndp_lscale": LSM_SPP_LSCALE,
            "iseed_lndp": ISEED_LSM_SPP,
            "lndp_var_list": LSM_SPP_VAR_LIST,
            "lndp_prt_list": LSM_SPP_MAG_LIST,
        }

    settings["nam_sfcperts"] = nam_sfcperts_dict

    settings_str = cfg_to_yaml_str(settings)

    logging.info(
        dedent(
            f"""
            The variable \"settings\" specifying values of the weather model's
            namelist variables has been set as follows:

            settings =\n\n"""
        )
        + settings_str,
    )
    #
    # -----------------------------------------------------------------------
    #
    # Call the set_namelist.py script to create a new FV3 namelist file (full
    # path specified by FV3_NML_FP) using the file FV3_NML_BASE_SUITE_FP as
    # the base (i.e. starting) namelist file, with physics-suite-dependent
    # modifications to the base file specified in the yaml configuration file
    # FV3_NML_YAML_CONFIG_FP (for the physics suite specified by CCPP_PHYS_SUITE),
    # and with additional physics-suite-independent modificaitons specified
    # in the variable "settings" set above.
    #
    # -----------------------------------------------------------------------
    #
    try:
        set_namelist(
            [
                "-q",
                "-n",
                FV3_NML_BASE_SUITE_FP,
                "-c",
                FV3_NML_YAML_CONFIG_FP,
                CCPP_PHYS_SUITE,
                "-u",
                settings_str,
                "-o",
                FV3_NML_FP,
            ]
        )
    except:
        logging.exception(
            dedent(
                f"""
            Call to python script set_namelist.py to generate an FV3 namelist file
            failed.  Parameters passed to this script are:
              Full path to base namelist file:
                FV3_NML_BASE_SUITE_FP = \"{FV3_NML_BASE_SUITE_FP}\"
              Full path to yaml configuration file for various physics suites:
                FV3_NML_YAML_CONFIG_FP = \"{FV3_NML_YAML_CONFIG_FP}\"
              Physics suite to extract from yaml configuration file:
                CCPP_PHYS_SUITE = \"{CCPP_PHYS_SUITE}\"
              Full path to output namelist file:
                FV3_NML_FP = \"{FV3_NML_FP}\"
              Namelist settings specified on command line:\n
                settings =\n\n"""
            )
            + settings_str
        )
    #
    # If not running the MAKE_GRID_TN task (which implies the workflow will
    # use pregenerated grid files), set the namelist variables specifying
    # the paths to surface climatology files.  These files are located in
    # (or have symlinks that point to them) in the FIXlam directory.
    #
    # Note that if running the MAKE_GRID_TN task, this action usually cannot
    # be performed here but must be performed in that task because the names
    # of the surface climatology files depend on the CRES parameter (which is
    # the C-resolution of the grid), and this parameter is in most workflow
    # configurations is not known until the grid is created.
    #
    if not RUN_TASK_MAKE_GRID:

        set_FV3nml_sfc_climo_filenames()

    # Call script to get NOMADS data
    if NOMADS:
        get_nomads_data(NOMADS_file_type,EXPTDIR,USHdir,DATE_FIRST_CYCL,CYCL_HRS,FCST_LEN_HRS,LBC_SPEC_INTVL_HRS)

    #
    # -----------------------------------------------------------------------
    #
    # To have a record of how this experiment/workflow was generated, copy
    # the experiment/workflow configuration file to the experiment directo-
    # ry.
    #
    # -----------------------------------------------------------------------
    #
    cp_vrfy(os.path.join(USHdir, EXPT_CONFIG_FN), EXPTDIR)
    #
    # -----------------------------------------------------------------------
    #
    # For convenience, print out the commands that need to be issued on the
    # command line in order to launch the workflow and to check its status.
    # Also, print out the line that should be placed in the user's cron table
    # in order for the workflow to be continually resubmitted.
    #
    # -----------------------------------------------------------------------
    #
    if WORKFLOW_MANAGER == "rocoto":
        wflow_db_fn = f"{os.path.splitext(WFLOW_XML_FN)[0]}.db"
        rocotorun_cmd = f"rocotorun -w {WFLOW_XML_FN} -d {wflow_db_fn} -v 10"
        rocotostat_cmd = f"rocotostat -w {WFLOW_XML_FN} -d {wflow_db_fn} -v 10"

    logging.info(
        f"""
        ========================================================================
        ========================================================================

        Experiment generation completed.  The experiment directory is:

          EXPTDIR=\"{EXPTDIR}\"

        ========================================================================
        ========================================================================
        """
    )
    #
    # -----------------------------------------------------------------------
    #
    # If rocoto is required, print instructions on how to load and use it
    #
    # -----------------------------------------------------------------------
    #
    if WORKFLOW_MANAGER == "rocoto":

        logging.info(
            f"""
            To launch the workflow, first ensure that you have a compatible version
            of rocoto available. For most pre-configured platforms, rocoto can be
            loaded via a module:

              > module load rocoto

            For more details on rocoto, see the User's Guide.

            To launch the workflow, first ensure that you have a compatible version
            of rocoto loaded.  For example, to load version 1.3.1 of rocoto, use

              > module load rocoto/1.3.1

            (This version has been tested on hera; later versions may also work but
            have not been tested.)

            To launch the workflow, change location to the experiment directory
            (EXPTDIR) and issue the rocotrun command, as follows:

              > cd {EXPTDIR}
              > {rocotorun_cmd}

            To check on the status of the workflow, issue the rocotostat command
            (also from the experiment directory):

              > {rocotostat_cmd}

            Note that:

            1) The rocotorun command must be issued after the completion of each
               task in the workflow in order for the workflow to submit the next
               task(s) to the queue.

            2) In order for the output of the rocotostat command to be up-to-date,
               the rocotorun command must be issued immediately before issuing the
               rocotostat command.

            For automatic resubmission of the workflow (say every 3 minutes), the
            following line can be added to the user's crontab (use \"crontab -e\" to
            edit the cron table):

            */{CRON_RELAUNCH_INTVL_MNTS} * * * * cd {EXPTDIR} && ./launch_FV3LAM_wflow.sh called_from_cron=\"TRUE\"
            """
        )

    # If we got to this point everything was successful: move the log file to the experiment directory.
    mv_vrfy(logfile, EXPTDIR)

def get_nomads_data(NOMADS_file_type,EXPTDIR,USHdir,DATE_FIRST_CYCL,CYCL_HRS,FCST_LEN_HRS,LBC_SPEC_INTVL_HRS):
    print("Getting NOMADS online data")
    print(f"NOMADS_file_type= {NOMADS_file_type}")
    cd_vrfy(EXPTDIR)
    NOMADS_script = os.path.join(USHdir, "NOMADS_get_extrn_mdl_files.sh")
    # run_command(f"""{NOMADS_script} {date_to_str(DATE_FIRST_CYCL,format="%Y%m%d")} \
    #                 {date_to_str(DATE_FIRST_CYCL,format="%H")} {NOMADS_file_type} {FCST_LEN_HRS} {LBC_SPEC_INTVL_HRS}""")
    raise Exception("Nomads script does not work")

def setup_logging(logfile: str = 'log.generate_FV3LAM_wflow') -> None:
    """
    Sets up logging, printing high-priority (INFO and higher) messages to screen, and printing all
    messages with detailed timing and routine info in the specified text file.
    """
    logging.basicConfig(level=logging.DEBUG,
                        format='%(name)-12s %(levelname)-8s %(message)s',
                        filename=logfile,
                        filemode='w')
    logging.debug(f'Finished setting up debug file logging in {logfile}')
    console = logging.StreamHandler()
    console.setLevel(logging.INFO)
    logging.getLogger().addHandler(console)
    logging.debug('Logging set up successfully')

if __name__ == "__main__":

    USHdir = os.path.dirname(os.path.abspath(__file__))
    logfile=f'{USHdir}/log.generate_FV3LAM_wflow'

    # Call the generate_FV3LAM_wflow function defined above to generate the
    # experiment/workflow.
    try:
        generate_FV3LAM_wflow(USHdir, logfile)
    except:
        # If the call to the generate_FV3LAM_wflow function above was not successful, 
        # print out an error message and exit with a nonzero return code.
        logging.exception(dedent(
            f"""
            *********************************************************************
            Experiment generation failed. See the error message(s) printed below.
            For more detailed information, check the log file from the workflow
            generation script: {logfile}
            *********************************************************************\n
            """
        ))

class Testing(unittest.TestCase):
    def test_generate_FV3LAM_wflow(self):

        USHdir = os.path.dirname(os.path.abspath(__file__))
        logfile='log.generate_FV3LAM_wflow'
        SED = get_env_var("SED")

        # community test case
        cp_vrfy(f"{USHdir}/config.community.yaml", f"{USHdir}/config.yaml")
        run_command(f"""{SED} -i 's/MACHINE: hera/MACHINE: linux/g' {USHdir}/config.yaml""")
        generate_FV3LAM_wflow(USHdir, logfile)

        # nco test case
        set_env_var("OPSROOT", f"{USHdir}/../../nco_dirs")
        cp_vrfy(f"{USHdir}/config.nco.yaml", f"{USHdir}/config.yaml")
        run_command(f"""{SED} -i 's/MACHINE: hera/MACHINE: linux/g' {USHdir}/config.yaml""")
        generate_FV3LAM_wflow(USHdir, logfile)

    def setUp(self):
        define_macos_utilities()
        set_env_var("DEBUG", False)
        set_env_var("VERBOSE", False)
