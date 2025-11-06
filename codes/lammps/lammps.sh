#!/bin/bash
export WORKSPACE_DIR=/usr/workspace/haque1/benchpark/apps/tuolumne-apu/lammps
mkdir -p $WORKSPACE_DIR
cd $WORKSPACE_DIR
rm -rf $WORKSPACE_DIR/zlib
rm -rf $WORKSPACE_DIR/cnpy
rm -rf $WORKSPACE_DIR/yaml-cpp
rm -rf $WORKSPACE_DIR/lammps-user-pace
rm -rf $WORKSPACE_DIR/kokkos
rm -rf $WORKSPACE_DIR/lammps

git clone https://github.com/madler/zlib.git
cd zlib
git checkout -b v1.3.1 v1.3.1
cd ..

git clone https://github.com/rogersce/cnpy.git
cd cnpy
cd ..

git clone https://github.com/jbeder/yaml-cpp.git
cd yaml-cpp
git checkout -b v0.8.0 0.8.0
cd ..

git clone https://github.com/ICAMS/lammps-user-pace.git
cd lammps-user-pace
git checkout -b v2023.11.25.2 v.2023.11.25.fix2
cd ..

git clone https://github.com/kokkos/kokkos.git
cd kokkos
git checkout -b v4.6.02 4.6.02
cd ..

git clone https://github.com/lammps/lammps.git
cd lammps
git checkout -b v20250722 patch_22Jul2025
cd ..

export WORKSPACE_DIR=/usr/workspace/haque1/benchpark/apps/tuolumne-apu/lammps
mkdir -p $WORKSPACE_DIR
cd $WORKSPACE_DIR

export ZLIB_DIR=$WORKSPACE_DIR/zib/install
export CNPY_DIR=$WORKSPACE_DIR/cnpy/install
export YAMLCPP_DIR=$WORKSPACE_DIR/yaml-cpp/install
export PACE_DIR=$WORKSPACE_DIR/lammps-user-pace/install
export KOKKOS_DIR=$WORKSPACE_DIR/kokkos/install
export LAMMPS_DIR=$WORKSPACE_DIR/lammps/install

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
#export ROCM_ARCH=AMD_GFX942
#export ROCM_ARCH=VEGA90A
export ROCM_ARCH=AMD_GFX942_APU
export PATH=$ROCM_PATH/bin:$PATH

export LD_LIBRARY_PATH=$COMPILER_ROOT/cce/x86_64/lib:$MPI_ROOT/lib:$MPI_BASE/gtl/lib:/opt/cray/pe/lib64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$ZLIB_DIR/lib:$CNPY_DIR/lib:$YAMLCPP_DIR/lib64:$PACE_DIR/lib64:$KOKKOS_DIR/lib64:$LAMMPS_DIR/lib64:$LD_LIBRARY_PATH

cd zlib
rm -rf install
mkdir install
make clean
CC=$CC CFLAGS="-O3 -fPIC" ./configure --prefix=$ZLIB_DIR --static
make -j
make install -j
cd ..

cd cnpy
rm -rf build install
mkdir build install
cd build
cmake .. -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_C_FLAGS="-fPIC" -DCMAKE_CXX_FLAGS="-fPIC"  -DCMAKE_INSTALL_PREFIX=$CNPY_DIR -DCMAKE_PREFIX_PATH="$ZLIB_DIR;$COMPILER_ROOT" -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF -DCMAKE_POLICY_DEFAULT_CMP0090=NEW -DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
make clean
make -j64
make -j install
cd ../../

cd yaml-cpp
rm -rf build install
mkdir build install
cd build
cmake .. -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_INSTALL_PREFIX=$YAMLCPP_DIR -DCMAKE_PREFIX_PATH="$COMPILER_ROOT" -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF -DCMAKE_POLICY_DEFAULT_CMP0090=NEW -DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DBUILD_SHARED_LIBS=ON -DYAML_BUILD_SHARED_LIBS=ON -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DYAML_CPP_BUILD_TESTS=OFF
make clean
make -j64
make -j install
cd ../../

cd lammps-user-pace
rm -rf build install
mkdir build install
cd build
cmake .. -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_INSTALL_PREFIX=$PACE_DIR -DCMAKE_PREFIX_PATH="$CNPY_DIR;$YAMLCPP_DIR;$ZLIB_DIR;$COMPILER_ROOT" -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF -DCMAKE_POLICY_DEFAULT_CMP0090=NEW -DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_POSITION_INDEPENDENT_CODE=ON
make clean
make -j64
make -j install
cd ../../

