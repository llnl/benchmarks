#!/usr/bin/env bash
# salloc -N 1 -n 4 --ntasks-per-node=4 --cpus-per-task=28 --gpus-per-task=1 --gpu-bind=closest -A fy240071 --time=1:00:00 -p short,batch --license=pscratch
. sparta_env_cts2gpu.sh
export EXE_SPARTA="${EXE_SPARTA:-sparta/_build-cts2gpu/src/spa_kokkos_cuda}"
export KOKKOS_TOOLS_LIBS="/tscratch/amagela/fcr/sparta-final/llnl-benchmarks-sparta/docs/31_sparta/kokkos-tools-cts2gpu/profiling/space-time-stack/kp_space_time_stack.so"
export CUDA_LAUNCH_BLOCKING=1
mpiexec \
    -np 4 \
    "${EXE_SPARTA}" \
    -k on g 4 -sf kk -var ppc 205 -in in.cylinder
