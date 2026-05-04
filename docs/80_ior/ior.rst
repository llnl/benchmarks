***
IOR
***

Purpose
=======

IOR is used for testing performance of parallel file systems using various interfaces and access patterns at the POSIX and MPI-IO level.

Characteristics
===============

IOR is available in the benchmarks repository.

* Github: `IOR Public <https://github.com/hpc/ior>`_

The github repo also contains mdtest.

Problem
-------

IOR measures parallel I/O performance at the POSIX and MPI-IO levels.
It writes and reads files, one per rank or shared between all ranks, on a parallel file system.
It should be run in lustre space.

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
    #make install
..

This will build both IOR with the POSIX and MPI-IO interfaces and create the
IOR executable at `src/ior`.

Running
=======

The ior tests can be run using the following command:

.. code-block:: bash

    srun ...

..

Where `load_type` is `load1` for sequential loads and `load2` for random loads, `io_type` is `posix` or `mpiio`, and `access_type` is `filepertask` and `sharedfile` for per task and shared accesses respectively.
There are six input decks in the `inputs.xroads` directory; each should be run on a single node and across the full system in parallel.

"*Note: Benchmark values for random loads are not presented here.*"

Input
-----

Running IOR does not require using the input files. All arguments can be given on the command line.


Validation
==========


Example Scalability Results
===========================


Memory Usage
============


Scaling on El Capitan
=====================


References
==========
