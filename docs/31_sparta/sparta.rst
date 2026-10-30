******
SPARTA
******

.. note::
   There may be some gaps with the performance data.

This is the documentation for the benchmark [SPARTA]_. The content
herein was created by the following authors (in alphabetical order).

- `Anthony M. Agelastos <mailto:amagela@sandia.gov>`_
- `Michael A. Gallis <mailto:magalli@sandia.gov>`_
- `Stan Moore <mailto:stamoor@sandia.gov>`_

This material is based upon work supported by the Sandia National
Laboratories (SNL), a multimission laboratory managed and operated by
National Technology and Engineering Solutions of Sandia under the
U.S. Department of Energy's National Nuclear Security Administration
under contract DE-NA0003525. Content herein considered unclassified
with unlimited distribution under SAND2023-01070O.


Purpose
=======

Heavily pulled from their [site]_:

   SPARTA is an acronym for **S**\ tochastic **PA**\ rallel **R**\
   arefied-gas **T**\ ime-accurate **A**\ nalyzer. SPARTA is a
   parallel Direct Simulation Monte Carlo (DSMC) code for performing
   simulations of low-density gases in 2d or 3d. Particles advect
   through a hierarchical Cartesian grid that overlays the simulation
   box. The grid is used to group particles by grid cell for purposes
   of performing collisions and chemistry. Physical objects with
   triangulated surfaces can be embedded in the grid, creating cut and
   split grid cells. The grid is also used to efficiently find
   particle/surface collisions. SPARTA runs on single processors or in
   parallel using message-passing techniques and a
   spatial-decomposition of the simulation domain. The code is
   designed to be easy to modify or extend with new
   functionality. Running SPARTA and the input command syntax is very
   similar to the LAMMPS molecular dynamics code (but SPARTA and
   LAMMPS use different underlying algorithms).


Characteristics
===============

The goal is to utilize the specified version of SPARTA (see
:ref:`SPARTAApplicationVersion`) that runs the benchmark problem (see
:ref:`SPARTAProblem`) correctly (see :ref:`SPARTACorrectness` if
changes are made to SPARTA).


.. _SPARTAApplicationVersion:

Application Version
-------------------

The command to clone is provided below.

.. literalinclude:: sparta_clone.sh
   :language: sh
   :lines: 2-

.. note::
   This version of SPARTA has been updated to include the full
   inclusion of Kokkos 5 and the CMake build along with at-scale
   performance enhancements.

The script to clone can be downloaded from :download:`sparta_clone.sh
<sparta_clone.sh>`. It can also be executed in place to clone into
``docs/31_sparta/sparta``.
 
.. code-block:: bash

   cd docs/31_sparta
   ./sparta_clone.sh


.. _SPARTAProblem:

Problem
-------

This input sets up a SPARTA simulation of argon gas particles moving
through a 3-D box. The particles collide with each other using a
gas-physics collision model, so it represents collisional flow rather
than free molecular flow. The gas starts at a temperature of 273.15 K
with no overall flow velocity.
 
This benchmark is relevant to production because it exercises the main
costs of a DSMC simulation: particle movement, particle sorting into
cells, and particle collisions. It has good weak-scaling
characteristics, so it is useful for testing how well SPARTA performs
as the problem size and processor count grow on large supercomputers.
Although it has no surfaces, that still represents important
production-style physics problems, such as Taylor–Green turbulent flow
or Rayleigh–Taylor mixing, where the dominant work is in the
gas-particle dynamics rather than surface interactions. Surface-heavy
problems are often harder to use as clean benchmarks because load
imbalance can grow as processor domains get smaller, making it
difficult to separate algorithmic performance from geometry-induced
imbalance.

This problem models 2D hypersonic flow of nitrogen over a circle with
periodic boundary conditions in the z dimension, which physically
translates to 3D flow over a cylinder of infinite length. Particles
are continuously emitted from the 4 faces of the simulation box during
the simulation, bounce off the circle, and then exit. The hierarchical
cartesian grid is statically adapted to 6 levels around the
circle. The memory array used to hold particles is reordered by grid
cell every 100 timesteps to improve data locality and cache access
patterns.

This problem is a modified version of an existing benchmark problem
within the SPARTA repository. Adding it formally is being actively
discussed. The components of this problem are listed below (paths
given are within SPARTA repository). Each of these files will need to
be copied into a run directory for the simulation.

``in.collide_halt_balance``
   This is the default input file that controls the simulation. Some
   parameters within this file may need to be changed depending upon
   what is being run (e.g., these parameters control how much memory
   it uses). 


