**********************
RAJA Performance Suite
**********************

RAJA Performance Suite source code is near-final at this point. It will be
released soon along with benchmark baseline data and instructions for running
the benchmark and generating evaluation metrics.

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
               kernels in the RAJA Performance Suite as described in
               :ref:`rajaperf_problems-label`.


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

To more closely align execution of kernels in the Suite with how they would 
run in the context of a full application, benchmark runs must be done using
multiple MPI ranks to ensure that all resources on a compute node are being
exercised and avoid misrepresentation of kernel and node performance. RAJA is
a potential *X* in the often referred to *MPI + X* parallel application
paradigm, where MPI is used for coarse-grained, distributed memory parallelism
and X (e.g., RAJA) supports fine-grained parallelism within an MPI rank. The
RAJA Performance Suite can be configured with MPI so that execution of kernels
in the Suite represents how those kernels would be exercised in an MPI + X HPC
application. When the RAJA Performance Suite is run using multiple MPI ranks,
the same kernel code is executed on each rank. Synchronization and
communication across ranks involves only sending execution timing information
to rank zero for reporting purposes.

.. important:: For RAJA Performance Suite benchmark execution, MPI must be used
               to run to ensure that all resources on a compute node are being 
               exercised and avoid misrepresentation of kernel and node
               performance. This is described in the instructions provided in
               :ref:`rajaperf_run-label`.


Characteristics
===============

The `RAJA Performance Suite GitHub project <https://github.com/LLNL/RAJAPerf>`_
contains the code for all the Suite kernels and all essential external software
dependencies in Git submodules. Thus, dependency versions are pinned to each
version of the Suite. Building the Suite requires an installation of CMake for
configuring a build, a C++17 compliant compiler to build the code, and an MPI
library installation when MPI is to be used. 

The Suite can be run in a myriad of ways by specifying parameters and options
as command-line arguments. The intent is that one can build the code and
use scripts to execute multiple Suite runs to generate data for a desired
performance experiment.

In particular, variants, problem sizes, etc. for the kernels can be set by a
user from the command line. Specific instructions for running the RAJA
Performance Suite benchmark are described in :ref:`rajaperf_run-label`.


.. _rajaperf_problems-label:

Problems
--------

The RAJA Performance Suite benchmark is limited to a subset of kernels in the
full Suite to focus on some of the more important computational patterns found
in LLNL applications. The subset of kernels is described.

.. note:: Each kernel contains a complete reference description located in the
          header file for the kernel object ``<kernel-name>.hpp``. The 
          reference is a C-style sequential implementation of the kernel in
          a comment section near the top of the header file.

Priority 1 kernels
^^^^^^^^^^^^^^^^^^^

 * *Apps* group (directory src/apps)

   #. **DIFFUSION3DPA** element-wise action of a 3D finite element volume diffusion operator via partial assembly and sum factorization *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **EDGE3D** stiffness matrix assembly for a 3D MHD calculation *(single loop with included function call, RAJA::forall API)*
   #. **ENERGY** internal energy calculation from an explicit hydrodynamics algorithm; *(multiple single-loop operations in sequence, conditional logic for correctness checks and cutoffs, RAJA::forall API)*
   #. **FEMSWEEP** finite element implementation of linear sweep algorithm used in radiation transport *(nested loops, RAJA::launch API)*
   #. **INTSC_HEXRECT** intersection between a 24-sided hexahedron and a rectangular solid, including volume and moment calculations *(single loop, RAJA::forall API)*
   #. **MASS3DEA** element assembly of a 3D finite element mass matrix *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **MASS3DPA_ATOMIC** action of a 3D finite element mass matrix on elements with shared DOFs via partial assembly and sum factorization *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **MASSVEC3DPA** element-wise action of a 3D finite element mass matrix via partial assembly and sum factorization on a block vector *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **MATVEC_3D_STENCIL** matrix-vector product based on a 3D mesh stencil *(single loop, data access via indirection array, RAJA::forall API)*
   #. **NODAL_ACCUMULATION_3D** on a 3D structured hexahedral mesh, sum a contribution from each hex vertex (nodal value) to its centroid (zonal value) *(single loop, data access via indirection array, 8-way atomic contention, RAJA::forall API)*
   #. **VOL3D** on a 3D structured hexahedral mesh (faces are not necessarily planes), compute volume of each zone (hex) *(single loop, data access via indirection array, RAJA::forall API)*


