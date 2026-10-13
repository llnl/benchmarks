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
    RAJA Performance Suite. The subset is described in the :ref:`rajaperf_problems-label` section.

  * All code needed to generate the RAJA Performance Suite Benchmark results described in this
    document is included in the `RAJAPerf-Benchmark <https://github.com/llnl/RAJAPerf-Benchmark>`_
    GitHub repo. The discussion herein refers to the contents of that repo. Instructions
    for building the Benchmark code and running it to generate the figures of merit (FOMs) can be found
    in the :ref:`rajaperf_build-label` and :ref:`rajaperf_run-label` sections.

More information about RAJA and the RAJA Performance Suite is available in their documentation linked
to their respective GitHub repos: 

  * `RAJA Performance Suite GitHub repo <https://github.com/LLNL/RAJAPerf>`_ 

  * `RAJA GitHub repo <https://github.com/LLNL/RAJAPerf>`_


Purpose
=======

The purpose of the RAJA Performance Suite Benchmark is for vendors and other collaborators
to generate the FOMs, described in :ref:`rajaperf_fom-label`, for a subset of the RAJA
Performance Suite Benchmark kernel subset. The Benchmark kernels have been identified by
RAJA developers as representing important computations in production applications using RAJA
at Lawrence Livermore National Laboratory.


Characteristics
===============

The RAJA Performance Suite Benchmark is a single node performance benchmark.
All applications that use RAJA follow the *MPI + X* parallel application
paradigm. That is, MPI is used for coarse-grained, distributed memory parallelism
and X, which is RAJA in this case, supports fine-grained parallelism within each MPI
rank. Typically, we run the Benchmark with multiple MPI ranks. When this is done, the
same code executes on each rank and the only synchronization and communication among ranks
involves each rank sending execution timing information to rank zero for reporting
purposes. The included run scripts launch multiple MPI ranks, one for each GPU on a node
for each architecture so that the node is *fully subscribed* when the benchmark is run.

While the RAJA Performance Suite can be run in myriad ways via command-line options
and arguments, the RAJA Performance Suite Benchmark is run in a specific fashion to generate
the results reported below. The `RAJAPerf-Benchmark <https://github.com/llnl/RAJAPerf-Benchmark>`_
GitHub repo contains everything needed to build and run the RAJA Performance Suite Benchmark to
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


.. _rajaperf_problems-label:

Problems
--------

The RAJA Performance Suite Benchmark consists of a subset of RAJA Performance
Suite kernels that represent key computational patterns found in LLNL HPC
applications. The Benchmark kernels are partitioned into two *tier* levels
described below. A basic description of each kernel is provided along with RAJA
features it exercises summarized in parentheses.

.. note:: In the RAJA Performance Suite repository, each kernel is implemented in
          multiple files. Source files include ``<kernel-name>.cpp`` (common code
          independent of kernel variant) and ``<kernel-name>-<back-end>.cpp``
          (variants that exercise a programming model *back-end*). The header file
          ``<kernel-name>.hpp`` contains a reference implementation of the kernel,
          which is a C-style sequential version of the kernel. This simple non-parallel
          version is used to generate the reference checksum against which to compare
          parallel variants for correctness.

The RAJA Performance Suite Benchmark kernels in each tier level are described below.


Tier 1 kernels
^^^^^^^^^^^^^^^^^^^

*Tier 1* kernels are most important. They are located in the
``RAJAPerf/src/apps`` sub-directory:

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


Tier 2 kernels
^^^^^^^^^^^^^^^^^^^

*Tier 2* kernels are also important, but less so than the *Tier 1*
kernels listed above. *Tier 2* kernels are located in ``RAJAPerf/src`` sub-directories
noted below (i.e., ``RAJAPerf/src/<subdir>/<kernel>``):

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

Each kernel variant has a Figure of Merit (FOM) that is determined by the problem size at
which the kernel variant *saturates* resources on a *single* compute node. The saturation
point is the problem size at which a computational throughput curve becomes flat, with
zero derivative, and beyond which running a larger problem size yields no further
increase in compute rate. Specifically, the FOM consists of 3 numerical values:

  * the saturation problem size (GB)
  * the compute rate (GFLOP/sec) at the saturation problem size 
  * the memory bandwidth (GB/sec) at the saturation problem size

