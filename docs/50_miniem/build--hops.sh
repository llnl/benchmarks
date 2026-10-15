#!/bin/sh
# spack env create miniem-hops-env
. "${SPACK_ROOT}/share/spack/setup-env.sh"
spack cd -e miniem-hops-env
spacktivate -p miniem-hops-env

# spack compiler find

# spack external find curl
# spack external find openssl
# spack external find openmpi
# spack external find gettext
# spack external find ncurses
# spack external find perl
# spack external find m4

spack add ninja
spack add cmake
spack add yaml-cpp
spack add blas
spack add lapack
spack add hdf5@1.10.9 api=v110
spack add parallel-netcdf@1.12.3
spack add netcdf-c@4.9+mpi+parallel-netcdf~szip~blosc~zstd

spack concretize
spack install
