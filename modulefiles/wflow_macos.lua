help([[
This module set a path needed to activate conda environement for running UFS SRW App on general macOS, following miniconda3 module and conda environments installations
]])

whatis([===[This module activates conda environment for running the UFS SRW App on macOS]===])

setenv("CMAKE_Platform", "macos")


load("conda")

-- add rocoto to path
local rocoto_path="/Users/username/rocoto"
prepend_path("PATH", pathJoin(rocoto_path,"bin"))

-- add fake slurm commands
local srw_path="/Users/username/ufs-srweather-app"
prepend_path("PATH", pathJoin(srw_path, "ush/rocoto_fake_slurm"))

prepend_path("MODULEPATH","/Users/username/miniconda3/modulefiles")
load(pathJoin("miniconda3", os.getenv("miniconda3_ver") or "23.9.0"))



-- display conda activation message
if mode() == "load" then
   LmodMsgRaw([===[Please do the following to activate conda virtual environment:

       > conda activate srw_app"

       > conda activate workflow_tools

]===])
end

