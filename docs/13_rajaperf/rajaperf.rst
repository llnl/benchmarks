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
variants that use common parallel programming models, such as OpenMP and CUDA,
including ones that use RAJA and ones that do not.

.. important:: The RAJA Performance Suite Benchmark is limited to a subset of
               kernels in the RAJA Performance Suite described in
               :ref:`rajaperf_problems-label`.

The `RAJAPerf-Benchmark GitHub project <https://github.com/llnl/RAJAPerf-Benchmark>`_ contains the source code, performance baseline data files, run scripts,
and data processing scripts for the RAJA Performance Suite Benchmark. The
project includes the RAJA Performance Suite repo as a submodule, which, in
turn, contains RAJA as a submodule. When the benchmark project repo is cloned
recursively, everything necessary to run the benchmark is included. Detailed
instructions are include in :ref:`rajaperf_build-label`.

Additional information about the RAJA Performance Suite and RAJA is available
at these links:

  * `RAJA Performance Suite GitHub project <https://github.com/LLNL/RAJAPerf>`_ 

  * `RAJA GitHub project <https://github.com/LLNL/RAJAPerf>`_


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
common programming models, such as OpenMP, CUDA, and HIP. Performance
comparisons between RAJA and non-RAJA variants are helpful to improve RAJA
implementations and to identify impacts that C++ abstractions have on compilers'
abilities to optimize. The Suite serves as an important collaboration tool
between the RAJA team and vendors to resolve performance issues observed in
production applications that use RAJA.


Characteristics
===============

The `RAJA Performance Suite GitHub project <https://github.com/LLNL/RAJAPerf>`_
contains the code for all the Suite kernels and all essential external software
dependencies in Git submodules. Thus, dependency versions are pinned to each
version of the Suite. Building the Suite requires an installation of CMake for
configuring a build, a C++17 compliant compiler to build the code, and an MPI
library installation to link against.

The Suite can be run in a myriad of ways via as command-line options and their
arguments. The intent is that once the code is compiled, scripts can be used
to execute necessary Suite runs to generate data for a desired performance
experiment. Instructions for getting the code for the RAJA Performance Suite
Benchmark, building it, and running it are described
in :ref:`rajaperf_run-label`.


.. _rajaperf_problems-label:

Problems
--------

The RAJA Performance Suite Benchmark consists of a subset of kernels in the
full Suite that focus on some key computational patterns found in LLNL
applications. The subset of kernels is described below, including key
kernel features and RAJA constructs used (in parentheses). 

.. note:: In the RAJA Performance Suite repository, each kernel contains a
          detailed reference description near the top of the header file for
          the kernel class; i.e., C++ header file named ``<kernel-name>.hpp``.
          The reference description is a C-style sequential implementation of
          the kernel in a comment section near the top of the file.

The RAJA Performance Suite Benchmark kernels are partitioned into two
priority levels described below.


Priority 1 kernels
^^^^^^^^^^^^^^^^^^^

*Priority 1* kernels are most important to us. They are located in the
``RAJAPerf/src/apps`` sub-directory:

   #. **DIFFUSION3DPA** element-wise action of a 3D finite element volume diffusion operator via partial assembly and sum factorization *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **EDGE3D** stiffness matrix assembly for a 3D MHD calculation *(single loop with included function call, RAJA::forall API)*
   #. **ENERGY** internal energy calculation from an explicit hydrodynamics algorithm; *(multiple single-loop operations in sequence, conditional logic for correctness checks and cutoffs, RAJA::forall API)*
   #. **FEMSWEEP** finite element implementation of linear sweep algorithm used in radiation transport *(nested loops, RAJA::launch API)*
   #. **INTSC_HEXRECT** intersection between a 24-sided hexahedron and a rectangular solid, including volume and moment calculations *(single loop, RAJA::forall API)*
   #. **MASS3DEA** element assembly of a 3D finite element mass matrix *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **MASS3DPA_ATOMIC** action of a 3D finite element mass matrix on elements with shared DOFs via partial assembly and sum factorization *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **MASSVEC3DPA** element-wise action of a 3D finite element mass matrix via partial assembly and sum factorization on a block vector *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **NODAL_ACCUMULATION_3D** on a 3D structured hexahedral mesh, sum a contribution from each hex vertex (nodal value) to its centroid (zonal value) *(single loop, data access via indirection array, 8-way atomic contention, RAJA::forall API)*
   #. **VOL3D** on a 3D structured hexahedral mesh (faces are not necessarily planes), compute volume of each zone (hex) *(single loop, data access via indirection array, RAJA::forall API)*


