#!/usr/bin/env bash
. sparta_env_cts2.sh
export EXE_SPARTA="${EXE_SPARTA:-sparta/_build-cts2/src/spa_kokkos_mpi_only}"
export KOKKOS_TOOLS_LIBS="/tscratch/amagela/fcr/sparta-final/llnl-benchmarks-sparta/docs/31_sparta/kokkos-tools-cts2/profiling/space-time-stack/kp_space_time_stack.so"
srun \
    --mpi=pmi2 \
    -n 112 \
    -u \
    "${EXE_SPARTA}" \
    -k on -sf kk -in in.cylinder
# mpiexec \
#     -n 112 \
#     "${EXE_SPARTA}" \
#     -k on -sf kk -in in.cylinder
