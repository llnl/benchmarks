#!/bin/bash

source ./lammps_env.sh

mkdir -p $WORKSPACE_DIR
cd $WORKSPACE_DIR

rm -rf $ZLIB_ROOT
rm -rf $CNPY_ROOT
rm -rf $YAMLCPP_ROOT
rm -rf $PACE_ROOT
rm -rf $KOKKOS_ROOT
rm -rf $LAMMPS_ROOT

git clone https://github.com/madler/zlib.git $ZLIB_ROOT
pushd $ZLIB_ROOT
git checkout -b v1.3.1 v1.3.1
popd

git clone https://github.com/rogersce/cnpy.git $CNPY_ROOT
pushd $CNPY_ROOT
popd

git clone https://github.com/jbeder/yaml-cpp.git $YAMLCPP_ROOT
pushd $YAMLCPP_ROOT
git checkout -b v0.8.0 0.8.0
popd

git clone https://github.com/ICAMS/lammps-user-pace.git $PACE_ROOT
pushd $PACE_ROOT
git checkout -b v2023.11.25.2 v.2023.11.25.fix2
popd

git clone https://github.com/kokkos/kokkos.git $KOKKOS_ROOT
pushd $KOKKOS_ROOT
git checkout -b v4.6.02 4.6.02
popd

git clone https://github.com/lammps/lammps.git $LAMMPS_ROOT
pushd $LAMMPS_ROOT
git checkout -b v20250722 patch_22Jul2025
popd