cd kokkos
rm -rf build install
mkdir build install
cd build
cmake .. -DCMAKE_CXX_COMPILER=$ROCM_PATH/bin/hipcc -DCMAKE_EXE_LINKER_FLAGS="-ldl" -DCMAKE_MODULE_LINKER_FLAGS="-ldl" -DCMAKE_SHARED_LINKER_FLAGS="-ldl" -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX=$KOKKOS_DIR -DCMAKE_PREFIX_PATH="$ROCM_PATH;COMPILER_ROOT" -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF -DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_POSITION_INDEPENDENT_CODE=OFF -DBUILD_SHARED_LIBS=ON -DKokkos_ENABLE_COMPILE_AS_CMAKE_LANGUAGE=OFF -DKokkos_ARCH_$ROCM_ARCH=ON -DKokkos_ENABLE_CUDA=OFF -DKokkos_ENABLE_OPENMP=OFF -DKokkos_ENABLE_THREADS=OFF -DKokkos_ENABLE_SERIAL=ON -DKokkos_ENABLE_HIP=ON -DKokkos_ENABLE_SYCL=OFF -DKokkos_ENABLE_OPENMPTARGET=OFF -DKokkos_ENABLE_AGGRESSIVE_VECTORIZATION=OFF -DKokkos_ENABLE_COMPILER_WARNINGS=OFF -DKokkos_ENABLE_COMPLEX_ALIGN=ON -DKokkos_ENABLE_HIP_RELOCATABLE_DEVICE_CODE=OFF -DKokkos_ENABLE_DEBUG=OFF -DKokkos_ENABLE_DEBUG_BOUNDS_CHECK=OFF -DKokkos_ENABLE_DEBUG_DUALVIEW_MODIFY_CHECK=OFF -DKokkos_ENABLE_EXAMPLES=OFF -DKokkos_ENABLE_TUNING=OFF -DKokkos_ENABLE_TESTS=OFF -DKokkos_ENABLE_HPX=OFF -DKokkos_ENABLE_HWLOC=OFF -DKokkos_ENABLE_ROCTHRUST=ON
make clean
make -j64
make -j install
cd ../../

