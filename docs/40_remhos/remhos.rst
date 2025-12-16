******
Remhos
******

https://github.com/CEED/Remhos

Remhos source code is not finalized at this point. The problems to run are yet to be defined.

Purpose
=======


Characteristics
===============

Problems
--------

Figure of Merit
---------------


Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications.
For Remhos, we define the following restrictions on source code modifications:

* Remhos uses MFEM and Hypre as libraries, available at https://github.com/mfem/mfem and https://github.com/hypre-space/hypre .  While source code changes to MFEM and Hypre can be proposed, MFEM and Hypre in Laghos may not be replaced with any other libraries.

* Solver parameters should remain unchanged (smoothers, coarsening, etc.).  Remhos uses the default MFEM and Hypre parameters appropriate for each platform.


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

Please see :ref:`ElCapitanSystemDescription` for El Capitan system description.


Weak Scaling on El Capitan
==========================


References
==========
