**********
LAMMPS ACE
**********

.. note::
   The documentation herein needs to be updated for current
   performance.

This is the documentation for the benchmark [LAMMPS]_. The content
herein was created by the following authors (in alphabetical order).

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


Problems
--------

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

.. https://docs.lammps.org/pair_pace.html
