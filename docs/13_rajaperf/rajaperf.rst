**********************
RAJA Performance Suite
**********************

The RAJA Performance Suite is a collection of loop-based computational kernels that
represent important algorithm patterns found in HPC applications. It is a
companion project to RAJA, which is a library of software abstractions used by
C++ application developers to write portable, performant, *single-source* code.
Each kernel in the Suite appears in multiple *variants* that employ common parallel
programming models, such as OpenMP and CUDA. Variants include implementations
that use RAJA and those that don't; non-RAJA variants are referred to as *Base* variants.

The main purpose of the RAJA Performance Suite is to study performance of computational kernels
implemented using RAJA and common parallel programming models. Comparison of RAJA and non-RAJA
variants helps to improve RAJA implementations and to understand impacts that C++ abstractions have
on compilers' abilities to optimize. The Suite is an important collaboration tool used by the RAJA
team to work with vendors and other collaborators to resolve performance issues observed in
production applications that use RAJA.

Important things to know about the RAJA Performance Suite Benchmark are:

  * The RAJA Performance Suite Benchmark exercises a small subset of kernels in the
    RAJA Performance Suite. The Benchmark subset is described in the :ref:`rajaperf_problems-label` section.

  * All code needed to generate the RAJA Performance Suite Benchmark results described in this
    document is included in the `RAJAPerf-Benchmark <https://github.com/llnl/RAJAPerf-Benchmark>`_
    GitHub repo. The discussion in this document refers to the contents of that repo. Instructions
    to build and run the Benchmark code and generate the figures of merit (FOM) can be found
    in the :ref:`rajaperf_build-label` and :ref:`rajaperf_run-label` sections.

More information about RAJA and the RAJA Performance Suite is available in their documentation linked
to their respective GitHub repos: 

  * `RAJA Performance Suite GitHub repo <https://github.com/LLNL/RAJAPerf>`_ 

  * `RAJA GitHub repo <https://github.com/LLNL/RAJAPerf>`_

.. important:: The results presented here are associated with the latest version of the RAJA Performance
               Suite Benchmark, which uses:

                 * Version ``v2026.07.0`` of the RAJA Performance Suite, which in turn uses
                 * Version ``v2026.07.1`` of RAJA
                 * All code needed for the latest version of the Benchmark is available in the
                   version ``v2026.10.0`` version of the
                   `RAJAPerf-Benchmark GitHub repo <https://github.com/llnl/RAJAPerf-Benchmark>`_ 
                 * More details are provided in the :ref:`rajaperf_build-label` section of this
                   documentation, along with build and run instructions including compilers and
                   versions.

Purpose
=======

The purpose of the RAJA Performance Suite Benchmark is for vendors and other collaborators
to generate the FOM, described in :ref:`rajaperf_fom-label`, for a subset of the RAJA
Performance Suite kernels. The Benchmark kernels have been chosen by RAJA developers and users
to representing important computations in production applications at Lawrence Livermore National Laboratory.


Characteristics
===============

The RAJA Performance Suite Benchmark is a single node performance benchmark.
All applications that use RAJA follow the *MPI + X* parallel application
paradigm. That is, MPI is used for coarse-grained, distributed memory parallelism
and X, which is RAJA in this case, supports fine-grained parallelism within each MPI
rank. Typically, we run the Benchmark with multiple MPI ranks. When this is done, the
same code executes on each rank and synchronization and communication are performed only
to collect execution timing information on rank zero for reporting purposes.
The Benchmark run scripts launch multiple MPI ranks, one for each GPU on a node
for each architecture so that the node is *fully subscribed* when the Benchmark is run.

While the RAJA Performance Suite can be run in myriad ways via command-line options
and arguments, the RAJA Performance Suite Benchmark is run in a specific fashion to generate
the results reported below. The `RAJAPerf-Benchmark <https://github.com/llnl/RAJAPerf-Benchmark>`_
GitHub repo contains everything needed to build and run the RAJA Performance Suite Benchmark and
generate the FOM. This includes the RAJA Performance Suite and RAJA codes in Git submodules
and scripts to build, run, and generate throughput plots and FOM data. Versions of the
RAJA Performance Suite and RAJA dependencies are pinned to each version of the RAJA Performance
Suite Benchmark repo. Thus, it is important to ensure that the desired Benchmark version is
checked out and that the submodules are consistent with that. Building the RAJA Performance
Suite Benchmark code requires:

  * CMake to configure a build
  * A C++20 compliant compiler to build the code
  * An MPI library installation to link the executable against

