#!/usr/bin/env bash

# This scripts extracts useful quantities from the resultant SPARTA
# output file. A sample excerpt is provided below for reference.
#
#<snip>
# KOKKOS mode is enabled (/tscratch/amagela/fcr/sparta-final/llnl-benchmarks-sparta/docs/31_sparta/sparta/src/KOKKOS/kokkos.cpp:40)
#   requested 0 GPU(s) per node
#   requested 1 thread(s) per MPI task
# Running on 112 MPI task(s)
#<snip>
# Particles per cell (ppc) = 47
#<snip>
# Weak scaling factor (nscale) = 1
#<snip>
#Performance: 1.481 timesteps/s, 486.612 Mparticle-step/s
#<snip>


file_name="log.sparta"

echo "FOM,PPC,NSCALE,ranks,GPUs/node,threads/rank,FILE"
find . \
     -type f \
     -name "${file_name}" \
     -print0 |
while IFS= read -r -d '' file; do  # <- read each name into $file
    gpus_per_node=`grep -oP 'requested.*?\K\d+(?=\s*GPU\(s\) per node)' "${file}" | sed -n '1{p;q;}'`
    threads_per_rank=`grep -oP 'requested.*?\K\d+(?=\s*thread\(s\) per MPI task)' "${file}" | sed -n '1{p;q;}'`
    ranks=`grep -oP 'Running on .*?\K\d+(?=\s*MPI task\(s\))' "${file}" | sed -n '1{p;q;}'`
    ppc=`grep -oP '^ Particles per cell \(ppc\) = \K[+-]?\d+' "${file}" | sed -n '1{p;q;}'`
    nscale=`grep -oP '^ Weak scaling factor \(nscale\) = \K[+-]?\d+' "${file}" | sed -n '1{p;q;}'`
    fom=`grep -oP '^Performance:.*?[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?.*?\K[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?' "${file}" | sed -n '2{p;q;}'`
    echo "${fom},${ppc},${nscale},${ranks},${gpus_per_node},${threads_per_rank},${file}"
done


exit 0
