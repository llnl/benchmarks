**********************
RAJA Performance Suite
**********************

The RAJA Performance Suite contains a variety of numerical kernels that
represent important computational patterns found in HPC applications. It is a
companion project to RAJA, which is a library of software abstractions used by
developers of C++ applications to write portable, *single-source* code. Each
kernel in the Suite has multiple implementations using common parallel
programming models, such as OpenMP and CUDA, including RAJA and non-RAJA variants.
The RAJA Performance Suite enables a wide range of performance experiments and
comparisons for kernel variants, compilers, etc.

.. important:: The RAJA Performance Suite Benchmark is limited to a subset of
               kernels in the RAJA Performance Suite described in
               :ref:`rajaperf_problems-label`.

The `RAJAPerf-Benchmark GitHub repo <https://github.com/llnl/RAJAPerf-Benchmark>`_
contains the source code, performance baseline data files, run scripts,
and data processing scripts for the RAJA Performance Suite Benchmark. It includes
the RAJA Performance Suite repo as a submodule which, in turn, contains RAJA as a
submodule. When the benchmark project repo is cloned recursively, everything
necessary to build and run the benchmark is included. Detailed instructions are
included in :ref:`rajaperf_build-label` and :ref:`rajaperf_run-label`.

Additional information about the RAJA Performance Suite and RAJA is available
at these links:

  * `RAJA Performance Suite GitHub repo <https://github.com/LLNL/RAJAPerf>`_ 

  * `RAJA GitHub repo <https://github.com/LLNL/RAJAPerf>`_


Purpose
=======

The main purpose of the RAJA Performance Suite is to analyze performance of
loop-based computational kernels representative of those found in HPC
applications and to compare implementation variants. The kernels in
the Suite originate from various sources ranging from open-source HPC
benchmarks to restricted-access production applications. Kernels exercise
a variety of loop structures and important parallel operations such as
reductions, atomics, scans, and sorts.

Each kernel in the Suite appears in RAJA and non-RAJA variants that exercise
common programming models, such as OpenMP, CUDA, and HIP. Performance
comparisons between RAJA and non-RAJA variants are helpful to improve RAJA
implementations and to identify impacts that C++ abstractions have on compilers'
abilities to optimize. The Suite serves as an important collaboration tool
between the RAJA team and vendors to resolve performance issues observed in
production applications that use RAJA.


Characteristics
===============

`RAJAPerf-Benchmark GitHub repo <https://github.com/llnl/RAJAPerf-Benchmark>`_
contains everything needed to build and run the benchmark. This includes the
the RAJA Performance Suite and RAJA software dependencies in Git submodules and 
build, run, and data processing scripts for analyzing the run data. Thus, all
dependency versions are pinned to each version of the benchmark. Building
the RAJA Performance Suite code requires CMake to configuring a build, a C++17
(soon to require C++20) compliant compiler to build the code, and an MPI library
installation to link against.

The Suite can be run in a myriad of ways via command-line options and their
arguments. The intent is that after compiling the code, simple scripts can be 
written to execute necessary Suite runs to generate data for desired performance
experiments. Instructions for getting the code for the RAJA Performance Suite
Benchmark, building it, and running it are described in
:ref:`rajaperf_build-label` and :ref:`rajaperf_run-label`.


.. _rajaperf_problems-label:

Problems
--------

The RAJA Performance Suite Benchmark consists of a subset of kernels in the
full Suite that focus on some key computational patterns found in LLNL
applications. The benchmark kernels are partitioned into two priority levels as
described below, along with notable features and RAJA constructs used in each
kernel (in parentheses). 

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
   #. **FEMSWEEP** finite element implementation of linear sweep algorithm used in radiation transport, with a register-heavy LU solver *(nested loops, RAJA::launch API)*
   #. **INTSC_HEXRECT** intersection between a 24-sided hexahedron and a rectangular solid, including volume and moment calculations *(single loop, RAJA::forall API)*
   #. **MASS3DEA** element assembly of a 3D finite element mass matrix *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **MASS3DPA_ATOMIC** action of a 3D finite element mass matrix on elements with shared DOFs via partial assembly and sum factorization *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **MASSVEC3DPA** element-wise action of a 3D finite element mass matrix via partial assembly and sum factorization on a block vector *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **NODAL_ACCUMULATION_3D** on a 3D structured hexahedral mesh, sum a contribution from each hex vertex (nodal value) to its centroid (zonal value) *(single loop, data access via indirection array, 8-way atomic contention, RAJA::forall API)*
   #. **VOL3D** on a 3D structured hexahedral mesh (faces are not necessarily planes), compute volume of each zone (hex) *(single loop, data access via indirection array, RAJA::forall API)*