Instructions for getting the RAJA Performance Suite Benchmark code, building it,
and running it are described in the :ref:`rajaperf_build-label` and :ref:`rajaperf_run-label`
sections.

When the Suite is run, problem size, compute rate, memory bandwidth, result checksums, etc.
are reported in various files in an output directory. We provide a Python script to traverse
the contents of an output directory and generate a smaller set of summary files, throughput plots,
and FOM information. We describe the exact Script usage in :ref:`rajaperf_run-label`.


.. _rajaperf_problems-label:

Problems
--------

The RAJA Performance Suite Benchmark consists of a subset of RAJA Performance
Suite kernels. The Benchmark kernels are partitioned into two Priority levels. Herein, we refer to
these as *Tiers*.

  * Descriptions of Tier 1 kernels, how they are built, run, and assessed for the Benchmark are
    provided below.
  * Similar information for Tier 2 kernels can be found in :doc:`RAJA Performance Suite Tier 2 Kernels
    <../modsim/rajaperf_priority2>`.

.. note:: In the RAJA Performance Suite repository, each kernel is implemented in
          multiple files. Source files include ``<kernel-name>.cpp``, which contains code that is
          independent of kernel variants, and multiple ``<kernel-name>-<back-end>.cpp`` files,
          each of which contains variants that exercise the named programming model back-end. A header file
          ``<kernel-name>.hpp`` contains a reference implementation of the kernel,
          which is a C-style sequential version. The reference is similar to the base sequential variant
          implemented in the Suite, which is used to generate the kernel reference checksum against which
          we compare results of all other variants for correctness validation.


Tier 1 kernels
^^^^^^^^^^^^^^^^^^^

Tier 1 are described in the following list, which includes the computational pattern/algorithm that each
kernel represents and which RAJA features it exercises. In the RAJA Performance Suite repo, the kernel source
code is located in files in the ``RAJAPerf/src/apps`` sub-directory:

   #. **DIFFUSION3DPA** element-wise action of a 3D finite element volume diffusion operator via partial assembly and sum factorization *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **EDGE3D** stiffness matrix assembly for a 3D MHD calculation *(single loop with included function call, RAJA::forall API)*
   #. **ENERGY** internal energy calculation from an explicit hydrodynamics algorithm; *(multiple single-loop operations in sequence, conditional logic for correctness checks and cutoffs, RAJA::forall API)*
   #. **FEMSWEEP** finite element implementation of linear sweep algorithm used in radiation transport, with a register-heavy LU solver *(nested loops, RAJA::launch API)*
   #. **INTSC_HEXRECT** intersection between a 24-sided hexahedron and a rectangular solid, including volume and moment calculations *(single loop, RAJA::forall API)*
   #. **MASS3DEA** element assembly of a 3D finite element mass matrix *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **MASS3DPA_ATOMIC** action of a 3D finite element mass matrix on elements with shared DOFs via partial assembly and sum factorization *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **MASSVEC3DPA** element-wise action of a 3D finite element mass matrix via partial assembly and sum factorization on a block vector *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **NODAL_ACCUMULATION_3D** on a 3D structured hexahedral mesh, sum a contribution from each hex vertex (nodal value) to its centroid (zonal value) *(single loop, data access via indirection array, 8-way atomic contention, RAJA::forall API)*
   #. **VOL3D** on a 3D structured hexahedral mesh (faces are not necessarily planes), compute volume of each zone (hex) *(single loop, data access via indirection array, RAJA::forall API)*


.. _rajaperf_fom-label:

Figure of Merit
---------------

The Figure of Merit (FOM) for each kernel and variant is determined by the problem size at
which the kernel variant *saturates* resources on a *single* compute node. We run each 
kernel and variant over a sequence of problem sizes to determine a saturation point where
the computational throughput curve becomes flat, with zero derivative, and beyond which
running a larger problem size yields no further increase in compute rate. Then, the
FOM consists of 3 numerical values:

  * the saturation problem size (GB)
  * the compute rate (GFLOP/sec) achieved at the saturation problem size 
  * the memory bandwidth (GB/sec) achieved at the saturation problem size

