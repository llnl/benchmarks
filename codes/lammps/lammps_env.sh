#!/bin/bash
export WORKSPACE_DIR=$1

export BUILD_DIR=build
export INSTALL_DIR=install

export ZLIB_ROOT=$WORKSPACE_DIR/zib
export ZLIB_DIR=$ZLIB_ROOT/$INSTALL_DIR

export CNPY_ROOT=$WORKSPACE_DIR/cnpy
export CNPY_DIR=$CNPY_ROOT/$INSTALL_DIR

export YAMLCPP_ROOT=$WORKSPACE_DIR/yaml-cpp
export YAMLCPP_DIR=$YAMLCPP_ROOT/$INSTALL_DIR

export PACE_ROOT=$WORKSPACE_DIR/lammps-user-pace
export PACE_DIR=$PACE_ROOT/$INSTALL_DIR

export KOKKOS_ROOT=$WORKSPACE_DIR/kokkos
export KOKKOS_DIR=$KOKKOS_ROOT/$INSTALL_DIR

export LAMMPS_ROOT=$WORKSPACE_DIR/lammps
export LAMMPS_DIR=$LAMMPS_ROOT/$INSTALL_DIR

export OMP_NUM_THREADS=1
export HSA_XNACK=1
export MPICH_GPU_SUPPORT_ENABLED=1

export COMPILER_ROOT=/opt/cray/pe/cce/20.0.0
export CC=$COMPILER_ROOT/bin/craycc
export CXX=$COMPILER_ROOT/bin/crayCC
export MPI_BASE=/opt/cray/pe/mpich/9.0.1
export MPI_ROOT=$MPI_BASE/ofi/crayclang/20.0
export MPI_LIB_DIRS="-L$MPI_ROOT/lib -L$MPI_BASE/gtl/lib"
export MPI_LIBS="-lmpich -lmpi_gtl_hsa"
export FC=$MPI_ROOT/bin/mpif77
export MPICC=$MPI_ROOT/bin/mpicc
export MPICXX=$MPI_ROOT/bin/mpicxx
export MPIF77=$MPI_ROOT/bin/mpif77
export ROCM_PATH=/opt/rocm-6.4.0
# tioga
#export ROCM_ARCH=VEGA90A
# tuolumne
#export ROCM_ARCH=AMD_GFX942
# tuolumne APU mode
export ROCM_ARCH=AMD_GFX942_APU
export PATH=$ROCM_PATH/bin:$PATH

export LD_LIBRARY_PATH=$COMPILER_ROOT/cce/x86_64/lib:$MPI_ROOT/lib:$MPI_BASE/gtl/lib:/opt/cray/pe/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$ZLIB_DIR/lib:$CNPY_DIR/lib:$YAMLCPP_DIR/lib64:$PACE_DIR/lib64:$KOKKOS_DIR/lib64:$LAMMPS_DIR/lib64:$LD_LIBRARY_PATH
