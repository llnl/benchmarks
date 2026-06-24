#!/usr/bin/env bash


# decide which platform to do
export IS_CTS2GPU=${IS_CTS2GPU:-0}
export IS_ELCAP=${IS_ELCAP:-0}

# decide which study to do
export IS_MEMSCALE=${IS_MEMSCALE:-0}
export IS_WEAK=${IS_WEAK:-0}

# set a few other things
export NUM_DUPLICATE=${NUM_DUPLICATE:-2}


# loop over PPC for single-node weak scaling
if test ${IS_MEMSCALE} -eq 1 ; then
    for m_pacechunksize in 16384 32768 ; do
        if test ${IS_CTS2GPU} -eq 1 ; then
            DIR_TAG="run-cts2gpu-" LAMMPS_NSCALE=1 LAMMPS_PACECHUNKSIZE=${m_pacechunksize} LAMMPS_IS_KOKKOS_TOOLS="yes" APP_REPEAT=1 \
                sbatch \
                    --nodes=1 \
                    --ntasks=4 \
                    --ntasks-per-node=4 \
                    --cpus-per-task=28 \
                    --gpus-per-task=1 \
                    --gpu-bind=closest \
                    --account=fy150069 \
                    --time=0:29:59 \
                    --partition=batch,short \
                    --job-name=lammpsfcr30 \
                    lammps_sbatch_cts2gpu.sh
        fi
    
        if test ${IS_ELCAP} -eq 1 ; then
            DIR_TAG="run-elcapitan-" LAMMPS_NSCALE=1 LAMMPS_PACECHUNKSIZE=${m_pacechunksize} LAMMPS_IS_KOKKOS_TOOLS="yes" APP_REPEAT=1 \
                flux batch \
                   --nodes=1 \
                   --time-limit=40 \
                   lammps_batch_elcapitan.sh
        fi
        sleep 0.5
    done
fi

# scale up!
if test ${IS_WEAK} -eq 1 ; then
    # ATS-4:     for m_nodes in 1 2 4 8 16 32 64 128 256 ; do
    # CTS-2+GPU: for m_nodes in 1 2 4 8 16 30 ; do
    for m_nodes in 1 2 4 8 16 32 64 128 256 ; do
        for m_dup in `seq 1 1 ${NUM_DUPLICATE}` ; do
            if test ${IS_CTS2GPU} -eq 1 ; then
                m_part="batch,short"
                if test ${m_nodes} -gt 8 ; then
                    m_part="batch"
                fi
                DIR_TAG="run-weak-cts2gpu-" LAMMPS_NSCALE=${m_nodes} LAMMPS_PACECHUNKSIZE=20000 LAMMPS_IS_KOKKOS_TOOLS="no" APP_REPEAT=2 \
                    sbatch \
                        --nodes=${m_nodes} \
                        --ntasks=$((m_nodes * 4)) \
                        --ntasks-per-node=4 \
                        --cpus-per-task=28 \
                        --gpus-per-task=1 \
                        --gpu-bind=closest \
                        --account=fy150069 \
                        --time=0:59:59 \
                        --partition=${m_part} \
                        --job-name=lammpsfcr30 \
                        lammps_sbatch_cts2gpu.sh
            fi
        
            if test ${IS_ELCAP} -eq 1 ; then
                DIR_TAG="run-weak-elcapitan-" LAMMPS_NSCALE=${m_nodes} LAMMPS_PACECHUNKSIZE=32768 LAMMPS_IS_KOKKOS_TOOLS="no" APP_REPEAT=2 \
                    flux batch \
                       --nodes=${m_nodes} \
                       --time-limit=59 \
                       lammps_batch_elcapitan.sh
            fi
            sleep 1.0
        done
    done
fi


exit 0
