#!/bin/bash

source ./laghos_env.sh

mkdir -p $WORKSPACE_DIR
pushd $WORKSPACE_DIR

rm -rf $ZLIB_ROOT zlib-1.3.1.tar.gz
mkdir -p $ZLIB_ROOT
wget http://zlib.net/fossils/zlib-1.3.1.tar.gz
tar -xzf zlib-1.3.1.tar.gz -C $ZLIB_ROOT --strip-components=1
pushd $ZLIB_ROOT
popd

rm -rf $METIS_ROOT
git clone https://github.com/KarypisLab/METIS.git $METIS_ROOT
pushd $METIS_ROOT
git checkout -b v5.1.0 a5a68846e4e2236b38e9c97aa778feee93346006
git submodule update --init --recursive
popd

rm -rf $ADIAK_ROOT
git clone https://github.com/LLNL/Adiak $ADIAK_ROOT
pushd $ADIAK_ROOT
git checkout -b test 7ac997111785bee6d9391664b1d18ebc2b3c557b
git submodule update --init blt
popd

rm -rf $CALIPER_ROOT
git clone https://github.com/LLNL/Caliper.git $CALIPER_ROOT
pushd $CALIPER_ROOT
git checkout master
popd

rm -rf $FMT_ROOT
git clone https://github.com/fmtlib/fmt.git $FMT_ROOT
git checkout -b v11.0.2 11.0.2
pushd $FMT_ROOT
popd

rm -rf $CAMP_ROOT
git clone https://github.com/LLNL/camp.git $CAMP_ROOT
pushd $CAMP_ROOT
git checkout -b v2025.03.0 ee0a3069a7ae72da8bcea63c06260fad34901d43
git submodule update --init extern/blt
popd

rm -rf $UMPIRE_ROOT
git clone https://github.com/LLNL/Umpire.git $UMPIRE_ROOT
pushd $UMPIRE_ROOT
git checkout -b v2025.03.0 1ed0669c57f041baa1f1070693991c3a7a43e7ee
git submodule update --init blt scripts/radiuss-spack-configs scripts/uberenv
popd

rm -rf $HYPRE_ROOT
git clone https://github.com/hypre-space/hypre.git $HYPRE_ROOT
pushd $HYPRE_ROOT
git checkout -b v2.33.0 v2.33.0
popd

rm -rf $MFEM_ROOT
git clone https://github.com/mfem/mfem.git $MFEM_ROOT
pushd $MFEM_ROOT
git checkout master 
popd

rm -rf $LAGHOS_ROOT
git clone https://github.com/tomstitt/Laghos.git $LAGHOS_ROOT
pushd $LAGHOS_ROOT
git checkout shared-umpire-pool
popd
