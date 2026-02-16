#!/bin/bash

module load craype-accel-amd-gfx942
module load PrgEnv-cray
module load rocm/6.2.1
module load python

export LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}

export MPICH_GPU_SUPPORT_ENABLED=1
export MPICH_OFI_NIC_POLICY=GPU

### FIXME ### Need a system wide install of libfabric from SHS 11 (or newer)
export LD_LIBRARY_PATH=/usr/workspace/wsb/accept/packages-2024/SHS11_lib:${LD_LIBRARY_PATH}

export HIP_PATH=`hipconfig -p`
export LD_LIBRARY_PATH=${HIP_PATH}/lib:${LD_LIBRARY_PATH}

### Tell libfabric to only look for the ROCm runtime, not cuda, etc.
export FI_HMEM="rocr"

# Have malloc() calls use huge pages
export HUGETLB_MORECORE=yes

# restrict libhugetlbfs to be enabled for these executables only:
export HUGETLB_RESTRICT_EXE="defrag:lmp"

export HSA_XNACK=1
