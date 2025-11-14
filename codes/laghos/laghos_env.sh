#!/bin/bash
export WORKSPACE_DIR=$1

export BUILD_DIR=build
export INSTALL_DIR=install

export ZLIB_ROOT=$WORKSPACE_DIR/zlib
export ZLIB_INSTALL_DIR=$ZLIB_ROOT/$INSTALL_DIR

export METIS_ROOT=$WORKSPACE_DIR/metis
export METIS_BUILD_DIR=$METIS_ROOT/$BUILD_DIR
export METIS_INSTALL_DIR=$METIS_ROOT/$INSTALL_DIR

export ADIAK_ROOT=$WORKSPACE_DIR/Adiak
export ADIAK_BUILD_DIR=$ADIAK_ROOT/$BUILD_DIR
export ADIAK_INSTALL_DIR=$ADIAK_ROOT/$INSTALL_DIR

export CALIPER_ROOT=$WORKSPACE_DIR/Caliper
export CALIPER_BUILD_DIR=$CALIPER_ROOT/$BUILD_DIR
export CALIPER_INSTALL_DIR=$CALIPER_ROOT/$INSTALL_DIR

export FMT_ROOT=$WORKSPACE_DIR/fmt
export FMT_BUILD_DIR=$FMT_ROOT/$BUILD_DIR
export FMT_INSTALL_DIR=$FMT_ROOT/$INSTALL_DIR

export CAMP_ROOT=$WORKSPACE_DIR/camp
export CAMP_BUILD_DIR=$CAMP_ROOT/$BUILD_DIR
export CAMP_INSTALL_DIR=$CAMP_ROOT/$INSTALL_DIR

export UMPIRE_ROOT=$WORKSPACE_DIR/Umpire
export UMPIRE_BUILD_DIR=$UMPIRE_ROOT/$BUILD_DIR
export UMPIRE_INSTALL_DIR=$UMPIRE_ROOT/$INSTALL_DIR

export HYPRE_ROOT=$WORKSPACE_DIR/hypre
export HYPRE_BUILD_DIR=$HYPRE_ROOT/$BUILD_DIR
export HYPRE_INSTALL_DIR=$HYPRE_ROOT/$INSTALL_DIR

export MFEM_ROOT=$WORKSPACE_DIR/mfem
export MFEM_INSTALL_DIR=$MFEM_ROOT/$INSTALL_DIR

export LAGHOS_ROOT=$WORKSPACE_DIR/Laghos

export OMP_NUM_THREADS="1";
export MPICH_GPU_SUPPORT_ENABLED=1
export MFEM_GPU_AWARE_MPI=1

export CRAYPE_DIR=/opt/cray/pe
export CC_DIR=$CRAYPE_DIR/cce/20.0.0
export CC=$CC_DIR/bin/craycc
export CXX=$CC_DIR/bin/crayCC
export MPI_ROOT=/opt/cray/pe/mpich/9.0.1
export MPI_DIR=$MPI_ROOT/ofi/crayclang/20.0
export MPI_LIB_DIRS="$MPI_DIR/lib $MPI_ROOT/gtl/lib"
export MPI_LIBS="mpi mpi_gtl_hsa"
export MPICC=$MPI_DIR/bin/mpicc
export MPICXX=$MPI_DIR/bin/mpicxx
export MPIF90=$MPI_DIR/bin/mpif90
export ROCM_PATH=/opt/rocm-6.4.2
export ROCM_ARCH=gfx942
export HIPCC=$ROCM_PATH/bin/hipcc
export PYTHON_DIR=/usr/tce/packages/python/python-3.9.12
export BLAS_LAPACK_LIBS="mkl_intel_lp64 mkl_sequential mkl_core pthread m dl"
export BLAS_LAPACK_LIBS_FLAGS="-lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl"
export BLAS_LAPACK_LIB_DIRS=/opt/intel/oneapi/mkl/2023.2.0/lib/intel64
export PATH=$ROCM_PATH/bin:$PATH
