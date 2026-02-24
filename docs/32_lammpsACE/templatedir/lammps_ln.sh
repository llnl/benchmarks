#!/bin/sh

set -v

test ! -e lammps_env_elcapitan.sh        && ln -s ../lammps_env_elcapitan.sh
test ! -e kokkos_tools_env_elcapitan.sh  && ln -s ../kokkos_tools_env_elcapitan.sh
test ! -e lammps                         && ln -s ../lammps
test ! -e Cu-PBE-core-rep.ace            && ln -s ../lammps/examples/PACKAGES/pace/Cu-PBE-core-rep.ace

exit 0