cd lammps
rm -rf build install
mkdir build install
cd build
cmake ../cmake -DCMAKE_CXX_COMPILER=$ROCM_PATH/bin/hipcc -DMPI_C_COMPILER=$MPICC -DMPI_CXX_COMPILER=$MPICXX -DMPI_CXX_LINK_FLAGS="$MPI_LIB_DIRS $MPI_LIBS" -DCMAKE_C_FLAGS="-g -O2" -DCMAKE_CXX_FLAGS="-g -O2 -std=c++14" -DCMAKE_Fortran_FLAGS="-g -O2 -hnopattern" -DCMAKE_EXE_LINKER_FLAGS="-ldl" -DCMAKE_MODULE_LINKER_FLAGS="-ldl" -DCMAKE_SHARED_LINKER_FLAGS="-ldl" -DCMAKE_INSTALL_PREFIX=$LAMMPS_DIR -DCMAKE_PREFIX_PATH="$ZLIB_DIR;$CNPY_DIR;$YAMLCPP_DIR;$PACE_DIR;$KOKKOS_DIR;$ROCM_PATH;COMPILER_ROOT;$MPI_ROOT" -DCMAKE_BUILD_TYPE=Release -DCMAKE_VERBOSE_MAKEFILE=ON -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF -DCMAKE_POLICY_DEFAULT_CMP0090=NEW -DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DBUILD_SHARED_LIBS=ON -DBUILD_MPI=ON -DBUILD_OMP=OFF -DBUILD_TOOLS=OFF -DENABLE_TESTING=OFF -DDOWNLOAD_POTENTIALS=OFF -DEXTERNAL_KOKKOS=ON -DFFT_KOKKOS=hipfft -DBUILD_LIB=ON -DCMAKE_TUNE_FLAGS="" -DLAMMPS_SIZES=bigbig -DWITH_JPEG=OFF -DWITH_PNG=OFF -DWITH_FFMPEG=OFF -DWITH_CURL=OFF -DPKG_ADIOS=OFF -DPKG_AMOEBA=OFF -DPKG_ASPHERE=ON -DPKG_ATC=OFF -DPKG_AWPMD=OFF -DPKG_BOCS=OFF -DPKG_BODY=OFF -DPKG_BPM=OFF -DPKG_BROWNIAN=OFF -DPKG_CG-DNA=OFF -DPKG_CG-SPICA=OFF -DPKG_CLASS2=OFF -DPKG_COLLOID=OFF -DPKG_COLVARS=OFF -DPKG_COMPRESS=OFF -DPKG_CORESHELL=OFF -DPKG_DIELECTRIC=OFF -DPKG_DIFFRACTION=OFF -DPKG_DIPOLE=OFF -DPKG_DPD-BASIC=ON -DPKG_DPD-MESO=ON -DPKG_DPD-REACT=ON -DPKG_DPD-SMOOTH=ON -DPKG_DRUDE=OFF -DPKG_EFF=OFF -DPKG_ELECTRODE=OFF -DPKG_EXTRA-COMMAND=OFF -DPKG_EXTRA-COMPUTE=OFF -DPKG_EXTRA-DUMP=OFF -DPKG_EXTRA-FIX=OFF -DPKG_EXTRA-MOLECULE=OFF -DPKG_EXTRA-PAIR=OFF -DPKG_FEP=OFF -DPKG_GRANULAR=OFF -DPKG_H5MD=OFF -DPKG_INTEL=OFF -DPKG_INTERLAYER=OFF -DPKG_KIM=OFF -DPKG_KOKKOS=ON -DPKG_KSPACE=ON -DPKG_LATBOLTZ=OFF -DPKG_LEPTON=OFF -DPKG_MACHDYN=OFF -DPKG_MANIFOLD=OFF -DPKG_MANYBODY=ON -DPKG_MC=OFF -DPKG_MDI=OFF -DPKG_MEAM=OFF -DPKG_MESONT=OFF -DPKG_MGPT=OFF -DPKG_MISC=OFF -DPKG_ML-HDNNP=OFF -DPKG_ML-IAP=OFF -DPKG_ML-PACE=ON -DPKG_ML-POD=OFF -DPKG_ML-RANN=OFF -DPKG_ML-SNAP=OFF -DPKG_ML-UF3=OFF -DPKG_MOFFF=OFF -DPKG_MOLECULE=ON -DPKG_MOLFILE=OFF -DPKG_NETCDF=OFF -DPKG_OPENMP=OFF -DPKG_OPT=ON -DPKG_ORIENT=OFF -DPKG_PERI=OFF -DPKG_PHONON=OFF -DPKG_PLUGIN=OFF -DPKG_PLUMED=OFF -DPKG_POEMS=OFF -DPKG_PTM=OFF -DPKG_PYTHON=OFF -DPKG_QEQ=OFF -DPKG_QTB=OFF -DPKG_REACTION=OFF -DPKG_REAXFF=ON -DPKG_RHEO=OFF -DPKG_REPLICA=OFF -DPKG_RIGID=ON -DPKG_SCAFACOS=OFF -DPKG_SHOCK=OFF -DPKG_SMTBQ=OFF -DPKG_SPH=OFF -DPKG_SPIN=OFF -DPKG_SRD=OFF -DPKG_TALLY=OFF -DPKG_UEF=OFF -DPKG_VORONOI=OFF -DPKG_VTK=OFF -DPKG_YAFF=OFF -DFFT=fftw3 -DFFT_USE_HEFFTE=OFF -DFFT_SINGLE=OFF
make clean
make -j64
make -j install
cd ../../

export OMP_NUM_THREADS=1
export HSA_XNACK=1
cd $LAMMPS_DIR
rm -rf run
mkdir -p run
cd run
cp -r ../../examples/PACKAGES/pace/* .
rm Cu-PBE-core-rep.ace
cp ../../potentials/Cu-PBE-core-rep.ace .
sed -i -e 's/lattice .*/lattice fcc $a/g' -i in.pace.product
sed -i -e 's/box block .*/box block 0 64 0 64 0 64/g' -i in.pace.product
sed 's/run.*[0-9]+/run		100/g' -i in.pace.product
flux run -n 4 --exclusive -N 1 -g 1 ../bin/lmp -i in.pace.product -k on g 1 -sf kk -pk kokkos gpu/aware on neigh half comm device neigh/qeq full newton on -nocite > 64x64x64_4.txt
flux run -n 8 --exclusive -N 2 -g 1 ../bin/lmp -i in.pace.product -k on g 1 -sf kk -pk kokkos gpu/aware on neigh half comm device neigh/qeq full newton on -nocite > 64x64x64_8.txt
flux run -n 16 --exclusive -N 4 -g 1 ../bin/lmp -i in.pace.product -k on g 1 -sf kk -pk kokkos gpu/aware on neigh half comm device neigh/qeq full newton on -nocite > 64x64x64_16.txt
flux run -n 32 --exclusive -N 8 -g 1 ../bin/lmp -i in.pace.product -k on g 1 -sf kk -pk kokkos gpu/aware on neigh half comm device neigh/qeq full newton on -nocite > 64x64x64_32.txt
flux run -n 64 --exclusive -N 16 -g 1 ../bin/lmp -i in.pace.product -k on g 1 -sf kk -pk kokkos gpu/aware on neigh half comm device neigh/qeq full newton on -nocite > 64x64x64_64.txt