In the Benchmark, the problem size refers to the amount of memory
allocated for the requested problem to run. The notion of problem size
can depend on what one is trying to measure. For our perspective on this topic,
please see the `Problem Size section <https://rajaperf.readthedocs.io/en/develop/sphinx/user_guide/output.html#notes-about-problem-size>`_ of the RAJA Performance Suite User Guide.

Computational throughput may be visualized on a plot where compute rate
(vertical axis) is plotted as a function of problem size (horizontal axis).
Ideally, such a curve is monotonically increasing and transitions to a flat,
horizontal line. Then, the saturation point is the problem size at which the derivative
of the throughput curve becomes zero. In reality, a measured throughput curve may be
non-monotonic or not have a strictly zero derivative for all points beyond some problem
size. Therefore, we apply a simple median based smoothing algorithm to the computed throughput
data points and use simple heuristics to estimate the saturation point based on a *smoothed*
approximation of the throughput curve. The details of our approach are documented in the Python script
``process_data.py`` that lives in the `scripts` directory of the
`RAJAPerf-Benchmark <https://github.com/llnl/RAJAPerf-Benchmark>`_ GitHub repo
for the baseline set we are interested in. We describe the use of the script
in :ref:`rajaperf_results-label`.

.. important:: * The scripts and their invocations described in :ref:`rajaperf_run-label`
                 show how we determine the FOM values. Others are free to generate the
                 values by other means if they prefer.
               * In any case, the saturation point for all Tier 1 kernels should be estimated based on compute rate data.

.. _rajaperf_codemod-label:

Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed Benchmark modifications.
For the RAJA Performance Suite Benchmark, we restrict source code modifications as follows:

* Source code changes to the RAJA Performance Suite kernels and to RAJA
  may be proposed for improved performance.
* RAJA may not be removed from *RAJA kernel variants* in the Suite or replaced
  with any other execution abstractions.

The *non-RAJA kernel variants* in the Suite are provided to show how
each kernel may be implemented directly using each programming model without
using RAJA. Apart from a few instances, the RAJA and non-RAJA variants for
each kernel and back-end should perform the same operations.


.. _rajaperf_build-label:

Building
========

Getting the code
----------------

All non-system software needed to compile and run the Benchmark is contained in the
`RAJAPerf-Benchmark GitHub repo <https://github.com/llnl/RAJAPerf-Benchmark>`_
repository and its Git submodules. The ``v2026.10.0`` version of that repo
was used to generate the results presented in the :ref:`rajaperf_results-label` section
of this document.

To clone the repo::

  $ git clone --recursive git@github.com:llnl/RAJAPerf-Benchmark.git

This will make a copy of the repo in a local directory and put you on the ``main``
branch of the repo, which is the default branch. To get the version used to
generate the results presented below, execute the following commands::

  $ cd path/to/RAJAPerf-Benchmark
  $ git checkout v2026.10.0
  $ git submodule update --init --recursive

This will ensure that you have the proper version of the Benchmark code, including
the RAJAPerf and RAJA submodules, in your local directory.


Configuration and compilation
------------------------------

The RAJA Performance Suite uses a CMake-based system to configure the code for
compilation. When building the code, RAJA and the RAJA
Performance Suite are built together with the same configuration which
is specified at the RAJA Performance Suite level. Generically, the process for
specifying a configuration and generating a build space involves creating a build
directory and running CMake in it with the desired options::

  $ cd path/to/RAJAPerf
  $ mkdir my-build
  $ cd my-build
  $ cmake <cmake args> ..
  $ make -j (or make -j <N> to build with a specified number of cores)

For convenience and informational purposes, we maintain configuration scripts
in ``RAJAPerf/scripts`` subdirectories for various builds. For example, the
``RAJAPerf/scripts/lc-builds`` directory contains scripts that we use to
generate build configurations for machines in the Livermore Computing (LC)
Center at Lawrence Livermore National Laboratory. These scripts are run from
the top-level RAJAPerf directory. Each script creates a descriptively-named build
space directory and runs CMake to generate a build space in it. Executing a
configuration script with no arguments will produce a message indicating
which arguments are required.

