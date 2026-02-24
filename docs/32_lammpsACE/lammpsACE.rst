**********
LAMMPS ACE
**********

.. note::
   The documentation herein needs to be updated for current
   performance.

This is the documentation for the benchmark [LAMMPS]_, specifically
KOKKOS-LAMMPS (see [KOKKOS-LAMMPS]_). The content herein was created
by the following authors (in alphabetical order).

- `Anthony M. Agelastos <mailto:amagela@sandia.gov>`_
- `Stan Moore <mailto:stamoor@sandia.gov>`_

This material is based upon work supported by the Sandia National
Laboratories (SNL), a multimission laboratory managed and operated by
National Technology and Engineering Solutions of Sandia under the
U.S. Department of Energy's National Nuclear Security Administration
under contract DE-NA0003525. Content herein considered unclassified
with unlimited distribution under SAND2023-01070O.


Purpose
=======

Heavily pulled from their [lammps-site]_:

   LAMMPS is a classical molecular dynamics code with a focus on
   materials modeling. It's an acronym for Large-scale
   Atomic/Molecular Massively Parallel Simulator. LAMMPS has
   potentials for solid-state materials (metals, semiconductors) and
   soft matter (biomolecules, polymers) and coarse-grained or
   mesoscopic systems. It can be used to model atoms or, more
   generically, as a parallel particle simulator at the atomic, meso,
   or continuum scale. LAMMPS runs on single processors or in parallel
   using message-passing techniques and a spatial-decomposition of the
   simulation domain. Many of its models have versions that provide
   accelerated performance on CPUs, GPUs, and Intel Xeon Phis. The
   code is designed to be easy to modify or extend with new
   functionality.


Characteristics
===============

The goal is to utilize the specified version of LAMMPS (see
:ref:`LAMMPSApplicationVersion`) that runs the benchmark problem (see
:ref:`LAMMPSProblem`) correctly (see :ref:`LAMMPSCorrectness` if
changes are made to LAMMPS).


.. _LAMMPSApplicationVersion:

Application Version
-------------------

The command to clone is provided below.

.. literalinclude:: lammps_clone.sh
   :language: sh
   :lines: 2-

.. note::
   The Git SHA will be updated with a tag soon.

The script to clone can be downloaded from :download:`lammps_clone.sh
<lammps_clone.sh>`. It can also be executed in place to clone into
``docs/32_lammpsACE/lammps``.
 
.. code-block:: bash

   cd docs/32_lammpsACE
   ./lammps_clone.sh


.. _LAMMPSProblem:

Problem
-------

This problem runs an ACE (atomic cluster expansion) machine-learned
potential for a copper crystal using a face-entered cubic (fcc)
lattice at 300 K. Please refer to [pace-site]_ and [pace-article]_ for
more information.

This problem is *mostly* present within the upstream LAMMPS
repository. The components of this problem are listed below (paths
given are within LAMMPS repository). Each of these files will need to
be copied into a run directory for the simulation.

``examples/PACKAGES/pace/Cu-PBE-core-rep.ace``
   This is an input needed for the simulation.

``examples/PACKAGES/pace/in.pace.product`` This is the default input
   file that controls the simulation. Some parameters within this file
   may need to be changed depending upon what is being run (i.e.,
   these parameters control how much memory it uses). The modified
   version of this within the template directory should be preferred;
   more on this below.

A template run directory was created to help ease performing a
simulation; this directory is ``templatedir``. There are some key
files within it.

``templatedir/in.pace.product``
   This is a modified version of the input file with some key
   parameters changed to be more appropriate as a benchmark. It is
   designed to run for approximately 11 minutes in 2 phases of 5.5
   minutes each. SPARTA already directly computes the FOM and outputs
   it for each of the phases. This second phase of 5.5 minutes is the
   FOM that is to be tracked.

``templatedir/lammps_ln.sh``
   This file creates symbolic links to files and folders needed for
   the simulation.

