#!/usr/bin/env bash

SPARTA_NSCALE=1 SPARTA_PPC=46 \
    sbatch \
        --account=fy140252 \
        --partition=batch,short \
        sparta_sbatch_cts2.sh

exit 0
