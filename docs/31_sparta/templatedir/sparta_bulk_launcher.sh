#!/usr/bin/env bash


# decide which to do
export IS_CTS2=${IS_CTS2:-0}
export IS_CTS2GPU=${IS_CTS2GPU:-0}
export IS_ELCAP=${IS_ELCAP:-1}

# loop over PPC for single-node weak scaling
for m_ppc in ` seq 45 20 205 ` ; do
    if test ${IS_CTS2} -eq 1 ; then
        DIR_TAG="run-cts2-" SPARTA_NSCALE=1 SPARTA_PPC=${m_ppc} SPARTA_IS_KOKKOS_TOOLS="yes" APP_REPEAT=1 \
            sbatch \
                --nodes=1 \
                --account=fy150069 \
                --job-name=fcr30sparta \
                --time=0:14:59 \
                --partition=batch,short \
                sparta_sbatch_cts2.sh
    fi

    if test ${IS_CTS2GPU} -eq 1 ; then
        DIR_TAG="run-cts2gpu-" SPARTA_NSCALE=1 SPARTA_PPC=${m_ppc} SPARTA_IS_KOKKOS_TOOLS="yes" APP_REPEAT=1 \
            sbatch \
                --nodes=1 \
                --ntasks=4 \
                --ntasks-per-node=4 \
                --cpus-per-task=28 \
                --gpus-per-task=1 \
                --gpu-bind=closest \
                --account=fy150069 \
                --time=0:14:59 \
                --partition=batch,short \
                --job-name=fcr30sparta \
                sparta_sbatch_cts2gpu.sh
    fi

    if test ${IS_ELCAP} -eq 1 ; then
        DIR_TAG="run-elcapitan-" SPARTA_NSCALE=1 SPARTA_PPC=${m_ppc} SPARTA_IS_KOKKOS_TOOLS="yes" APP_REPEAT=1 \
            flux batch sparta_batch_elcapitan.sh
    fi
    sleep 0.5
done


exit 0
