******
MiniEM
******

.. note::
   The documentation herein needs to be updated for current
   performance.

This is the documentation for the Future Computing Resource (FCR) FY30
Benchmark MiniEM. The content herein was created by the following
authors (in alphabetical order).

- `Anthony M. Agelastos <mailto:amagela@sandia.gov>`_
- `James J. Elliott <mailto:jjellio@sandia.gov>`_
- `Christian A. Glusa <mailto:caglusa@sandia.gov>`_
- `Roger P. Pawlowski <mailto:rppawlo@sandia.gov>`_

This material is based upon work supported by the Sandia National Laboratories
(SNL), a multimission laboratory managed and operated by National Technology and
Engineering Solutions of Sandia under the U.S. Department of Energy's National
Nuclear Security Administration under contract DE-NA0003525. Content herein
considered unclassified with unlimited distribution under SAND2023-01069O.


Purpose
=======

MiniEM solves a first order formulation of Maxwell's equations of
electromagnetics. MiniEM is the [Trilinos]_ proxy driver for the
electromagnetics sub-problem solved by EMPIRE and exercises the relevant
Trilinos components (i.e., Tpetra, Belos, MueLu, Ifpack2, Intrepid2, Panzer).


Characteristics
===============

The goal is to utilize the specified version of MiniEM (see
:ref:`MiniEMApplicationVersion`) that runs the benchmark problem (see
:ref:`MiniEMProblem`) correctly (see :ref:`MiniEMCorrectness` if
changes are made to MiniEM).


.. _MiniEMApplicationVersion:

Application Version
-------------------

The command to clone is provided below.

.. literalinclude:: miniem_clone.sh
   :language: sh
   :lines: 2-

.. note::
   The Git SHA will be updated with a tag soon.

The script to clone can be downloaded from :download:`miniem_clone.sh
<miniem_clone.sh>`. It can also be executed in place to clone into
``docs/50_miniem/miniem``.
 
.. code-block:: bash

   cd docs/50_miniem
   ./miniem_clone.sh


Problem
-------

The [Maxwell-Large]_ problem given by the input deck "maxwell-large.xml"
describes a uniform mesh of a 3D box which makes it ideal for scaling studies.
The stock input file for this can be found within the Trilinos repository in the
aforementioned link.

Useful parameters from within this input deck are shown below.

.. code-block::

   <snip>
   23    <ParameterList name="Inline Mesh">
   <snip>
   28      <ParameterList name="Mesh Factory Parameter List">
   <snip>
   35        <Parameter name="X Elements" type="int" value="40" />
   36        <Parameter name="Y Elements" type="int" value="40" />
   37        <Parameter name="Z Elements" type="int" value="40" />

These parameters are described below.

``X Elements, Y Elements, Z Elements``
   This sets the size of the problem, which is the product of these 3
   quantities. These parameters are set to other values with the cases shown
   herein. These values should be identical for the calculations herein.


Figure of Merit
---------------

Each MiniEM simulation writes out a Figure of Merit (FOM) block to
STDOUT. The relevant portion of this block is in the below example.

.. code-block::

   =================================
   FOM Calculation
   =================================
     Number of cells = 4116000
     Time for Belos Linear Solve = 705.737 seconds
     Number of Time Steps (one linear solve per step) = 1541
     FOM ( num_cells * num_steps / solver_time / 1000) = 8987.42 k-cell-steps per second 
   =================================

The number of steps, specified with the ``--numTimeSteps`` command
line option, described below in :ref:`MiniEMRunATS4`), must be large
enough so the time for the Belos Linear Solve is greater than 600
seconds, i.e., so the solver runs for at least 10 minutes. The figure
of merit (FOM) is the bottom entry in this block, i.e., ``FOM (
num_cells * num_steps / solver_time / 1000)``.

It is desired to capture the FOM for varying problem sizes that
encompass utilizing 35% to 75% of available memory (when all PEs are
utilized). The ultimate goal is to maximize this throughput FOM while
utilizing at least 50% of available memory.


Correctness Check
-----------------

MiniEM also provides the [Maxwell-AnalyticSolution]_ problem given by
the input deck "maxwell-analyticSolution.xml". This will output
analytic error values (see below for an example) and will cause the
simulation to fail (and return a non-zero exit code) if it exceeds
appropriate thresholds. This should be used to verify the build of
MiniEM upon the system to assess both the used programming environment
and any changes made to the benchmark.

