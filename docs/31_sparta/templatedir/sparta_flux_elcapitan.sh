#!/usr/bin/env bash

#flux: # --nodes=1
#flux: -u
#flux: --exclusive
#flux: -q pbatch
#flux: -t 20
#flux: --job-name=spartafcr30
#flux: --setattr=thp=always
#flux: --setattr=hugepages=512GB

umask 022
ulimit -c unlimited
set -e
set -x

# directory and log file setup
export DIR_BUILD_TAG="${DIR_BUILD_TAG:-elcapitan}"
# export SLURM_JOB_ID=${SLURM_JOB_ID:-424242}
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
# export TMPDIR="/tmp/$SLURM_JOB_ID"  # set to avoid potential runtime error
export FILE_LOG="output-srun-${DIR_CASE}.log"
export FILE_METRICS="output-metrics-${DIR_CASE}.csv"
export FILE_ENV="output-environment-${DIR_CASE}.txt"
export FILE_STATE="output-state-${DIR_CASE}.log"
export FILE_TRY="output-script-${DIR_CASE}.log"
export FILE_TIME="output-time-${DIR_CASE}.txt"

# SPARTA setup
export SPARTA_PPC=${SPARTA_PPC:-222}
export SPARTA_NSCALE=${SPARTA_NSCALE:-1}
export SPARTA_IS_KOKKOS_TOOLS="${SPARTA_IS_KOKKOS_TOOLS:-no}"
export APP_REPEAT=${APP_REPEAT:-4}
export APP_NAME=${APP_NAME:-"spa_elcapitan_kokkos"}
export APP_EXE="${DIR_EXE}/${APP_NAME}"

# FLUX Item(s)
export FLUX_JOB_NODES=${FLUX_JOB_NODES:-`flux resource list -s up -no {nnodes}`}

# Kokkos Tools
if test "${SPARTA_IS_KOKKOS_TOOLS}" = "yes" ; then
    export KOKKOS_TOOLS_LIBS="${DIR_ROOT}/docs/31_sparta/kokkos-tools-${DIR_BUILD_TAG}/profiling/space-time-stack/kp_space_time_stack.so"
else
    unset KOKKOS_TOOLS_LIBS
fi

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
    echo "    INFO: FLUX info"
    env | grep -i flux
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
        flux run \
            -u \
            --exclusive \
            --verbose \
            -N ${FLUX_JOB_NODES} \
            -n $((4 * flux_job_nodes)) \
            -x \
            -c 24 \
            -o cpu-affinity=off \
            -o gpu-affinity=off \
            -o mpibind=on,smt:1,verbose:0 \
            "${APP_EXE}" \
                -sf kk -k on g 1 \
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

exit 0
