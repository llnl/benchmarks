*********************
MPI: SMB Message Rate
*********************

Sandia Microbenchmarks Message Rate is a multi-node MPI point-to-point
benchmark designed to measure message-rate behavior under communication
patterns representative of production high-performance computing applications.

Repository: https://github.com/sandialabs/SMB

Purpose
=======

Sandia Microbenchmarks Message Rate is a realistic messaging benchmark intended
to emulate application communication behavior more closely than simple latency
or bandwidth tests. The benchmark stresses multi-peer, nonblocking
point-to-point MPI communication with many outstanding MPI requests. As a
result, it provides insight into message injection rate, request management,
message matching, MPI progress, and the cost of communicating with multiple
peers.

Several features distinguish this benchmark:

#. It uses a configurable peer count to emulate different communication
   patterns.
#. It uses configurable message counts and message sizes to evaluate behavior
   across a broad operating range.
#. It supports multiple communication patterns, including pre-posted receives,
   to evaluate performance under different MPI ordering scenarios.
#. It clears or overwrites cache-resident state between iterations to obtain
   more realistic performance numbers.
#. It supports host-memory and accelerator-resident communication paths,
   including CPU, CUDA, HIP, and Kokkos execution modalities.

Characteristics
===============

Benchmark Modalities
--------------------

The benchmark supports several execution modalities so that host-memory and
accelerator-resident communication can be compared using the same communication
patterns.

.. list-table::
   :header-rows: 1

   * - Modality
     - Buffer residency
     - Purpose
   * - CPU
     - Host memory
     - Baseline MPI message-rate measurement
   * - CUDA
     - NVIDIA GPU memory
     - GPU-aware MPI path using CUDA buffers
   * - HIP
     - AMD GPU memory
     - GPU-aware MPI path using HIP buffers
   * - Kokkos
     - Kokkos-managed memory space
     - Performance-portable application-style buffers

When CUDA, HIP, or an accelerator-backed Kokkos memory space is used, the MPI
implementation must support GPU-aware communication.

Problem
-------

SMB implements four communication patterns:

``single direction``
   The job is split into lower-rank and upper-rank halves. Lower ranks send to
   corresponding upper ranks. This measures directed one-way message injection.

``pair-based``
   Each rank communicates with one peer group at a time. For each peer, receives
   and sends are posted, then completed before moving to the next peer.

``pre-post``
   Receives are posted before the timed send phase. Each iteration performs a
   barrier, posts all sends, waits for completion, and posts receives for the
   next iteration. This reduces or avoids unexpected-message behavior.

``all-start``
   Each rank posts all receives and then immediately posts all sends without a
   global synchronization between those phases. This can exercise
   unexpected-message paths and stresses MPI request management and message
   matching.

For this evaluation, the primary focus is the ``pre-post`` communication
pattern.

Command-Line Parameters
-----------------------

The principal benchmark parameters are:

.. code-block:: text

   -p <num>     Number of peers used in communication
   -i <num>     Number of iterations per test
   -m <num>     Number of messages per peer per iteration
   -s <size>    Number of bytes per message
   -c <size>    Cache size in bytes
   -n <ppn>     Number of processes per node
   -o           Format output to be machine readable
   -v           Validate message contents

Peer Selection
--------------

SMB uses deterministic peer selection to generate repeatable communication
patterns. The process-per-node parameter, ``-n``, is used as a stride when
selecting peers. Under a typical rank layout, adding or subtracting this value
moves to the same node-local rank position on a neighboring node.

For the multi-peer tests, including ``pair-based``, ``pre-post``, and
``all-start``, peer offsets are selected in multiples of the process-per-node
value. For an even number of peers, offsets are symmetric around the current
rank and the zero offset is skipped. For example, with six peers, the symbolic
offsets are:

.. code-block:: text

   -3*PPN, -2*PPN, -1*PPN, +1*PPN, +2*PPN, +3*PPN

For an odd number of peers, the benchmark uses asymmetric send and receive
lists so that the reversed send ordering matches the receive ordering. Peer
selection wraps around the MPI rank space.

Figure of Merit
---------------

Because SMB is designed to represent a variety of application behaviors, there
is not a single universal figure of merit. For this test, the figure of merit is
the message rate of the ``pre-post`` communication pattern across message sizes
and peer counts.

Message rate should be evaluated as a function of:

* message size,
* number of peers,
* number of messages per peer,
* processes per node,
* node count,
* CPU or accelerator memory residency,
* MPI implementation and transport configuration.

Source Code Modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed
modifications.

Building
========

Accessing the Sources
---------------------

Clone the SMB submodule from the benchmarks repository checkout.

.. code-block:: bash

   cd <path/to/benchmarks>
   git submodule update --init --recursive
   cd SMB/src/msgrate/

Build Requirements
------------------

Required:

* C/C++ compiler with support for C11 and C++14
* MPI 3.0 or newer

Supported MPI examples include:

* `Open MPI 1.10+ <https://www.open-mpi.org/software/ompi/>`_
* `MPICH <http://www.mpich.org>`_

GPU-Aware Requirements
----------------------

For accelerator-resident communication, the system must provide:

* GPU-aware MPI support
* CUDA or HIP installation, depending on target platform
* Correct runtime, driver, and network transport configuration
* Appropriate rank-to-device placement

Build Commands
--------------

CPU build:

.. code-block:: bash

   cd <path/to/smb>
   make -j