Priority 2 kernels
^^^^^^^^^^^^^^^^^^^

*Priority 2* kernels are also important, but less so than the *Priority 1*
kernels listed above. *Priority 2* kernels are listed below and are located in
the ``RAJAPerf/src`` sub-directories noted:

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
zero derivative, and beyond which running larger problem sizes does not yield
an increase in compute rate. The FOM for each kernel includes 3 numerical
values:

  * the saturation problem size (GB)
  * the compute rate (GFLOP/s) at the saturation problem size 
  * the memory bandwidth (GB/s) at the saturation problem size

.. important:: In the results presented in :ref:`rajaperf_results-label`,
               problem size is computed individually for each kernel based on
               a requested memory allocation size. The concept of size is
               subjective and depends on what one is looking for. We discuss
               how we determine problem sizes for the kernels in the RAJA
               Performance Suite in `<https://rajaperf.readthedocs.io/en/develop/sphinx/user_guide/output.html#notes-about-problem-size>`_

When the Suite is run, problem size, compute rate, and memory bandwidth, among
other data are reported in output files. We provide a Python script that can
traverse the contents of an output directory and generate condensed summary
files, throughput plots, and a FOM information. Usage of the script is 
detailed below.

One can visualize computational throughput using a plot where compute rate,
such as GFLOP/s, plotted on the vertical axis, is plotted as a function of
problem size on the horizontal axis. Ideally, such a curve will be monotonically
increasing and transition to a flat, horizontal line. Then, the saturation point
is the problem size at which the derivative of the throughput curve becomes zero.
In reality, throughput curves are often non-monotonic or do not have a 
strictly zero derivative for all points beyond some problem size. Therefore, we
apply a simple median based smoothing algorithm to the throughput curve data
and heuristically estimate the saturation point based on the smoothed
throughput curve. The details of our approach are documented in the
``process_data.py`` script in the
`RAJAPerf-Benchmark GitHub repo <https://github.com/llnl/RAJAPerf-Benchmark>`_,
which we use in :ref:`rajaperf_results-label`

Lastly, we emphasize that we want the kernels to be run in an execution
environment that aligns with how they would run if part of a real application.
Thus, the Suite should be run **using multiple MPI ranks** so that all
resources on a compute node are being exercised in a way that is
representative of how an application would run.

All applications that use RAJA use it in the *MPI + X* parallel application
paradigm, where MPI is used for coarse-grained, distributed memory parallelism
and X (RAJA in this case) supports fine-grained parallelism within each MPI
rank. The RAJA Performance Suite can be configured with MPI so that execution
of kernels in the Suite follows the *MPI + X* application paradigm. When a
kernel is run using multiple MPI ranks, the same code executes simultaneously
on each, and synchronization and communication among ranks involves only the
sending execution timing information from each rank to rank zero for reporting
purposes.

.. important:: For RAJA Performance Suite benchmark execution,
               **MPI must be used** to run to ensure that all resources on a
               compute node are being exercised so as to avoid misrepresentation
               of kernel and node performance. This is described in
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
benchmark are contained in the
`RAJAPerf-Benchmark GitHub repo <https://github.com/llnl/RAJAPerf-Benchmark>`_
repository as Git submodules. The ``v2026.04.1`` version of the repo is the
current version and was used to generate the baseline data described in
:ref:`rajaperf_results-label`.

The following command can be used to clone the GitHub repo::

  $ git clone --recursive git@github.com:llnl/RAJAPerf-Benchmark.git

This will clone the repo into your local directory and put you on the ``main``
branch of the benchmark repo, which is the default branch. To get a local copy
of the version used to generate the baselines, execute the following commands::

  $ git checkout v2026.04.1
  $ git submodule update --init --recursive

This will assure that you have the proper versions of the RAJAPerf and RAJA
submodules in your repo clone.


Configuration and compilation
------------------------------