.. important:: The scripts and their invocations described in :ref:`rajaperf_run-label`
               show how we determine the FOM values. Others are free to generate the
               values by other means if they prefer.

Computational throughput may be visualized on a plot where compute rate
(vertical axis) is plotted as a function of problem size (horizontal axis).
Ideally, such a curve is monotonically increasing and transitions to a flat,
horizontal line. Then, the saturation point is the problem size at which the derivative
of the throughput curve becomes zero. In reality, a measured throughput curve may be
non-monotonic or not have a strictly zero derivative for all points beyond some problem
size. Therefore, we apply a simple median based smoothing algorithm to the throughput
curve data and use simple heuristics to estimate the saturation point based on the smoothed
throughput curve. The details of our approach are documented in the Python script
``process_data.py`` that lives in the `scripts` directory of the
`RAJAPerf-Benchmark <https://github.com/llnl/RAJAPerf-Benchmark>`_ GitHub repo
for the baseline set we are interested in. We describe the use of the script
in :ref:`rajaperf_results-label`.

.. note:: In the Benchmark, problem size is computed for each kernel based on the 
          memory allocated for the requested problem size to run. The notion of
          problem size is subjective and depends on what one is trying to measure.
          For our perspective on this topic, please see the
          `Problem Size section <https://rajaperf.readthedocs.io/en/develop/sphinx/user_guide/output.html#notes-about-problem-size>`_ of the RAJA Performance Suite User Guide.

When the Suite is run, problem size, compute rate, memory bandwidth, result checksums, etc.
are reported in various files in an output directory. We provide a Python script to traverse
the contents of an output directory and generate summary files, throughput plots,
and FOM information. Script usage is described in :ref:`rajaperf_run-label`.

.. important:: For RAJA Performance Suite Benchmark execution on any multicore architecture,,
               **MPI must be used** to run to ensure that all resources on a
               compute node are being exercised so as to avoid misrepresentation
               of kernel and node performance. The scripts provided to run the Benchmark
               illustrate how this is done on the architectures for which we have provided 
               baseline results. Specific commands used to invoke the scripts are shown in
               :ref:`rajaperf_run-label`.


.. _rajaperf_codemod-label:

Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed benchmark modifications.
For the RAJA Performance Suite Benchmark, we restrtict source code modifications as follows:

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
was used to generate the baseline data described in the :ref:`rajaperf_results-label` section.

To clone the repo::

  $ git clone --recursive git@github.com:llnl/RAJAPerf-Benchmark.git

This will clone the repo into a local directory and put you on the ``main``
branch of the benchmark repo, which is the default branch. To get a local copy
of the version used to generate the baselines in this document, execute the following
commands::

  $ cd path/to/RAJAPerf-Benchmark
  $ git checkout v2026.10.0
  $ git submodule update --init --recursive

This will assure that you have the proper version of the Benchmark code, including
the RAJAPerf and RAJA submodules, in your local directory.


Configuration and compilation
------------------------------

The RAJA Performance Suite uses a CMake-based system to configure the code for
compilation. When building the code, RAJA and the RAJA
Performance Suite are built together with the same configuration which
is specified at the RAJA Performance Suite level. Generically, the process for
specifying a configuration and generating a build space involves creating a build
directory and running CMake in it with the proper options. For example::

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
space directory and runs CMake to generate a build space appropriate for the
platform and compiler(s) indicated by the script name and arguments passed to
it. Executing a script with no arguments will print a message indicating
which arguments are required.

These scripts were used to configure the Benchmark code for compilation to generate the
benchmark baseline results described below.

.. _rajaperf_build_mi300a-label:

MI300A architecture
--------------------

To configure and build the code to generate baseline data on a system with 
AMD MI300A processors (the ATS-4 (El Capitan) architecture) discussed in
:ref:`rajaperf_results-label`, we ran the following commands::

  $ cd path/to/RAJAPerf
  $ ./scripts/lc-builds/toss4_cray-mpich_amdclang.sh 9.0.1 6.4.3 gfx942
  $ cd build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ make -j

