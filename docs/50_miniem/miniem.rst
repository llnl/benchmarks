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

Figure of Merit
---------------


Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications. 


Building
========

MiniEM and Trilinos prefer static versus dynamic linking for its
third-party libraries. Instructions for two systems will be provided
below. The first is for the Hops system whose compute nodes have two
Intel Xeon Sapphire Rapids processors each and a total of four Nvidia
H100 GPUs.


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

.. code-block:: sh

   # clone Spack and add it to the environment
   ./spack--hops.sh

This script is replicated below for posterity.

.. literalinclude:: spack--hops.sh
   :language: sh
   :lines: 2-


TPLs
^^^^

.. literalinclude:: build--hops.sh
   :language: sh
   :lines: 2-


MiniEM
^^^^^^

.. literalinclude:: trilinos--hops.sh
   :language: sh
   :lines: 2-



El Capitan
----------


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