Priority 2 kernels
^^^^^^^^^^^^^^^^^^^

*Priority 1* kernels important, but less than the kernels listed above. They
are listed below and are located in the ``RAJAPerf/src`` sub-directories noted:

   #. **apps/CONVECTION3DPA** element-wise action of a 3D finite element volume convection operator via partial assembly and sum factorization *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **apps/DEL_DOT_VEC_2D** divergence of a vector field at a set of points on a mesh *(single loop, data access via indirection array, RAJA::forall API)*
   #. **apps/INTSC_HEXHEX** intersection between two 24-sided hexahedra, including volume and moment calculations *(multiple single-loop operations in sequence, RAJA::forall API)*
   #. **apps/LTIMES** one step of the source-iteration technique for solving the steady-state linear Boltzmann equation, multi-dimensional matrix product *(nested loops, RAJA::kernel API)*
   #. **apps/MASS3DPA** element-wise action of a 3D finite element mass matrix via partial assembly and sum factorization *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **apps/MATVEC_3D_STENCIL** matrix-vector product based on a 3D mesh stencil *(single loop, data access via indirection array, RAJA::forall API)*
   #. **basic/MULTI_REDUCE** multiple reductions in a kernel, where number of reductions is set at run time *(single loop, irregular atomic contention, RAJA::forall API)*
   #. **basic/REDUCE_STRUCT** multiple reductions in a kernel, where number of reductions (6) is known at compile time *(single loop, multiple reductions, RAJA::forall API)*
   #. **basic/INDEXLIST_3LOOP** construction of set of indices used in other kernel executions *(single loops, vendor scan implementations, RAJA::forall API)*
   #. **comm/HALO_PACKING_FUSED** packing and unpacking MPI message buffers for point-to-point distributed memory halo data exchange for mesh-based codes *(overhead of launching many small kernels, GPU variants use RAJA::Workgroup concepts to execute multiple kernels with one launch)* 


.. _rajaperf_fom-label:

Figure of Merit
---------------

The figure of merit (FOM) for each kernel is determined by the problem size at
which the kernel *saturates* resources on a *single* compute node. That is,
the problem size at which a computational throughput curve becomes flat, with
zero derivative, and beyond which a running larger problem sizes does not yield
an increase in compute rate. The FOM for each kernel includes 3 numerical
values:

  * the saturation problem size (GB)
  * the compute rate (GFLOP/s) at the saturation problem size 
  * the memory bandwidth (GB/s) at the saturation problem size

When the Suite is run, problem size, compute rate, and memory bandwidth, among
other data are reported in output files. We provide a Python script, whose
usage is described below, to generate throughput plots and a FOM file for the
kernels run across a range of problem sizes. 

One can visualize computational throughput using a plot where compute rate,
such as GFLOP/s, is plotted on the vertical axis as a function of problem size
on the horizontal axis. Ideally, such a curve will be monotonically increasing
and asymptote to a flat, horizontal line. Then, the saturation point is the
problem size at which the derivative of the throughput curve becomes zero.
In reality, throughput curves are often non-monotonic or do not have a 
strictly zero derivative for all points beyond some problem size. Therefore, we
apply a simple median based smoothing algorithm to the throughput curve data
and heuristically estimate the saturation point based on the smoothed
throughput curve. The details of our approach are documented in the
``process_data.py`` script in the `RAJAPerf-Benchmark GitHub project <https://github.com/llnl/RAJAPerf-Benchmark>`_ repository, which we use in 
:ref:`rajaperf_run-label`

Lastly, we emphasize that we want the kernels to be run in an execution
environment that aligns with how they would run if used in a real application.
Thus, the Suite should be run **using multiple MPI ranks** so that all
resources on a compute node are being exercised in a way that is
representative of how an application would run.

All applications that use RAJA use it in an the *MPI + X* parallel application
paradigm, where MPI is used for coarse-grained, distributed memory parallelism
and X (RAJA in this case) supports fine-grained parallelism within each MPI
rank. The RAJA Performance Suite can be configured with MPI so that execution
of kernels in the Suite follows the *MPI + X* application paradigm. When a
kernel is run using multiple MPI ranks, the same code executes simultaneously
on each MPI rank. Synchronization and communication across ranks only involves
sending execution timing information from each rank to rank zero for reporting
purposes.

