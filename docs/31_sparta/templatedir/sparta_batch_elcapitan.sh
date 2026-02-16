#!/usr/bin/env bash

#flux: # --nodes=1
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
flux_job_nodes=${flux_job_nodes:-`flux resource list -s up -no {nnodes}`}
echo "sparta_len=${sparta_len}"
echo "is_kokkos_tools=${is_kokkos_tools}"
echo "flux_job_nodes=${flux_job_nodes}"

# define useful locations
dir_base="` pwd -P `"

# set up environment appropriately
. sparta_env_elcapitan.sh
test ${is_kokkos_tools} -eq 1 && . kokkos_tools_env_elcapitan.sh

# run on 4 GPUs per node
flux run \
     -u \
     --exclusive \
     --verbose \
     -N ${flux_job_nodes} \
     -n $((4 * flux_job_nodes)) \
     -x \
     -c 24 \
     -o cpu-affinity=off \
     -o gpu-affinity=off \
     -o mpibind=on,smt:1,verbose:0 \
     "${dir_base}/sparta/_build/src/spa_elcapitan_kokkos" \
         -sf kk -k on g 1 \
         -in in.cylinder \
         -var L ${sparta_len}
