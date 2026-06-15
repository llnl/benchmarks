#!/usr/bin/env bash

# dump out steps
set -x

# set some convenience vars
env_platform="elcapitan"

# load environment
. sparta_env_${env_platform}.sh
module list

# go into checkout if present and checkout if not
if test ! -d sparta ; then
    ./sparta_clone.sh
fi
pushd sparta

# create and enter build directory
dir_build="_build-${env_platform}"
mkdir -p "${dir_build}"
pushd "${dir_build}"

# perform the build
cmake \
    -C ../cmake/presets/elcapitan_kokkos.cmake \
    ../cmake
nice -n 1 gmake -j 64

popd
popd
