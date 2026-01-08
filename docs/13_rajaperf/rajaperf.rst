**********************
RAJA Performance Suite
**********************

RAJA Performance Suite source code is near-final at this point. The problems to run are yet to be finalized.

The RAJA Performance Suite contains a variety of numerical kernels that
represent important computational patterns found in HPC applications. It is a
companion project to RAJA, which is a library of software abstractions enabling
developers of C++ applications to write portable, single-source code. The Suite
provides mechanisms to analyze RAJA performance and, in particular, to compare
performance of kernel implementations that use RAJA and those that do not.

Source code and documentation for RAJA and the RAJA Performance Suite is 
available at:

  * `RAJA Performance Suite GitHub project <https://github.com/LLNL/RAJAPerf>`_ 

  * `RAJA GitHub project <https://github.com/LLNL/RAJAPerf>`_

.. important:: The RAJA Performance Suite benchmark is limited to a subset of
               kernels in the RAJA Performance Suite as described below.


Purpose
=======

The main purpose of the RAJA Performance Suite is to analyze performance of
loop-based computational kernels representative of those found in HPC
applications and which are implemented using `RAJA <https://github.com/LLNL/RAJA>`_. 
Each kernel in the Suite appears in RAJA and *non-RAJA* variants that exercise
common parallel programming models, such as OpenMP, CUDA, HIP, and SYCL.
RAJA and non-RAJA variants enable comparison of performance and
compiler-generated code that uses RAJA and that which does not.

The kernels in the RAJA Performance Suite originate from open-source HPC
benchmark suites and restricted-access production applications. Kernels
employ various loop structures and parallel operations such as reductions,
atomics, scans, and sorts. Often, kernels in the Suite are developed to
provide vendors with simplified reproducers of performance and compiler
optimization issues observed in production applications that use RAJA.

RAJA is the *X* in *MPI + X* parallel application paradigm, where MPI is used
for coarse-grained, distributed memory parallelism and X (RAJA in this
case) supports fine-grained parallelism within an MPI rank. The RAJA Performance
Suite supports MPI so that execution of kernels in the Suite aligns with the
way individual kernels are exercised in production HPC applications. For
example, we may want to compare performance of a kernel running on a many core
system using OpenMP multithreading to exercise all cores and the case where
each core is mapped to an MPI rank and code within each rank is executed
sequentially. Similarly, on a system where a GPU can be partitioned into
multiple compute devices, we may want to compare performance of different
GPU partitionings where each partition is assigned to a different MPI rank. 


Characteristics
===============

The RAJA Performance Suite repository contains all of its software dependencies
in Git submodules; thus dependency versions are pinned to each version of 
the Suite. Building the Suite requires a C++17 compliant compiler and an
MPI library installation, if MPI is used. 

The Suite is designed so that its key parameters and options are defined via
command-line options. The intent is that one can build the code and use scripts
to execute a series of Suite runs to generate data for desired performance
experiments.

Problems
--------

The RAJA Performance Suite benchmark is limited to a subset of kernels.

.. note:: There is a reference description for each kernel located in the
          header file for the kernel object ``kernel-name.hpp``. The 
          reference is a C-style sequential implementation of the kernel in
          a comment section near the top of the header file.

 * *Apps* group (directory src/apps)

   #. **CONVECTION3DPA** action of a 3D finite element convection operator (matrix) via partial assembly
   #. **DEL_DOT_VEC_2D** divergence of a vector field on a set of points on a mesh, where the mesh points are traversed using an indirection array
   #. **DIFFUSION3DPA** action of a 3D finite element diffusion operator (matrix) via partial assembly
   #. **EDGE3D** stiffness matrix assembly for a 3D MHD calculation
   #. **ENERGY** internal energy calculation for an explicit hydrodynamics calculation; illustrates conditional logic used to apply various cutoffs
   #. **FEMSWEEP** linear sweep used in a finite element implementation of radiation transport
   #. **INTSC_HEXHEX** intersection between two 24-sided hexahedra, including volume and moment calculations
   #. **INTSC_HEXRECT** intersection between a 24-sided hexahedron and a rectangular solid, including volume and moment calculations
   #. **LTIMES** one step of the source-iteration technique for solving the steady-state linear Boltzmann equation -- multi-dimensional matrix product 
   #. **MASS3DEA** assembly of a 3D finite element mass matrix
   #. **MASSVEC3DPA** action of a 3D finite element mass matrix via partial assembly on a block vector
   #. **MATVEC_3D_STENCIL** matrix-vector product based on a 3D mesh stencil
   #. **NODAL_ACCUMULATION_3D** on a 3D structured hexahedral mesh, sum a constribution from each hex vertex (nodal value) to its centroid (zonal value) -- 8-way atomic contention
   #. **VOL3D** on a 3D structured hexahedral mesh (faces are not necessarily planes), compute volume of each zone (hex)

 * *Basic* group (directory src/basic)

   #. **INDEXLIST_3LOOP** construction of list of indices based on some boolean test to enumerate iterates for a subsequent kernel execution -- exercises vendor scan implementations
   #. **MULTI_REDUCE** multiple reductions in a kernel, where number of reductions is set at run time 
   #. **REDUCE_STRUCT** multiple reductions in a kernel, where number of reductions (6) is known at compile time

 * *Comm* group (directory src/comm)

   #. **HALO_EXCHANGE_FUSED** packing and unpacking MPI message buffers for point-to-point distributed memory communication -- represents halo data exchange for mesh-based codes 

 

Figure of Merit
---------------




Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications. 
For the RAJA Performance Suite, we define the following restrictions on source code modifications:

* RAJA Performance Suite uses RAJA as the portability library, available at https://github.com/LLNL/RAJA .  While source code changes to RAJA can be proposed, RAJA in RAJA Performance Suite may not be removed or replaced with any other library.


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