An excerpt from this input file that has its key parameters is
provided below.

.. code-block::
   :emphasize-lines: 18,32,35,38,39,48,49,55,56

   # advect particles via VSS collisional flow on a uniform grid
   # particles reflect off global box boundaries
   #
   # Balanced weak-scaling version.
   #
   # Assumptions:
   #   nscale = number of nodes
   #   4 MPI ranks / GPUs per node
   #   total MPI ranks = 4*nscale
   #   nscale must be a power of 2
   #
   # Goal:
   #   Every MPI rank owns a cubic local grid:
   #     nloc x nloc x nloc
   #
   # The global domain may be non-cubic.

   variable            nscale index 1
   variable            ppc index 10

   global              optmove yes particle/reorder 10
   # Help debug slow nodes...
   # global              timer/rank yes timer/file timings.txt

   # -------------------------------------------------------------------------
   # Local grid size per MPI rank
   #
   # 305^3 = 28,372,625 cells/rank
   # with ppc=10 -> 283,726,250 particles/rank
   # -------------------------------------------------------------------------

   variable            nloc index 305
   <snip>
   stats_style         step cpu spcpu np nattempt ncoll
   stats               10
   stats_modify        flush yes
   <snip>
   timestep            7.00E-8
   run                 30
   <snip>
   ###################################
   # Output
   ###################################

   stats               0

   # Stop after 5.5 minutes
   fix             1 halt 10 tlimit > 330.0 message no error continue
   run             1000000

   unfix           1
   reset_timestep 0

   # Stop after 5.5 minutes
   fix             2 halt 10 tlimit > 330.0 message no
   run             1000000

   These parameters are described below.

``nloc``
   This corresponds to the **l**\ ength scale factor. This will scale
   the x and y dimensions of the problem, e.g., a doubling of this
   parameter will result in a domain that is 4x larger. This is used
   to weak scale a problem, e.g., setting this to 32 would be
   sufficient to weak scale a single-node problem onto 1,024 nodes.

``nscale``
   This sets the **p**\ articles **p**\ er **c**\ ell variable. This
   variable controls the size of the problem and, accordingly, the
   amount of memory it uses. Adjust this if the initial memory size is
   too high and a value of ``L`` would need to be less than 1.0.

``stats``
   This sets the interval at which the output required to compute the
   :ref:`SPARTAFigureOfMerit` is generated. In general, it is good to
   select a value that will produce approx. 20 entries between the
   time range of interest. If it produces too much data, then it may
   slow down the simulaton.  If it produces too little, then it may
   adversely impact the FOM calculations.

``stats_modify flush yes``
   This enables the log output to buffer continuously on El Capitan.

``run 30``
   This sets the first sub-job to run for 30 steps at a large timestep
   to unsort the particle array.

``fix 1 halt 10 tlimit > 330.0 message no error continue``
   This sets the second sub-job termination to 330.0 seconds of wall
   time by checking on progress up to every 10 steps. This is the
   transient period whose performance will be discarded.

``fix 2 halt 10 tlimit > 330.0 message no``
   This sets the third sub-job termination to 330.0 seconds of wall
   time by checking on progress up to every 10 steps. This is the
   period whose performance will be evaluated. The simulation will
   stop afterwards.

.. note::

   First, one scales the problem size on a single node to match the
   needed memory characteristics via ``nloc``. Then, one weak scales
   from a single node to an arbitrary number by changing
   ``nscale``. Both of these parameters are defined via ``index``, so
   they can be altered on the command line invocation of SPARTA.

Due to differences in how memory is allocated, Kokkos must be enabled
for the simulation regardless of the hardware being used. If Kokkos is
enabled, the following excerpts should be found within the log file.

.. code-block::
   :emphasize-lines: 2,6
   
   SPARTA (dd mmm yyyy)
   KOKKOS mode is enabled (/path/to/kokkos.cpp:40)
     requested 1 GPU(s) per node
     requested 1 thread(s) per MPI task
   Running on 4 MPI task(s)
   package kokkos


.. _SPARTAFigureOfMerit:

Figure of Merit
---------------

Each SPARTA simulation writes out a file named "log.sparta". At the
end of this simulation is a block that resembles the following
example.

.. code-block::

       Step          CPU        S/CPU         Np      Natt     Ncoll
          0            0            0 9079240000 903884280 641603306
        200    24.009253    8.3301203 9079240000 903879874 641591530
   Loop time of 24.3716 on 32 procs for 200 steps with 9079240000 particles
   Performance: 8.206 timesteps/s, 74.507 Gparticle-step/s