.. code-block::
   :emphasize-lines: 2

   The Belos solver "GMRES block system" of type ""Belos::BlockGmresSolMgr": {Flexible: true, Num Blocks: 10, Maximum Iterations: 10, Maximum Restarts: 20, Convergence Tolerance: 1e-08}" returned a solve status of "SOLVE_STATUS_CONVERGED" in 1 iterations with total CPU time of 0.0189103 sec
   L2 Error E maxwell - analyticSolution = 0.0566793

   * finished time step 6, t = 5e-09
   **************************************************

This case can be run simply by following the overall instructions in
:ref:`MiniEMRunning` and replacing the benchmark input file with
"maxwell-analyticSolution.xml". Example output of a failed case is
provided below (also note that this case exited with an exit code of
134).

.. code-block::

   what():  /path/to/trilinos/packages/panzer/mini-em/example/BlockPrec/main.cpp:690:

   Throw number = 1

   Throw test that evaluated to true: !( (std::sqrt(Thyra::get_ele(*g,0))) < (0.065) )

   Error, (std::sqrt(Thyra::get_ele(*g,0)) = 0.0819696) < (0.065 = 0.065)! FAILED!
   terminate called after throwing an instance of 'std::out_of_range'
   what():  /path/to/trilinos/packages/panzer/mini-em/example/BlockPrec/main.cpp:690:


Permissable Modifications
-------------------------

The authors of this benchmark invite vendors to propose any
algorithmic improvements that: (1.) do not alter the current Multigrid
solver approach; and (2.) follow the advice given in previous
subsections. Please email the authors with any questions about what is
or is not in scope. Some additional guidance is provided below.

A minimum of one level of V-cycle is required for both sub-hierarchies
to ensure the Trilinos MueLu Algebraic Multigrid (AMG) code path is
exercised. This behavior is reflected in the benchmark problem and
needs to be preserved with vendor changes. In essence, the solver sets
up two sub-problems, and each is solved using AMG. Example Multigrid
output that demonstrates this is below. It is appropriate for the
following characteristics of this output to be preserved.
 
* ``Scalar`` should be ``double`` (e.g., line 838)
* ``Number of levels`` should be at least ``2`` (e.g., line 839)
* ``Cycle type`` should be ``V`` (e.g., line 842)
 
.. code-block::

   835 --------------------------------------------------------------------------------
   836 ---                            Multigrid Summary RefMaxwell coarse (1,1)     ---
   837 --------------------------------------------------------------------------------
   838 Scalar              = double
   839 Number of levels    = 2
   840 Operator complexity = 1.02
   841 Smoother complexity = 1.07
   842 Cycle type          = V
   843
   844 level  rows   nnz      nnz/row  c ratio  procs
   845   0  21510  1840968  85.59                 5
   846   1  687    29525    42.98    31.31        1

Additionally, there are a couple of parameters within
"solverMueLu.xml" that should not be altered since changes will impact
the Multigrid work. The specified target size for the coarse grid
problems should not be modified.  These parameters are highlighted
below for reference.

.. code-block::
   :emphasize-lines: 10,12

   <ParameterList name="Linear Solver">
     <ParameterList name="Preconditioner Types">
       <ParameterList name="Teko">
         <ParameterList name="Inverse Factory Library">
           <ParameterList name="Maxwell">
             <ParameterList name="S_E Preconditioner">
               <ParameterList name="Preconditioner Types">
                 <ParameterList name="MueLuRefMaxwell">
                   <ParameterList name="refmaxwell: 11list">
                     <Parameter name="coarse: max size" type="int" value="2500"/>
                   <ParameterList name="refmaxwell: 22list">
                     <Parameter name="coarse: max size" type="int" value="2500"/>


Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications. 


Building
========

MiniEM and Trilinos prefer static versus dynamic linking for its
third-party libraries. Instructions for two systems will be provided
below. 

The platforms utilized for benchmarking activities are listed and described below.

* A GPU build and test system within Sandia National Laboratories
  named "hops" (see :ref:`MiniEMCTS2PlusHopsBuild`). This system has
  compute nodes with two Intel Xeon Sapphire Rapids processors each
  and a total of four Nvidia H100 GPUs.
* El Capitan (see :ref:`MiniEMATS4Build`)


.. _MiniEMCTS2PlusHopsBuild:

Hops
----

Environment
^^^^^^^^^^^

Change to a relevant environment.

