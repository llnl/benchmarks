#!/usr/bin/env bash

umask 022
set -e
set -x

dir_root="`git rev-parse --show-toplevel`"
dir_src="${dir_root}/sparta"
dir_base="` pwd -P `"

module list

pushd "${dir_src}"
git clean -fdx
git reset --hard
popd
cp -a Makefile.crossroads_serial_spr "${dir_src}/src/MAKE"
pushd "${dir_src}/src"
make yes-kokkos
make -j 16 crossroads_serial_spr
echo "Resultant build info:"
ls -lh "`pwd -P`/spa_crossroads_serial_spr"
cp -a "`pwd -P`/spa_crossroads_serial_spr" "${dir_base}"
popd

. ats4_env.sh
cd sparta
mkdir _build
cd _build
cmake -C ../cmake/presets/elcapitan_kokkos.cmake -DPKG_FFT=on -DBUILD_MPI=on ../cmake
make -j 64
flux alloc -N1 --exclusive --setattr=thp=always --setattr=hugepages=512GB -q pbatch
cd ../examples/cylinder/
flux run -u --exclusive --verbose -N 1 -n 4 -x -c24 -o cpu-affinity=off -o gpu-affinity=off -o mpibind=on,smt:1,verbose:0  ../../_build/src/spa_elcapitan_kokkos -sf kk -k on g 1 -in in.cylinder


exit 0