These scripts were used to configure the Benchmark code for compilation to generate the
Benchmark results as described in the next couple of sections.

.. _rajaperf_build_mi300a-label:

AMD MI300A architecture
------------------------

The following commands were used to configure and build the code to generate the AMD
MI300A results presented in :ref:`rajaperf_results-label`::

  $ cd path/to/RAJAPerf
  $ ./scripts/lc-builds/toss4_cray-mpich_amdclang.sh 9.0.1 6.4.3 gfx942
  $ cd build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ make -j

This was done on an ASC ATS-4 platform (El Capitan architecture) at LLNL.
Specifically, we built the code with version 9.0.1 of the Cray MPICH MPI library
and the AMD clang compiler with ROCm version 6.4.3 targeting GPU compute architecture gfx942.

.. note:: Newer ROCm compilers are available. However, version 6.4.3 was used
          by all LLNL codes using RAJA for production builds at the time
          we generated the baseline results. Thus, we use that compiler version here.

.. _rajaperf_build_h100-label:

NVIDIA H100 architecture
-------------------------
The following commands were used to configure and build the code to generate the 
NVIDIA H100 results presented in :ref:`rajaperf_results-label`::

  $ cd path/to/RAJAPerf
  $ ./scripts/lc-builds/toss4_mvapich2_nvcc_gcc.sh 2.3.7 13.1.1 90 10.3.1
  $ cd build_lc_toss4-mvapich2-2.3.7-nvcc-13.1.1-90-gcc-10.3.1
  $ make -j

This was done on a Livermore Computing platform with 4th generation Intel
Sapphire Rapids CPUs and NVIDIA H100 GPUs. Specifically, we built the code 
with version 2.3.7 of the MVAPICH2 MPI library, version 13.1.1 of the
nvcc CUDA compiler targeting GPU compute architecture sm_90, and version 10.3.1
of the GNU compiler for host code.

.. note:: These compiler and MPI versions were the system defaults on the
          the LC platform we used when we generated the baseline results. 


.. _rajaperf_run-label:

Running
=======

When the RAJA Performance Suite code is built using the steps above, the
executable will be generated in the ``bin`` subdirectory of the build space.

.. important:: In :ref:`rajaperf_results-label`, we provide the exact commands we used to
               run the code and generate the baseline results for the Benchmark.

To learn about other ways in which the RAJA Performance Suite code can be run, please consult
the user documentation in the `RAJA Performance Suite GitHub repo <https://github.com/LLNL/RAJAPerf>`_.

.. _rajaperf_validation-label:

Validation
==========

When each kernel variant is run, it produces a checksum value based on its output,
such as a data array whose entries are computed by the kernel. In general, such a
checksum value depends on the kernel problem size; thus, we compute the checksum each time a kernel
variant runs. Kernel result validation compares the checksum of the kernel variant run and a reference
variant of the same kernel. For the Benchmark, the reference variant is the sequential (CPU)
variant. Thus, the Benchmark run scripts execute the sequential variants although we
we are only interested in the FOM for the Benchmark (CUDA and HIP) variants.

The checksum tolerance is specific to each kernel and is set in the kernel class constructor,
based on how sensitive kernel results are to order of operation differences when run in parallel
or some other aspect of the kernel. Whether the checksum for a kernel is within its expected tolerance
is reported as checksum ``PASSED`` or ``FAILED`` in the checksum output files.

.. important:: All Tier 1 kernels have the *normal* checksum tolerance values for the Suite by default,
               which is 1e-10, except for the FEMSWEEP kernel which has a *loose* tolerance value of 5e-6. 
               The reason for the loose tolerance is that the implementation of the kernel uses an LU
               factorization without pivoting in the linear solver, unlike the application it came from, and
               the kernel data is initialized in a way that causes a high amount of variance in the output.


.. _rajaperf_results-label:

Benchmark Results
===========================

We are interested in single-node throughput with this Benchmark and the FOM
described above. To generate throughput curves and
estimate saturation points, we use a bash shell script to run the code
and a Python script to process the data. These scripts are available in the
`RAJAPerf-Benchmark GitHub repo <https://github.com/llnl/RAJAPerf-Benchmark>`_
in the ``RAJAPerf-Benchmark/RPB-v2026.10.0/scripts`` directory.