That is, we configured and compiled the code using version
9.0.1 of the Cray MPICH MPI library and the AMD clang compiler with ROCm
version 6.4.3 targeting GPU compute architecture gfx942.

.. note:: While newer ROCm compilers are available, version 6.4.3 was used
          by all LLNL codes using RAJA for production builds when
          we generated the baseline results. Thus, we use that version
          of the compiler here.

.. _rajaperf_build_h100-label:

H100 architecture
--------------------

To configure and build the code to generate baseline data on a system with
NVIDIA H100 processors discussed in :ref:`rajaperf_results-label`, we ran the
following commands::

  $ cd path/to/RAJAPerf
  $ ./scripts/lc-builds/toss4_mvapich2_nvcc_gcc.sh 2.3.7 13.1.1 90 10.3.1
  $ cd build_lc_toss4-mvapich2-2.3.7-nvcc-13.1.1-90-gcc-10.3.1
  $ make -j

That is, we configured and compiled the code using version
2.3.7 of the MVAPICH2 MPI library, version 13.1.1 of the nvcc compiler for CUDA
targeting GPU compute architecture sm_90, and version 10.3.1 of the GNU compiler
for compiling host code.

.. note:: The compiler and MPI versions we used were the system defaults on the
          NVIDIA GPU based machine we had access to at LLNL when we generated the
          baseline results. 


.. _rajaperf_run-label:

Running
=======

When the RAJA Performance Suite code is built using the procedure above, the executable
will be generated in the ``bin`` subdirectory of the build space.

To see full details about all the code execution options, use the *help option*::

  $ cd path/to/RAJAPerf
  $ cd my-build
  $ ls bin
  raja-perf.exe
  $ ./bin/raja-perf.exe --help (or -h)

This will print all available command-line arguments along with options
and defaults. All arguments are optional. If none are specified, the suite will run all
Suite kernels in their default configurations for the variants that are available based
on the way the code was compiled.

.. important:: In :ref:`rajaperf_results-label`, we provide the exact commands we used to
               run the code and generate the baseline results for the Benchmark.

.. _rajaperf_validation-label:

Validation
==========

Each kernel variant that is run produces a checksum value based on kernel output,
such as a data array whose entries are computed by the kernel.
Since a checksum value generally depends on the kernel problem size, the checksum is 
computed at run time after kernel execution is complete. Results validation compares the
checksum of the kernel variant run and a reference variant of the same kernel.
For the Benchmark, the reference variant is the sequential (CPU) variant of each kernel.
Thus, the Benchmark run scripts execute the baseline sequential variant in addition
to the Benchmark variants we are interested in to validate kernel results.

Each kernel is annotated in the source code as to whether variant checksums
are expected to match the reference checksum exactly, or to be within some tolerance
due to order of operation or other differences when run in parallel. Whether the
checksum for a kernel is within its expected tolerance is reported as checksum
``PASSED`` or ``FAILED`` in the checksum output files.


.. _rajaperf_results-label:

Benchmark Results
===========================

As stated earlier, we are interested in single-node throughput
with this Benchmark. To generate throughput curves and estimate
saturation points, we use a bash shell script to run the code on each
platform and a Python script to process the data to construct throughput
plots, estimate saturation points, and make CSV files for tables of results.
These scripts are available in the
`RAJAPerf-Benchmark GitHub repo <https://github.com/llnl/RAJAPerf-Benchmark>`_
in the ``RAJAPerf-Benchmark/RPB-v2026.10.0/scripts`` directory.

.. important:: In the following sections, we present detailed results,
               including FOM tables and throughput plots for the Tier 1
               kernels described above. For completeness, we also include a
               brief summary of results for Tier 2 kernels in less detail.
               Data files containing results for all Benchmark kernels are included
               in this LLNL Benchmarks repository for reference.

AMD MI300A throughput results (Tier 1 kernels)
----------------------------------------------------

For the MI300A architecture, we present two sets of throughput results. One is
run in ``SPX mode`` where we use 4 MPI ranks on a node, one for each MI300A APU,
thus treating each APU as a single GPU. The other is run in ``CPX mode`` where
we run with 24 MPI ranks on a node, six for each MI300A APU, treating each APU as
6 GPUs (i.e., one GPU = 1 XCD). For each mode, we run each kernel over a sequence
of problem sizes so that the saturation point is evident on its associated throughput curve.

