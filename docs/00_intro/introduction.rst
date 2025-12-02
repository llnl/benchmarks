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
   - **Libraries**
 * - AMG2023
   - AMG solver of sparse matrices  
   - C 
   - | MPI+CUDA/HIP/SYCL
     | OpenMP on CPU
   - Hypre
 * - Kripke
   - | Scalable 3D Sn deterministic 
     | particle transport code 
   - C++
   - MPI+RAJA
   - RAJA
 * - Laghos
   - | LAGrangian High-Order Solver, 
     | unstructured high-order finite element compressible gas dynamics
   - C++
   - MPI+RAJA/CUDA/HIP
   - MFEM, Hypre
 * - ScaFFold
   - | LAGrangian High-Order Solver, 
     | unstructured high-order finite element method
   - Python, C++
   - MPI/NCCL/RCCL+CUDA/HIP
   - PyTorch
 * - Branson
   - Implicit Monte Carlo transport
   - C++
   - MPI+CUDA/HIP
   - N/A
 * - Sparta
   - Direct Simulation Monte Carlo
   - C++
   - MPI+Kokkos
   - Kokkos
 * - LAMMPS ACE
   - | Molecular dynamics using
   - | Atomic Cluster Expansion (ACE)
   - C++
   - MPI+Kokkos
   - Kokkos
 * - Remhos
   - | REMap High-Order Solver, 
     | unstructured high-order finite element advection
   - C++
   - MPI+RAJA/CUDA/HIP
   - MFEM, Hypre
* - MiniEM
   - Electro-Magnetics solver
   - C++
   - MPI+Kokkos
   - Kokkos
* - MLPerf
   - Llama 3.1 405B training 
   - NVIDIA NeMo
   - 
   - 


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

