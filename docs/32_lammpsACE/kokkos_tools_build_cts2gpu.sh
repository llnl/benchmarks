#!/usr/bin/env bash

# set top-level script parameters
umask 022
set -e
set -x

# create vars for common directories and files
dir_root="`git rev-parse --show-toplevel`"
dir_pwd="` pwd -P `"
dir_src_root="${dir_pwd}/kokkos-tools"
dir_sts="profiling/space-time-stack"
dir_src="${dir_src_root}/${dir_sts}"
dir_build_root="${dir_pwd}/kokkos-tools-cts2gpu"
dir_build="${dir_build_root}/${dir_sts}"
file_log="${dir_pwd}/kokkos-tools-build-cts2gpu.log"

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
test -d "${dir_build_root}" && rm -rf "${dir_build_root}"
mkdir -p "${dir_build_root}"
rsync -va "${dir_src_root}/" "${dir_build_root}/"

# build
# list current environment
module list
# alter environment
. lammps_env_cts2gpu.sh
# list current environment
module list
pushd "${dir_build}"
/usr/bin/time --verbose -- \
    nice -n 1 \
        gmake CXX="mpicxx -DUSE_MPI=1"
popd

# gracefully exit
exit 0
