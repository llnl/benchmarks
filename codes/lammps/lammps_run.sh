#!/bin/bash
source ./lammps_env.sh

pushd $LAMMPS_DIR
rm -rf run
mkdir -p run
cd run
cp -r ../../examples/PACKAGES/pace/* .
rm Cu-PBE-core-rep.ace
cp ../../potentials/Cu-PBE-core-rep.ace .
sed -i -e 's/lattice .*/lattice fcc $a/g' -i in.pace.product
sed -i -e 's/box block .*/box block 0 64 0 64 0 64/g' -i in.pace.product
sed 's/run.*[0-9]+/run		100/g' -i in.pace.product
flux run -n 4 --exclusive -N 1 -g 1 ../bin/lmp -i in.pace.product -k on g 1 -sf kk -pk kokkos gpu/aware on neigh half comm device neigh/qeq full newton on -nocite > 64x64x64_4.txt
flux run -n 8 --exclusive -N 2 -g 1 ../bin/lmp -i in.pace.product -k on g 1 -sf kk -pk kokkos gpu/aware on neigh half comm device neigh/qeq full newton on -nocite > 64x64x64_8.txt
flux run -n 16 --exclusive -N 4 -g 1 ../bin/lmp -i in.pace.product -k on g 1 -sf kk -pk kokkos gpu/aware on neigh half comm device neigh/qeq full newton on -nocite > 64x64x64_16.txt
flux run -n 32 --exclusive -N 8 -g 1 ../bin/lmp -i in.pace.product -k on g 1 -sf kk -pk kokkos gpu/aware on neigh half comm device neigh/qeq full newton on -nocite > 64x64x64_32.txt
flux run -n 64 --exclusive -N 16 -g 1 ../bin/lmp -i in.pace.product -k on g 1 -sf kk -pk kokkos gpu/aware on neigh half comm device neigh/qeq full newton on -nocite > 64x64x64_64.txt
popd
