#!/bin/sh

set -v

test ! -e air.species                    && ln -s ../sparta/examples/cylinder/air.species
test ! -e air.tce                        && ln -s ../sparta/examples/cylinder/air.tce
test ! -e air.vss                        && ln -s ../sparta/examples/cylinder/air.vss
test ! -e circle_R0.5_P10000.surf        && ln -s ../sparta/examples/cylinder/circle_R0.5_P10000.surf
test ! -e sparta_env_elcapitan.sh        && ln -s ../sparta_env_elcapitan.sh
test ! -e sparta_fom.py                  && ln -s ../sparta_fom.py
test ! -e kokkos_tools_env_elcapitan.sh  && ln -s ../kokkos_tools_env_elcapitan.sh
test ! -e sparta                         && ln -s ../sparta

exit 0
