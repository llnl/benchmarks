******
Remhos
******

Documentation for Remhos (REMap High-Order Solver).

https://github.com/CEED/Remhos

Remhos source code is not finalized at this point. The problems to run are yet to be defined.

Purpose
=======

Remhos serves as a proxy-app for the advection-based remap methods used in LLNL's MARBL code.

Characteristics
===============

Problems
--------

The sample runs of interest are listed below. Those represent a bounded high-order remap of a simple scalar finite element field between two computational meshes.

2D cpu:

``lrun -n 8 remhos -dim 2 -epm 1024 -o 3 -p 14 -dt -1.0 -tf 0.5 -ho 3 -lo 5 -fct 2 -vs 1 -ms 5 -no-vis -pa -d cpu``

2D gpu:

``lrun -n 8 remhos -dim 2 -epm 1024 -o 3 -p 14 -dt -1.0 -tf 0.5 -ho 3 -lo 5 -fct 2 -vs 1 -ms 5 -no-vis -pa -d cuda``

3D cpu:

``lrun -n 8 remhos -dim 3 -epm 512 -o 2 -p 10 -dt -1.0 -tf 0.5 -ho 3 -lo 5 -fct 2 -vs 1 -ms 5 -no-vis -pa -d cpu``

3D gpu:

``lrun -n 8 remhos -dim 3 -epm 512 -o 2 -p 10 -dt -1.0 -tf 0.5 -ho 3 -lo 5 -fct 2 -vs 1 -ms 5 -no-vis -pa -d cuda``

Figure of Merit
---------------

Remhos reports several FOMs in the terminal, based on the distinct phases of an advection-based remap calculation. All FOMs are reported in ``(megaDOFs x time steps) per second``, reflecting the throughput of the calculation.

* FOM RHS: construction of the right-hand side of the system.
* FOM INV: inverting the high-order operator, which is used to obtain a high-order unbounded (HO) solution.
* FOM LO:  computation of the low-order bounded (LO) approximation of the solution.
* FOM FCT: computation of the FCT solution, combining the LO and HO solutions to obtain a bounded high-order solution.
* **FOM**: performance metric combining all the above phases.


Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications.
For Remhos, we define the following restrictions on source code modifications:

* Remhos uses MFEM and Hypre as libraries, available at https://github.com/mfem/mfem and https://github.com/hypre-space/hypre . While source code changes to MFEM and Hypre can be proposed, MFEM and Hypre in Remhos may not be replaced with any other libraries.

* Solver parameters should remain unchanged (smoothers, coarsening, etc.). Remhos uses the default MFEM and Hypre parameters appropriate for each platform.


Building
========

Remhos has the following external dependencies:

- **hypre**, used for parallel linear algebra, we recommend version 2.24.0

  https://github.com/hypre-space/hypre

- **MFEM**, used for (high-order) finite element discretization, its GitHub master branch

  https://github.com/mfem/mfem

To build the miniapp, first download **hypre** from the links above
and put everything on the same level as the `Remhos` directory::

    ~> mkdir remhos
    ~> ls
    remhos/  hypre.tar.gz
 
Build **hypre** (note that the folder must be named ``hypre``)::

    ~> tar -zxvf hypre.tar.gz
    ~> cd hypre/src/
    ~/hypre/src> ./configure --disable-fortran
    ~/hypre/src> make -j
    ~/hypre/src> cd ../..

For large runs (problem size above 2 billion unknowns), add the
``--enable-bigint`` option to the above ``configure`` line.

Clone and build the parallel version of MFEM::

    ~> git clone https://github.com/mfem/mfem.git ./mfem
    ~> cd mfem/
    ~/mfem> make parallel -j MFEM_USE_METIS=NO
    ~/mfem> cd ..

The above uses the `master` branch of MFEM. See the [MFEM building page](http://mfem.org/building/) for additional details.

Build Remhos::

    ~> git clone https://github.com/CEED/Remhos.git ./remhos
    ~> cd remhos/
    ~/remhos> make

See ``make help`` for additional options.

Running
=======

The main performance-related options are the device ``(-d)``, number of tasks ``(-n)``, the elements per task ``(-epm)``, and the finite element order ``(-o)``. Appropriate mesh and partitioning are generated automatically. The product of ``(-n)`` and ``(-epm)`` determines the mesh size. The order ``(-o)`` can also be increased, resulting in more work per mesh element. For example, for weak scaling, vary ``(-n)`` and fix ``(-epm)``; for strong scaling, make sure the product of ``(-n)*(-epm)`` is constant.


Validation
==========


Example Scalability Results
===========================

Not available.

Memory Usage
============

For each task, the memory usage is determined by the number of elements per task ``(-n)`` and the finite-element order ``(-o)``.
The dominant contributors are the mesh data structures and the finite-element operator storage.

Let ``d`` denote the spatial dimension and ``r`` the number of uniform refinements in one dimension (``r ≈ (n)^(1/d)``).
The number of elements per task then scales as ``O(r^d)``. The storage required per element (mesh plus operators) depends on the polynomial order ``o``.
Because Remhos employs partial assembly, the per-element operator storage is optimal, scaling as ``O(o^d)``. Consequently, the total memory consumption per task scales as ``O(r^d o^d) = O((r o)^d)``.

Strong Scaling on El Capitan
============================

Please see :ref:`ElCapitanSystemDescription` for El Capitan system description.


Weak Scaling on El Capitan
==========================

Not available.

References
==========
