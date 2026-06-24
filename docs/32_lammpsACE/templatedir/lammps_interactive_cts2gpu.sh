#!/usr/bin/env bash
# salloc -N 1 -n 4 --ntasks-per-node=4 --cpus-per-task=28 --gpus-per-task=1 --gpu-bind=closest -A fy240071 --time=1:00:00 -p short,batch --license=pscratch
. lammps_env_cts2gpu.sh
export EXE_LAMMPS="${EXE_LAMMPS:-lammps/_build-cts2gpu/lmp}"
# export KOKKOS_TOOLS_LIBS="/tscratch/amagela/fcr/sparta-final/llnl-benchmarks-sparta/docs/31_sparta/kokkos-tools-cts2gpu/profiling/space-time-stack/kp_space_time_stack.so"
# export CUDA_LAUNCH_BLOCKING=1
mpiexec \
    -np 8 \
    "${EXE_LAMMPS}" \
    -k on g 4 -sf kk -pk kokkos newton on neigh half \
    -var Lprime 64 \
    -var nscale 2 \
    -in in.pace.product