SPX mode (Tier 1)
^^^^^^^^^^^^^^^^^^^^^^

For SPX mode (1 MPI rank per APU on a node), we choose the smallest
problem to use ~100,000 bytes of allocated memory and the largest problem
to use ~400MB of allocated memory, which is about 1.5 times the MALL 
(Memory Attached Last-Level cache) size on the MI300A. The MALL is 256MB
(256 * 1024 * 1024 = 268,435,456 bytes).

Note that for two of the kernels, ``FEMSWEEP`` and ``MASS3DEA``, we ran a
different problem size range because these kernels don't clearly saturate.
For them, we chose the smallest problem to use ~3.2MB of allocated
memory and the largest problem to use ~600MB memory, which is over twice as
big as the MALL.

After building the code as described in :ref:`rajaperf_build_mi300a-label`, we
ran the ``Tier 1`` kernels in **SPX mode** as follows::

  $ cd path/to/RAJAPerf
  $ cd build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ cp ../../RPB-v2026.10.0/scripts/run_tier_mi300a.sh .
  $ ./run_tier_mi300a.sh spx tier1

This generates a directory named ``RPBenchmark_MI300A_tier1-SPX`` containing
output files for each kernel run over its range of problem sizes.

Then, we processed the data to generate more concise baseline results
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

SPX mode (Tier 2)
^^^^^^^^^^^^^^^^^^^^^^

The process for generating results for the Tier 2 kernels is essentially
the same as for the Tier 1 kernels just described. The only differences are
that the command to run the kernels passes the ``tier2`` argument (instead of
``tier1``)::

  $ ./run_tier_mi300a.sh spx tier2

and the results directories have ``tier1`` replaced by ``tier2`` in their names.

For the Tier2 case, note that the two kernels ``INDEXLIST_3LOOP`` and ``HALO_PACKING_FUSED``
do not perform any floating point operations; i.e., they have zero GFLOP/sec rates.
They represent recurring computational patterns in our applications that are important despite not
doing floating point operations. Thus, we consider bandwidth as the appropriate metric to consider.
We include the baseline data files for Tier 2 kernels run on the MI300A architecture in
SPX mode in this repo in the directory ``./docs/13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-SPX``.

.. csv-table:: FOM results for Tier 2 kernels run on MI300A in SPX mode
   :file: ./baseline_data/RPBenchmark_MI300A_tier2-SPX/FOM/combined_fom.csv
   :align: center
   :widths: auto
   :header-rows: 1

CPX mode (Tier 1) 
^^^^^^^^^^^^^^^^^^^^^^

For CPX mode (run with 6 MPI ranks per APU on a node), we choose the
smallest problem to use ~50,000 bytes of allocated memory and the largest
problem to use ~75MB of allocated memory, which is slightly less than 1/3
the MALL size.

Similar to SPX mode, we ran a different problem size range for the ``FEMSWEEP``
and ``MASS3DEA`` kernels because they don't clearly saturate. For those, we chose
the smallest problem to use ~1.6MB of allocated memory and the largest problem to
use ~200MB memory, which is a little less than the MALL size.

Similar to the SPX mode description above, we run the ``Tier 1`` kernels in
**CPX mode** as follows::

  $ cd path/to/RAJAPerf
  $ cd build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ $ cp ../../RPB-v2026.10.0/scripts/run_tier_mi300a.sh .
  $ ./run_tier_mi300a.sh cpx tier1

This generates a directory named ``RPBenchmark_MI300A_tier1-CPX``, which
contains all the results files for each kernel run over its range of problem
sizes.

Then, we process the data for reporting the results here in a concise
form by running a Python script we provide::

  $ cd path/to/RAJAPerf
  $ cp ../../RPB-v2026.10.0/scripts/process_data.py .
  $ python3 ./process_data.py --root-dir ./RPBenchmark_MI300A_tier1-CPX --output-dir ./RPBenchmark_MI300A_tier1-CPX/Output --exclude-plot-variant Base_Seq

