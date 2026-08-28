#!/bin/sh

# go into Spack environment
. "${SPACK_ROOT}/share/spack/setup-env.sh"
spack cd -e miniem-hops-env
spacktivate -p miniem-hops-env

export TRILINOS_SRC_DIR="${BUILD_BASE_DIR}/Trilinos"
export TRILINOS_BUILD_DIR="${BUILD_BASE_DIR}/Trilinos-build"

# get Trilinos if necessary
if test ! -d "${TRILINOS_SRC_DIR}" ; then
    git clone --branch develop git@github.com:trilinos/Trilinos "${TRILINOS_SRC_DIR}"
fi

# This is set in the load_spack_cuda.sh file.
export OMPI_CXX="${TRILINOS_SRC_DIR}/packages/kokkos/bin/nvcc_wrapper"

mkdir -p "${TRILINOS_BUILD_DIR}"
pushd "${TRILINOS_BUILD_DIR}"

rm -rf CMake*
cmake \
    -D Teuchos_ENABLE_DEBUG_RCP_NODE_TRACING=OFF \
    -G Ninja \
    -D Trilinos_ENABLE_Fortran:BOOL=OFF \
    -D PYTHON_EXECUTABLE:FILEPATH=python3 \
    -D CMAKE_INSTALL_PREFIX="$BUILD_BASE_DIR/install-trilinos" \
    -D Trilinos_ENABLE_EXPLICIT_INSTANTIATION:BOOL=ON \
    -D CMAKE_CXX_STANDARD="20" \
    -D Trilinos_ENABLE_CHECKED_STL:BOOL=OFF \
    -D Trilinos_ENABLE_TEUCHOS_TIME_MONITOR:BOOL=ON \
    -D Panzer_ENABLE_TEUCHOS_TIME_MONITOR:BOOL=ON \
    -D NOX_ENABLE_TEUCHOS_TIME_MONITOR:BOOL=ON \
    -D NOX_BUILD_PRERELEASE=ON \
    \
    -D NOX_ENABLE_TESTS=OFF \
    -D NOX_ENABLE_EXAMPLES=OFF \
    \
    -D Trilinos_ENABLE_INSTALL_CMAKE_CONFIG_FILES:BOOL=ON \
    -D Trilinos_ENABLE_ALL_PACKAGES:BOOL=OFF \
    -D Trilinos_ENABLE_ALL_OPTIONAL_PACKAGES:BOOL=OFF \
    -D Trilinos_ENABLE_EXAMPLES:BOOL=OFF \
    -D Trilinos_ENABLE_TESTS:BOOL=OFF \
    -D EpetraExt_ENABLE_HDF5:BOOL=OFF \
    -D Teuchos_ENABLE_FLOAT:BOOL=OFF \
    -D Teuchos_ENABLE_COMPLEX:BOOL=OFF \
    -D Teuchos_KOKKOS_PROFILING:BOOL=ON \
    -D Kokkos_ENABLE_PROFILING:BOOL=ON \
    -D Tpetra_INST_FLOAT:BOOL=OFF \
    -D Tpetra_INST_COMPLEX_FLOAT:BOOL=OFF \
    -D Tpetra_INST_COMPLEX_DOUBLE:BOOL=OFF \
    -D Tpetra_INST_INT_INT:BOOL=OFF \
    -D Xpetra_ENABLE_Epetra:BOOL=OFF \
    -D MueLu_ENABLE_Epetra:BOOL=OFF \
    -D Piro_ENABLE_MueLu:BOOL=OFF \
    -D SEACASExodus_ENABLE_MPI:BOOL=OFF \
    -D Trilinos_ENABLE_SEACASExodiff=ON \
    -D Trilinos_ENABLE_SEACASEpu=ON \
    -D Trilinos_ENABLE_SEACASNemspread=ON \
    -D Trilinos_ENABLE_SEACASNemslice=ON \
    -D Trilinos_ENABLE_SEACASAprepro:BOOL=ON \
    -D Trilinos_ENABLE_KokkosCore:BOOL=ON \
    -D Trilinos_ENABLE_KokkosAlgorithms:BOOL=ON \
    -D Trilinos_ENABLE_Tempus:BOOL=OFF \
    -D Trilinos_ENABLE_Zoltan2:BOOL=ON \
    -D Trilinos_ENABLE_Xpetra=ON \
    -D Trilinos_ENABLE_MueLu:BOOL=ON \
    -D MueLu_ENABLE_Kokkos_Refactor:BOOL=ON \
    -D Xpetra_ENABLE_Kokkos_Refactor:BOOL=ON \
    -D MueLu_ENABLE_Kokkos_Refactor_Use_By_Default:BOOL=ON \
    -D Trilinos_ENABLE_Ifpack2:BOOL=ON \
    -D Trilinos_ENABLE_Amesos2:BOOL=ON \
    -D Amesos2_ENABLE_LAPACK:BOOL=ON \
    -D Amesos2_ENABLE_KLU2:BOOL=ON \
    -D Trilinos_ENABLE_Pamgen:BOOL=ON \
    -D Intrepid2_ENABLE_TESTS=OFF \
    -D Phalanx_SHOW_DEPRECATED_WARNINGS:BOOL=ON \
    -D Phalanx_ENABLE_DEVICE_DAG=OFF \
    -D Phalanx_ENABLE_TESTS=OFF \
    -D Trilinos_ENABLE_Panzer:BOOL=ON \
    -D Trilinos_ENABLE_PanzerExprEval=ON \
    -D Sacado_ENABLE_HIERARCHICAL_DFAD=ON \
    -D Panzer_ENABLE_HESSIAN_SUPPORT:BOOL=OFF \
    -D Panzer_ENABLE_TESTS:BOOL=ON \
    -D Panzer_ENABLE_EXAMPLES:BOOL=ON \
    -D Trilinos_ENABLE_Percept=ON \
    -D Trilinos_ENABLE_SECONDARY_TESTED_CODE:BOOL=ON \
    -D Trilinos_ENABLE_TriKota:BOOL=OFF \
    -D TPL_ENABLE_MPI:BOOL=ON \
    -D MPI_EXEC_POST_NUMPROCS_FLAGS="-bind-to;None" \
    -D TPL_ENABLE_Boost:BOOL=OFF \
    -D TPL_ENABLE_HDF5:BOOL=ON \
    -D HDF5_INCLUDE_DIRS="$(spack location -i hdf5)/include" \
    -D HDF5_LIBRARY_DIRS="$(spack location -i hdf5)/lib64" \
    -D TPL_ENABLE_Zlib:BOOL=ON \
    -D TPL_ENABLE_Netcdf:BOOL=ON \
    -DTPL_ENABLE_Matio=OFF \
    -DTPL_ENABLE_X11=OFF \
    -D CMAKE_CXX_COMPILER:FILEPATH="mpicxx" \
    -D CMAKE_C_COMPILER:FILEPATH="mpicc" \
    -D CMAKE_Fortran_COMPILER:FILEPATH="mpifort" \
    -D CMAKE_CXX_FLAGS:STRING="-g1 -Wshadow -Wall -fdiagnostics-color=always -Wno-deprecated-declarations" \
    -D CMAKE_C_FLAGS:STRING="-g1" \
    -D CMAKE_Fortran_FLAGS:STRING="-g1" \
    -D CMAKE_EXE_LINKER_FLAGS:STRING="-lgfortran" \
    -D CMAKE_VERBOSE_MAKEFILE:BOOL=OFF \
    -D Trilinos_VERBOSE_CONFIGURE:BOOL=OFF \
    -D CMAKE_BUILD_TYPE:STRING=Release \
    -D Trilinos_ENABLE_DEBUG=OFF \
    -D Trilinos_ENABLE_DEBUG_SYMBOLS:BOOL=OFF \
    -D Kokkos_ENABLE_DEBUG:BOOL=OFF \
    -D Phalanx_ENABLE_DEBUG=OFF \
    -D BUILD_SHARED_LIBS:BOOL=OFF \
    -D Trilinos_ENABLE_COVERAGE_TESTING:BOOL=OFF \
    -D Trilinos_ENABLE_OpenMP:BOOL=OFF \
    -D Tpetra_ENABLE_CUDA=ON \
    -D Tpetra_INST_CUDA=ON \
    -D Tpetra_INST_SERIAL=ON \
    -D TPL_ENABLE_CUDA=ON \
    -D TPL_ENABLE_CUSPARSE=ON \
    -D CUDA_cublas_LIBRARY=${CUDA_LIBS}/libcublas.so \
    -D CUDA_cusparse_LIBRARY=${CUDA_LIBS}/libcusparse.so \
    -D CUDA_cusolver_LIBRARY=${CUDA_LIBS}/libcusolver.so \
    -D CUDA_cufft_LIBRARY=${CUDA_LIBS}/libcufft.so \
    -D Kokkos_ENABLE_CUDA=ON \
    -D Kokkos_ENABLE_DEBUG_BOUNDS_CHECK=OFF \
    -D Kokkos_ENABLE_CUDA_RELOCATABLE_DEVICE_CODE=ON \
    -D Kokkos_ARCH_HOPPER90=ON \
    \
    -D Trilinos_PARALLEL_LINK_JOBS_LIMIT=12 \
    \
    -D TPL_ENABLE_HDF5=ON \
    -D TPL_ENABLE_Netcdf:BOOL=ON \
    \
    -D Trilinos_AUTOGENERATE_TEST_RESOURCE_FILE=OFF \
    -D Trilinos_CUDA_NUM_GPUS=4 \
    -D Trilinos_CUDA_SLOTS_PER_GPU=3 \
    \
    -D Panzer_ADD_EXPENSIVE_CUDA_TESTS=ON \
    -D TPL_ENABLE_gtest=OFF \
    \
    "${TRILINOS_SRC_DIR}"

## Prevents re-configure after a new configure.
touch build.ninja rules.ninja

ninja -j 32
ninja -j 8

popd

