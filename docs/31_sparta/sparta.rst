******
SPARTA
******

.. note::
   The documentation herein needs to be updated for current
   performance.

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
   The Git SHA will be updated with a tag soon.

The script to clone can be downloaded from :download:`sparta_clone.sh
<sparta_clone.sh>`. It can also be executed in place to clone into
``docs/31_sparta/sparta``.
 
.. code-block:: bash

   cd docs/31_sparta
   ./sparta_clone.sh


.. _SPARTAProblem:

Problem
-------

This problem models 2D hypersonic flow of nitrogen over a circle with
periodic boundary conditions in the z dimension, which physically
translates to 3D flow over a cylinder of infinite length. Particles
are continuously emitted from the 4 faces of the simulation box during
the simulation, bounce off the circle, and then exit. The hierarchical
cartesian grid is statically adapted to 6 levels around the
circle. The memory array used to hold particles is reordered by grid
cell every 100 timesteps to improve data locality and cache access
patterns.

This problem is *mostly* present within the upstream SPARTA
repository. The components of this problem are listed below (paths
given are within SPARTA repository). Each of these files will need to
be copied into a run directory for the simulation.

``examples/cylinder/in.cylinder``
   This is the default input file that controls the simulation. Some
   parameters within this file may need to be changed depending upon
   what is being run (i.e., these parameters control how long this
   simulation runs for and how much memory it uses). The modified
   version of this within the template directory should be preferred;
   more on this below.

``examples/cylinder/circle_R0.5_P10000.surf``
   This is the mesh file and will remain unchanged.

``examples/cylinder/air.*``
   These three files (i.e., ``air.species``, ``air.tce``, and
   ``air.vss``) contain the composition and reactions inherent with
   the air. These files, like the mesh file, are not to be edited.

A template run directory was created to help ease performing a
simulation; this directory is ``templatedir``. There are some key
files within it.

``templatedir/in.cylinder``
   This is a modified version of the input file with some key parameters
   changed to be more appropriate as a benchmark.

``templatedir/sparta_ln.sh``
   This file creates symbolic links to files and folders needed for
   the simulation.

``templatedir/sparta_batch_elcapitan.sh``
   This is a batch script compatible with El Capitan. It has
   capabilities for setting key job parameters from the command line;
   more on that below.


An excerpt from this input file that has its key parameters is
provided below.

.. code-block::
   :emphasize-lines: 6,11,17,23,26,29,32,34

   <snip>
   ###################################
   # Trajectory inputs
   ###################################
   <snip>
   variable            L index 1.
   <snip>
   ###################################
   # Simulation initialization standards
   ###################################
   variable            ppc equal 47
   <snip>
   #####################################
   # Gas/Collision Model Specification #
   #####################################
   <snip>
   collide_modify      vremax 100 yes vibrate no rotate smooth nearcp yes 10
   <snip>
   ###################################
   # Output
   ###################################
   <snip>
   stats               100
   <snip>
   # Some systems buffer extensively
   stats_modify        flush yes
   <snip>
   # Stop after 11 minutes
   fix 1 halt 10 tlimit > 660.0 message no
   <snip>
   # Print out the value of L for parsing ease
   print "The value of L is $L" 
   <snip>
   run                 10000000

These parameters are described below.

``L``
   This corresponds to the **l**\ ength scale factor. This will scale
   the x and y dimensions of the problem, e.g., a doubling of this
   parameter will result in a domain that is 4x larger. This is used
   to weak scale a problem, e.g., setting this to 32 would be
   sufficient to weak scale a single-node problem onto 1,024 nodes.

``ppc``
   This sets the **p**\ articles **p**\ er **c**\ ell variable. This
   variable controls the size of the problem and, accordingly, the
   amount of memory it uses. Adjust this if the initial memory size is
   too high and a value of ``L`` would need to be less than 1.0.

``collide_modify``
   The official documentation for this value is `here
   <https://sparta.github.io/doc/collide_modify.html>`_. This resets
   the number of collisions and attempts to enable consistent work for
   each time step.

``stats``
   This sets the interval at which the output required to compute the
   :ref:`SPARTAFigureOfMerit` is generated. In general, it is good to
   select a value that will produce approx. 20 entries between the
   time range of interest. If it produces too much data, then it may
   slow down the simulaton.  If it produces too little, then it may
   adversely impact the FOM calculations.

``stats_modify flush yes``
   This enables the log output to buffer continuously on El Capitan.

``fix 1 halt 10 tlimit > 660.0 message no``
   This sets job termination to 660.0 seconds of wall time by checking
   on progress every 10 steps.

``print "The value of L is $L"``
   This line outputs the value of ``L`` in a way that is easy to parse
   since it can be set external to the input file.

``run``
   This sets how many iterations it will run for, which also controls
   the wall time required for termination. If the ``fix 1 halt ...``
   is used, then set this to a large number so it allows the ``halt``
   to stop at the appropriate time.