This generates throughput curve files for ``Base_HIP`` and ``RAJA_HIP``
variants of each kernel and summarizes the FOM (described in
:ref:`rajaperf_fom-label`) in a CSV file. These files are included in this repo in the
directory ``./docs/13_rajaperf/baseline_data/RPBenchmark_MI300A_tier1-CPX``.

.. csv-table:: FOM results for Tier 1 kernels run on MI300A in CPX mode
   :file: ./baseline_data/RPBenchmark_MI300A_tier1-CPX/FOM/combined_fom.csv
   :align: center
   :widths: auto
   :header-rows: 1

CPX mode (Tier 2)
^^^^^^^^^^^^^^^^^^^^^^

Similar to SPX mode, the process for generating results for the Tier 2 kernels in
CPX mode is essentially the same as for the Tier 1 kernels just described. The only
differences are that the command to run the kernels passes the ``tier2`` argument (instead of
``tier1``)::

  $ ./run_tier_mi300a.sh cpx tier2

and the results directories have ``tier1`` replaced by ``tier2`` in their names.

As noted earlier, two of the kernels ``INDEXLIST_3LOOP`` and ``HALO_PACKING_FUSED`` do not
perform any floating point operations. So, we consider the bandwidth
as the appropriate metric to consider. We include the baseline data files for Tier 2
kernels run on the MI300A architecture in CPX mode in this repo in the
directory ``./docs/13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-CPX``.

.. csv-table:: FOM results for Tier 2 kernels run on MI300A in CPX mode
   :file: ./baseline_data/RPBenchmark_MI300A_tier2-CPX/FOM/combined_fom.csv
   :align: center
   :widths: auto
   :header-rows: 1

AMD MI300A throughput plots (Tier 1)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This section contains throughput plots for each Tier 1 kernel run as described
above on the MI300A architecture in SPX mode (left column) and CPX mode (right column).
Each plot has multiple curves with GFLOP/sec (compute rate) plotted as a function of problem size
(allocated bytes). The legend in each plot indicates the curves shown. Each plot includes:

  * Throughput curves for Base and RAJA variant(s) of the kernels. Solid line
    segments connect the dots, where the dots are actual GFLOP rates
    determined from the kernel being run at a given problem size.
  * Smoothed versions of the throughput curves (dashed lines), which are 
    constructed from the dots. 
  * Stars indicate approximate saturation points based on the smoothed
    curves and computed using simple heuristics. The legend contains the (x, y)
    values for the saturation points.

Most plots contain two variants, with the *Base* non-RAJA variant in blue and RAJA
variant in orange. In each case, the throughput curves and saturation points are close,
which indicates that the RAJA variants perform as well as the non-RAJA variants
that are written directly in HIP with no RAJA abstractions. Two kernels
(MASS3DEA, MASSVEC3DPA) contain additional curves that show more variants.
These additional curves are included to show how kernel execution choices,
RAJA execution policies in particular, can have a significant impact on
performance.

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

For the H100 architecture, we present one set of throughput results, where we ran with
4 MPI ranks on a node -- one for each H100 GPU. We ran each ``Tier 1``
kernel over a sequence of problem sizes such that the saturation point is
evident on its associated throughput curve.

We choose the smallest problem to use ~50,000 bytes of allocated memory and
the largest problem to use ~150MB of allocated memory, which is about 3 times
the L2 cache size on the H100 GPU.  The L2 cache is 50MB
(50 * 1024 * 1024 = 52428800 bytes).

Again, we ran a different problem size range for the ``FEMSWEEP`` and ``MASS3DEA``
kernels because they kernels don't clearly saturate. For them, we chose the smallest
problem to use ~1.6MB of allocated memory and the largest problem to use ~300MB memory,
which is about 6 times the L2 cache size.

After building the code as described in :ref:`rajaperf_build_h100-label`, we
run the ``Tier 1`` kernels as follows::

  $ cd path/to/RAJAPerf
  $ cd build_lc_toss4-mvapich2-2.3.7-nvcc-13.1.1-90-gcc-10.3.1
  $ cp ../../RPB-v2026.10.0/scripts/run_tier_h100.sh .
  $ ./run_tier_h100.sh tier1

This generates a directory named ``RPBenchmark_H100_tier1``, which contains
the results files for each kernel run over its range of problem sizes.

Then, we process the data for reporting the results here in a concise form
by running the Python script we provide::

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

