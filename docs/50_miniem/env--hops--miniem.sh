#!/bin/sh
module purge
module load cudatoolkit/12.4
module load gnu/12.2.1
module load openmpi-gnu/4.1
export BUILD_BASE_DIR="` pwd -P `"
export OMPI_CXX="${BUILD_BASE_DIR}/Trilinos/packages/kokkos/bin/nvcc_wrapper"
export TMPDIR="${BUILD_BASE_DIR}/tmp"
export SPACK_ROOT="${BUILD_BASE_DIR}/spack"
export SPACK_DISABLE_LOCAL_CONFIG=true
export SPACK_USER_CACHE_PATH="${SPACK_ROOT}/${USER}_local_cache"
export SPACK_EDITOR='emacs -nw'
tmppath="${SPACK_ROOT}/bin"
[[ ":$PATH:" != *":${tmppath}:"* ]] && export PATH="${tmppath}:${PATH}"
mkdir -p "${TMPDIR}"
