***********
MPI: Phloem
***********


Purpose
=======

`Phloem <https://github.com/llnl/phloem>`` is a suite of MPI Microbenchmarks
designed to stress-test the HPC data communication fabric with common MPI
operations implemented in a manner as close as possible to the methods used by
modeling and simulation codes.

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
| ``mpiBench Reduce``    | Device, one rank is allocated on   | 8B, 4KiB, 2MiB,          |
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
`Phloem <https://github.com/llnl/phloem/tree/2f9c8ce38c14f6eb29b053efcb841c38ecb096cc/.gitlab/ci>`_`
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

    srun -N 1 -n 2 com -w Latency,Bidirectional -e 2097152
    srun -N 2 -n 2 -w host1,host2 com -w Latency,Bidirectional -e 2097152
    srun -N 2 -n 2 -w host1,host9001 com -w Latency,Bidirectional -e 2097152

Collectives:

.. code-block:: bash

	srun -N 384 -n 1536 mpiBench Barrier Bcast Allreduce Reduce -e 2097152
	srun -N 384 -n 32256 mpiBench Barrier Bcast Allreduce Reduce -e 2097152

Validation
==========

Benchmarks can be run with ``-C`` to ensure buffers are transferred correctly.
The GPU runtime should be in the banner. If it is not, the test is running on
host buffers.

Example Results
===============

