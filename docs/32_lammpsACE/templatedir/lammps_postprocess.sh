#!/usr/bin/env bash

# This scripts extracts useful quantities from the resultant LAMMPS
# output file(s). A sample excerpt is provided below for reference.
#


export IS_LAMMPS_MEMORY=${IS_LAMMPS_MEMORY:-0}

file_name="log.lammps"
file_result="${file_name}.csv"
file_tmp="${file_result}.tmp"

if test ${IS_LAMMPS_MEMORY} -eq 0 ; then
    echo "PACE CHUNK SIZE,NSCALE,GPUs/node,FOM,FILE" > "${file_tmp}"
else
    echo "PACE CHUNK SIZE,NSCALE,GPUs/node,FOM,Host Mean MaxRSS (KiB),Host Mean Nodal MaxRSS (GiB),Max CUDA (KiB),Max Nodal CUDA (GiB),Max HIP (KiB),Max Nodal HIP (GiB),FILE" > "${file_tmp}"
fi

find . \
     -type f \
     -name "${file_name}" \
     -print0 |
while IFS= read -r -d '' file; do  # <- read each name into $file
    dir_lammpslog="` dirname \"${file}\" `"
    gpus_per_node=`grep -oP 'will use up to.*?\K\d+(?=\s*GPU\(s\) per node)' "${file}" | sed -n '1{p;q;}'`
    nscale=`grep -oP '^ Weak scaling factor \(nscale\) = \K[+-]?\d+' "${file}" | sed -n '1{p;q;}'`
    pacechunksize=`grep -oP '^ PACE Chunk Size \(pacechunksize\) = \K[+-]?\d+' "${file}" | sed -n '1{p;q;}'`
    fom=`grep -m2 '^Performance:' "${file}" | tail -n 1 | grep -oP '^Performance:\s*(?:[-+]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][-+]?[0-9]+)?[^0-9+-]+){3}\K[-+]?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)(?:[eE][-+]?[0-9]+)?'`

    if test ${IS_LAMMPS_MEMORY} -eq 0 ; then
        echo "${ppc},${nscale},${gpus_per_node},${fom},${file}" >> "${file_tmp}"
    else
        maxrss=`grep -zPo '(?m)^Host process high water mark memory consumption:[ \t]*\d+[ \t]*kB\n[ \t]*Max:[ \t]*\d+,[ \t]*Min:[ \t]*\d+,[ \t]*Ave:[ \t]*\K\d+(?=[ \t]*kB)' "${dir_spartalog}"/output-launcher*.log | tr '\0' '\n'`
        mem_host_node=`echo "((${maxrss}*(${ranks}/${nscale}))/1024)/1024" | bc -l`

        cuda_single=`grep -A2 -m1 '^KOKKOS CUDA SPACE:$' "${dir_spartalog}"/output-launcher*.log | grep -oP '^MAX MEMORY ALLOCATED:[[:space:]]*\K[-+]?[0-9]+(?:\.[0-9]+)?(?:[eE][-+]?[0-9]+)?(?=[[:space:]]*kB)'`
        cuda_node=`echo "((${cuda_single}*${gpus_per_node})/1024)/1024" | bc -l`

        hip_single=`grep -A2 -m1 '^KOKKOS HIP SPACE:$' "${dir_spartalog}"/output-launcher*.log | grep -oP '^MAX MEMORY ALLOCATED:[[:space:]]*\K[-+]?[0-9]+(?:\.[0-9]+)?(?:[eE][-+]?[0-9]+)?(?=[[:space:]]*kB)'`
        hip_node=`echo "((${hip_single}*4)/1024)/1024" | bc -l`

        echo "${pacechunksize},${nscale},${gpus_per_node},${fom},${maxrss},${mem_host_node},${cuda_single},${cuda_node},${hip_single},${hip_node},${file}" >> "${file_tmp}"
    fi
    
done

(head -n 1 "${file_tmp}" && tail -n +2 "${file_tmp}" | sort -t, -k1,1n) > "${file_result}"
cat "${file_result}"
rm -f "${file_tmp}"


exit 0