The RAJA Performance Suite uses a CMake-based system to configure the code for
compilation. When building the RAJA Performance Suite, RAJA and the RAJA
Performance Suite are built together with the same CMake configuration which
is specified at the RAJA Performance Suite level. 
The generic process for specifying a configuration and generating a build space
is to create a build directory and run CMake in it with the proper options.
For example::

  $ pwd
  path/to/RAJAPerf
  $ mkdir my-build
  $ cd my-build
  $ cmake <cmake args> ..
  $ make -j (or make -j <N> to build with a specified number of cores)

For convenience and informational purposes, we maintain configuration scripts
in ``RAJAPerf/scripts`` subdirectories for various builds. For example, the
``RAJAPerf/scripts/lc-builds`` directory contains scripts that we use to
generate build configurations for machines in the Livermore Computing (LC)
Center at Lawrence Livermore National Laboratory for basic development.
These scripts are run in the top-level RAJAPerf directory. Each script creates
a descriptively-named build space directory and runs CMake to generate a build
space appropriate for the
platform and compiler(s) indicated by the script name and arguments passed to
it. Executing a script with no arguments will print a message indicating
which arguments are required.

.. _rajaperf_build_mi300a-label:

MI300A architecture
--------------------

To configure and build the code to generate baseline data on a system with 
AMD MI300A processors (i.e., ATS-4 (El Capitan) architecture) discussed in
:ref:`rajaperf_results-label`, we ran the following commands::

  $ pwd
  path/to/RAJAPerf
  $ ./scripts/lc-builds/toss4_cray-mpich_amdclang.sh 9.0.1 6.4.3 gfx942
  $ cd build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ make -j

Specifically, we configured and compiled the code for execution using version
9.0.1 of the Cray MPICH MPI library and the AMD clang compiler with ROCm
version 6.4.3 targeting GPU compute architecture gfx942.

.. _rajaperf_build_h100-label:

H100 architecture
--------------------

To configure and build the code to generate baseline data on a system with
NVIDIA H100 processors discussed in :ref:`rajaperf_results-label`, we ran the
following commands::

  $ pwd
  path/to/RAJAPerf
  $ ./scripts/lc-builds/toss4_mvapich2_nvcc_gcc.sh 2.3.7 12.9.1 90 10.3.1
  $ cd build_lc_toss4-mvapich2-2.3.7-nvcc-12.9.1-90-gcc-10.3.1
  $ make -j

Specifically, we configured and compiled the code for execution using version
2.3.7 of the MVAPICH2 MPI library, version 12.9.1 of the nvcc compiler for CUDA
targeting GPU compute architecture sm_90, and version 10.3.1 of the GNU compiler
for compiling host code.


.. _rajaperf_run-label:

Running
=======

After the RAJA Performance Suite code is built, the executable will be located
in the ``bin`` subdirectory of the build space.

To get information about how to run the code, use the *help option*::

  $ pwd
  path/to/RAJAPerf
  $ cd my-build
  $ ls bin
  rajaperf.exe
  $ ./bin/rajaperf.exe --help (or -h)

This will print all available command-line options along with potential
arguments and defaults. Available options allow one to print information about
the kernels in the Suite, to select output directory and file details, to
select kernels and variants to run, to define how kernels are run (problem
sizes, # times each kernel is run to collect min/max/avg timing data, data
spaces to use for array allocation, etc.). All arguments are optional. If no
arguments are specified, the suite will run all kernels in their default 
configurations for the variants that are available based on the way the code
was compiled.

In :ref:`rajaperf_results-label`, we provide the exact commands we used to
run the code and generate the baseline results for the benchmark.

.. _rajaperf_validation-label:

Validation
==========

Each kernel variant run generates a checksum value based on the result of its
execution, such as an output data array computed by the kernel. The checksum
depends on the problem size run for the kernel; thus, each checksum is 
computed at run time. Validation criteria are defined in terms of the checksum
difference between each kernel variant and problem size run and a corresponding
reference variant. The reference variant is the baseline sequential (CPU)
variant for each kernel. The run scripts, described below, execute the baseline
sequential variant in addition to the benchmark variants to validate the answers
of the benchmark variants.

Each kernel is annotated in the source code as to whether the checksum for
each variant is expected to match the reference checksum exactly, or to be
within some tolerance due to order of operation or other differences when run in
parallel. Whether the checksum for a kernel is within its expected tolerance
is reported as checksum ``PASSED`` or ``FAILED`` in the checksum output files.


