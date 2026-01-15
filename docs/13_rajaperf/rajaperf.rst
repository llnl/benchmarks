**********************
RAJA Performance Suite
**********************

RAJA Performance Suite source code is near-final at this point. The problems to run are not yet finalized.

The RAJA Performance Suite contains a variety of numerical kernels that
represent important computational patterns found in HPC applications. It is a
companion project to RAJA, which is a library of software abstractions used by
developers of C++ applications to write portable, single-source code. The RAJA
Performance Suite enables performance experiments and comparisons for kernel
variants that use RAJA and those that do not.

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
The kernels in the Suite originate from different sources ranging from
open-source HPC benchmarks to restricted-access production applications.
Kernels exercise various loop structures as well as parallel operations such
as reductions, atomics, scans, and sorts.

Each kernel in the Suite appears in RAJA and non-RAJA variants that exercise
common programming models, such as OpenMP, CUDA, HIP, and SYCL. Performance
comparisons between RAJA and non-RAJA variants are helpful to improve RAJA
implementation and to identify impacts C++ abstractions have on compilers'
ability to optimize. Often, kernels in the Suite serve as collaboration tools
enabling the RAJA team to work with vendors to resolve performance issues
observed in production applications that use RAJA.

RAJA is a potential *X* in the commonly used *MPI + X* parallel application
paradigm, where MPI is used for coarse-grained, distributed memory parallelism
and X (e.g., RAJA) supports fine-grained parallelism within an MPI rank.
The RAJA Performance Suite can be configured with MPI so that execution of
kernels in the Suite is representative of the ways in which numerical kernels
are exercised in an MPI + X HPC applications. When the RAJA Performance Suite
is run using multiple MPI ranks, the same kernel code is executed on each rank.
Synchronization and communication across ranks involves only sending execution
timing information to rank zero.

.. important:: For RAJA Performance Suite benchmark execution, MPI must be used
               to ensure that all resources on a compute node are being 
               exercised and avoid misrepresenting node performance.


Characteristics
===============

The `RAJA Performance Suite GitHub project <https://github.com/LLNL/RAJAPerf>`_
contains the code for all the Suite kernels and all of essential software
dependencies in Git submodules. Thus, dependency versions are pinned to each
version of the Suite. Building the Suite requires an installation of CMake for
configuring a build, a C++17 compliant compiler to build the code, and an MPI
library installation, if MPI is to be used. 

The Suite can be run in a myriad of ways by specifying parameters and options
in its command-line interface. The intent is that one can build the code and
use scripts to execute a series of Suite runs to generate data for each desired
performance experiment.

Problems
--------

The RAJA Performance Suite benchmark is limited to a subset of kernels
listed below.

.. note:: Each kernel contains a reference description which is located in the
          header file for the kernel object ``<kernel-name>.hpp``. The 
          reference is a C-style sequential implementation of the kernel in
          a comment section near the top of the header file.

 * *Apps* group (directory src/apps) -- **Tier 1**

   #. **DIFFUSION3DPA** action of a 3D finite element diffusion operator via partial assembly *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **EDGE3D** stiffness matrix assembly for a 3D MHD calculation *(single loop with included function call, RAJA::forall API)*
   #. **ENERGY** internal energy calculation from an explicit hydrodynamics algorithm; *(multiple single-loop operations in sequence, conditional logic for correctness checks and cutoffs, RAJA::forall API)*
   #. **FEMSWEEP** finite element implementation of linear sweep algorithm used in radiation transport *(nested loops, RAJA::launch API)*
   #. **INTSC_HEXHEX** intersection between two 24-sided hexahedra, including volume and moment calculations *(multiple single-loop operations in sequence, RAJA::forall API)*
   #. **INTSC_HEXRECT** intersection between a 24-sided hexahedron and a rectangular solid, including volume and moment calculations *(single loop, RAJA::forall API)*
   #. **MASS3DEA** element assembly of a 3D finite element mass matrix *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **MASS3DPA_ATOMIC** action of a 3D finite element mass matrix via partial assembly *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **MASSVEC3DPA** action of a 3D finite element mass matrix via partial assembly on a block vector *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **MATVEC_3D_STENCIL** matrix-vector product based on a 3D mesh stencil *(single loop, data access via indirection array, RAJA::forall API)*
   #. **NODAL_ACCUMULATION_3D** on a 3D structured hexahedral mesh, sum a constribution from each hex vertex (nodal value) to its centroid (zonal value) *(single loop, data access via indirection array, 8-way atomic contention, RAJA::forall API)*
   #. **VOL3D** on a 3D structured hexahedral mesh (faces are not necessarily planes), compute volume of each zone (hex) *(single loop, data access via indirection array, RAJA::forall API)*

 * *Apps* group (directory src/apps) -- **Tier 2**

   #. **CONVECTION3DPA** action of a 3D finite element convection operator via partial assembly *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **DEL_DOT_VEC_2D** divergence of a vector field at a set of points on a mesh *(single loop, data access via indirection array, RAJA::forall API)*
   #. **MASS3DPA** action of a 3D finite element mass matrix via partial assembly *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **MASSVEC3DPA_ATOMIC** action of a 3D finite element mass matrix via partial assembly on a block vector *(nested loops, GPU shared memory, RAJA::launch API)*


 * *Basic* group (directory src/basic) -- **Tier 1**

   #. **MULTI_REDUCE** multiple reductions in a kernel, where number of reductions is set at run time *(single loop, irregular atomic contention, RAJA::forall API)*
   #. **REDUCE_STRUCT** multiple reductions in a kernel, where number of reductions (6) is known at compile time *(single loop, multiple reductions, RAJA::forall API)*

 * *Basic* group (directory src/basic) -- **Tier 2**

   #. **INDEXLIST_3LOOP** construction of set of indices used in other kernel executions *(single loops, vendor scan implementations, RAJA::forall API)*

 * *Comm* group (directory src/comm) -- **Tier 2**

   #. **HALO_EXCHANGE_FUSED** packing and unpacking MPI message buffers for point-to-point distributed memory halo data exchange for mesh-based codes *(overhead of launching many small kernels, GPU variants use RAJA::Workgroup concepts to execute multiple kernels with one launch)* 

 

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