The Figure of Merit (**FOM**) is "Gparticle-step/s", which can be
directly extracted from the last line of the 3rd sub-job's performance
output (which resembles the block above). Sometimes it is useful to
normalize the FOM by the number of nodes. The ultimate goal is to
maximize this throughput FOM while utilizing at least 50% of available
memory.


.. _SPARTACorrectness:

Correctness
-----------

The aforementioned relevant block of output within "log.sparta" is
replicated below.

.. code-block::

       Step          CPU        S/CPU         Np      Natt     Ncoll
          0            0            0 9079240000 903884280 641603306
        200    24.009253    8.3301203 9079240000 903879874 641591530
   Loop time of 24.3716 on 32 procs for 200 steps with 9079240000 particles
   Performance: 8.206 timesteps/s, 74.507 Gparticle-step/s

There are several columns of interest regarding correctness; these are
listed below.

``Step``
   This is the step number and is the first column.

``CPU``
   This is the elapsed time and is the second column.

``S/CPU``
   This is the number of steps per CPU. It is a simulation rate that
   allows one to view relative performance across different output
   steps.

``Np``
   This is the number of particles and is the third column.

``Natt``
   This is the number of attempts and is the fourth column.

``Ncoll``
   This is the number of collisions and is the fifth column.

Assessing the correctness will involve comparing these quantities
across modified (henceforth denoted with "mod" subscript) and
unmodified ("unmod" subscript) SPARTA subject to the methodology
below.

The **first** step is to adjust the ``run`` input file parameter so
that SPARTA\ :sub:`mod` has ``CPU`` output that exceeds 600 seconds
(per :ref:`SPARTAFigureOfMerit`). Also, adjust the ``stats`` parameter
to a value of 1 so fine-grained output is generated; if this is
significantly slowing down computation, then it can be increased to a
value of 10. Then, produce output from SPARTA\ :sub:`unmod` with the
same ``run`` and ``stats`` settings.

The **second** step is to compute the absolute differences between
modified and unmodified SPARTA for ``Np``, ``Natt``, and ``Ncoll`` for
each row, *i*, whose ``Step`` is relevant for the FOM for SPARTA\
:sub:`mod`,

.. math::
   \Delta \texttt{Np}_i &= | \texttt{Np}_{\textrm{mod},i}-\texttt{Np}_{\textrm{unmod},i} | \\
   \Delta \texttt{Natt}_i &= | \texttt{Natt}_{\textrm{mod},i}-\texttt{Natt}_{\textrm{unmod},i} | \\
   \Delta \texttt{Ncoll}_i &= | \texttt{Ncoll}_{\textrm{mod},i}-\texttt{Ncoll}_{\textrm{unmod},i} |

where

* *i* is each line whose ``CPU`` time is between 300 and 600 seconds for SPARTA\ :sub:`mod`

The **third** step is to compute the arithmetic mean of each of the
aforementioned quantities over the *n* rows,

.. math::
   \mu _{\Delta \texttt{Np}} &= \frac{\sum_{i} \Delta \texttt{Np}_i}{n} \\
   \mu _{\Delta \texttt{Natt}} &= \frac{\sum_{i} \Delta \texttt{Natt}_i}{n} \\
   \mu _{\Delta \texttt{Ncoll}} &= \frac{\sum_{i} \Delta \texttt{Ncoll}_i}{n}

where

.. math::
   n = \sum_{i} 1

The **fourth** step is to compute the arithmetic mean of the *n*
matching rows of the unmodified SPARTA,

.. math::
   \mu _{\texttt{Np},\textrm{unmod}} &= \frac{\sum_{i} \texttt{Np}_{\textrm{unmod},i}}{n} \\
   \mu _{\texttt{Natt},\textrm{unmod}} &= \frac{\sum_{i} \texttt{Natt}_{\textrm{unmod},i}}{n} \\
   \mu _{\texttt{Ncoll},\textrm{unmod}} &= \frac{\sum_{i} \texttt{Ncoll}_{\textrm{unmod},i}}{n}

The **fifth** step is to normalize the differences with the baseline
values to create the error ratios,

.. math::
   \varepsilon _{\texttt{Np}} &= \frac{\mu _{\Delta \texttt{Np}}}{\mu _{\texttt{Np},\textrm{unmod}}} \\
   \varepsilon _{\texttt{Natt}} &= \frac{\mu _{\Delta \texttt{Natt}}}{\mu _{\texttt{Natt},\textrm{unmod}}} \\
   \varepsilon _{\texttt{Ncoll}} &= \frac{\mu _{\Delta \texttt{Ncoll}}}{\mu _{\texttt{Ncoll},\textrm{unmod}}}

