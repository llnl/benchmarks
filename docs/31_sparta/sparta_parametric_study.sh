#!/usr/bin/env bash

# Initialize variables
count=${count:-"1.00"}
limit=${limit:-"2.30"}
increment=${increment:-"0.05"}
dir_tag=${dir_tag:-"check-para--nodes-001--L"}

# Use bc to compare decimals in the while loop condition
while [ "$(bc <<< "$count < $limit")" == "1" ]; do
    echo "Current value: $count"
    dir_new="${dir_tag}-${count}"
    cp -a templatedir "${dir_new}"
    pushd "${dir_new}"
    fexit=1
    while [ ! $fexit -eq 0 ] ; do
        sleep 8
        sparta_len=${count} is_kokkos_tools=1 flux batch --nodes=1 sparta_batch_elcapitan.sh
        fexit=$?
    done
    popd
    count=$(bc <<< "$count + $increment")
done

exit 0
