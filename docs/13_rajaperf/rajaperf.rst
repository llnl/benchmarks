**********************
RAJA Performance Suite
**********************

RAJA Performance Suite source code is near-final at this point. The problems to run are yet to be finalized.

The RAJA Performance Suite contains a collection of computational kernels that
represent important computational patterns found in HPC applications. It is a
companion project to RAJA, which is a library of software abstractions used to
write portable, single-source application code in C++. The Suite provides a
means to assess and analyze RAJA performance and, in particular, to compare
kernel implementations that use RAJA and those that do not use RAJA.

Source code and documentation for RAJA and RAJA Performance Suite is 
available at:

  * `RAJA Performance Suite GitHub project <https://github.com/LLNL/RAJAPerf>`_ 

  * `RAJA GitHub project <https://github.com/LLNL/RAJAPerf>`_

.. important:: The RAJA Performance Suite benchmark is limited to a subset of
               kernels in the RAJA Performance Suite, as described below.


Purpose
=======

The RAJA Performance Suite is used to analyze performance of loop-based
computational kernels representative of those found in HPC applications and
which are implemented using `RAJA <https://github.com/LLNL/RAJA>`_. Each kernel
in the Suite appears in RAJA and *non-RAJA* variants that employ standard or
vendor-defined parallel programming models, such as OpenMP, CUDA, HIP, and
SYCL. RAJA and non-RAJA variants enable comparison of performance and
compiler-generated code that uses RAJA and that which does not.

The kernels in the RAJA Performance Suite originate from open-source HPC
benchmark suites and restricted-access production applications. Kernels
represent various types of loop structures, such as simple for-loops,
perfectly and non-perfectly nested for-loops, and important parallel operations
including reductions, atomics, scans, and sorts. Often, kernels in the Suite
are developed to serve as reproducers of performance and compiler optimization
issues observed in production applications that use RAJA.

When used, RAJA is the *X* in *MPI + X* parallel application paradigm, where
MPI is used for distributed memory, multi-node parallelism and X (RAJA in this
case) supports fine-grained parallelism within an MPI rank. The RAJA Performance
Suite supports MPI so that performance of a kernel in the Suite aligns with how
the kernel would perform in a real application. For example, observed memory
bandwidth may be different when running on a many core system using OpenMP
multithreading to exercise all cores than when each core is mapped to an MPI
rank. Similarly, on a system where a GPU can be partitioned into multiple 
compute devices, performance can be different when running only a single
partition than when exercising the entire GPU with each partition assigned to
a different MPI rank. 


Characteristics
===============

The RAJA Performance Suite repository contains all of its software dependencies
as submodules whose versions are pinned to the Suite version. Thus,
recursively cloning the Suite repo and its submodules is all that is needed to
configure, build, and run the Suite.

The Suite is designed so that its key parameters and options are defined via
command-line options. The intent is that one would write scripts to execute
a series of Suite runs to generate data for a performance experiment.

Problems
--------

List and describe subset of kernels in the benchmark....

Figure of Merit
---------------




Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications. 
For the RAJA Performance Suite, we define the following restrictions on source code modifications:

* RAJA Performance Suite uses RAJA as the portability library, available at https://github.com/LLNL/RAJA .  While source code changes to RAJA can be proposed, RAJA in RAJA Performance Suite may not be removed or replaced with any other library.


Building
========


Running
=======


Validation
==========


Example Scalability Results
===========================


Memory Usage
============


Strong Scaling on El Capitan
============================

Please see :ref:`ElCapitanSystemDescription` for El Capitan system description.


Weak Scaling on El Capitan
==========================


References
==========