The **sixth** and final step is to check over all of the error ratios
and if any of them exceed 25%, then the modifications are not approved
without discussing them with this benchmark's authors. This is the
same criteria that SPARTA uses for its own testing. The success
criteria are:

.. math::
   \varepsilon _{\texttt{Np}} &\le 25\% \\
   \varepsilon _{\texttt{Natt}} &\le 25\% \\
   \varepsilon _{\texttt{Ncoll}} &\le 25\%


System Information
==================

The platforms utilized for benchmarking activities are listed and
described below.

* Advanced Technology System 4 (ATS-4), also known as El Capitan (see
  :ref:`ElCapitanSystemDescription`)
* Commodity Technology System 2 (CTS-2) with 4x Nvidia H100 GPUs, also
  known as Hops.


Building
========

A script (``sparta_clone.sh``) is provided to clone the SPARTA
repository within the "sparta" folder. Instructions are provided on
how to build SPARTA for the following systems:

* Generic (see :ref:`BuildSpartaGeneric`)
* Advanced Technology System 4 (ATS-4), also known as El Capitan (see
  :ref:`BuildSpartaATS4`)
* Commodity Technology System 2 (CTS-2) with 4x Nvidia H100 GPUs, also
  known as Hops (see :ref:`BuildSpartaCTS2GPU`)


.. _BuildSpartaGeneric:

Generic
-------

Refer to SPARTA's [sparta-build]_ documentation for generic
instructions.


.. _BuildSpartaATS4:

El Capitan
----------

Instructions for building on El Capitan are provided below. These
instructions assume this repository has been cloned and that the
current working directory is at the top level of this repository. 

.. code-block:: bash

   cd docs/31_sparta
   ./sparta_build_elcapitan.sh

The script discussed above is :download:`sparta_build_elcapitan.sh
<sparta_build_elcapitan.sh>` and is produced below for convenience and
reference.

.. literalinclude:: sparta_build_elcapitan.sh
   :language: bash


.. _BuildSpartaCTS2GPU:

Hops
----

Instructions for building on Hops are provided below. These
instructions assume this repository has been cloned and that the
current working directory is at the top level of this repository.

.. code-block:: bash

   cd docs/31_sparta
   ./sparta_build_hops.sh

The script discussed above is :download:`sparta_build_hops.sh
<sparta_build_hops.sh>` and is produced below for convenience and
reference.

.. literalinclude:: sparta_build_hops.sh
   :language: bash


Running
=======

Instructions are provided on how to run SPARTA for the following
systems:

* Advanced Technology System 4 (ATS-4), also known as El Capitan (see
  :ref:`SPARTARunATS4`)
  * Profiling with Kokkos Tools on El Capitan (see
    :ref:`SPARTAProfileKokkosToolsElCapitan`)
* Commodity Technology System 2 (CTS-2) with 4x Nvidia H100 GPUs, also
  known as Hops (see :ref:`SpartaRunCTS2GPU`)
  * Profiling with Kokkos Tools on Hops (see
    :ref:`SPARTAProfileKokkosToolsHops`)


.. _SPARTARunATS4:

El Capitan
----------

An example for performing simulations on El Capitan is provided below.

.. code-block:: bash

   # first, copy templatedir into something useful
   cp -a templatedir useful

   # next, go into the run folder
   cd useful

   # submit job and set parameters on command line if desired
   #   this example sets nloc (aka sparta_nloc) to 355
   #   this example turns on Kokkos Tools profiling (aka kokkos_tools)
   #   this example runs on 1 node (aka --nodes=1)
   sparta_nloc=355 is_kokkos_tools=1 flux batch --nodes=1 sparta_batch_elcapitan.sh


.. _SPARTAProfileKokkosToolsElCapitan:

Profiling with Kokkos Tools
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Scripts are provided to clone and build Kokkos Tools. The steps to do
both are provided below.

.. code-block:: bash

   # go into the SPARTA documentation folder
   cd docs/31_sparta

   # clone Kokkos Tools
   ./kokkos_tools_clone.sh

   # build Kokkos Tools' Space Time
   ./kokkos_tools_build_elcapitan.sh

Once built, the command line variable ``is_kokkos_tools`` can be set
to ``1`` for the batch script to turn it on. After a successful run,
it will output additional memory information. An example of this (for
``L`` equal to 2.0 and ``ppc`` equal to 47) on El Capitan is provided
below that shows approximately 82.2 GB of memory allocated on each
GPU.

.. code-block::

   KOKKOS HIP SPACE:
   ===================
   MAX MEMORY ALLOCATED: 82222221.9 kB


