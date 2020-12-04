#Setup instructions for CISL Cheyenne using Intel-19.1.1 (bash shell)

module purge
module load ncarenv/1.3
module load gnu/9.1.0
module load mpt/2.22
module load ncarcompilers/0.5.0
module load cmake/3.16.4


module use /glade/p/ral/jntp/GMTB/tools/hpc-stack-nco-20201113/modulefiles/stack
module load hpc/1.0.0-beta1
module load hpc-gnu/9.1.0
module load hpc-mpt/2.22
module load jasper/2.0.22
module load zlib/1.2.11
module load png/1.6.35
module load hdf5/1.10.6
module load netcdf/4.7.4
module load pio/2.5.1
module load esmf/8_1_0_beta_snapshot_27
module load bacio/2.4.1
module load crtm/2.3.0
module load g2/3.4.1
module load g2tmpl/1.9.1
module load ip/3.3.3
module load nemsio/2.5.2
module load sp/2.3.3
module load w3emc/2.7.3
module load w3nco/2.4.1
module load upp/10.0.0

module load gfsio/1.4.1
module load sfcio/1.4.1
module load landsfcutil/2.4.1
module load nemsiogfs/2.5.3
module load wgrib2/2.0.8

export CMAKE_C_COMPILER=mpicc
export CMAKE_CXX_COMPILER=mpicxx
export CMAKE_Fortran_COMPILER=mpif90
export CMAKE_Platform=cheyenne.gnu