.. important:: In the following sections, we present detailed results,
               including FOM tables and throughput plots for the Tier 1
               kernels described above. Data and plot files are included
               in the ``baseline_data`` directory of this benchmark
               repository for reference.

AMD MI300A throughput results (Tier 1 kernels)
----------------------------------------------------

For the MI300A architecture, we present two sets of throughput results. One is
run in ``SPX mode`` where we use 4 MPI ranks on a node, one for each MI300A APU,
thus treating each APU as a single GPU. The other is run in ``CPX mode`` where
we run with 24 MPI ranks on a node, six for each MI300A APU, treating each APU as
6 GPUs (i.e., one GPU = 1 XCD).

SPX mode (Tier 1)
^^^^^^^^^^^^^^^^^^^^^^

For SPX mode (1 MPI rank per APU on a node), we chose the problem size range
such that the smallest problem allocates ~100,000 bytes of memory and the largest
problem allocates ~400MB of memory. The largest size is about 1.5 times the MALL 
(Memory Attached Last-Level cache) size on the MI300A. The MALL is 256MB
(256 * 1024 * 1024 = 268,435,456 bytes).

Note that we run a different problem size range for two of the kernels,
``FEMSWEEP`` and ``MASS3DEA``, because they don't clearly saturate.
For those kernels, the smallest problem allocates ~3.2MB of memory and the
largest problem allocates ~600MB memory, which is over twice as big as the MALL.

After building the code as described in :ref:`rajaperf_build_mi300a-label`, we
ran the ``Tier 1`` kernels in **SPX mode** using the following commands::

  $ cd path/to/RAJAPerf
  $ cd build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ cp ../../RPB-v2026.10.0/scripts/run_tier_mi300a.sh .
  $ ./run_tier_mi300a.sh spx tier1

This generates a directory named ``RPBenchmark_MI300A_tier1-SPX`` containing
output files for each kernel.

Then, we processed the data to generate FOM and throughput plots
by running a Python script we provide::

  $ cd path/to/RAJAPerf
  $ cd build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ cp ../../RPB-v2026.10.0/scripts/process_data.py .
  $ python3 ./process_data.py --root-dir ./RPBenchmark_MI300A_tier1-SPX --output-dir ./RPBenchmark_MI300A_tier1-SPX/Output --exclude-plot-variant Base_Seq

This generates throughput curve files for ``Base_HIP`` and ``RAJA_HIP``
variants of each kernel and summarizes the FOM (described in
:ref:`rajaperf_fom-label`) in a CSV file. We include the files generated by the
``process_data.py`` script in this repo in the directory
``./docs/13_rajaperf/baseline_data/RPBenchmark_MI300A_tier1-SPX``.

.. csv-table:: FOM results for Tier 1 kernels run on MI300A in SPX mode
   :file: ./baseline_data/RPBenchmark_MI300A_tier1-SPX/FOM/combined_fom.csv
   :align: center
   :widths: auto
   :header-rows: 1

CPX mode (Tier 1) 
^^^^^^^^^^^^^^^^^^^^^^

For CPX mode (run with 6 MPI ranks per APU on a node), we choose the
smallest problem to allocate ~50,000 bytes of memory and the largest
problem to allocate ~75MB of memory, which is slightly less than 1/3 the MALL size.

Similar to SPX mode, we ran a different problem size range for the ``FEMSWEEP``
and ``MASS3DEA`` kernels because they don't clearly saturate. For those, we chose
the smallest problem to allocate ~1.6MB of memory and the largest problem to
allocate ~200MB memory, which is a little less than the MALL size.

Similar to the SPX mode description above, we ran the ``Tier 1`` kernels in
**CPX mode** using the following commands::

  $ cd path/to/RAJAPerf
  $ cd build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ cp ../../RPB-v2026.10.0/scripts/run_tier_mi300a.sh .
  $ ./run_tier_mi300a.sh cpx tier1

This generates a directory named ``RPBenchmark_MI300A_tier1-CPX`` containing
output files for each kernel.