.. _rajaperf_results-label:

Example Benchmark Results
===========================

As stated earlier, we are mainly interested in single-node computational
throughput with this benchmark. To generate throughput curves and estimate
saturation points, we use a bash shell script to run the code on each
platform and a Python script to process the data to construct throughput
plots, estimate saturation points, and make CSV files for tables of results.
These scripts are also available in the
`RAJAPerf-Benchmark GitHub repo <https://github.com/llnl/RAJAPerf-Benchmark>`_.
The scripts and results discussed here are located in the ``scripts/2026-FCR``
directory there.

.. important:: In the following sections, we present detailed results,
               including FOM tables and throughput plots for the Priority 1
               kernels described above. For completeness, we also include a
               brief summary of results for Priority 2 kernels in less detail.
               Data files containing results for all kernels run are included
               in this repository.

AMD MI300A throughput results (Priority 1 kernels)
----------------------------------------------------

For the MI300A architecture, we present two sets of throughput results. One is
run in ``SPX mode``, meaning that we run with 4 MPI ranks on a node -- one for
each MI300A APU -- and treat each APU as a single GPU. The other is run in 
``CPX mode``, where we run with 24 MPI ranks on a node -- six for each MI300A
APU -- and treat each APU as 6 GPUs (one GPU = 1 XCD). In each case, we run
each kernel over a sequence of problem sizes such that the saturation point is
evident on its associated throughput curve.

SPX mode (Priority 1)
^^^^^^^^^^^^^^^^^^^^^^

For SPX mode (run with 1 MPI rank per APU on a node), we choose the smallest
problem to use ~100,000 bytes of allocated memory and the largest problem
to use ~400MB of allocated memory, which is about 1.5 times the MALL 
(Memory Attached Last-Level cache) size on the MI300A. The MALL is 256 MB
(256 * 1024 * 1024 = 268435456 bytes). 

Note that for two of the kernels ``FEMSWEEP`` and ``MASS3DEA``, we ran a
different problem size range because these kernels don't clearly saturate.
For them, we chose the smallest problem to use ~3.2MB of allocated
memory and the largest problem to use ~600MB memory, which is over twice as
large as the MALL.

After building the code as described in :ref:`rajaperf_build_mi300a-label`, we
run the ``Priority 1`` kernels in **SPX mode** as follows::

  $ pwd
  path/to/RAJAPerf
  $ cd build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ ./run_tier_mi300a.sh spx tier1

This generates a directory named ``RPBenchmark_MI300A_tier1-SPX``, which
contains the results files for each kernel run over its range of problem sizes.

Then, we process the data for reporting the results in a concise form
by running a Python script we provide::

  $ pwd
  path/to/RAJAPerf
  $ python3 path/to/process_data.py --root-dir path/to/build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942/RPBenchmark_MI300A_tier1-SPX --output-dir path/to/build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942/RPBenchmark_MI300A_tier1-SPX/Output

This generates throughput curve files for ``Base_HIP`` and ``RAJA_HIP``
variants of each kernel and summarizes the FOM (described in
:ref:`rajaperf_fom-label`) in a CSV file. These files will be located in the
directory specified by via the ``--output-dir`` option above. We include
the files generated by the ``process_data.py`` script ` here <https://github.com/llnl/benchmarks/tree/develop/docs/13_rajaperf/baseline_data/RPBenchmark_MI300A_tier1-SPX`_.

.. csv-table:: FOM results for Priority 1 kernels run on MI300A in SPX mode
   :file: ./baseline_data/RPBenchmark_MI300A_tier1-SPX/FOM/combined_fom.csv
   :align: center
   :widths: auto
   :header-rows: 1

SPX mode (Priority 2)
^^^^^^^^^^^^^^^^^^^^^^

The process for generating results for the Priority 2 kernels is essentially
the same as for the Priority 1 kernels just described. Note that two of the
kernels ``INDEXLIST_3LOOP`` and ``HALO_PACKING_FUSED`` do not perform any 
floating point operations. They represent recurring computational patterns
in our application that are important rather than key numerical kernels.
Thus, the two kernels have zero GFLOP/s rates. So, we consider the bandwidth
as the appropriate metric to consider.

