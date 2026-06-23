#!/usr/bin/env bash

# This scripts extracts useful quantities from the resultant SPARTA
# output file(s). A sample excerpt is provided below for reference.
#
# SAMPLE log.sparta
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
#
# SAMPLE output-srun*.log
#<snip>
#BEGIN KOKKOS PROFILING REPORT:
#TOTAL TIME: 671.207 seconds
#<snip>
#Host process high water mark memory consumption: 852156 kB
#
#END KOKKOS PROFILING REPORT.


export IS_SPARTA_MEMORY=${IS_SPARTA_MEMORY:-0}

file_name="log.sparta"
file_result="${file_name}.csv"
file_tmp="${file_result}.tmp"

if test ${IS_SPARTA_MEMORY} -eq 0 ; then
    echo "PPC,NSCALE,ranks,GPUs/node,threads/rank,FOM,FILE" > "${file_tmp}"
else
    echo "PPC,NSCALE,ranks,GPUs/node,threads/rank,FOM,Host Mean MaxRSS (KiB),Host Mean Nodal MaxRSS (GiB),Max CUDA (KiB),Max Nodal CUDA (GiB),Max HIP (KiB),Max Nodal HIP (GiB),FILE" > "${file_tmp}"
fi

find . \
     -type f \
     -name "${file_name}" \
     -print0 |
while IFS= read -r -d '' file; do  # <- read each name into $file
    dir_spartalog="` dirname \"${file}\" `"
    gpus_per_node=`grep -oP 'requested.*?\K\d+(?=\s*GPU\(s\) per node)' "${file}" | sed -n '1{p;q;}'`
    threads_per_rank=`grep -oP 'requested.*?\K\d+(?=\s*thread\(s\) per MPI task)' "${file}" | sed -n '1{p;q;}'`
    ranks=`grep -oP 'Running on .*?\K\d+(?=\s*MPI task\(s\))' "${file}" | sed -n '1{p;q;}'`
    ppc=`grep -oP '^ Particles per cell \(ppc\) = \K[+-]?\d+' "${file}" | sed -n '1{p;q;}'`
    nscale=`grep -oP '^ Weak scaling factor \(nscale\) = \K[+-]?\d+' "${file}" | sed -n '1{p;q;}'`
    fom=`grep -oP '^Performance:.*?[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?.*?\K[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?' "${file}" | sed -n '2{p;q;}'`

    if test ${IS_SPARTA_MEMORY} -eq 0 ; then
        echo "${ppc},${nscale},${ranks},${gpus_per_node},${threads_per_rank},${fom},${file}" >> "${file_tmp}"
    else
        maxrss=`grep -zPo '(?m)^Host process high water mark memory consumption:[ \t]*\d+[ \t]*kB\n[ \t]*Max:[ \t]*\d+,[ \t]*Min:[ \t]*\d+,[ \t]*Ave:[ \t]*\K\d+(?=[ \t]*kB)' "${dir_spartalog}"/output-launcher*.log | tr '\0' '\n'`
        mem_host_node=`echo "((${maxrss}*(${ranks}/${nscale}))/1024)/1024" | bc -l`

        cuda_single=`grep -A2 -m1 '^KOKKOS CUDA SPACE:$' "${dir_spartalog}"/output-launcher*.log | grep -oP '^MAX MEMORY ALLOCATED:[[:space:]]*\K[-+]?[0-9]+(?:\.[0-9]+)?(?:[eE][-+]?[0-9]+)?(?=[[:space:]]*kB)'`
        cuda_node=`echo "((${cuda_single}*${gpus_per_node})/1024)/1024" | bc -l`

        hip_single=`grep -A2 -m1 '^KOKKOS HIP SPACE:$' "${dir_spartalog}"/output-launcher*.log | grep -oP '^MAX MEMORY ALLOCATED:[[:space:]]*\K[-+]?[0-9]+(?:\.[0-9]+)?(?:[eE][-+]?[0-9]+)?(?=[[:space:]]*kB)'`
        hip_node=`echo "((${hip_single}*4)/1024)/1024" | bc -l`

        echo "${ppc},${nscale},${ranks},${gpus_per_node},${threads_per_rank},${fom},${maxrss},${mem_host_node},${cuda_single},${cuda_node},${hip_single},${hip_node},${file}" >> "${file_tmp}"
    fi
    
done

(head -n 1 "${file_tmp}" && tail -n +2 "${file_tmp}" | sort -t, -k1,1n) > "${file_result}"
cat "${file_result}"
rm -f "${file_tmp}"


exit 0
