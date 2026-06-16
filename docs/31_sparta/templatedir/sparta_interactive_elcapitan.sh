# flux alloc -N1 --exclusive --setattr=thp=always --setattr=hugepages=512GB -q pbatch
. sparta_env_elcapitan.sh
flux run \
    -u --exclusive \
    -N 1 -n 4 \
    -x -c24 \
    -o cpu-affinity=off \
    -o gpu-affinity=off \
    -o mpibind=on,smt:1 \
    ./sparta/_build-elcapitan/src/spa_elcapitan_kokkos \
        -in in.cylinder \
        -k on g 1 -sf kk