.. csv-table:: FOM results for Priority 2 kernels run on MI300A in SPX mode
   :file: ./baseline_data/RPBenchmark_MI300A_tier2-SPX/FOM/combined_fom.csv
   :align: center
   :widths: auto
   :header-rows: 1

CPX mode (Priority 1) 
^^^^^^^^^^^^^^^^^^^^^^

For CPX mode (run with 6 MPI ranks per APU on a node), we choose the
smallest problem to use ~50,000 bytes of allocated memory and the largest
problem to use ~75MB of allocated memory, which is slightly less than 1/3
the MALL size.

Note that for two of the kernels ``FEMSWEEP`` and ``MASS3DEA``, we ran a 
different problem size range because these kernels don't clearly saturate.
For them, we chose the smallest problem to use ~1.6MB of allocated
memory and the largest problem to use ~200MB memory, which is a little less
than the MALL size.

Similar to the SPX mode description above, we run the ``Priority 1`` kernels in
**CPX mode** as follows::

  $ pwd
  path/to/RAJAPerf
  $ cd build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ ./run_tier_mi300a.sh cpx tier1

This generates a directory named ``RPBenchmark_MI300A_tier1-CPX``, which
contains all the results files for each kernel run over its range of problem
sizes.

Then, we process the data for reporting the results here in a concise
form by running a Python script we provide::

  $ pwd
  path/to/RAJAPerf
  $ python3 path/to/process_data.py --root-dir path/to/build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942/RPBenchmark_MI300A_tier1-CPX --output-dir path/to/build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942/RPBenchmark_MI300A_tier1-CPX/Output

This generates throughput curve files for ``Base_HIP`` and ``RAJA_HIP``
variants of each kernel and summarizes the FOM (described in
:ref:`rajaperf_fom-label`) in a CSV file. These files will be located in the
directory specified by via the ``--output-dir`` option above. We include
the files generated by the ``process_data.py`` script ` here <https://github.com/llnl/benchmarks/tree/develop/docs/13_rajaperf/baseline_data/RPBenchmark_MI300A_tier1-CPX`_.

.. csv-table:: FOM results for Priority 1 kernels run on MI300A in CPX mode
   :file: ./baseline_data/RPBenchmark_MI300A_tier1-CPX/FOM/combined_fom.csv
   :align: center
   :widths: auto
   :header-rows: 1

CPX mode (Priority 2)
^^^^^^^^^^^^^^^^^^^^^^

The process for generating results for the Priority 2 kernels is essentially
the same as for the Priority 1 kernels just described. Note that two of the
kernels ``INDEXLIST_3LOOP`` and ``HALO_PACKING_FUSED`` do not perform any
floating point operations. They represent recurring computational patterns
in our application that are important rather than key numerical kernels.
Thus, the two kernels have zero GFLOP/s rates. So, we consider the bandwidth
as the appropriate metric to consider.

.. csv-table:: FOM results for Priority 2 kernels run on MI300A in CPX mode
   :file: ./baseline_data/RPBenchmark_MI300A_tier2-CPX/FOM/combined_fom.csv
   :align: center
   :widths: auto
   :header-rows: 1

AMD MI300A throughput plots (Priority 1)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following table contains throughput plots for each kernel run as described
above on the MI300A architecture in SPX mode and CPX mode. Each plot has multiple
curves with GFLOP/sec (compute rate) plotted as a function of problem size
(allocated bytes). The left column shows SPX mode. The right column shows CPX
mode. The legend in each plot indicates the curves shown. Each plot includes:

  * Throughput curves for Base and RAJA variant(s) of the kernel (solid line
    segments connecting the dots, where the dots are actual GFLOP rates
    determined from the kernel being run at a given problem size).
  * Smoothed versions of the throughput curves (dashed lines), which are 
    constructed from the dots. 
  * Stars that indicate approximate saturation points based on the smoothed
    curves and computed using simple heuristics. The legend contains the (x, y)
    values for the saturation points.

Most plots contain two variants, with the Base variant in blue and RAJA
variant in orange. In these cases, the throughput and saturation are close,
which indicates that the RAJA variants perform as well as the Base variants
that are written directly in HIP with no RAJA abstractions. Two kernels
(MASS3DEA, MASSVEC3DPA) contain additional curves that show more variants.
These additional curves are included to show how kernel execution choices,
RAJA execution policies specifically, can have a significant impact on
performance.

