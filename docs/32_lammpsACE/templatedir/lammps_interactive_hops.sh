#!/usr/bin/env bash

# define runtime params
lammps_lprime=${lammps_lprime:-64.0}
lammps_nscale=${lammps_nscale:-1.0}
is_kokkos_tools=${is_kokkos_tools:-0}
# flux_job_nodes=${flux_job_nodes:-`flux resource list -s up -no {nnodes}`}
slurm_job_nodes=${SLURM_JOB_NUM_NODES:-1}
slurm_job_ranks=$(( slurm_job_nodes * 4 ))
echo "lammps_lprime=${lammps_lprime}"
echo "lammps_nscale=${lammps_nscale}"
echo "is_kokkos_tools=${is_kokkos_tools}"
# echo "flux_job_nodes=${flux_job_nodes}"
echo "slurm_job_nodes=${slurm_job_nodes}"

# define useful locations
dir_base="` pwd -P `"

# set up environment appropriately
. lammps_env_hops.sh
test ${is_kokkos_tools} -eq 1 && . kokkos_tools_env_hops.sh

# run on 4 GPUs per node
mpirun \
    --map-by ppr:2:socket:pe=28 \
    --bind-to core \
    -np $slurm_job_ranks \
    "${dir_base}/hops-gpu-bind-with-numa.sh" \
    "${dir_base}/../lammps/_build/lmp" \
        -sf kk -k on g 1 -pk kokkos neigh half newton on \
        -in in.pace.fcr_short \
        -var Lprime ${lammps_lprime} \
        -var nscale ${lammps_nscale}

