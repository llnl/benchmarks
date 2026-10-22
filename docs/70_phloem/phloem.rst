***********
MPI: Phloem
***********


Purpose
=======

Phloem is a suite of MPI Microbenchmarks designed to stress-test the HPC data
communication fabric with common MPI operations implemented in a manner as close
as possible to the methods used by modeling and simulation codes.

Characteristics
===============

Problems
--------

The key problems for this procurement are as follows:

MPI Benchmarks
==============

The ModSim MPI benchmarks target specific characteristics of the proposed
network interconnects. The evaluation team will use benchmark results to assess
measured performance relative to peak performance, overall system balance, and
potential communication bottlenecks. The MPI benchmarks reproduce communication
patterns representative of NNSA applications but make little or no attempt to
evaluate the numerical performance of those applications.

MPI Benchmark Execution Considerations
---------------------------------------

Worst-Case Latency
~~~~~~~~~~~~~~~~~~

Unless otherwise specified, reported latency shall be the worst-case maximum
latency, not the average after no more than 100 warm-up iterations.

Worst-Case Path
~~~~~~~~~~~~~~~

The worst-case path is the communication path expected to exhibit the highest
latency or lowest bandwidth. A path may be worst case because of physical
topology, hardware locality, routing, contention, or software-stack
implementation. The Offeror shall make a good-faith effort to identify and
report the worst-case path and its corresponding latency or throughput.

Buffer Allocation Strategies
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

MPI benchmarks shall reflect realistic memory-allocation and memory-use
practices.

Host allocation uses ``malloc``, or an equivalent mechanism, executed by a CPU
capable of running an operating-system kernel.

Device allocation uses a mechanism executed by a device that cannot, or is not
configured to, run the operating-system kernel. Examples include ``hipMalloc``
and ``cudaMalloc``.

If memory pooling is used, Host and Device memory pools shall remain separate
and shall not be mixed.

Use of a Memory Portability Layer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Phloem benchmarks use Umpire as a memory allocation portability layer. Any
optimizations related to MPI buffer allocation should be made via the Umpire
memory allocation portability layer, either by modifying calls to Umpire
functions, or proposing changes to the framework itself using a GitHub pull
request workflow. Pooling may be used exclusively via Umpire wherever Umpire is
used.

Environment Variables and Modifications Requiring User Intervention
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Users cannot reasonably be expected to stop an application, modify or tune its
execution environment, and restart it to obtain acceptable performance.
Therefore, no changes between tests, benchmarks, message sizes, allocation
strategies, or other benchmark conditions shall require user intervention.

Self-tuning MPI, LLCA, LLCA-provider, plugin, or driver implementations are
permitted, provided that they do not require user intervention.

Affinity
~~~~~~~~

Unless otherwise specified, each MPI rank shall be bound to a unique
accelerator or CPU core within a node. The Offeror should verify and document
rank affinity using a tool such as ``mpibind`` run in verbose mode or an
equivalent affinity checker.

Low-Noise Cores and System Reserved Cores
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

System-reserved cores are dedicated to operating-system and system-service
processes that could introduce network or execution noise. Low-noise cores are
then available for application workloads with minimal interference.

If the Offeror proposes a system noise strategy, it must apply that same
strategy consistently across all benchmarks and proxy applications.

Optimal Message Sizes
~~~~~~~~~~~~~~~~~~~~~

Where a benchmark specifies an "Optimal" message size, the Offeror may use
the minimum message size that delivers optimal bandwidth or protocol efficiency
for a given benchmark. The selected size can vary by benchmark or for various
paths, affinities, and allocation strategies. The Offeror will report the
message size used in each case.

Point-to-Point Benchmarks
-------------------------

NNSA application codes use a variety of communication patterns that depend on
low-latency point-to-point messaging performance. These benchmarks are intended
to test the latency and goodput that can be expected from the MPI
implementation.

