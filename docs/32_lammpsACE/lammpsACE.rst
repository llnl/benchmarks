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
   :emphasize-lines: 2,7

   <snip>
   variable        L index 64.0
   region          box block 0 ${L} 0 ${L} 0 ${L}
   <snip>
   pair_style      pace product chunksize 49152
   <snip>
   thermo          10
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

``thermo``
   Compute and print thermodynamic info (e.g., temperature, energy,
   pressure) on timesteps that are a multiple of this parameter and at
   the beginning and end of a simulation.

This problem exhibits different runtime characteristics whether or not
Kokkos is enabled. Specifically, there is some work that is performed
within Kokkos that helps to keep this problem as well behaved from a
throughput perspective as possible. Ergo, Kokkos must be enabled for
the simulations regardless of the hardware being used (the cases
herein have configurations that enable it for reference).


Figure of Merit
---------------

Each LAMMPS simulation writes out a file named "log.lammps". At the
end of this simulation is a block that resembles the following
example.

.. code-block::
   :emphasize-lines: 11

   Step         CPU        Temp       E_pair       TotEng       Press      v_delenergy       v_delpress  
    640   0           299.7264    -3834241     -3793616.4   62562.774   -3.7252903e-08    4.8748916e-10
    650   5.1882405   300.1416    -3834085.9   -3793405     62656.487    3.7252903e-08    2.2555469e-10
    660   10.389581   300.04536   -3834003.9   -3793336     62705.836   -1.4901161e-08    2.910383e-11 
   <snip>
   1260   323.38353   300.55705   -3834187.5   -3793450.4   62842.117    9.778887e-09     1.5279511e-10
   1270   328.58739   300.25528   -3834141.7   -3793445.4   62861.607    1.0244548e-08   -5.0931703e-10
   1280   333.79045   300.1357    -3834154.7   -3793474.6   62856.262   -1.1641532e-08    1.6734703e-10
   Loop time of 333.812 on 4 procs for 640 steps with 1048576 atoms

   Performance: 0.083 ns/day, 289.767 hours/ns, 1.917 timesteps/s, 2.010 Matom-step/s
   45.1% CPU use with 4 MPI tasks x 1 OpenMP threads

The quantity of interest (QOI) is "Mega atom steps per second," which
is directly computed as ``Matom-step/s`` in the example above.

It is desired to capture the FOM for varying problem sizes that
encompass utilizing 50% to 80% of available memory (when all PEs are
utilized). The ultimate goal is to maximize this throughput FOM while
utilizing at least 50% of available memory.


.. _LAMMPSCorrectness:

Correctness
-----------

The aforementioned relevant block of output within "log.lammps" is
replicated below.

.. code-block::
   :emphasize-lines: 2,3,4,6,7,8

   Step         CPU        Temp       E_pair       TotEng       Press      v_delenergy       v_delpress  
    640   0           299.7264    -3834241     -3793616.4   62562.774   -3.7252903e-08    4.8748916e-10
    650   5.1882405   300.1416    -3834085.9   -3793405     62656.487    3.7252903e-08    2.2555469e-10
    660   10.389581   300.04536   -3834003.9   -3793336     62705.836   -1.4901161e-08    2.910383e-11 
   <snip>
   1260   323.38353   300.55705   -3834187.5   -3793450.4   62842.117    9.778887e-09     1.5279511e-10
   1270   328.58739   300.25528   -3834141.7   -3793445.4   62861.607    1.0244548e-08   -5.0931703e-10
   1280   333.79045   300.1357    -3834154.7   -3793474.6   62856.262   -1.1641532e-08    1.6734703e-10
   Loop time of 333.812 on 4 procs for 640 steps with 1048576 atoms

   Performance: 0.083 ns/day, 289.767 hours/ns, 1.917 timesteps/s, 2.010 Matom-step/s
   45.1% CPU use with 4 MPI tasks x 1 OpenMP threads

There are several columns of interest regarding correctness; these are
listed below.

``Step``
   This is the step number and is the first column.

``Temp``
   This tracks the temperature aspect of the simulation.

``Press``
   This tracks the pressure aspect of the simulation.

