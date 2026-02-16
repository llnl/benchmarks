#!/usr/bin/env bash

#flux: --nodes=1
#flux: -u
#flux: --exclusive
#flux: -q pbatch
#flux: -t 20
#flux: --job-name=sparta-fcr-fy30
#flux: --setattr=thp=always
#flux: --setattr=hugepages=512GB

# e.g., to set the L parameter to a different value: sparta_len=2.0    flux batch sparta_batch.sh
# e.g., to turn on Kokkos Tools Space Time:          is_kokkos_tools=1 flux batch sparta_batch.sh

# define runtime params
sparta_len=${sparta_len:-1}
is_kokkos_tools=${is_kokkos_tools:-0}

# define useful locations
dir_base="` pwd -P `"
# date_stamp="`date '+%Y%m%d-%H%M%S'`"
# dir_run="${dir_base}/sparta-${date_stamp}"

# set up environment appropriately
. sparta_env_elcapitan.sh
test ${is_kokkos_tools} -eq 1 && . kokkos_tools_env_elcapitan.sh

# run on 4 GPUs per node
flux run \
     -u \
     --exclusive \
     --verbose \
     -N 1 \
     -n 4 \
     -x \
     -c24 \
     -o cpu-affinity=off \
     -o gpu-affinity=off \
     -o mpibind=on,smt:1,verbose:0 \
     "${dir_base}/sparta/_build/src/spa_elcapitan_kokkos" \
         -sf kk -k on g 1 \
         -in in.cylinder \
         -var L ${sparta_len}
