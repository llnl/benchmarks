#!/usr/bin/env bash


for miel in 110 112 114 116 118 120 122 124 126 128 ; do
    sleep 0.5
    export MINIEM_ELEMENTS=${miel}
    flux batch --queue=admin --nodes=1  job-with-retry.sh
    flux batch --queue=admin --nodes=2  job-with-retry.sh
    flux batch --queue=admin --nodes=4  job-with-retry.sh
    flux batch --queue=admin --nodes=8  job-with-retry.sh
    flux batch --queue=admin --nodes=16 job-with-retry.sh
    flux batch --queue=admin --nodes=32 job-with-retry.sh
done


exit 0