+-----------------------------------------------------------------------------------------------------+-----------------------------------------------------------------------------------------------------+
| Priority 1 Kernels: MI300A Node Throughput (SPX Mode)                                               | Priority 1 Kernels: MI300A Node Throughput (CPX Mode)                                               |
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


NVIDIA H100 throughput results (Priority 1 kernels)
----------------------------------------------------

For the H100 architecture, we present throughput results, where we run with
4 MPI ranks on a node -- one for each H100 GPU. We run each ``Priority 1``
kernel over a sequence of problem sizes such that the saturation point is
evident on its associated throughput curve.

We choose the smallest problem to use ~50,000 bytes of allocated memory and
the largest problem to use ~150MB of allocated memory, which is about 3 times
the L2-cache size on the H100 GPU.  The L2-cache is 50 MB
(50 * 1024 * 1024 = 52428800 bytes).

Note that for two of the kernels ``FEMSWEEP`` and ``MASS3DEA``, we ran a
different problem size range because these kernels don't clearly saturate.
For them, we chose the smallest problem to use ~1.6MB of allocated memory
and the largest problem to use ~300MB memory, which is about 6 times the 
L2 cache size.

After building the code as described in :ref:`rajaperf_build_h100-label`, we
run the ``Priority 1`` kernels as follows::

  $ pwd
  path/to/RAJAPerf
  $ cd build_lc_toss4-mvapich2-2.3.7-nvcc-12.9.1-90-gcc-10.3.1
  $ ./run_tier_h100.sh tier1

This generates a directory named ``RPBenchmark_H100_tier1``, which contains
the results files for each kernel run over its range of problem sizes.

Then, we process the data for reporting the results here in a concise form
by running a Python script we provide::

  $ pwd
  path/to/RAJAPerf
  $ python3 path/to/process_data.py --root-dir path/to/build_lc_toss4-mvapich2-2.3.7-nvcc-12.9.1-90-gcc-10.3.1/RPBenchmark_H100_tier1 --output-dir path/to/build_lc_toss4-mvapich2-2.3.7-nvcc-12.9.1-90-gcc-10.3.1/RPBenchmark_H100_tier1/Output

This generates throughput curve files for ``Base_HIP`` and ``RAJA_HIP``
variants of each kernel and summarizes the FOM (described in
:ref:`rajaperf_fom-label`) in a CSV file. These files will be located in the
directory specified by via the ``--output-dir`` option above. We include
the files generated by the ``process_data.py`` script ` here <https://github.com/llnl/benchmarks/tree/develop/docs/13_rajaperf/baseline_data/RPBenchmark_H100_tier1`_.

.. csv-table:: FOM results for Priority 1 kernels run on H100
   :file: ./baseline_data/RPBenchmark_H100_tier1/FOM/combined_fom.csv
   :align: center
   :widths: auto
   :header-rows: 1

H100 (Priority 2)
^^^^^^^^^^^^^^^^^^^^^^

The process for generating results for the Priority 2 kernels is essentially
the same as for the Priority 1 kernels just described. Note that two of the
kernels ``INDEXLIST_3LOOP`` and ``HALO_PACKING_FUSED`` do not perform any
floating point operations. They represent recurring computational patterns
in our application that are important rather than key numerical kernels.
Thus, the two kernels have zero GFLOP/s rates. So, we consider the bandwidth
as the appropriate metric to consider.

.. csv-table:: FOM results for Priority 2 kernels run on H100
   :file: ./baseline_data/RPBenchmark_H100_tier2/FOM/combined_fom.csv
   :align: center
   :widths: auto
   :header-rows: 1

NVIDIA H100 throughput plots (Priority 1)
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

Most plots contain two variants, with the Base variant in blue and RAJA
variant in orange. In these cases, the throughput and saturation are close,
which indicates that the RAJA variants perform as well as the Base variants
that are written directly in CUDA with no RAJA abstractions. Two kernels
(MASS3DEA, MASSVEC3DPA) contain additional curves that show more variants.
These additional curves were included to show how kernel execution choices,
RAJA execution policies specifically, can have a noticeable impact on performance.

+-----------------------------------------------------------------------------------------------------+
| Priority 1 Kernels H100 Node Throughput                                                             |
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
