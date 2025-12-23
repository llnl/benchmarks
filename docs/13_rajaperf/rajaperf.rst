**********************
RAJA Performance Suite
**********************

The RAJA Performance Suite is a companion project to the
`RAJA project <https://github.com/LLNL/RAJA>`_, which is an open-source library
of C++ abstractions that enable single-source portable application code. The
RAJA Performance Suite contains loop-based computational kernels representative
of those found in production HPC applications. Each kernel appears in RAJA and
non-RAJA variants to enable comparison of performance between them.

The RAJA Performance Suite is available at https://github.com/LLNL/RAJAPerf

RAJA Performance Suite source code is near-final at this point. The problems to run are yet to be finalized.


Purpose
=======

The RAJA Performance Suite is designed to analyze performance of loop-based
computational kernels found in HPC applications, specifically those implemented
using `RAJA <https://github.com/LLNL/RAJA>`_. Each kernel in the Suite appears
in multiple RAJA and *non-RAJA* variants using common parallel programming
models, such as OpenMP, CUDA, HIP, and SYCL. 

The kernels in the RAJA Performance Suite originate from other HPC benchmark
suites as well as peroduction applications. Kernels are chosen and/or
developed for performance analysis of RAJA on various types of loop structures
(e.g., simple for-loops, perfectly and non-perfectly nested for-loops) and
operations (e.g., reductions, atomics, scans, sorts). In particular, many
kernels are designed to reproduce compiler optimization and other issues
observed in real applications that use RAJA. The RAJA team works with compiler
and hardware vendors to resolve the issues.

The RAJA Performance Suite benchmark exercises a small subset of kernels in the
Suite that are chosen because they represent important computational patterns
in relevant applications.

Characteristics
===============

Problems
--------

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
