#!/usr/bin/env bash

for m_ppc in ` seq 126 145 ` ; do
    SPARTA_NSCALE=1 SPARTA_PPC=${m_ppc} SPARTA_IS_KOKKOS_TOOLS="yes" APP_REPEAT=1 \
        sbatch \
            --nodes=1 \
            --account=fy140252 \
            --job-name=fcr30sparta \
            --time=0:14:59 \
            --partition=batch,short \
            sparta_sbatch_cts2.sh
    sleep 0.5
done

exit 0
