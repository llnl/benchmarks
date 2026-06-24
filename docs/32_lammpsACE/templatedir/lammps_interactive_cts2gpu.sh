#!/usr/bin/env bash
# salloc -N 1 -n 4 --ntasks-per-node=4 --cpus-per-task=28 --gpus-per-task=1 --gpu-bind=closest -A fy240071 --time=1:00:00 -p short,batch --license=pscratch
. lammps_env_cts2gpu.sh
export EXE_LAMMPS="${EXE_LAMMPS:-lammps/_build-cts2gpu/lmp}"
export KOKKOS_TOOLS_LIBS="/rlfs01/amagela/fcr/lammps/llnl-benchmarks/docs/32_lammpsACE/kokkos-tools-cts2gpu/profiling/space-time-stack/kp_space_time_stack.so"
mpiexec \
    -np 4 \
    "${EXE_LAMMPS}" \
        -k on g 4 -sf kk -pk kokkos newton on neigh half \
        -var nscale 1 \
        -var pacechunksize 20000 \
        -var Lprime 64 \
        -in in.pace.product