.. important:: For RAJA Performance Suite benchmark execution, MPI must be used
               to run to ensure that all resources on a compute node are being 
               exercised and avoid misrepresentation of kernel and node
               performance. This is described in the instructions provided in
               :ref:`rajaperf_run-label`.


.. _rajaperf_codemod-label:

Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications. 
For the RAJA Performance Suite, we define the following restrictions on source
code modifications:

* While source code changes to the RAJA Performance Suite kernels and to RAJA
  can be proposed for improved performance, for example, RAJA may not be
  removed from *RAJA kernel variants* in the Suite or replaced with any other
  library. The *Base kernel variants* in the Suite are provided to show how
  each kernel can be implemented directly in the corresponding programming
  model back-end without the RAJA abstraction layer. Apart from some special
  cases, the RAJA and Base variants for each kernel should execute the same
  operations.


.. _rajaperf_build-label:

Building
========

Getting the code
----------------

All non-system related software dependencies needed to compile and run the
benchmark are contained in the `RAJAPerf-Benchmark GitHub project <https://github.com/llnl/RAJAPerf-Benchmark>`_ repository as Git submodules.
The ``v2025.12.0`` version of the repo is the current version and was used to
generate the baseline data described in this document.

Clone the GitHub repo::

  $ git clone --recursive git@github.com:llnl/RAJAPerf-Benchmark.git

When you do that, you will be on the ``main`` branch of the benchmark repo,
which is the default branch. To get a local copy of the version used to
generate the baselines, execute the following commands::

  $ git checkout v2025.12.0
  $ git submodule update --init --recursive 

Configuration and compilation
------------------------------

The RAJA Performance Suite uses a CMake-based system to configure the code for
compilation. When building the RAJA Performance Suite, RAJA and the RAJA
Performance Suite are built together with the same CMake configuration.
The general process for specifying a configuration and generating a build space
is to create a build directory and run CMake in it with the proper options.
For example::

  $ pwd
  path/to/RAJAPerf
  $ mkdir my-build
  $ cd my-build
  $ cmake <cmake args> ..
  $ make -j (or make -j <N> to build with a specified number of cores)

For convenience and informational purposes, configuration scripts are maintained
in ``RAJAPerf/scripts`` subdirectories for various build configurations.
For example, the ``RAJAPerf/scripts/lc-builds`` directory contains scripts that
can be used to generate build configurations for machines in the Livermore
Computing (LC) Center at Lawrence Livermore National Laboratory. These scripts
are to be run in the top-level RAJAPerf directory. Each script creates a
descriptively-named build space directory and runs CMake with a configuration
appropriate for the platform and specified compiler(s) indicated by the build
script name. 

MI300A architecture
--------------------

To configure and build the code to generate baseline data on a system with 
AMD MI300A processors (i.e., El Capitan architecture) discussed in
:ref:`rajaperf_results-label`, we ran the following commands::

  $ pwd
  path/to/RAJAPerf
  $ ./scripts/lc-builds/toss4_cray-mpich_amdclang.sh 9.0.1 6.4.3 gfx942
  $ cd build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ make -j

Specifically, we configured and compiled the code for execution using version
9.0.1 of the Cray MPICH MPI library and version 6.4.3 of the AMD clang compiler
(ROCm version 6.4.3) targeting GPU compute architecture gfx942.

H100 architecture
--------------------

To configure and build the code to generate baseline data on a system with
NVIDIA H100 processors discussed in :ref:`rajaperf_results-label`, we ran the
following commands::

  $ pwd
  path/to/RAJAPerf
  $ ./scripts/lc-builds/toss4_mvapich2_nvcc_gcc.sh 2.3.7 12.9.1 90 10.3.1
  $ build_lc_toss4-mvapich2-2.3.7-nvcc-12.9.1-90-gcc-10.3.1
  $ make -j

Specifically, we configured and compiled the code for execution using version
2.3.7 of the MVAPICH2 MPI library, version 12.9.1 of the nvcc compiler targeting
GPU compute architecture sm_90, and version 10.3.1 of the GNU compiler.


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
