#!/bin/bash
#flux: --exclusive
#flux: --setattr=thp=always
#flux: --setattr=hugepages=460GB
#flux: --coral2-hugepages
#flux: --conf=resource.rediscover=true
#flux: --time=limit=120
# flux alloc -N1 --exclusive --setattr=thp=always -setattr=hugepages=460GB --coral2-hugepages --conf=resource.rediscover=true --time-limit=120

. ./miniem_env_elcapitan.sh

# Runtime switches
export MINIEM_ELEMENTS=${MINIEM_ELEMENTS:-111}
export MINIEM_DT=${MINIEM_DT:-4.44e-13}

# Dynamic Flux environment
export MINIEM_NUM_NODES=${MINIEM_NUM_NODES:=`flux getattr size`}
let "MINIEM_NUM_MPI_PROCS=$MINIEM_NUM_NODES*4"
export FI_UNIVERSE_SIZE=$MINIEM_NUM_MPI_PROCS

# HPE debugging
export FI_CXI_RDZV_THRESHOLD=0
export FI_CXI_RDZV_EAGER_SIZE=0
export FI_LOG_LEVEL=warn

dir_base="` pwd -P `"
app_exe="${dir_base}/../install/amd-6.4.3_prgenv-amd_rocm-6.4.3_mpich-9.0.1_pure-amd_hip_amd-NOinlall-NOfunc-gfx942_devtpls_opt-g_cxx20_libonly_static/trilinos/example/PanzerMiniEM/PanzerMiniEM_BlockPrec.exe"

flux run \
    --exclusive \
    -N $MINIEM_NUM_NODES \
    -n $MINIEM_NUM_MPI_PROCS \
    "${app_exe}" \
        --x-elements=${MINIEM_ELEMENTS} \
        --y-elements=${MINIEM_ELEMENTS} \
        --z-elements=${MINIEM_ELEMENTS} \
        --dt=${MINIEM_DT} \
        --numTimeSteps=100 \
        --workset-size=20000 \
        --inputFile=maxwell-large.xml


exit 0