CUDA build:

.. code-block:: bash

   cd <path/to/smb>
   make -j CUDA=1

HIP build:

.. code-block:: bash

   cd <path/to/smb>
   make -j HIP=1

Additional include paths, library paths, modules, or environment variables may
be required depending on the system configuration.

Kokkos build instructions depend on the Kokkos installation and target backend.
When using Kokkos with accelerator memory spaces, GPU-aware MPI is still
required.

Testing the Build
-----------------

A basic CPU smoke test can be run with:

.. code-block:: bash

   mpirun -n 8 msgrate -n 1

Expected output is similar to:

.. code-block:: text

   job size:   8
   npeers:     6
   niters:     4096
   nmsgs:      128
   nbytes:     8
   cache size: 8388608
   ppn:        1
   single direction: 2578047.02
   pair-based: 4343577.14
     pre-post: 1889840.49
    all-start: 2398236.06

For a single-node smoke test, the ``-n`` value may need to be set to ``1``.
This is acceptable for build validation, but it is not representative of
multi-node performance. The benchmark is designed to exercise network
communication.

Verification
============

SMB includes an optional verification mode enabled with ``-v``. Verification is
especially useful when testing GPU-aware MPI paths because successful MPI
completion alone does not guarantee that accelerator-resident communication was
configured correctly.

The benchmark initializes send buffers with a deterministic byte pattern based
on source rank, message index, and byte index. After communication completes,
the receive buffer is checked against the expected source data. If accelerator
buffers are used, the receive data is copied back to host before validation.

On success, the benchmark prints:

.. code-block:: text

   verification: PASSED

On failure, the benchmark reports the rank, receive slot, message index, byte
index, observed value, expected value, and expected source rank, then aborts the
MPI job.

Running
=======

This benchmark is used with two representative communication patterns:

* a 2D 9-point stencil-like pattern,
* a 3D 27-point stencil-like pattern.

Each case should be run across message sizes and scales to evaluate the
performance of the full system.

System-Specific Variables
-------------------------

Define the following variables for each system:

``PPN``
   Number of MPI processes per node.

``CACHE``
   Two times the size of the largest relevant cache. The factor of two is used
   to be conservative when clearing cache effects.

Memory Usage
------------

These tests can be memory intensive. Approximate memory usage grows as:

.. math::

   O(\text{message size} \times \text{number of messages}
   \times \text{number of peers} \times \text{processes per node})

If memory issues occur at larger message sizes, use the ``-m`` flag to reduce
the number of messages per peer per iteration.

9-Point Stencil Case
--------------------

The 9-point stencil case uses eight peers.

.. code-block:: bash

   for i in {0..24}; do
       mpirun msgrate -n ${PPN} -p 8 -c ${CACHE} -s $((2**i)) -o
   done

27-Point Stencil Case
---------------------

The 27-point stencil case uses 26 peers.

.. code-block:: bash

   for i in {0..24}; do
       mpirun msgrate -n ${PPN} -p 26 -c ${CACHE} -s $((2**i)) -o
   done

Example GPU-Aware Runs
----------------------

CUDA example:

.. code-block:: bash

   for i in {0..24}; do
       mpirun msgrate -n ${PPN} -p 8 -c ${CACHE} -s $((2**i)) -o -v
   done

HIP example:

.. code-block:: bash

   for i in {0..24}; do
       mpirun msgrate -n ${PPN} -p 8 -c ${CACHE} -s $((2**i)) -o -v
   done

The exact executable name and launch syntax may vary by build configuration,
scheduler, MPI implementation, and platform.

Results
=======

Results from SMB are provided on the following systems:

* Eldorado CPU

Validation
==========

Validation should include:

* successful build of the selected modality,
* successful smoke test,
* successful ``-v`` verification run where supported,
* confirmation that the requested process placement is honored,
* confirmation of GPU-aware MPI configuration for CUDA, HIP, or accelerator
  Kokkos runs,
* recording of MPI version, compiler version, runtime modules, and launch
  command.

For accelerator runs, production and procurement results should also record the
rank-to-device mapping and relevant MPI/runtime environment variables.

Example Scalability Results
===========================

The following figures show representative SMB message-rate results for the
`pre-post` communication pattern. The 9-point stencil case uses 8 peers, while
the 27-point stencil case uses 26 peers. Results should be interpreted as the
aggregate message rate for the selected process count, message size, peer count,
and process placement.

The 9-point and 27-point cases are intended to represent common structured-grid
communication patterns. The 9-point case exercises a moderate number of peer
connections, while the 27-point case increases the number of communicating
neighbors and places additional stress on MPI message matching, request
management, and network injection behavior.

When comparing results across systems or configurations, record the MPI
implementation, compiler, process count, processes per node, message count,
message size range, cache size, and any CPU or GPU affinity settings used for
the run.
Memory Usage
============

Memory usage should be monitored carefully for high peer counts, high message
counts, large message sizes, and large PPN values. If a run exceeds available
memory, reduce ``-m`` for the larger message-size cases while documenting the
change.

Strong Scaling on El Capitan
============================

To be added when El Capitan strong-scaling data is available.

Weak Scaling on El Capitan
==========================

To be added when El Capitan weak-scaling data is available.

References
==========

* Sandia Microbenchmarks repository: https://github.com/sandialabs/SMB
* Understanding the Sandia Message Rate Benchmark, Sandia report draft,
  Matthew G. F. Dosanjh.
