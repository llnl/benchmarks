#!/usr/bin/env bash

#flux: -u
#flux: --exclusive
#flux: --job-name=lammpsfcr30
#flux: --output='lammpsfcr30.{{id}}.out'
#flux: --error='lammpsfcr30.{{id}}.err'
#flux: --setattr=thp=always
#flux: --setattr=hugepages=512GB

umask 022
ulimit -c unlimited
set -e
set -x

# directory and log file setup
export DIR_BUILD_TAG="${DIR_BUILD_TAG:-elcapitan}"
export SLURM_JOB_ID=${SLURM_JOB_ID:-424242}
export FLUX_JOB_ID=${FLUX_JOB_ID:-`flux getattr jobid`}
export DIR_BASE="`pwd -P`"
export DIR_ROOT="`git rev-parse --show-toplevel`"
export DIR_SRC="${DIR_BASE}/lammps"
export DIR_EXE="${DIR_SRC}/_build-${DIR_BUILD_TAG}"
export DIR_TAG="${DIR_TAG:-run}"
export DAYSTAMP="`date '+%Y%m%d'`"
export SECSTAMP="`date '+%Y%m%d_%H%M%S'`"
export FULLUNIQ="${SECSTAMP}_${RANDOM}"
export DIR_CASE="${SECSTAMP}_${FLUX_JOB_ID}"
export DIR_RUN="${DIR_TAG}-${DIR_CASE}"
# export TMPDIR="/tmp/$SLURM_JOB_ID"  # set to avoid potential runtime error
export FILE_LOG="output-launcher-${DIR_CASE}.log"
export FILE_METRICS="output-metrics-${DIR_CASE}.csv"
export FILE_ENV="output-environment-${DIR_CASE}.txt"
export FILE_STATE="output-state-${DIR_CASE}.log"
export FILE_TRY="output-script-${DIR_CASE}.log"
export FILE_TIME="output-time-${DIR_CASE}.txt"

# environment
. ./lammps_env_${DIR_BUILD_TAG}.sh

# LAMMPS setup
export LAMMPS_PACECHUNKSIZE=${LAMMPS_PACECHUNKSIZE:-32768}
export LAMMPS_LPRIME=${LAMMPS_LPRIME:-64}
export LAMMPS_NSCALE=${LAMMPS_NSCALE:-1}
export LAMMPS_IS_KOKKOS_TOOLS="${LAMMPS_IS_KOKKOS_TOOLS:-no}"
export APP_REPEAT=${APP_REPEAT:-4}
export APP_NAME=${APP_NAME:-"lmp"}
export APP_EXE="${DIR_EXE}/${APP_NAME}"

# FLUX Item(s)
export FLUX_JOB_NODES=${FLUX_JOB_NODES:-`flux resource list -s up -no {nnodes}`}

# Kokkos Tools
if test "${LAMMPS_IS_KOKKOS_TOOLS}" = "yes" ; then
    export KOKKOS_TOOLS_LIBS="${DIR_ROOT}/docs/32_lammpsACE/kokkos-tools-${DIR_BUILD_TAG}/profiling/space-time-stack/kp_space_time_stack.so"
else
    unset KOKKOS_TOOLS_LIBS
fi

# Create and populate run folder and edit input file
prep_toplevel_run()
{
    mkdir -p "${DIR_BASE}/${DIR_RUN}"
    cd "${DIR_BASE}/${DIR_RUN}"
    cp -a "${DIR_BASE}/in.pace.product" ./
    cp -a "${DIR_SRC}/potentials/Cu-PBE-core-rep.ace" ./
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
    ln -s ../in.pace.product ../Cu-PBE-core-rep.ace ./

    # export LD_PRELOAD=libldpxi_mpi.so
    # export LD_PRELOAD=/usr/projects/hpctest/amagela/ldpxi/ldpxi/install/ats3/ldpxi-1.0.1/intel+cray-mpich-8.1.25/lib/libldpxi_mpi.so.1.0.1
    # export LD_PRELOAD=/usr/projects/hpctest/amagela/ats-5/LDPXI/xr/libldpxi.so
    # time
    m_file_log="${FILE_LOG//.log/-${i}.log}"
    /usr/bin/time --verbose --output="${FILE_TIME}" \
        flux run \
            -u \
            --exclusive \
            --verbose \
            -N ${FLUX_JOB_NODES} \
            -n $((4 * FLUX_JOB_NODES)) \
            -x \
            -c 24 \
            -o cpu-affinity=off \
            -o gpu-affinity=off \
            -o mpibind=on,smt:1,verbose:0 \
            --output="${m_file_log}" \
            "${APP_EXE}" \
                -k on g 1 -sf kk -pk kokkos newton on neigh half \
                -var nscale ${LAMMPS_NSCALE} \
                -var pacechunksize ${LAMMPS_PACECHUNKSIZE} \
                -var Lprime ${LAMMPS_LPRIME} \
                -in "in.pace.product"
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