Table 4-5: ATS-6 ModSim MPI Point-to-Point Benchmarks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+----------------------------+------------------------------------------+----------------------+--------------------------+
| Benchmark                  | Path                                     | Buffer Allocation    | Message Sizes            |
|                            |                                          | Strategy             |                          |
+============================+==========================================+======================+==========================+
| ``com latency``            | Intra-node worst-case path               | Device to Device,    | 8B, 4KiB, 2MiB,          |
|                            |                                          | Host to Host         | Optimal                  |
|                            | Inter-node worst-case path, same ToR     |                      |                          |
|                            | switch                                   |                      |                          |
|                            | Inter-node worst-case path               |                      |                          |
+----------------------------+------------------------------------------+----------------------+--------------------------+
| ``com bidirectional        | Intra-node worst-case path               | Device to Device,    | 8B, 4KiB, 2MiB,          |
| bandwidth``                |                                          | Host to Host         | Optimal                  |
|                            | Inter-node worst-case path, same ToR     |                      |                          |
|                            | switch                                   |                      |                          |
|                            | Inter-node worst-case path               |                      |                          |
+----------------------------+------------------------------------------+----------------------+--------------------------+

Multi-Point Messaging Rate and Global Bandwidth Benchmarks
-----------------------------------------------------------

NNSA application codes require the ability to conduct highly asynchronous
concurrent point-to-point operations without encountering network congestion.
These benchmarks are designed to stress-test network congestion and fan-in and
fan-out behavior in communicating nodes in an MPI implementation.

Table 4-6: ATS-6 ModSim MPI Multi-Point Messaging Rate and Global Bandwidth Benchmarks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+-----------------------------------+--------------------------------------+--------------------------+
| Benchmark                         | Rank Affinity and Buffer Allocation | Message Sizes            |
|                                   | Strategy                             |                          |
+===================================+======================================+==========================+
| ``com global bisection            | Worst-case performance over 100      | Optimal                  |
| bandwidth``                        | random rank allocations              |                          |
|                                   |                                      |                          |
|                                   | Device, one rank is allocated on    |                          |
|                                   | each device in the ModSim system    |                          |
|                                   |                                      |                          |
|                                   | Host, one rank is allocated on each |                          |
|                                   | CPU core in the ModSim system,      |                          |
|                                   | exclusive of pre-defined noise      |                          |
|                                   | cores                                |                          |
+-----------------------------------+--------------------------------------+--------------------------+

Collective Benchmarks
---------------------

Collective communication is extremely important to NNSA application codes.
These benchmarks are intended to test the worst-case latency of some of the
more common collective operations. All of the benchmarks below are to be run
both with and without Partitioned Communicators.

Table 4-7: ATS-6 ModSim MPI Collective Benchmarks
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+-----------------------+--------------------------------------+--------------------------+
| Benchmark             | Rank Affinity and Buffer Allocation | Message Sizes            |
|                       | Strategy                             |                          |
+=======================+======================================+==========================+
| ``mpiBench Barrier``  | Device, one rank is allocated on    | N/A                      |
|                       | each device in the ModSim system    |                          |
|                       |                                      |                          |
|                       | Host, one rank is allocated on each |                          |
|                       | CPU core in the ModSim system,      |                          |
|                       | exclusive of pre-defined noise      |                          |
|                       | cores                                |                          |
+-----------------------+--------------------------------------+--------------------------+
| ``mpiBench Allreduce``| Device, one rank is allocated on    | 8B, 4KiB, 2MiB,          |
|                       | each device in the ModSim system    | Optimal                  |
|                       |                                      |                          |
|                       | Host, one rank is allocated on each |                          |
|                       | CPU core in the ModSim system,      |                          |
|                       | exclusive of pre-defined noise      |                          |
|                       | cores                                |                          |
+-----------------------+--------------------------------------+--------------------------+
| ``mpiBench Broadcast``| Device, one rank is allocated on   | 8B, 4KiB, 2MiB,          |
|                        | each device in the ModSim system   | Optimal                  |
|                        |                                      |                          |
|                        | Host, one rank is allocated on each |                          |
|                        | CPU core in the ModSim system,      |                          |
|                        | exclusive of pre-defined noise      |                          |
|                        | cores                                |                          |
+------------------------+--------------------------------------+--------------------------+

Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications.