Priority 2 kernels
^^^^^^^^^^^^^^^^^^^

 * *Apps* group (directory src/apps)

   #. **CONVECTION3DPA** element-wise action of a 3D finite element volume convection operator via partial assembly and sum factorization *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **DEL_DOT_VEC_2D** divergence of a vector field at a set of points on a mesh *(single loop, data access via indirection array, RAJA::forall API)*
   #. **INTSC_HEXHEX** intersection between two 24-sided hexahedra, including volume and moment calculations *(multiple single-loop operations in sequence, RAJA::forall API)*
   #. **LTIMES** one step of the source-iteration technique for solving the steady-state linear Boltzmann equation, multi-dimensional matrix product *(nested loops, RAJA::kernel API)*
   #. **MASS3DPA** element-wise action of a 3D finite element mass matrix via partial assembly and sum factorization *(nested loops, GPU shared memory, RAJA::launch API)*

 * *Basic* group (directory src/basic)

   #. **MULTI_REDUCE** multiple reductions in a kernel, where number of reductions is set at run time *(single loop, irregular atomic contention, RAJA::forall API)*
   #. **REDUCE_STRUCT** multiple reductions in a kernel, where number of reductions (6) is known at compile time *(single loop, multiple reductions, RAJA::forall API)*
   #. **INDEXLIST_3LOOP** construction of set of indices used in other kernel executions *(single loops, vendor scan implementations, RAJA::forall API)*

 * *Comm* group (directory src/comm)

   #. **HALO_PACKING_FUSED** packing and unpacking MPI message buffers for point-to-point distributed memory halo data exchange for mesh-based codes *(overhead of launching many small kernels, GPU variants use RAJA::Workgroup concepts to execute multiple kernels with one launch)* 


.. _rajaperf_fom-label:

Figure of Merit
---------------

There are two figures of merit (FOM) for each benchmark kernel: execution time
and memory bandwidth..... **fill this in***

**Describe how to set problem size based on architecture and how key output quantities are computed.....***



.. _rajaperf_codemod-label:

Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications. 
For the RAJA Performance Suite, we define the following restrictions on source
code modifications:

* While source code changes to the RAJA Performance Suite kernels and to RAJA
  can be proposed, RAJA may not be removed from *RAJA kernel variants* in the 
  Suite or replaced with any other library. The *Base kernel variants* in the
  Suite are provided to show how each kernel could be implemented directly
  in the corresponding programming model back-end without the RAJA abstraction
  layer. Apart from some special cases, the RAJA and Base variants for each
  kernel should perform the same computation.


.. _rajaperf_build-label:

Building
========

The RAJA Performance Suite uses a CMake-based system to configure the code for
compilation. As noted earlier, all non-system related software dependencies are
included in the RAJA Performance Suite repository as Git submodules.

The current RAJA Performance Suite benchmark uses the ``v2025.12.0`` version of
the code. When the git repository is cloned, you will be on the ``develop``
branch, which is the default RAJA Performance Suite branch. To get a local copy
of this version of the code and the correct versions of submodules::

  $ git clone --recursive https://github.com/LLNL/RAJAPerf.git
  $ git checkout v2025.12.0
  $ git submodule update --init --recursive 

When building the RAJA Performance Suite, RAJA and the RAJA Performance Suite
are built together using the same CMake configuration. The basic process for
specifying a configuration and generating a build space is to create a build
directory and run CMake in it with the proper options. For example::

  $ pwd
  path/to/RAJAPerf
  $ mkdir my-build
  $ cd my-build
  $ cmake <cmake args> ..
  $ make -j (or make -j <N> to build with a specified number of cores)