.. _SPARTARunCTS2GPU:

Hops
----

An example for performing simulations on Hops is provided below.

.. code-block:: bash

   # first, copy templatedir into something useful
   cp -a templatedir useful

   # next, go into the run folder
   cd useful

   # submit job and set parameters on command line if desired
   #   this example sets nloc (aka sparta_nloc) to 355
   #   this example turns on Kokkos Tools profiling (aka kokkos_tools)
   #   this example runs on 1 node (aka --nodes=1)
   sparta_nloc=355 is_kokkos_tools=1 sbatch --nodes=1 sparta_batch_hops.sh


.. _SPARTAProfileKokkosToolsHops:

Profiling with Kokkos Tools
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Scripts are provided to clone and build Kokkos Tools. The steps to do
both are provided below.

.. code-block:: bash

   # go into the SPARTA documentation folder
   cd docs/31_sparta

   # clone Kokkos Tools
   ./kokkos_tools_clone.sh

   # build Kokkos Tools' Space Time
   ./kokkos_tools_build_hops.sh

Once built, the command line variable ``is_kokkos_tools`` can be set
to ``1`` for the batch script to turn it on. After a successful run,
it will output additional memory information. An example of this (for
``L`` equal to 2.0 and ``ppc`` equal to 47) on El Capitan is provided
below that shows approximately 82.2 GB of memory allocated on each
GPU.

.. code-block::

   KOKKOS CUDA SPACE:
   ===================
   MAX MEMORY ALLOCATED: 82222221.9 kB


.. _SPARTAResults:

Verification of Results
=======================

Additional information:

* The sub-section :ref:`SPARTAComputeFOM` describes how to compute the
  FOM

Single-node results from SPARTA are provided on the following systems:

* Advanced Technology System 4 (ATS-4), also known as El Capitan (see
  :ref:`ResultsSpartaATS4`)
* Commodity Technology System 2 (CTS-2) with 4x Nvidia H100 GPUs, also
  known as Hops (see :ref:`ResultsSpartaCTS2GPU`).

Multi-node results from SPARTA are provided on the following system(s):

* Advanced Technology System 4 (ATS-4), also known as El Capitan (see
  :ref:`ResultsSpartaScaleATS4`)
* Commodity Technology System 2 (CTS-2) with 4x Nvidia H100 GPUs, also
  known as Hops (see :ref:`ResultsSpartaScaleCTS2GPU`).


.. _SPARTAComputeFOM:

Compute Figure of Merit
-----------------------

As stated in :ref:`SPARTAFigureOfMerit`, the FOM is the QOI directly
extracted from the SPARTA log file divided by the number of nodes.


.. _ResultsSpartaATS4:

El Capitan - Single Node
------------------------

.. note::
   This data is forthcoming.

Hops - Single Node
------------------

.. note::
   This data is forthcoming.


.. _ResultsSpartaScaleATS4:

El Capitan - Many Nodes
-----------------------

The weak-scaling data are provided in
  :download:`elcapitan-weakscaling.csv <elcapitan-weakscaling.csv>`.

  .. csv-table:: SPARTA weak-scaling results on El Capitan
     :file: elcapitan-weakscaling.csv
     :header-rows: 1
     :widths: 15 30 30 25

  .. figure:: elcapitan-weakscaling.png
     :alt: SPARTA weak-scaling FOM on El Capitan from 1 to 4096 nodes, with parallel efficiency
  annotations.
     :align: center
     :width: 90%

     SPARTA weak-scaling Figure of Merit on El Capitan. Point annotations show
     the corresponding parallel efficiency at each node count.


.. _ResultsSpartaScaleCTS2GPU:

Hops - Many Nodes
-----------------

.. note::
   This data is forthcoming.


References
==========

.. [SPARTA] S. J. Plimpton and S. G. Moore and A. Borner and A. K. Stagg
            and T. P. Koehler and J. R. Torczynski and M. A. Gallis, 'Direct
            Simulation Monte Carlo on petaflop supercomputers and beyond',
            2019, Physics of Fluids, 31, 086101.
.. [site] M. Gallis and S. Plimpton and S. Moore, 'SPARTA Direct Simulation
          Monte Carlo Simulator', 2023. [Online]. Available:
          https://sparta.github.io. [Accessed: 22- Feb- 2023]
.. [sparta-build] M. Gallis and S. Plimpton and S. Moore, 'SPARTA Documentation Getting
                  Started', 2023. [Online]. Available:
                  https://sparta.github.io/doc/Section_start.html#start_2. [Accessed:
                  26- Mar- 2023]
