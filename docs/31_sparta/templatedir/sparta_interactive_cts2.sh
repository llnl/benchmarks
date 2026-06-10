#!/usr/bin/env bash
. sparta_env_cts2.sh
export EXE_SPARTA="${EXE_SPARTA:-sparta/_build-cts2/src/spa_kokkos_mpi_only}"
srun \
    --mpi=pmi2 \
    -n 112 \
    -u \
    "${EXE_SPARTA}" \
    -k on -sf kk -in in.cylinder