``templatedir/lammps_batch_elcapitan.sh``
   This is a batch script compatible with El Capitan. It has
   capabilities for setting key job parameters from the command line;
   more on that below.


An excerpt from this input file that has its key parameters is
provided below.

.. code-block::
   :emphasize-lines: 2

   <snip>
   variable        L index 64.0
   region          box block 0 ${L} 0 ${L} 0 ${L}
   <snip>
   pair_style      pace product chunksize 49152
   <snip>
   thermo_style    custom step cpu temp epair etotal press v_delenergy v_delpress
   <snip>
   ##################################
   ### Benchmarking modifications ###
   ##################################
   
   # Add a thermostat to keep temperature from falling
   variable        tdamp equal $(dt)
   fix             mynvt all nvt temp 300.0 300.0 ${tdamp}
   
   # Some systems buffer extensively
   thermo_modify   flush yes
   
   # Print out the value of L for parsing ease
   print "The value of L is $L" 
   
   ### Throw out first 5 minutes for hardware equilibrium
   
   # Stop after 5.5 minutes
   fix             2 all halt 10 tlimit > 330.0 message no error continue
   run             10000000
   
   ### Run another 5 minutes for final FOM
   unfix           2
   
   # Stop after 5.5 minutes
   fix             3 all halt 10 tlimit > 330.0 message no
   run             10000000

These parameters are described below.

``L``
   This corresponds to the **l**\ ength scale factor. This will scale
   the dimensions of the problem.

This problem exhibits different runtime characteristics whether or not
Kokkos is enabled. Specifically, there is some work that is performed
within Kokkos that helps to keep this problem as well behaved from a
throughput perspective as possible. Ergo, Kokkos must be enabled for
the simulations regardless of the hardware being used (the cases
herein have configurations that enable it for reference).


Figure of Merit
---------------


Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications. 

Building
========


Running
=======


Validation
==========


Example Scalability Results
===========================


Memory Usage
============


Strong Scaling on El Capitan
============================


Weak Scaling on El Capitan
==========================


References
==========

.. [LAMMPS] LAMMPS - a flexible simulation tool for particle-based
            materials modeling at the atomic, meso, and continuum scales,
            A. P. Thompson, H. M. Aktulga, R. Berger, D. S. Bolintineanu,
            W. M. Brown, P. S. Crozier, P. J. in't Veld, A. Kohlmeyer,
            S. G. Moore, T. D. Nguyen, R. Shan, M. J. Stevens, J. Tranchida,
            C. Trott, S. J. Plimpton, Comp Phys Comm, 271 (2022) 10817.
.. [lammps-site] LAMMPS Developers, 'LAMMPS Molecular Dynamics Simulator', 2026.
                 [Online]. Available: https://lammps.org. [Accessed: 15- Feb- 2026]
.. [pace-site] LAMMPS Developers, 'pair_style pace command - LAMMPS Documentation', 2026.
               [Online]. Available: https://docs.lammps.org/pair_pace.html#description
.. [pace-article] Lysogorskiy, Y., Oord, C.v.d., Bochkarev, A. et al.,
                  Performant implementation of the atomic cluster expansion (PACE)
                  and application to copper and silicon. NPJ Comput Mater 7, 97 (2021).
                  https://doi.org/10.1038/s41524-021-00559-9
.. [KOKKOS-LAMMPS] Anders Johansson, Evan Weinberg, Christian Trott, Megan McCarthy, and Stan Moore.
                   2025. LAMMPS-KOKKOS: Performance Portable Molecular Dynamics Across Exascale Architectures.
                   In Proceedings of the SC '25 Workshops of the International Conference for High Performance
                   Computing, Networking, Storage and Analysis (SC Workshops '25).
                   Association for Computing Machinery, New York, NY, USA, 1217–1232.
                   https://doi.org/10.1145/3731599.3767498