For convenience and informational purposes, configuration scripts are maintained
in the ``RAJAPerf/scripts`` subdirectories for various build configurations.
For example, the ``RAJAPerf/scripts/lc-builds`` directory contains scripts that
can be used to generate build configurations for machines in the Livermore
Computing (LC) Center at Lawrence Livermore National Laboratory. These scripts
are to be run in the top-level RAJAPerf directory. Each script creates a
descriptively-named build space directory and runs CMake with a configuration
appropriate for the platform and specified compiler(s) indicated by the build
script name. For example, to build the code to generate baseline data on the
El Capitan system::

  $ pwd
  path/to/RAJAPerf
  $ ./scripts/lc-builds/toss4_cray-mpich_amdclang.sh 9.0.1 6.4.3 gfx942
  $ build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ make -j

This will build the code for CPU-GPU execution using the system-installed
version 9.0.1 of the Cray MPICH MPI library with the version 6.4.3 of the AMD
clang compiler (ROCm version 6.4.3) targeting GPU compute architecture gfx942,
which is appropriate for the AMD MI300A APU hardware on El Capitan. Please
consult the build script files in the ``RAJAPerf/scripts/lc-builds`` directory
for hints at building the code for other architectures and compilers. 
Additional information on build configurations is described in the 
`RAJA Performance Suite User Guide <https://app.readthedocs.org/projects/rajaperf/>`_ for the version of the code in which you are interested.


.. _rajaperf_run-label:

Running
=======

After the code is built, the executable will located in the ``bin`` directory
of the build space. Continuing the El Capitan example above::

  $ pwd
  path/to/build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ ls bin
  rajaperf.exe

To get usage information::

  $ path/to/rajaperf.exe --help (or -h)

This command will print all available command-line options along with potential
arguments and defaults. Options are avail to print information about the Suite,
to select output directory and file details, to select kernels and variants to
run, and how they are run (problem sizes, # times each kernel is run, data
spaces to use for array allocation, etc.). All arguments are optional. If no
arguments are specified, the suite will run all kernels in their default 
configurations for the variants that are available for the way the code
is configured to build.

The script to run the benchmark for generating baselines for EL Capitan is
described in :ref:`rajaperf_results-label`. A similar recipe should be followed
for benchmarking other systems.


.. _rajaperf_validation-label:

Validation
==========

Each kernel and variant run generates a checksum value based on kernel execution
output, such as an output data array computed by the kernel. The checksum
depends on the problem size run for the kernel; thus, each checksum is 
computed at run time. Validation criteria is defined in terms of the checksum
difference between each kernel variant and problem size run and a corresponding
reference variant. The ``Base_Seq`` variant is used to define the
reference checksum and so that variant should be run for each kernel as part of
a performance study. Each kernel is annotated in the source code as to whether
the checksum for each variant is expected to match the reference checksum
exactly, or to be within some tolerance due to order of operation differences
when run in parallel.

Whether the checksum for each kernel is considered to be within its expected
tolerance is reported as checksum ``PASSED`` or ``FAILED`` in the output files.

**Show an example of this for the EL Capitan baseline runs!!**

**Reminder: add more accurate Base_Seq summation tunings (left fold is inaccurate for large problem sizes).**

.. _rajaperf_results-label:

Example Benchmark Results
===========================

**Include tables of results of El Capitan baseline results**


.. _rajaperf_memory-label:

Memory Usage
============

**Do we need to say anything here, if we describe how benchmark problem size 
is set in the benchmark results section above???**


Strong Scaling on El Capitan
============================

The RAJA Performance Suite is primarily a single-node and compiler assessment
tool. Thus, strong scaling is not part of the benchmark.


Weak Scaling on El Capitan
==========================

The RAJA Performance Suite is primarily a single-node and compiler assessment
tool. Thus, weak scaling is not part of the benchmark.


References
==========
