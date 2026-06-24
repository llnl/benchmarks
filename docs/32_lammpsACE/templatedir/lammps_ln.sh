#!/bin/sh

set -v

test ! -e lammps                         && ln -s ../lammps
test ! -e Cu-PBE-core-rep.ace            && ln -s ../lammps/potentials/Cu-PBE-core-rep.ace

exit 0
