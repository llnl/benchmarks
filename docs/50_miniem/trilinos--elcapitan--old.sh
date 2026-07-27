#!/bin/sh

# go into Spack environment
. "${SPACK_ROOT}/share/spack/setup-env.sh"
spack cd -e miniem-ats4-env
spacktivate -p miniem-ats4-env

export TRILINOS_SRC_DIR="${BUILD_BASE_DIR}/Trilinos"
export TRILINOS_BUILD_DIR="${BUILD_BASE_DIR}/Trilinos-build"

mkdir -p "${TRILINOS_BUILD_DIR}"
pushd "${TRILINOS_BUILD_DIR}"

rm -rf CMake*
cmake \
 "-GNinja" \
 "-DPYTHON_EXECUTABLE=/usr/tce/bin/python3" \
 "-DCMAKE_BUILD_TYPE:STRING=Release" \
 "-DTrilinos_ENABLE_TrilinosBuildStats=OFF" \
 "-DTrilinos_ENABLE_BUILD_STATS=OFF" \
 "-DTrilinosBuildStats_ENABLE_TESTS=OFF" \
 "-DBUILD_SHARED_LIBS:BOOL=OFF" \
 "-DTrilinos_ENABLE_Teuchos=ON" \
 "-DPercept_ENABLE_TESTS=OFF" \
 "-DTrilinos_ENABLE_Panzer=ON" \
 "-DTrilinos_ENABLE_Percept=ON" \
 "-DIntrepid2_ENABLE_TESTS=OFF" \
 "-DTrilinos_ENABLE_PanzerMiniEM=ON" \
 "-DPanzerMiniEM_ENABLE_EXAMPLES=ON" \
 "-DPanzerMiniEM_ENABLE_TESTS=ON" \
 "-DIfpack2_ENABLE_EXAMPLES=ON" \
 "-DTpetra_INST_SERIAL:BOOL=OFF" \
 "-DKokkos_ENABLE_OPENMP:BOOL=OFF" \
 "-DTpetra_INST_OPENMP:BOOL=OFF" \
 "-DTrilinos_ENABLE_OpenMP:BOOL=OFF" \
 "-DKokkos_ENABLE_HIP:BOOL=ON" \
 "-DTpetra_INST_HIP:BOOL=ON" \
 "-DKOKKOSKERNELS_ENABLE_TPL_BLAS:BOOL=ON" \
 "-DKOKKOSKERNELS_ENABLE_TPL_LAPACK:BOOL=ON" \
 "-DSacado_ENABLE_HIERARCHICAL_DFAD=ON" \
 "-DKokkos_ARCH_AMD_GFX942_APU:BOOL=ON" \
 "-DKokkos_ARCH_NATIVE:BOOL=ON" \
 "-DCMAKE_EXE_LINKER_FLAGS=--offload-new-driver -x none --hip-link -Wl,--image-base=0x20000000 -Wl,-z,common-page-size=0x200000 -Wl,-z,max-page-size=0x200000 -Wl,--whole-archive,-lhugetlbfs,--no-whole-archive  " \
 "-DCMAKE_SHARED_LINKER_FLAGS=--offload-new-driver -x none --hip-link -Wl,--image-base=0x20000000 -Wl,-z,common-page-size=0x200000 -Wl,-z,max-page-size=0x200000 -Wl,--whole-archive,-lhugetlbfs,--no-whole-archive  " \
 "-DFC_FN_UNDERSCORE=UNDER" \
 "-DCMAKE_CXX_COMPILER=/opt/cray/pe/mpich/9.0.1/ofi/amd/6.0/bin/mpicxx" \
 "-DCMAKE_C_COMPILER=/opt/cray/pe/mpich/9.0.1/ofi/amd/6.0/bin/mpicc" \
 "-DCMAKE_Fortran_COMPILER=/opt/cray/pe/mpich/9.0.1/ofi/amd/6.0/bin/mpif90" \
 "-DCMAKE_CXX_FLAGS=--offload-new-driver -x hip -mllvm -amdgpu-early-inline-all=false -mllvm -amdgpu-function-calls=false -g " \
 "-DCMAKE_Fortran_FLAGS=" \
 "-DCMAKE_C_FLAGS=" \
 "-DCMAKE_LINKER=/opt/cray/pe/mpich/9.0.1/ofi/amd/6.0/bin/mpicxx" \
 "-DTrilinos_EXTRA_LINK_FLAGS=-L/opt/cray/pe/mpich/9.0.1/ofi/amd/6.0/lib -Wl,-rpath,/opt/cray/pe/mpich/9.0.1/ofi/amd/6.0/lib -lmpi_amd -lxpmem -L/opt/cray/pe/mpich/9.0.1/gtl/lib -Wl,-rpath,/opt/cray/pe/mpich/9.0.1/gtl/lib -lmpi_gtl_hsa -L/opt/rocm-6.4.3/lib -Wl,-rpath,/opt/rocm-6.4.3/lib -Wl,-rpath,/opt/rocm-6.4.3/llvm/lib -Wl,--disable-new-dtags,--as-needed,-lpthread,-lm,--no-as-needed" \
 "-DCMAKE_CXX_STANDARD=20" \
 "-DTrilinos_ENABLE_Fortran:BOOL=OFF" \
 "-DAztecOO_C_FLAGS=-Wno-implicit-function-declaration" \
 "-DTrilinos_ENABLE_TrilinosATDMConfigTests:BOOL=OFF" \
 "-DTrilinos_ENABLE_TrilinosFrameworkTests=OFF" \
 "-DTrilinos_ENABLE_Isorropia=OFF" \
 "-DTrilinos_ENABLE_KokkosExample=OFF" \
 "-DTrilinos_ENABLE_Domi=OFF" \
 "-DTrilinos_ENABLE_Pliris=OFF" \
 "-DTrilinos_ENABLE_Komplex=OFF" \
 "-DTrilinos_ENABLE_FEI=OFF" \
 "-DTrilinos_ENABLE_TriKota=OFF" \
 "-DTrilinos_ENABLE_Compadre=OFF" \
 "-DTrilinos_ENABLE_Moertel=OFF" \
 "-DTrilinos_ENABLE_Stokhos=OFF" \
 "-DTrilinos_ENABLE_MOOCHO=OFF" \
 "-DTrilinos_ENABLE_PyTrilinos=OFF" \
 "-DTrilinos_ENABLE_TrilinosCouplings=OFF" \
 "-DTrilinos_ENABLE_Pike=OFF" \
 "-DTrilinos_ENABLE_Krino=OFF" \
 "-DShyLU_DD_ENABLE_BDDC=OFF" \
 "-DTrilinos_ENABLE_PyTrilinos=OFF" \
 "-DTrilinos_ENABLE_ThyraEpetraExtAdapters=OFF" \
 "-DTrilinos_ENABLE_ThyraEpetraAdapters=OFF" \
 "-DTrilinos_ENABLE_ML=OFF" \
 "-DTrilinos_ENABLE_Ifpack=OFF" \
 "-DTrilinos_ENABLE_EpetraExt=OFF" \
 "-DTrilinos_ENABLE_Epetra=OFF" \
 "-DTrilinos_ENABLE_AztecOO=OFF" \
 "-DTrilinos_ENABLE_Amesos=OFF" \
 "-DROL_ENABLE_TESTS=OFF" \
 "-DROL_ENABLE_EXAMPLES=OFF" \
 "-DTPL_ENABLE_Gtest=OFF" \
 "-DTrilinos_ENABLE_Gtest=OFF" \
 "-DTPL_ENABLE_gtest=OFF" \
 "-DTrilinos_ENABLE_gtest=OFF" \
 "-DKOKKOSKERNELS_TPL_BLAS_RETURN_COMPLEX=OFF" \
 "-DTacho_ENABLE_INT_INT:BOOL=ON" \
 "-DMATH_LIBRARY_IS_SUPPLIED:BOOL=TRUE" \
 "-DTPL_ENABLE_BinUtils:BOOL=OFF" \
 "-DBinUtils_INCLUDE_DIRS=/include" \
 "-DBinUtils_LIBRARY_DIRS=/lib" \
 "-DTPL_ENABLE_BLAS:BOOL=ON" \
 "-DTPL_ENABLE_LAPACK:BOOL=ON" \
 "-DBLAS_LIBRARY_NAMES=openblas;omp;pthread" \
 "-DBLAS_INCLUDE_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/openblas-0.3.26-7ous25omfpnyeakkmkkcuj5yo2flwbz2/include" \
 "-DBLAS_LIBRARY_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/openblas-0.3.26-7ous25omfpnyeakkmkkcuj5yo2flwbz2/lib" \
 "-DLAPACK_LIBRARY_NAMES=openblas;omp;pthread" \
 "-DLAPACK_INCLUDE_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/openblas-0.3.26-7ous25omfpnyeakkmkkcuj5yo2flwbz2/include" \
 "-DLAPACK_LIBRARY_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/openblas-0.3.26-7ous25omfpnyeakkmkkcuj5yo2flwbz2/lib" \
 "-DTPL_ENABLE_Boost:BOOL=ON" \
 "-DTPL_ENABLE_BoostLib:BOOL=ON" \
 "-DBoost_INCLUDE_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/boost-1.84.0-s6nrdx55cgkb7nrn7egjj6vghowza7go/include" \
 "-DBoost_LIBRARY_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/boost-1.84.0-s6nrdx55cgkb7nrn7egjj6vghowza7go/lib" \
 "-DBoostLib_INCLUDE_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/boost-1.84.0-s6nrdx55cgkb7nrn7egjj6vghowza7go/include" \
 "-DBoostLib_LIBRARY_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/boost-1.84.0-s6nrdx55cgkb7nrn7egjj6vghowza7go/lib" \
 "-DTPL_ENABLE_METIS:BOOL=ON" \
 "-DTPL_ENABLE_ParMETIS:BOOL=ON" \
 "-DMETIS_INCLUDE_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/metis-5.1.0-sonspt6l325bwlxz6vs5e5kp3wy2t27v/include" \
 "-DMETIS_LIBRARY_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/metis-5.1.0-sonspt6l325bwlxz6vs5e5kp3wy2t27v/lib" \
 "-DParMETIS_INCLUDE_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/parmetis-4.0.3-7me2x3yqtsqjusxnob2tj5ydgevs7d2v/include;/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/metis-5.1.0-sonspt6l325bwlxz6vs5e5kp3wy2t27v/include" \
 "-DParMETIS_LIBRARY_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/parmetis-4.0.3-7me2x3yqtsqjusxnob2tj5ydgevs7d2v/lib;/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/metis-5.1.0-sonspt6l325bwlxz6vs5e5kp3wy2t27v/lib" \
 "-DTPL_ENABLE_CGNS:BOOL=ON" \
 "-DCGNS_INCLUDE_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/cgns-4.4.0-wdqq2fnyhjgws4qr52civhekb5bxmjow/include" \
 "-DCGNS_LIBRARY_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/cgns-4.4.0-wdqq2fnyhjgws4qr52civhekb5bxmjow/lib" \
 "-DTPL_ENABLE_HDF5:BOOL=ON" \
 "-DHDF5_LIBRARY_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/hdf5-1.10.7-dact4arqw6rnvz363lp27fvl3zaorg4p/lib;/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/zlib-ng-2.1.6-txnpxomrj6vzuhydnyjnuoalr2uag762/lib" \
 "-DHDF5_INCLUDE_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/hdf5-1.10.7-dact4arqw6rnvz363lp27fvl3zaorg4p/include" \
 "-DHDF5_LIBRARY_NAMES=hdf5_hl;hdf5;z;dl" \
 "-DTPL_ENABLE_Netcdf:BOOL=ON" \
 "-DNetcdf_LIBRARY_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/zlib-ng-2.1.6-txnpxomrj6vzuhydnyjnuoalr2uag762/lib;/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/boost-1.84.0-s6nrdx55cgkb7nrn7egjj6vghowza7go/lib;/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/netcdf-c-4.9.2-hocnq5daqf5ei4uutejwr4wih4rmy72f/lib;/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/parallel-netcdf-1.12.3-ukjcb2hshjspzan677qx2267rf6vrny2/lib;/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/hdf5-1.10.7-dact4arqw6rnvz363lp27fvl3zaorg4p/lib;/lib" \
 "-DNetcdf_LIBRARY_NAMES=netcdf;pnetcdf;z;hdf5_hl;hdf5" \
 "-DNetcdf_INCLUDE_DIRS=/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/netcdf-c-4.9.2-hocnq5daqf5ei4uutejwr4wih4rmy72f/include;/tscratch/jjellio/trilinos-dev/spack/nov-25-2025/install/linux-rhel8-zen3/rocmcc-6.4.3/parallel-netcdf-1.12.3-ukjcb2hshjspzan677qx2267rf6vrny2/include" \
 "-DTPL_ENABLE_SuperLUDist:BOOL=OFF" \
 "-DSuperLUDist_INCLUDE_DIRS=/include" \
 "-DSuperLUDist_LIBRARY_DIRS=/lib" \
 "-DTPL_ENABLE_Matio=OFF" \
 "-DTPL_ENABLE_X11=OFF" \
 "-DMPI_EXEC_NUMPROCS_FLAG=run;-x;-N;1;-n" \
 "-DMPI_EXEC=flux" \
 "-DTPL_ENABLE_MPI:BOOL=ON" \
 "-DMPI_USE_COMPILER_WRAPPERS=OFF" \
 "-DTPL_ENABLE_DLlib:BOOL=ON" \
 "-DDLlib_INCLUDE_DIRS=/opt/rocm-6.4.3/include" \
 "-DDLlib_LIBRARY_DIRS=/opt/rocm-6.4.3/lib" \
 "-DDLlib_LIBRARY_NAMES=dl;m" \
 "-DKOKKOSKERNELS_ENABLE_TPL_ROCBLAS:BOOL=ON" \
 "-DTPL_ENABLE_ROCBLAS:BOOL=ON" \
 "-DROCBLAS_INCLUDE_DIRS=/opt/rocm-6.4.3/include" \
 "-DROCBLAS_LIBRARY_DIRS=/opt/rocm-6.4.3/lib" \
 "-DTrilinos_ENABLE_ShyLU_NodeTacho=OFF" \
 "-DKOKKOSKERNELS_ENABLE_TPL_ROCSPARSE:BOOL=ON" \
 "-DTPL_ENABLE_ROCSPARSE:BOOL=ON" \
 "-DROCSPARSE_INCLUDE_DIRS=/opt/rocm-6.4.3/include" \
 "-DROCSPARSE_LIBRARY_DIRS=/opt/rocm-6.4.3/lib" \
 "-DCMAKE_INSTALL_PREFIX=/tscratch/amagela/fcr/miniem/install/amd-6.4.3_prgenv-amd_rocm-6.4.3_mpich-9.0.1_pure-amd_hip_amd-NOinlall-NOfunc-gfx942_devtpls_opt-g_cxx20_libonly_static/trilinos" \
/tscratch/amagela/fcr/miniem/trilinos 2>&1 | tee configure_trilinos_performance.log 

## Prevents re-configure after a new configure.
touch build.ninja rules.ninja

ninja -j 32
ninja -j 8

popd