.. code-block:: sh

   # source script to alter environment
   . env--hops.sh

This script is replicated below for posterity.

.. literalinclude:: env--hops.sh
   :language: sh
   :lines: 2-


Spack
^^^^^

The following script will clone Spack and add it to the environment.

.. code-block:: sh

   # clone Spack and add it to the environment
   ./spack--hops.sh

This script is replicated below for posterity.

.. literalinclude:: spack--hops.sh
   :language: sh
   :lines: 2-


TPLs
^^^^

The following script will build the third-party libraries for Trilinos
and, by extension, MiniEM.

.. code-block:: sh

   # build TPLs
   ./build--hops.sh

This script is replicated below for posterity.

.. literalinclude:: build--hops.sh
   :language: sh
   :lines: 2-


MiniEM
^^^^^^

The following script will build Trilinos and MiniEM once its
dependencies are taken care of. This directly leverages Trilinos'
CMake build system.

.. code-block:: sh

   # build Trilinos/MiniEM
   ./trilinos--hops.sh

.. literalinclude:: trilinos--hops.sh
   :language: sh
   :lines: 2-


.. _MiniEMATS4Build:

El Capitan
----------

The El Capitan instructions are slightly more complicated due to
complications with building Trilinos' TPLs in an appropriate manner
for static linking. Accordingly, the TPL stack was built and leveraged
by the bulk of SNL code teams that use Trilinos. This stack will be
regenerated in a reproducible fashion soon. Until then, its existence
is required.

Environment
^^^^^^^^^^^

Change to a relevant environment.

.. code-block:: sh

   # source script to alter environment
   . env--ats4.sh

This script is replicated below for posterity.

.. literalinclude:: env--ats4.sh
   :language: sh
   :lines: 2-

Spack
^^^^^

The TPL stack can be built via Spack. Specific patching for El Capitan
is being created in a reproducible fashion.

.. note::
   This will be updated once the Spack recipe is reproducible.

TPLs
^^^^

The TPL stack can be built via Spack. Specific patching for El Capitan
is being created in a reproducible fashion.

.. note::
   This will be updated once the Spack recipe is reproducible.

MiniEM
^^^^^^

The following script will build Trilinos and MiniEM once its
dependencies are taken care of. This directly leverages Trilinos'
CMake build system. 

.. code-block:: sh

   # build Trilinos/MiniEM
   ./trilinos--ats4.sh

.. note::
   This will be updated for referencing ones own TPLs soon.

.. literalinclude:: trilinos--ats4.sh
   :language: sh
   :lines: 2-


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

.. [Trilinos] M. A. Heroux and R. A. Bartlett and V. E. Howle and R. J. Hoekstra
              and J. J. Hu and T. G. Kolda and R. B. Lehoucq and K. R. Long
              and R. P. Pawlowski and E. T. Phipps and A. G. Salinger and H. K.
              Thornquist and R. S. Tuminaro and J. M. Willenbring and A.
              Williams and K. S. Stanley, 'An Overview of the Trilinos Project',
              2005, ACM Trans. Math. Softw., Volume 31, No. 3, ISSN 0098-3500.
.. [TrilinosBuild] R. A. Bartlett, 'Trilinos Configure, Build, Test, and Install
                   Reference Guide', 2023. [Online]. Available:
                   https://docs.trilinos.org/files/TrilinosBuildReference.html.
                   [Accessed: 26- Mar- 2023]
.. [Maxwell-Large] Trilinos developers, 'maxwell-large.xml', 2024. [Online]. Available: https://github.com/trilinos/Trilinos/blob/master/packages/panzer/mini-em/example/BlockPrec/maxwell-large.xml. [Accessed: 22- Feb- 2024]
.. [Maxwell-AnalyticSolution] Trilinos developers, 'maxwell-analyticSolution.xml', 2024. [Online]. Available: https://github.com/trilinos/Trilinos/blob/master/packages/panzer/mini-em/example/BlockPrec/maxwell-analyticSolution.xml. [Accessed: 22- Feb- 2024]
.. [Intel-8260] Intel. 'Intel Xeon Platinum 8260 Processor 35.75M Cache 2.40 GHz Product Specifications', 2024. [Online]. Available: https://ark.intel.com/content/www/us/en/ark/products/192474/intel-xeon-platinum-8260-processor-35-75m-cache-2-40-ghz.html. [Accessed: 18- Mar- 2024]
