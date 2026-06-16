#!/usr/bin/env bash

umask 022
ulimit -c unlimited
set -e
set -x

# directory and log file setup
export DIR_BUILD_TAG="${DIR_BUILD_TAG:-cts2}"
export SLURM_JOB_ID=${SLURM_JOB_ID:-424242}
export DIR_BASE="`pwd -P`"
export DIR_ROOT="`git rev-parse --show-toplevel`"
export DIR_SRC="${DIR_BASE}/sparta"
export DIR_EXE="${DIR_SRC}/_build-${DIR_BUILD_TAG}/src"
export DIR_TAG="${DIR_TAG:-run}"
export DAYSTAMP="`date '+%Y%m%d'`"
export SECSTAMP="`date '+%Y%m%d_%H%M%S'`"
export FULLUNIQ="${SECSTAMP}_${RANDOM}"
export DIR_CASE="${SECSTAMP}_${SLURM_JOB_ID}"
export DIR_RUN="${DIR_TAG}-${DIR_CASE}"
export TMPDIR="/tmp/$SLURM_JOB_ID"  # set to avoid potential runtime error
export FILE_LOG="output-launcher-${DIR_CASE}.log"
export FILE_METRICS="output-metrics-${DIR_CASE}.csv"
export FILE_ENV="output-environment-${DIR_CASE}.txt"
export FILE_STATE="output-state-${DIR_CASE}.log"
export FILE_TRY="output-script-${DIR_CASE}.log"
export FILE_TIME="output-time-${DIR_CASE}.txt"

# SPARTA setup
export SPARTA_PPC=${SPARTA_PPC:-47}
export SPARTA_NSCALE=${SPARTA_NSCALE:-1}
export SPARTA_IS_KOKKOS_TOOLS="${SPARTA_IS_KOKKOS_TOOLS:-no}"
export APP_REPEAT=${APP_REPEAT:-4}
export APP_NAME=${APP_NAME:-"spa_kokkos_mpi_only"}
export APP_EXE="${DIR_EXE}/${APP_NAME}"

# MPI & hardware setup
export SLURM_JOB_NUM_NODES=${SLURM_JOB_NUM_NODES:-1}
export NODES=${NODES:-$SLURM_JOB_NUM_NODES}
export RANKS_PER_DOMAIN=${RANKS_PER_DOMAIN:-14}
export SOCKETS_PER_NODE=${SOCKETS_PER_NODE:-2}
export DOMAINS_PER_SOCKET=${DOMAINS_PER_SOCKET:-4}
export RANKS_PER_SOCKET=$(( $RANKS_PER_DOMAIN * $DOMAINS_PER_SOCKET ))
export RANKS_PER_NODE=$(( $RANKS_PER_DOMAIN * $DOMAINS_PER_SOCKET * $SOCKETS_PER_NODE ))
export RANKS_PER_JOB=$(( $RANKS_PER_NODE * $NODES ))
# export SPARTA_RANK_BIND="`${DIR_ROOT}/map_cpu/map_cpu ${RANKS_PER_NODE} 2>/dev/null`"

# Thread setup
export SWTHREADS_PER_RANK=${SWTHREADS_PER_RANK:-1}
export HWTHREADS_PER_CORE=${HWTHREADS_PER_CORE:-2}
export PLACEHOLDERS_PER_RANK=$(( $SWTHREADS_PER_RANK * $HWTHREADS_PER_CORE ))
export PLACEHOLDERS_PER_RANK=1
export PES_PER_NODE=$(( $RANKS_PER_NODE * $SWTHREADS_PER_RANK ))

# Kokkos Tools
if test "${SPARTA_IS_KOKKOS_TOOLS}" = "yes" ; then
    export KOKKOS_TOOLS_LIBS="${DIR_ROOT}/docs/31_sparta/kokkos-tools-${DIR_BUILD_TAG}/profiling/space-time-stack/kp_space_time_stack.so"
else
    unset KOKKOS_TOOLS_LIBS
fi

