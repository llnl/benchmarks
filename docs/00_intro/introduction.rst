************
Introduction
************

This is benchmark documentation for a Department of Energy (DOE)
National Nuclear Security Administration (NNSA) Advanced Simulation
and Computing (ASC) **Future Computing Resource (FCR)**.


Benchmark Overview 
==================

.. list-table::

 * - **Benchmark**
   - **Description**
   - **Language**
   - **Parallelism** 
 * - AMG2023
   - | AMG solver of sparse matrices 
     | using Hypre 
   - C 
   - | MPI+CUDA/HIP/SYCL
     | OpenMP on CPU
 * - Branson
   - Implicit Monte Carlo transport
   - C++
   - MPI + Cuda/HIP
 * - MiniEM
   - Electro-Magnetics solver
   - C++
   - MPI+Kokkos
 * - Sparta
   - Direct Simulation Monte Carlo
   - C++
   - MPI+Kokkos


.. _GlobalRunRules:

Run Rules Synopsis
==================

Source code modification categories:

* Baseline: “out-of-the-box” performance

  * Code modifications not permitted

  * Compiler options can be modified, library substitutions permitted, problem decomposition may be changed

* Ported: “alternative baseline for new architectures”

  * Limited source-code modifications are permitted to port and tune for the target architecture using directives or commonly used interfaces.

* Optimized: "speed of light"

  * Aggressive code changes that enhance performance are permitted.

  * Algorithms fundamental to the program may not be replaced.

  * The modified code must still pass validation tests.

  * Optimizations will be reviewed by subject matter experts for applicability to the larger application portfolio and other goals such as performance portability and programmer productivity. 


     

Approvals
=========

- Content from Sandia National Laboratories considered unclassified with
  unlimited distribution under SAND2023-12176O, SAND2023-01069O, and
  SAND2023-01070O.