Assessing the correctness will involve comparing these quantities
across modified (henceforth denoted with "mod" subscript) and
unmodified ("unmod" subscript) LAMMPS subject to the methodology
below.

The **first** step is to adjust the ``thermo`` parameter
to a value of 1 so fine-grained output is generated; if this is
significantly slowing down computation, then it can be increased to a
value of 10. Then, produce output from LAMMPS\ :sub:`unmod` with the
same settings.

The **second** step is to compute the absolute differences between
modified and unmodified LAMMPS for ``Temp`` and ``Press`` for each
row, *i*, whose ``Step`` is relevant for the FOM for LAMMPS\
:sub:`mod`,

.. math::
   \Delta \texttt{Temp}_i &= | \texttt{Temp}_{\textrm{mod},i}-\texttt{Temp}_{\textrm{unmod},i} | \\
   \Delta \texttt{Press}_i &= | \texttt{Press}_{\textrm{mod},i}-\texttt{Press}_{\textrm{unmod},i} | \\

where

* *i* is each line whose ``CPU`` time is part of the second phase for LAMMPS\ :sub:`mod`

The **third** step is to compute the arithmetic mean of each of the
aforementioned quantities over the *n* rows,

.. math::
   \mu _{\Delta \texttt{Temp}} &= \frac{\sum_{i} \Delta \texttt{Temp}_i}{n} \\
   \mu _{\Delta \texttt{Press}} &= \frac{\sum_{i} \Delta \texttt{Press}_i}{n} \\

where

.. math::
   n = \sum_{i} 1

The **fourth** step is to compute the arithmetic mean of the *n*
matching rows of the unmodified LAMMPS,

.. math::
   \mu _{\texttt{Temp},\textrm{unmod}} &= \frac{\sum_{i} \texttt{Temp}_{\textrm{unmod},i}}{n} \\
   \mu _{\texttt{Press},\textrm{unmod}} &= \frac{\sum_{i} \texttt{Press}_{\textrm{unmod},i}}{n} \\

The **fifth** step is to normalize the differences with the baseline
values to create the error ratios,

.. math::
   \varepsilon _{\texttt{Temp}} &= \frac{\mu _{\Delta \texttt{Temp}}}{\mu _{\texttt{Temp},\textrm{unmod}}} \\
   \varepsilon _{\texttt{Press}} &= \frac{\mu _{\Delta \texttt{Press}}}{\mu _{\texttt{Press},\textrm{unmod}}} \\

The **sixth** and final step is to check over all of the error ratios
and if any of them exceed 5%, then the modifications are not approved
without discussing them with this benchmark's authors. The success
criteria are:

.. math::
   \varepsilon _{\texttt{Temp}} &\le 5\% \\
   \varepsilon _{\texttt{Press}} &\le 5\%

 
Source Code Modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed
modifications.


System Information
==================

The platforms utilized for benchmarking activities are listed and
described below.

* Advanced Technology System 4 (ATS-4), also known as El Capitan (see
  :ref:`ElCapitanSystemDescription`)


Building
========

A script (``lammps_clone.sh``) is provided to clone the LAMMPS
repository within the "lammps" folder. Instructions are provided on
how to build LAMMPS for the following systems:

* Generic (see :ref:`BuildLammpsGeneric`)
* Advanced Technology System 4 (ATS-4), also known as El Capitan (see
  :ref:`BuildLammpsATS4`)


.. _BuildLammpsGeneric:

Generic
-------

Refer to LAMMP's [lammps-build]_ documentation for generic
instructions.


.. _BuildLammpsATS4:

El Capitan
----------

Instructions for building on El Capitan are provided below. These
instructions assume this repository has been cloned and that the
current working directory is at the top level of this repository. 

.. code-block:: bash

   cd docs/32_lammpsACE
   ./lammps_build_elcapitan.sh

The script discussed above is :download:`lammps_build_elcapitan.sh
<lammps_build_elcapitan.sh>` and is produced below for convenience and
reference.

.. literalinclude:: lammps_build_elcapitan.sh
   :language: bash


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
.. [lammps-build] LAMMPS Developers, 'LAMMPS Documentation', 2026.
                 [Online]. Available: https://dics.lammps.org/Manual.html.
                 [Accessed: 15- Feb- 2026]
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
