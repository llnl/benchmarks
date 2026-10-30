#!/usr/bin/env bash

#SBATCH: --time=1:00:00
#SBATCH: --ntasks-per-node=4
#SBATCH: --cpus-per-task=28
#SBATCH: --gpus-per-task=1
#SBATCH: --gpu-bind=closest
#SBATCH: --account=fy150069
#SBATCH: --license=rnfs01
#SBATCH: --partition=short,batch

# salloc -N 2 -n 8 --ntasks-per-node=4 --cpus-per-task=28 --gpus-per-task=1 --gpu-bind=closest -A fy200101 --time=4:00:00 -p short,batch --license=pscratch
# e.g., to set the nloc parameter to a different value: sparta_nloc=355    flux batch sparta_batch.sh
# e.g., to turn on Kokkos Tools Space Time:             is_kokkos_tools=1  flux batch sparta_batch.sh

# define runtime params
sparta_nloc=${sparta_nloc:-305}
sparta_nscale=${sparta_nscale:-1}
is_kokkos_tools=${is_kokkos_tools:-0}

# Dynamic SLURM/Flux environment
slurm_job_nodes=${SLURM_JOB_NUM_NODES:-1}
let "sparta_num_mpi_procs=$slurm_job_nodes*4"

test ! ${sparta_nscale} -eq ${slurm_job_nodes} && sparta_nscale=${slurm_job_nodes}
echo "sparta_nloc=${sparta_nloc}"
echo "sparta_nscale=${sparta_nscale}"
echo "is_kokkos_tools=${is_kokkos_tools}"
echo "slurm_job_nodes=${slurm_job_nodes}"

# define useful locations
dir_base="` pwd -P `"

# set up environment appropriately
. ../sparta_env_hops.sh
test ${is_kokkos_tools} -eq 1 && . kokkos_tools_env_hops.sh

# run on 4 GPUs per node
mpiexec \
    -np ${sparta_num_mpi_procs} \
    -map-by ppr:2:socket:pe=28 \
    --bind-to core \
    ./hops-gpu-bind-with-numa.sh \
    ../sparta/_build/src/spa_kokkos_cuda \
        -sf kk -k on g 1 \
        -in in.collide_halt_balance \
        -var nloc ${sparta_nloc} \
        -var nscale ${sparta_nscale} 