# LDPXI setup if applicable
# export LDPXI_INST="gru,io,mpi,rank,mem"
# export LDPXI_PERF_EVENTS="cpu-cycles,ref-cycles,dTLB-load-misses,dTLB-loads"
# export LDPXI_OUTPUT="sparta-ldpxi.$SLURM_JOB_ID.csv"

# Create and populate run folder and edit input file
prep_toplevel_run()
{
    mkdir -p "${DIR_BASE}/${DIR_RUN}"
    cd "${DIR_BASE}/${DIR_RUN}"
    cp -a "${DIR_BASE}/in.cylinder" ./
    # awk "\$1 ~ /^run\$/ {\$2 = ${SPARTA_RUN}}1" "${DIR_SRC}/examples/cylinder/in.cylinder" \
    #     | awk "\$2 ~ /^ppc\$/ {\$4 = ${SPARTA_PPC}}1" \
    #     | awk "\$1 ~ /^stats\$/ {\$2 = ${SPARTA_STATS}}1" \
    #     > "./in.cylinder"
    cp -a "${DIR_SRC}/examples/cylinder/circle_R0.5_P10000.surf" ./
    cp -a "${DIR_SRC}"/examples/cylinder/air.* ./
}
export -f prep_toplevel_run
prep_toplevel_run

print_system_env_info()
{
    echo "################"
    echo "INFO (` date `): System and environment information"
    echo "    INFO: Date and Time"
    date
    echo "    INFO: modules"
    module list
    echo "    INFO: CPU info"
    # cat /proc/cpuinfo | tail -27
    lscpu
    echo "    INFO: memory info"
    cat /proc/meminfo
    echo "    INFO: SLURM info"
    env | grep -i slurm
    echo "    INFO: HOST info"
    hostname
    echo "    INFO: NUMA info"
    numactl --hardware
}
export -f print_system_env_info
print_system_env_info >"${FILE_ENV}" 2>&1

# do work
run_try()
{
    set -x
    i=$1
    echo "INFO (` date `): Inner Perform Simulation #${i}"
    date
    dir_try="try-` printf '%02d' $i `"
    mkdir -p "${dir_try}"
    pushd "${dir_try}"
    ln -s ../air.* ../*.surf ../in.cylinder ./

    # export LD_PRELOAD=libldpxi_mpi.so
    # export LD_PRELOAD=/usr/projects/hpctest/amagela/ldpxi/ldpxi/install/ats3/ldpxi-1.0.1/intel+cray-mpich-8.1.25/lib/libldpxi_mpi.so.1.0.1
    # export LD_PRELOAD=/usr/projects/hpctest/amagela/ats-5/LDPXI/xr/libldpxi.so
    # time
    /usr/bin/time --verbose --output="${FILE_TIME}" \
        srun \
            --unbuffered \
            --ntasks=$RANKS_PER_JOB \
            --ntasks-per-node=$RANKS_PER_NODE \
            --cpu-bind=verbose \
            --distribution=block:block \
            --output="${FILE_LOG//.log/-${i}.log}" \
            "${APP_EXE}" \
                -k on -sf kk \
                -var nscale ${SPARTA_NSCALE} \
                -var ppc ${SPARTA_PPC} \
                -in "in.cylinder"
    # unset LD_PRELOAD
#             --ntasks-per-socket=$RANKS_PER_SOCKET \
#             --hint=nomultithread \
#             --cpu-bind=verbose,ldoms \
#             --cpus-per-task=$SRUN_CPUS_PER_TASK \
#             --cpus-per-task=${PLACEHOLDERS_PER_RANK} \
#             --distribution=block:cyclic \
#             --cpu-bind="map_cpu:`${DIR_ROOT}/map_cpu/map_cpu ${PES_PER_NODE} 2>/dev/null`" \
    popd
    date
}
export -f run_try

for (( i=0; i<${APP_REPEAT}; i++ )) ; do
    echo "INFO (` date `): Outer Perform Simulation #${i}"
    run_try $i >"${FILE_TRY//.log/-${i}.log}" 2>&1
done
                        
# mv ../slurm-${SLURM_JOBID}.out .

exit 0
