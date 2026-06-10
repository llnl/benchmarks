#!/bin/sh

set -x

test ! -e air.species                    && ln -s ../sparta/examples/cylinder/air.species
test ! -e air.tce                        && ln -s ../sparta/examples/cylinder/air.tce
test ! -e air.vss                        && ln -s ../sparta/examples/cylinder/air.vss
test ! -e circle_R0.5_P10000.surf        && ln -s ../sparta/examples/cylinder/circle_R0.5_P10000.surf
test ! -e sparta_env_elcapitan.sh        && ln -s ../sparta_env_elcapitan.sh
test ! -e sparta_env_cts2.sh             && ln -s ../sparta_env_cts2.sh
test ! -e sparta_env_cts2gpu.sh          && ln -s ../sparta_env_cts2gpu.sh
test ! -e kokkos_tools_env_elcapitan.sh  && ln -s ../kokkos_tools_env_elcapitan.sh
test ! -e kokkos_tools_env_cts2gpu.sh    && ln -s ../kokkos_tools_env_cts2gpu.sh
test ! -e sparta_src                     && ln -s ../sparta

exit 0
