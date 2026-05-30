***
IOR
***

Purpose
=======

IOR is used for testing MPI-based I/O performance of POSIX-based parallel file systems using various protocols and access patterns. Many attributes can be set to test different application I/O profiles, including I/O sizing and patterns such as file-per-process (FPP) and single-shared-file (SSF).

Characteristics
===============

IOR is available in the benchmarks repository.

* Github: `IOR Public <https://github.com/hpc/ior>`_

The github repo also contains mdtest.

Problem
-------

HPC applications can perform I/O to storage in numerous ways. Capturing the I/O performance of a full application run may be difficult, so synthetic benchmarks like IOR allow one to simulate an I/O workload similar to an application to provide a rough approximation of how that particular application's I/O workload will perform
IOR measures parallel I/O performance at the POSIX and MPI-IO levels using MPI across multiple CPUs and/or nodes. It writes and reads files, with a myriad of options and patterns, on a parallel file system such as Lustre.

Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications. 


Building
========

MPI, MPI-IO, and OpenMP are required in order to build and run the code. The
source code used for this benchmark is derived from IOR 3.0.1 and it is
included here. 

Ensure that the MPI compiler wrappers (e.g., `mpicc`) are in `$PATH`. Then create a build directory and an (optional) install directory.

.. code-block:: bash
    
    <BENCHMARK_PATH>/microbenchmarks/ior/configure --prefix=<INSTALL_DIR>
    make
    make install
..

This will build both IOR with the POSIX and MPI-IO interfaces and create the
IOR executable at `src/ior` in the specified install directory.

Test Patterns
=======

File-per-process (fpp)
-----
- Write: $IOR -a POSIX -C -e -E -F -g -k -vvv -t ${XFER_SIZE} -b ${BLK_SIZE} -o ${TESTDIR}/IOR_POSIX -w
- Read:  $IOR -a POSIX -C -e -E -F -g -k -vvv -t ${XFER_SIZE} -b ${BLK_SIZE} -o ${TESTDIR}/IOR_POSIX -r

Single-shared-file (ssf)
-----
- Write: $IOR -a ${API} [-c] -C -e -E -g -k -vvv -t ${XFER_SIZE} [-s SEGMENTS] -b ${BLK_SIZE} -o ${TESTDIR}/${API} -w
- Read:  $IOR -a ${API} [-c] -C -e -E -g -k -vvv -t ${XFER_SIZE} [-s SEGMENTS] -b ${BLK_SIZE} -o ${TESTDIR}/${API} -r 

Running
=======

The ior tests can be run under Slurm using the following command:

.. code-block:: bash

    srun ...

..


Where `load_type` is `load1` for sequential loads and `load2` for random loads, `io_type` is `posix` or `mpiio`, and `access_type` is `filepertask` and `sharedfile` for per task and shared accesses respectively.
There are six input decks in the `inputs.xroads` directory; each should be run on a single node and across the full system in parallel.

"*Note: Benchmark values for random loads are not presented here.*"


Validation
==========


Example Scalability Results
===========================


Scaling on El Capitan
=====================


References
==========