Then, we processed the data to generate FOM and throughput plots
by running a Python script we provide::

  $ cd path/to/RAJAPerf
  $ cp ../../RPB-v2026.10.0/scripts/process_data.py .
  $ python3 ./process_data.py --root-dir ./RPBenchmark_MI300A_tier1-CPX --output-dir ./RPBenchmark_MI300A_tier1-CPX/Output --exclude-plot-variant Base_Seq

This generates throughput curve files for ``Base_HIP`` and ``RAJA_HIP``
variants of each kernel and summarizes the FOM (described in
:ref:`rajaperf_fom-label`) in a CSV file. We include these files in this repo in the
directory ``./docs/13_rajaperf/baseline_data/RPBenchmark_MI300A_tier1-CPX``.

.. csv-table:: FOM results for Tier 1 kernels run on MI300A in CPX mode
   :file: ./baseline_data/RPBenchmark_MI300A_tier1-CPX/FOM/combined_fom.csv
   :align: center
   :widths: auto
  :header-rows: 1
 
.. _rajaperf_results_mi300_throughput-label:

AMD MI300A throughput plots (Tier 1)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This section contains throughput plots for each Tier 1 kernel
on the MI300A architecture in SPX mode (left column) and CPX mode (right column).
Each plot has multiple curves with GFLOP/sec (compute rate) plotted as a function of problem size
(allocated bytes).  Each plot includes:

  * Throughput curves for Base and RAJA variant(s) of the kernels. Solid line
    segments connect the dots, where the dots are actual GFLOP rates
    determined from the run data.
  * Smoothed versions of the throughput curves, plotted as dashed lines,
    which are computed using a median based smoothing algorithm.
  * Stars indicating approximate saturation points based on the smoothed
    curves and computed using simple heuristics. The legend contains the (x, y)
    values for the saturation points.

Most plots contain two variants, with the *Base* non-RAJA variant in blue and RAJA
variant in orange. In each case, the throughput curves and saturation points are close,
which indicates that the RAJA variants perform as well as the non-RAJA variants
that are written directly in HIP with no RAJA abstractions. Some kernel plots
contain additional curves that show more variants. Additional curves are included to
show how kernel execution choices, such as RAJA execution policies, can have a significant
impact on run time performance.

+-----------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+
| Tier 1 Kernels: MI300A Node Throughput (SPX Mode)                                                   | Tier 1 Kernels: MI300A Node Throughput (CPX Mode)                                                   |
+-----------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_MI300A_tier1-SPX/figures/Apps_DIFFUSION3DPA_flops.png         | .. figure:: baseline_data/RPBenchmark_MI300A_tier1-CPX/figures/Apps_DIFFUSION3DPA_flops.png         |
|    :width: 100 %                                                                                    |    :width: 100 %                                                                                    |
|    :align: center                                                                                   |    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_MI300A_tier1-SPX/figures/Apps_EDGE3D_flops.png                | .. figure:: baseline_data/RPBenchmark_MI300A_tier1-CPX/figures/Apps_EDGE3D_flops.png                |
|    :width: 100 %                                                                                    |    :width: 100 %                                                                                    |
|    :align: center                                                                                   |    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_MI300A_tier1-SPX/figures/Apps_ENERGY_flops.png                | .. figure:: baseline_data/RPBenchmark_MI300A_tier1-CPX/figures/Apps_ENERGY_flops.png                |
|    :width: 100 %                                                                                    |    :width: 100 %                                                                                    |
|    :align: center                                                                                   |    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_MI300A_tier1-SPX/figures/Apps_FEMSWEEP_flops.png              | .. figure:: baseline_data/RPBenchmark_MI300A_tier1-CPX/figures/Apps_FEMSWEEP_flops.png              |
|    :width: 100 %                                                                                    |    :width: 100 %                                                                                    |
|    :align: center                                                                                   |    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_MI300A_tier1-SPX/figures/Apps_INTSC_HEXRECT_flops.png         | .. figure:: baseline_data/RPBenchmark_MI300A_tier1-CPX/figures/Apps_INTSC_HEXRECT_flops.png         |
|    :width: 100 %                                                                                    |    :width: 100 %                                                                                    |
|    :align: center                                                                                   |    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_MI300A_tier1-SPX/figures/Apps_MASS3DEA_flops.png              | .. figure:: baseline_data/RPBenchmark_MI300A_tier1-CPX/figures/Apps_MASS3DEA_flops.png              |
|    :width: 100 %                                                                                    |    :width: 100 %                                                                                    |
|    :align: center                                                                                   |    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_MI300A_tier1-SPX/figures/Apps_MASS3DPA_ATOMIC_flops.png       | .. figure:: baseline_data/RPBenchmark_MI300A_tier1-CPX/figures/Apps_MASS3DPA_ATOMIC_flops.png       |
|    :width: 100 %                                                                                    |    :width: 100 %                                                                                    |
|    :align: center                                                                                   |    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_MI300A_tier1-SPX/figures/Apps_MASSVEC3DPA_flops.png           | .. figure:: baseline_data/RPBenchmark_MI300A_tier1-CPX/figures/Apps_MASSVEC3DPA_flops.png           |
|    :width: 100 %                                                                                    |    :width: 100 %                                                                                    |
|    :align: center                                                                                   |    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_MI300A_tier1-SPX/figures/Apps_NODAL_ACCUMULATION_3D_flops.png | .. figure:: baseline_data/RPBenchmark_MI300A_tier1-CPX/figures/Apps_NODAL_ACCUMULATION_3D_flops.png |
|    :width: 100 %                                                                                    |    :width: 100 %                                                                                    |
|    :align: center                                                                                   |    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_MI300A_tier1-SPX/figures/Apps_VOL3D_flops.png                 | .. figure:: baseline_data/RPBenchmark_MI300A_tier1-CPX/figures/Apps_VOL3D_flops.png                 |
|    :width: 100 %                                                                                    |    :width: 100 %                                                                                    |
|    :align: center                                                                                   |    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+