H100 (Tier 2)
^^^^^^^^^^^^^^^^^^^^^^

The process for generating results for the Tier 2 kernels is essentially
the same as for the Tier 1 kernels just described. The only differences are that
the command to run the kernels passes the ``tier2`` argument (instead of ``tier1``):

$ ./run_tier_h100.sh tier2

and the results directories have ``tier1`` replaced by ``tier2`` in their names.

For the Tier2 case, the ``INDEXLIST_3LOOP`` and ``HALO_PACKING_FUSED`` kernels
do not perform any floating point operations, so they have zero GFLOP/sec rates.
Thus, we consider the bandwidth as the appropriate metric to consider for them.
We include the baseline data files for Tier 2 kernels run on the H100 architecture
in this repo in the directory ``./docs/13_rajaperf/baseline_data/RPBenchmark_H100_tier2-SPX``.

.. csv-table:: FOM results for Tier 2 kernels run on H100
   :file: ./baseline_data/RPBenchmark_H100_tier2/FOM/combined_fom.csv
   :align: center
   :widths: auto
   :header-rows: 1

NVIDIA H100 throughput plots (Tier 1)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following table contains throughput plots for each kernel run as described
above for the H100 architecture. Each plot has multiple curves where GFLOP/sec
(compute rate) is plotted as a function of problem size (allocated bytes). 
The legend in each plot indicates the curves shown. Each plot includes:

  * Throughput curves for Base and RAJA variant(s) of the kernel (solid line
    segments connecting the dots, where the dots are actual GFLOP rates
    determined from the kernel being run at a given problem size).
  * Smoothed versions of the throughput curves (dashed lines), which are
    constructed from the dots.
  * Stars that indicate approximate saturation points based on the smoothed
    curves and computed using simple heuristics. The legend contains the
    (x, y) values for the saturation points.

Most plots contain two variants, with the *Base* non-RAJA variant in blue and RAJA
variant in orange. In these cases, the throughput and saturation are close,
which indicates that the RAJA variants perform as well as the non-RAJA variants
that are written directly in CUDA with no RAJA abstractions. Two kernels
(MASS3DEA, MASSVEC3DPA) contain additional curves that show more variants.
These additional curves were included to show how kernel execution choices,
RAJA execution policies specifically, can have a noticeable impact on performance.

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

The GitHub repositories are the primary references for RAJA and the RAJA 
Performance Suite:

  * `RAJA Performance Suite GitHub project <https://github.com/LLNL/RAJAPerf>`_

  * `RAJA GitHub project <https://github.com/LLNL/RAJAPerf>`_

Other helpful references include:

  * Olga Pearce, Jason Burmark, Rich Hornung, Befikir Bogale, Ian Lumsden, Michael McKinsey, Dewi Yokelson, David Boehme, Stephanie Brink, Michela Taufer, Tom Scogland, "RAJA Performance Suite: Performance Portability Analysis with Caliper and Thicket", in 2024 IEEE/ACM International Workshop on Performance, Portability and Productivity in HPC (P3HPC) at the International Conference on High Performance Computing, Network, Storage, and Analysis (SC-W 2024). [Download here](https://dl.acm.org/doi/pdf/10.1109/SCW63240.2024.00162)

  * D. A. Beckingsale, J. Burmark, R. Hornung, H. Jones, W. Killian, A. J. Kunen, O. Pearce, P. Robinson, B. S. Ryujin, T. R. W. Scogland, "RAJA: Portable Performance for Large-Scale Scientific Applications", 2019 IEEE/ACM International Workshop on Performance, Portability and Productivity in HPC (P3HPC). [Download here](https://conferences.computer.org/sc19w/2019/#!/toc/14) 

  * Arturo Vargas, Thomas M. Stitt, Kenneth Weiss, Vladimir Z. Tomov, Jean-Sylvain Camier, Tzanio Kolev, Robert N. Rieben, "Matrix-free Approaches for GPU Acceleration of a High-order Finite Element Hydrodynamic Application using MFEM, Umpire, and RAJA", International Journal of High Performance Computing Applications. 36(4):492-509 (2022). [Download here](https://journals.sagepub.com/doi/10.1177/10943420221100262)
