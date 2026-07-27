#!/usr/bin/env bash

ENABLE_TEST_BINARIES=true \
RUN_TESTS=false \
BUILD_TESTS=false \
CONFIGURE_ONLY=false \
BUILD_OPENMP=false \
BUILD_SERIAL=false \
BUILD_HIP=true \
BUILD_PURE_CCE=false \
BUILD_PURE_AMD=true \
BUILD_AMDCLANG=true \
FULL_ATDM=false \
BUILD_COMPLEX=false \
BUILD_DEBUG_SYM=true \
CXX_STD=20 \
AMD_FUNCTION_CALLS=false \
AMD_EARLY_INLINE_ALL=false \
GPU_INLINE_THRESHOLD=false \
prgenv_toolchain=amd \
prgenv_version=20.0.0 \
cce_offload_target=gfx942_APU \
BUILD_SHARED=false \
ENABLE_RDC=false \
AMD_REPORT_KERNEL_USAGE=false \
ATDM_USE_DEVICE_TPLS=true \
JJE_INSTALL=true \
PERFORMANCE_TEST=false \
ATDM_ENABLE_OFFLOAD_NEW_DRIVER=true \
ATDM_USE_HUGETLBFS=false \
ROCM_VERSION=6.4.3 \
BUILD_FOR_EMPIRE=false \
CMAKE_INSTALL_PREFIX=/rlfs01/amagela/fcr/miniem/eldorado/install \
TRILINOS_SRC=/tscratch/amagela/fcr/miniem/trilinos \
./build-trilinos-classic2-new.sh

#/tscratch/jjellio/trilinos-dev/spack/config/build-trilinos-classic2.sh