NVIDIA H100 throughput results (Tier 1 kernels)
----------------------------------------------------

For the NVIDIA H100 architecture, we present one set of throughput results, where we ran with
4 MPI ranks on a node -- one for each H100 GPU.

Similar to our methodology for the MI300A architecture, we ran each kernel and variant
over a range of problem sizes to expose the saturation point. Specifically, we chose the
smallest problem to allocate ~50,000 bytes of memory and the largest problem to allocate
~150MB of memory, which is about 3 times the L2 cache size on the H100 GPU.  The L2 cache
is 50MB (50 * 1024 * 1024 = 52,428,800 bytes).

We ran a different problem size range for the ``FEMSWEEP`` and ``MASS3DEA``
kernels because they don't clearly saturate. For them, we chose the smallest
problem to allocate ~1.6MB of memory and the largest problem to allocate ~300MB of memory,
which is about 6 times the L2 cache size.

After building the code as described in :ref:`rajaperf_build_h100-label`, we
ran the ``Tier 1`` kernels using the following commands::

  $ cd path/to/RAJAPerf
  $ cd build_lc_toss4-mvapich2-2.3.7-nvcc-13.1.1-90-gcc-10.3.1
  $ cp ../../RPB-v2026.10.0/scripts/run_tier_h100.sh .
  $ ./run_tier_h100.sh tier1

This generates a directory named ``RPBenchmark_H100_tier1`` containing
results files for each kernel run.

Then, we processed the data to generate FOM and throughput plots
by running a Python script we provide::

  $ cd path/to/RAJAPerf
  $ cd build_lc_toss4-mvapich2-2.3.7-nvcc-13.1.1-90-gcc-10.3.1
  $ cp ../../RPB-v2026.10.0/scripts/process_data.py .
  $ python3 ./process_data.py --root-dir ./RPBenchmark_H100_tier1 --output-dir ./RPBenchmark_H100_tier1/Output --exclude-plot-variant Base_Seq

This generates throughput curve files for ``Base_CUDA`` and ``RAJA_CUDA``
variants of each kernel and summarizes the FOM (described in
:ref:`rajaperf_fom-label`) in a CSV file.  We include
the files generated by the ``process_data.py`` script in this repo in the
directory ``./docs/13_rajaperf/baseline_data/RPBenchmark_H100_tier1``.

.. csv-table:: FOM results for Tier 1 kernels run on H100
   :file: ./baseline_data/RPBenchmark_H100_tier1/FOM/combined_fom.csv
   :align: center
   :widths: auto
   :header-rows: 1

