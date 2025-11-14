#!/bin/bash
source ./laghos_env.sh

pushd $LAGHOS_ROOT/bin

export CALI_CONFIG="spot(profile.hip,rocm.gputime,profile.mpi,time.exclusive,time.variance)"

flux run -n 4 --exclusive -N 1 -g=1 laghos -p 3 -m default -nx 2 -ny 2 -nz 2 -rs 2 -rp 0 -ms 250 -ok 1 -ot 0 -oq 2 --fom --gpu-aware-mpi -d hip -pa -tf 0.0033 > linear.txt
flux run -n 4 --exclusive -N 1 -g=1 laghos -p 3 -m default -nx 2 -ny 2 -nz 2 -rs 2 -rp 0 -ms 250 -ok 2 -ot 1 -oq 3 --fom --gpu-aware-mpi -d hip -pa -tf 0.0033 > quadratic.txt
flux run -n 4 --exclusive -N 1 -g=1 laghos -p 3 -m default -nx 2 -ny 2 -nz 2 -rs 2 -rp 0 -ms 250 -ok 3 -ot 2 -oq 4 --fom --gpu-aware-mpi -d hip -pa -tf 0.0033 > cubic.txt