.. code-block::

	srun -N2 -n2 com -w Latency,Bidirectional -e 2097152

	################################################################################

	#  com Point-to-Point MPI Bandwidth and Latency Benchmark
	#  Version 2.0.0
	#  Run at 10/31/26  00:17:04, with rank 0 on lynx632

	#  Process pair allocation              : block
	#  GB size for BW calculation           : 1073741824

	#  Bandwidth calculated as sum of process bandwidths.

	################################################################################


	#Bidirectional Test Results
	# (tasks, size, ops/sample, samples) : min/mean/max
	--------------------------------------------------------------------------------
	     2        2    10     3         0.002         0.003         0.003
	     2        4    10     3         0.004         0.005         0.006
	     2        8    10     3         0.010         0.011         0.013
	     2       16    10     3         0.025         0.025         0.025
	     2       32    10     3         0.037         0.039         0.042
	     2       64    10     3         0.070         0.079         0.086
	     2      128    10     3         0.146         0.162         0.173
	     2      256    10     3         0.243         0.281         0.306
	     2      512    10     3         0.523         0.569         0.605
	     2     1024    10     3         0.927         1.013         1.080
	     2     2048    10     3         1.519         1.708         1.856
	     2     4096    10     3         2.532         2.640         2.723
	     2     8192    10     3         4.014         4.287         4.686
	     2    16384    10     3         4.178         4.809         5.888
	     2    32768    10     3         0.407         1.565         3.876
	     2    65536    10     3         5.107         5.153         5.231
	     2   131072    10     3         7.788         7.841         7.880
	     2   262144    10     3         9.693         9.798         9.936
	     2   524288    10     3        11.073        11.229        11.453
	     2  1048576    10     3        12.347        12.543        12.672
	     2  2097152    10     3        12.968        13.084        13.184

	# Summary  :         min/mean/max =        0.002 /        3.659 /       13.184


	#Latency Test Results
	# (tasks, size, ops/sample, samples) : min/mean/max
	--------------------------------------------------------------------------------
	     2         0     10      3         1.127         1.140         1.146
	     2         2     10      3         1.134         1.147         1.169
	     2         4     10      3         1.121         1.135         1.143
	     2         8     10      3         1.135         1.157         1.179
	     2        16     10      3         1.127         1.133         1.140
	     2        32     10      3         1.307         1.324         1.339
	     2        64     10      3         1.313         1.320         1.334
	     2       128     10      3         1.319         1.345         1.358
	     2       256     10      3         1.348         1.371         1.394
	     2       512     10      3         1.505         1.517         1.531
	     2      1024     10      3         1.636         1.654         1.688
	     2      2048     10      3         1.871         1.885         1.892
	     2      4096     10      3         2.210         2.239         2.263
	     2      8192     10      3         2.991         3.015         3.032
	     2     16384     10      3         3.884         3.910         3.936
	     2     32768     10      3        12.645        12.849        13.163
	     2     65536     10      3        20.945        21.348        21.683
	     2    131072     10      3        25.320        25.611        25.987
	     2    262144     10      3        39.803        40.072        40.467
	     2    524288     10      3        67.510        67.818        68.317
	     2   1048576     10      3       124.650       125.093       125.905
	     2   2097152     10      3       238.260       239.789       241.661

	# Summary  :             min/mean/max =  1.121 / 25.358 / 241.661

	################################################################################

	srun -N 384 --ntasks-per-node=8 mpiBench Barrier Bcast Allreduce Reduce -e 2097152
	START mpiBench  v2.0.0
	Barrier                 Bytes:         0        Iters:     1000 Avg:     16.1137        Min:     16.0949        Max:     16.1255        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:         0        Iters:     1000 Avg:      0.0315        Min:      0.0272        Max:      0.0458        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:         1        Iters:     1000 Avg:      8.4881        Min:      0.5412        Max:     16.8365        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:         2        Iters:     1000 Avg:      8.4791        Min:      0.5371        Max:     16.8717        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:         4        Iters:     1000 Avg:      8.4236        Min:      0.5416        Max:     16.6922        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:         8        Iters:     1000 Avg:      8.4187        Min:      0.5114        Max:     16.7655        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:        16        Iters:     1000 Avg:      8.3649        Min:      0.5056        Max:     16.6033        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:        32        Iters:     1000 Avg:      9.2627        Min:      1.5166        Max:     17.0798        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:        64        Iters:     1000 Avg:      9.3010        Min:      1.5250        Max:     17.1377        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:       128        Iters:     1000 Avg:      9.5449        Min:      1.8351        Max:     17.3887        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:       256        Iters:     1000 Avg:      9.7471        Min:      2.0215        Max:     17.6855        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:       512        Iters:     1000 Avg:     10.2325        Min:      2.3160        Max:     18.2953        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:      1024        Iters:     1000 Avg:     11.2231        Min:      2.8950        Max:     19.6971        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:      2048        Iters:     1000 Avg:     13.3579        Min:      3.7554        Max:     22.9963        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:      4096        Iters:     1000 Avg:     16.4752        Min:      5.3903        Max:     27.4441        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:      8192        Iters:     1000 Avg:     23.4052        Min:     10.2820        Max:     36.6993        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:     16384        Iters:     1000 Avg:     61.6489        Min:      5.1364        Max:    120.6415        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:     32768        Iters:     1000 Avg:    149.1840        Min:      6.6812        Max:    255.5067        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:     65536        Iters:     1000 Avg:    260.9880        Min:     11.4437        Max:    468.1308        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:    131072        Iters:     1000 Avg:    476.8981        Min:     13.9109        Max:    890.0920        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:    262144        Iters:       80 Avg:    503.5647        Min:    264.8219        Max:    751.3589        Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:    524288        Iters:       55 Avg:    832.0146        Min:    457.5249        Max:    1272.0942       Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:   1048576        Iters:       31 Avg:    1556.7905       Min:    695.4855        Max:    2651.6152       Comm: MPI_COMM_WORLD    Ranks: 3072
	Bcast                   Bytes:   2097152        Iters:       16 Avg:    2989.2796       Min:    1138.1313       Max:    5085.3959       Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:         8        Iters:     1000 Avg:     17.3965        Min:     14.1009        Max:     20.8815        Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:        16        Iters:     1000 Avg:     17.3264        Min:     13.9194        Max:     20.8884        Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:        32        Iters:     1000 Avg:     18.0444        Min:     14.6799        Max:     21.6179        Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:        64        Iters:     1000 Avg:     18.0924        Min:     14.7681        Max:     21.5927        Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:       128        Iters:     1000 Avg:     18.4846        Min:     15.1175        Max:     22.0183        Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:       256        Iters:     1000 Avg:     19.0650        Min:     15.7244        Max:     22.4845        Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:       512        Iters:     1000 Avg:     20.2286        Min:     17.0380        Max:     23.7724        Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:      1024        Iters:     1000 Avg:     22.6654        Min:     18.9287        Max:     26.6148        Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:      2048        Iters:     1000 Avg:     27.3391        Min:     23.1980        Max:     31.3470        Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:      4096        Iters:     1000 Avg:     39.4816        Min:     33.1147        Max:     44.5760        Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:      8192        Iters:      847 Avg:     46.8793        Min:     40.0497        Max:     52.8131        Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:     16384        Iters:      744 Avg:     64.5935        Min:     56.9985        Max:     71.5055        Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:     32768        Iters:      429 Avg:    110.8342        Min:     98.1679        Max:    121.1366        Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:     65536        Iters:       96 Avg:    427.0376        Min:    406.9617        Max:    452.2851        Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:    131072        Iters:       50 Avg:    686.3671        Min:    655.2997        Max:    737.2216        Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:    262144        Iters:       31 Avg:    1186.7106       Min:    1111.3192       Max:    1287.2576       Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:    524288        Iters:       21 Avg:    2064.8700       Min:    1927.8941       Max:    2198.8365       Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:   1048576        Iters:       13 Avg:    3784.3272       Min:    3610.8210       Max:    4151.4543       Comm: MPI_COMM_WORLD    Ranks: 3072
	Allreduce               Bytes:   2097152        Iters:        8 Avg:    6060.3563       Min:    5566.8839       Max:    6761.4481       Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:         8        Iters:     1000 Avg:      1.2494        Min:      0.1888        Max:     24.9869        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:        16        Iters:     1000 Avg:      1.2480        Min:      0.1928        Max:     24.9919        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:        32        Iters:     1000 Avg:      1.2892        Min:      0.1860        Max:     25.4524        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:        64        Iters:     1000 Avg:      1.2921        Min:      0.1927        Max:     25.5711        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:       128        Iters:     1000 Avg:      1.3011        Min:      0.1855        Max:     25.8987        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:       256        Iters:     1000 Avg:      1.3345        Min:      0.1958        Max:     26.6906        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:       512        Iters:     1000 Avg:      1.4242        Min:      0.1944        Max:     27.9444        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:      1024        Iters:     1000 Avg:      1.6506        Min:      0.2050        Max:     30.7584        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:      2048        Iters:     1000 Avg:      2.1095        Min:      0.2232        Max:     36.3232        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:      4096        Iters:     1000 Avg:      3.2711        Min:      0.2891        Max:     35.5242        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:      8192        Iters:     1000 Avg:      4.9204        Min:      0.8808        Max:     46.3976        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:     16384        Iters:      750 Avg:     14.8854        Min:     10.1955        Max:     65.4748        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:     32768        Iters:      300 Avg:     37.0167        Min:     29.5448        Max:    161.5620        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:     65536        Iters:      210 Avg:     77.9697        Min:     68.7182        Max:    236.7491        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:    131072        Iters:      135 Avg:    159.6619        Min:    147.4229        Max:    370.6152        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:    262144        Iters:       78 Avg:    322.9039        Min:    305.3889        Max:    633.5928        Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:    524288        Iters:       41 Avg:    650.2750        Min:    619.9044        Max:    1192.5473       Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:   1048576        Iters:       21 Avg:    1306.9632       Min:    1250.1182       Max:    2343.9855       Comm: MPI_COMM_WORLD    Ranks: 3072
	Reduce                  Bytes:   2097152        Iters:       10 Avg:    2564.0579       Min:    2451.0372       Max:    4797.2759       Comm: MPI_COMM_WORLD    Ranks: 3072


References
==========