.. _rajaperf_results_h100_throughput-label:

NVIDIA H100 throughput plots (Tier 1)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This section contains throughput plots for each Tier 1 kernel run
on the H100 architecture. The plots contain information similar to
what is described in :ref:`rajaperf_results_mi300_throughput-label`.

+-----------------------------------------------------------------------------------------------------+
| Tier 1 Kernels H100 Node Throughput                                                                 |
+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_H100_tier1/figures/Apps_DIFFUSION3DPA_flops.png               |
|    :width: 100 %                                                                                    |
|    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_H100_tier1/figures/Apps_EDGE3D_flops.png                      |
|    :width: 100 %                                                                                    |
|    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_H100_tier1/figures/Apps_ENERGY_flops.png                      |
|    :width: 100 %                                                                                    |
|    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_H100_tier1/figures/Apps_FEMSWEEP_flops.png                    |
|    :width: 100 %                                                                                    |
|    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_H100_tier1/figures/Apps_INTSC_HEXRECT_flops.png               |
|    :width: 100 %                                                                                    |
|    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_H100_tier1/figures/Apps_MASS3DEA_flops.png                    |
|    :width: 100 %                                                                                    |
|    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_H100_tier1/figures/Apps_MASS3DPA_ATOMIC_flops.png             |
|    :width: 100 %                                                                                    |
|    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_H100_tier1/figures/Apps_MASSVEC3DPA_flops.png                 |
|    :width: 100 %                                                                                    |
|    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_H100_tier1/figures/Apps_NODAL_ACCUMULATION_3D_flops.png       |
|    :width: 100 %                                                                                    |
|    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+
|                                                                                                     |
| .. figure:: baseline_data/RPBenchmark_H100_tier1/figures/Apps_VOL3D_flops.png                       |
|    :width: 100 %                                                                                    |
|    :align: center                                                                                   |
+-----------------------------------------------------------------------------------------------------+


.. _rajaperf_memory-label:

Memory Usage
============

For the RAJA Performance Suite Benchmark, we run each kernel over a sequence
of problem sizes to generate a throughput curve and, based on that, estimate
a saturation point. The memory usage for each entry in the sequence is 
roughly the same for each kernel. However, there is no significant meaning to
take away from this since the memory usage of kernels like those in the Suite
will be determined by the application context in which they are used.


References
==========

The GitHub repositories are the primary references for RAJA and the RAJA 
Performance Suite:

  * `RAJA Performance Suite GitHub project <https://github.com/LLNL/RAJAPerf>`_

  * `RAJA GitHub project <https://github.com/LLNL/RAJAPerf>`_

Other helpful references include:

  * Olga Pearce, Jason Burmark, Rich Hornung, Befikir Bogale, Ian Lumsden, Michael McKinsey, Dewi Yokelson, David Boehme, Stephanie Brink, Michela Taufer, Tom Scogland, "RAJA Performance Suite: Performance Portability Analysis with Caliper and Thicket", in 2024 IEEE/ACM International Workshop on Performance, Portability and Productivity in HPC (P3HPC) at the International Conference on High Performance Computing, Network, Storage, and Analysis (SC-W 2024). https://dl.acm.org/doi/pdf/10.1109/SCW63240.2024.00162

  * D. A. Beckingsale, J. Burmark, R. Hornung, H. Jones, W. Killian, A. J. Kunen, O. Pearce, P. Robinson, B. S. Ryujin, T. R. W. Scogland, "RAJA: Portable Performance for Large-Scale Scientific Applications", 2019 IEEE/ACM International Workshop on Performance, Portability and Productivity in HPC (P3HPC). https://conferences.computer.org/sc19w/2019/#!/toc/14

  * Arturo Vargas, Thomas M. Stitt, Kenneth Weiss, Vladimir Z. Tomov, Jean-Sylvain Camier, Tzanio Kolev, Robert N. Rieben, "Matrix-free Approaches for GPU Acceleration of a High-order Finite Element Hydrodynamic Application using MFEM, Umpire, and RAJA", International Journal of High Performance Computing Applications. 36(4):492-509 (2022). https://journals.sagepub.com/doi/10.1177/10943420221100262
