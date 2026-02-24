#!/usr/bin/env bash

# set top-level script parameters
umask 022
set -e
set -x

# create vars for common directories and files
dir_root="`git rev-parse --show-toplevel`"
dir_pwd="` pwd -P `"
dir_src="${dir_pwd}/lammps"
dir_build="${dir_pwd}/lammps/_build"
file_log="${dir_pwd}/lammps_build.log"

# redirect STDOUT and STDERR through tee
exec &> >(tee >(ts '[%Y-%m-%d %H:%M:%S]' > "${file_log}"))

# let's turn on verbosity now
set -v

# output for posterity
hostname
uptime
lscpu

# clean and reset source
pushd "${dir_src}"
git clean -fdx
git reset --hard
popd

# create build directory
test -d "${dir_build}" && rm -rf "${dir_build}"
mkdir -p "${dir_build}"

# build
#   list current environment
module list
#   alter environment
. lammps_env_elcapitan.sh
#   list current environment
module list
pushd "${dir_build}"
cmake \
    -C ../cmake/presets/elcapitan_kokkos.cmake \
    -DPKG_ML-PACE=on \
    -DBUILD_MPI=on \
    -D CMAKE_BUILD_TYPE=Release \
    ../cmake
/usr/bin/time --verbose -- \
    nice -n 1 \
        gmake -j 64
popd

# gracefully exit
exit 0
