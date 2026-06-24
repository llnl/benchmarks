# flux alloc -N1 --exclusive --setattr=thp=always --setattr=hugepages=512GB -q pbatch
. lammps_env_cts2gpu.sh
export EXE_LAMMPS="${EXE_LAMMPS:-lammps/_build-elcapitan/lmp}"
export KOKKOS_TOOLS_LIBS="/rlfs01/amagela/fcr/lammps/llnl-benchmarks/docs/32_lammpsACE/kokkos-tools-elcapitan/profiling/space-time-stack/kp_space_time_stack.so"
flux run \
    -u --exclusive \
    -N 1 -n 4 \
    -x -c24 \
    -o cpu-affinity=off \
    -o gpu-affinity=off \
    -o mpibind=on,smt:1 \
    "${EXE_LAMMPS}" \
        -k on g 1 -sf kk -pk kokkos newton on neigh half \
        -var nscale 1 \
        -var pacechunksize 32768 \
        -var Lprime 64 \
        -in in.pace.product