Building
========

Host Version:

With Spack:

.. code-block:: bash

	spack info phloem # to review variants
	spack install phloem

Without Spack:

.. code-block:: bash

	git clone --recurse-submodules https://github.com/llnl/phloem.git
	cd phloem
	cmake -S . -B build \
	    -DENABLE_MPI=ON \
	    -DMPI_C_COMPILER="$(which mpicc)" \
	    -DMPI_CXX_COMPILER="$(which mpicxx)" \
	    -DCMAKE_INSTALL_PREFIX=${HOME}/opt/phloem/
	cmake --build build -j
	cmake --install build


Example of a GPU version:

With Spack on a non-Cray system:

.. code-block:: bash

	spack install phloem+cuda

or

.. code-block:: bash

	spack install phloem+rocm

Without Spack on a non-Cray system:

Edit a BLT host-config.cmake cache file (see the
`Phloem <https://github.com/nhanford/phloem/tree/2f9c8ce38c14f6eb29b053efcb841c38ecb096cc/.gitlab/ci>`_`
repository for examples).

.. code-block:: bash

	git clone --recurse-submodules https://github.com/llnl/phloem.git
	cd phloem
	cmake -S . -B build -C host-config.cmake \
	    -DENABLE_CUDA=ON \
	    -DCMAKE_INSTALL_PREFIX=${HOME}/opt/phloem/
	cmake --build build -j
	cmake --install build

or

.. code-block:: bash

	git clone --recurse-submodules https://github.com/llnl/phloem.git
	cd phloem
	cmake -S . -B build -C host-config.cmake \
	    -DENABLE_HIP=ON \
	    -DCMAKE_INSTALL_PREFIX=${HOME}/opt/phloem/
	cmake --build build -j
	cmake --install build

Considerations for running on Cray systems with GPUs:

The GPU-Aware (Device) benchmarks must have the ``-lmpi_gtl_hsa`` compile flag and
the ``MPICH_GPU_SUPPORT_ENABLED=1`` runtime flag set in order to properly use
GPU-Aware Cray MPICH. The Phloem benchmark GitHub repository contains a Spack
package that will wrap calls to mpicc, adding the build flag appropriately, and
setup the run variable appropriately as well. The BLT host config CMake cache
files linked above also contains the appropriate flags.

Running
=======

Latency and Bidirectional Bandwidth:

Run these on both the Host (CPU) and Device (GPU) versions of the benchmarks.
Report full results including the test banner. If the GPU runtime is not in the
test banner, then the results are from running on Host buffers. In the following
example, host1 and host2 share the same ToR switch, while host1 and host9001 are
located across the worst-case path for the delivered system.

.. code-block:: bash

    srun -N 1 -n 2 com -w Latency -e 2097152
    srun -N 1 -n 2 com -w Bidirectional -e 2097152
    srun -N 2 -n 2 -w host1,host2 Latency -e 2097152
    srun -N 2 -n 2 -w host1,host2 Bidirectional -e 2097152
    srun -N 2 -n 2 -w host1,host9001 Latency -e 2097152
    srun -N 2 -n 2 -w host1,host9001 Bidirectional -e 2097152

Collectives:

.. code-block:: bash

	srun -N 384 -n 1536 mpiBench Barrier Bcast Allreduce -e 2097152
	srun -N 384 -n 32256 mpiBench Barrier Bcast Allreduce -e 2097152

Validation
==========

Benchmarks can be run with ``-C`` to ensure buffers are transferred correctly.

Example Results
===============

References
==========
