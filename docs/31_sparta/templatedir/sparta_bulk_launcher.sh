#!/usr/bin/env bash

SPARTA_NSCALE=2 SPARTA_PPC=47 SPARTA_IS_KOKKOS_TOOLS="yes" APP_REPEAT=1 \
    sbatch \
        --nodes=2 \
        --account=fy140252 \
        --job-name=fcr30sparta \
        --time=0:59:59 \
        --partition=batch,short \
        sparta_sbatch_cts2.sh

exit 0