This problem exhibits different runtime characteristics whether or not
Kokkos is enabled. Specifically, there is some work that is performed
within Kokkos that helps to keep this problem as well behaved from a
throughput perspective as possible. Ergo, Kokkos must be enabled for
the simulations regardless of the hardware being used (the cases
herein have configurations that enable it for reference). If Kokkos is
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
   :emphasize-lines: 8-12

       Step          CPU         Np     Natt    Ncoll Maxlevel
          0            0 1342895588        0        0        3 
        100    55.100981 1342896690 30660997 24422279        3 
        200    108.04593 1342894859 30715618 24465908        3 
        300    162.82546 1342894246 30765809 24505854        3 
        400    217.92144 1342895598 30812328 24539812        3 
        500    274.18419 1342897827 30854579 24573110        3 
        600    330.94615 1342897254 30902088 24612675        3 
        700    387.95385 1342893864 30939073 24640919        3 
        800    445.66487 1342885429 30978764 24674696        3 
        900    505.13571 1342886863 31014395 24701985        3 
       1000    564.62459 1342883798 31050409 24731144        3 
       1100    624.14498 1342885848 31083875 24756941        3 
       1200    683.65841 1342884461 31116135 24780002        3 
   Loop time of 683.659 on 4 procs for 1200 steps with 1342884461 particles

The quantity of interest (QOI) is "Mega particle steps per second,"
which can be computed from the above table by multiplying the third
column (no. of particles) by the first (no. of steps), dividing the
result by the second column (elapsed time in seconds), and finally
dividing by 1,000,000 (normalize). The number of steps must be large
enough so the times mentioned in the second column exceed 600 (i.e.,
so it runs for at least 10 minutes).

The Figure of Merit (**FOM**) is the harmonic mean of the QOI computed
from the times between 300 and 600 seconds and then divided by the
number of nodes, i.e., "Mega particle steps per second per node." A
Python script (:download:`sparta_fom.py <sparta_fom.py>`) is included
within the repository to aid in computing this quantity. Pass it the
``-h`` command line argument to view its help page for additional
information.

It is desired to capture the FOM for varying problem sizes that
encompass utilizing 35% to 75% of available memory (when all PEs are
utilized). The ultimate goal is to maximize this throughput FOM while
utilizing at least 50% of available memory.


.. _SPARTACorrectness:

Correctness
-----------

The aforementioned relevant block of output within "log.sparta" is
replicated below.

.. code-block::
   :emphasize-lines: 8-12

       Step          CPU         Np     Natt    Ncoll Maxlevel
          0            0 1342895588        0        0        3 
        100    55.100981 1342896690 30660997 24422279        3 
        200    108.04593 1342894859 30715618 24465908        3 
        300    162.82546 1342894246 30765809 24505854        3 
        400    217.92144 1342895598 30812328 24539812        3 
        500    274.18419 1342897827 30854579 24573110        3 
        600    330.94615 1342897254 30902088 24612675        3 
        700    387.95385 1342893864 30939073 24640919        3 
        800    445.66487 1342885429 30978764 24674696        3 
        900    505.13571 1342886863 31014395 24701985        3 
       1000    564.62459 1342883798 31050409 24731144        3 
       1100    624.14498 1342885848 31083875 24756941        3 
       1200    683.65841 1342884461 31116135 24780002        3 
   Loop time of 683.659 on 4 procs for 1200 steps with 1342884461 particles

There are several columns of interest regarding correctness; these are
listed below.

``Step``
   This is the step number and is the first column.

``CPU``
   This is the elapsed time and is the second column.

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

.. note::
   The example above is generating output every 100 time steps, which
   is also what the value of ``collide_modify`` is set to. This has
   the side effect of having low attempt and collision values since it
   is outputting on the reset step. The final value shown at a time
   step of 4,346 has values that are more inline with the actual
   problem. This is why output, for this correctness step, needs to
   occur at each time step.

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


Building
========

A script (``sparta_clone.sh``) is provided to clone the SPARTA
repository within the "sparta" folder. Instructions are provided on
how to build SPARTA for the following systems:

* Generic (see :ref:`BuildGeneric`)
* Advanced Technology System 4 (ATS-4), also known as El Capitan (see
  :ref:`BuildATS4`)


.. _BuildGeneric:

Generic
-------

Refer to SPARTA's [sparta-build]_ documentation for generic
instructions.


.. _BuildATS4:

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


Running
=======

Instructions are provided on how to run SPARTA for the following
systems:

* Advanced Technology System 4 (ATS-4), also known as El Capitan (see
  :ref:`SPARTARunATS4`)
  * Profiling with Kokkos Tools on El Capitan (see
    :ref:`SPARTAProfileKokkosToolsElCapitan`)


.. _SPARTARunATS4:

El Capitan
----------

.. note::

   This section will be updated with some more content soon.

An example for performing simulations on El Capitan is
provided below.

.. code-block:: bash

   # first, copy templatedir into something useful
   cp -a templatedir useful

   # next, go into the run folder
   cd useful

   # submit job and set parameters on command line if desired
   #   this example sets L (aka sparta_len) to 2.5
   #   this example turns on Kokkos Tools profiling (aka kokkos_tools)
   #   this example runs on 1 node (aka --nodes=1)
   sparta_len=2.5 is_kokkos_tools=1 flux batch --nodes=1 sparta_batch_elcapitan.s


.. _SPARTAProfileKokkosTools:

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


.. _SPARTAResults:

Verification of Results
=======================

Additional information:

* The sub-section :ref:`SPARTAComputeFOM` describes how to compute the
  FOM

Single-node results from SPARTA are provided on the following systems:

* Advanced Technology System 4 (ATS-4), also known as El Capitan (see
  :ref:`ResultsATS4`)

Multi-node results from SPARTA are provided on the following system(s):

* Advanced Technology System 4 (ATS-4), also known as El Capitan (see
  :ref:`ResultsScaleATS4`)


.. _SPARTAComputeFOM:

Compute Figure of Merit
-----------------------

A script (``sparta_fom.py``) is provided to compute the figure of
merit (FOM). A single-node example of it is below on El Capitan
showcasing 2,408 Mega particle steps per second per node. Its default
values are to always run ``--all``, to set 4 MPI ranks per node, and
to look for a file named "log.sparta" meaning the arguments in the
example were unnecessary.

.. code-block::
   :emphasize-lines: 2

   $ ./sparta_fom.py --all --numRanksPerNode 4 --file log.sparta
   INFO - 2026-02-16 20:54:44,673 - FOM (M-particle-steps/sec/node) = 2407.678218234091
   INFO - 2026-02-16 20:54:44,673 - No. Ranks = 4
   INFO - 2026-02-16 20:54:44,673 - No. Nodes = 1
   INFO - 2026-02-16 20:54:44,673 - Wall Time (sec) = 683.659
   INFO - 2026-02-16 20:54:44,673 - No. Steps = 1200
   INFO - 2026-02-16 20:54:44,673 - No. Particles = 1342884461
   INFO - 2026-02-16 20:54:44,673 - Particles Per Cell [PPC] = 47
   INFO - 2026-02-16 20:54:44,673 - Length Scaling Factor [L] = 2.0
   INFO - 2026-02-16 20:54:44,673 - File = /path/to/llnl-benchmarks/docs/31_sparta/checks-10--nodes-001--L-2.0--ktst/log.sparta


.. _ResultsATS4:

El Capitan - Single Node
------------------------

.. note::

   This section will be updated with some more content soon.

A single-node example is below that showcases 2,408 Mega particle
steps per second per node. The other relevant parameters are displayed
as part of the output.

.. code-block::
   :emphasize-lines: 2

   $ ./sparta_fom.py --all --numRanksPerNode 4 --file log.sparta
   INFO - 2026-02-16 20:54:44,673 - FOM (M-particle-steps/sec/node) = 2407.678218234091
   INFO - 2026-02-16 20:54:44,673 - No. Ranks = 4
   INFO - 2026-02-16 20:54:44,673 - No. Nodes = 1
   INFO - 2026-02-16 20:54:44,673 - Wall Time (sec) = 683.659
   INFO - 2026-02-16 20:54:44,673 - No. Steps = 1200
   INFO - 2026-02-16 20:54:44,673 - No. Particles = 1342884461
   INFO - 2026-02-16 20:54:44,673 - Particles Per Cell [PPC] = 47
   INFO - 2026-02-16 20:54:44,673 - Length Scaling Factor [L] = 2.0
   INFO - 2026-02-16 20:54:44,673 - File = /path/to/llnl-benchmarks/docs/31_sparta/checks-10--nodes-001--L-2.0--ktst/log.sparta


.. _ResultsScaleATS4:

El Capitan - Many Nodes
-----------------------

.. note::

   This section will be updated with some more content soon.


Timing Breakdown
^^^^^^^^^^^^^^^^

.. note::

   This section will be updated with some more content soon.

Timing breakdown information directly from SPARTA on El Capitan is
provided for various node counts. SPARTA writes out a timer block that
resembles the following.

.. code-block::

   Section |  min time  |  avg time  |  max time  |%varavg| %total
   ---------------------------------------------------------------
   Move    | 159.2      | 161.74     | 165.21     |  18.7 | 23.66
   Coll    | 186.02     | 325.5      | 476.79     | 771.3 | 47.61
   Sort    | 26.944     | 29.01      | 31.18      |  35.9 |  4.24
   Comm    | 1.7542     | 1.762      | 1.7726     |   0.5 |  0.26
   Modify  | 2.502      | 2.9416     | 3.3764     |  24.7 |  0.43
   Output  | 0.049965   | 1.7761     | 3.441      | 124.6 |  0.26
   Other   |            | 160.9      |            |       | 23.54

A description of the work performed for each of the sections is
provided below.

``Move``
   Particle advection through the mesh, i.e., particle push

``Coll``
   Particle collisions

``Sort``
   Particle sorting (i.e., make a list of all particles in each grid
   cell) and reorder (i.e., reorder the particle array by grid cell)

``Comm``
   The bulk of the MPI communications

``Modify``
   Time spent in diagnostics like "fixes" or "computes"

``Output``
   Time spent writing statistical output to log, or other, file(s)

``Other``
   Leftover time not captured by the categories above; this can
   include load imbalance (i.e., ranks waiting at a collective
   operation)


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
