.. Numbering is intended to facilitate order from a directory listing
   perspective (e.g., section 00 comes before 31).
   Suggestion:
   00-09 :: Front matter
   10-19 :: LLNL Mini-Apps
   20-29 :: LANL Mini-Apps
   30-39 :: SNL Mini-Apps
   40-69 :: More Mini-Apps
   70-89 :: Microbenchmarks
   90-99 :: Appendices


******************
Benchmark Overview
******************

ModSim benchmarks are features, components, performance characteristics,
or other properties that are important to the Laboratories.

**ModSim Priority 1**

.. list-table::

 * - **Benchmark**
   - **Description**
   - **Language**
   - **Parallelism**
   - **Scale**
   - **Libraries**
 * - Kripke
   - | Scalable 3D Sn deterministic
     | particle transport code
   - C++
   - MPI+RAJA
   - Multi-node
   - RAJA, CHAI, Camp, Umpire
 * - Laghos
   - | LAGrangian High-Order Solver,
     | unstructured high-order finite
     | element compressible gas dynamics
   - C++
   - MPI+RAJA/CUDA/HIP
   - Multi-node  
   - RAJA, MFEM, Hypre, Umpire
 * - RAJA Performance Suite
   - | Collection of loop-based computational
     | kernels found in HPC applications
   - C++
   - | MPI+RAJA
     | /CUDA/HIP/OpenMP
   - Single node
   - RAJA
 * - Branson
   - Implicit Monte Carlo transport
   - C++
   - MPI+CUDA/HIP
   - Multi-node
   - Umpire
 * - Sparta
   - Direct Simulation Monte Carlo
   - C++
   - MPI+Kokkos
   - Multi-node     
   - Kokkos


**ModSim Priority 2**

.. list-table::

 * - **Benchmark**
   - **Description**
   - **Language**
   - **Parallelism**
   - **Scale**
   - **Libraries**
 * - AMG2023
   - AMG solver of sparse matrices
   - C
   - | MPI+CUDA/HIP/SYCL
     | OpenMP on CPU
   - Multi-node
   - Hypre, Umpire
 * - LAMMPS ACE
   - | Molecular dynamics using
     | Atomic Cluster Expansion (ACE)
   - C++
   - MPI+Kokkos
   - Multi-node
   - Kokkos
 * - Remhos
   - | REMap High-Order Solver, unstructured
     | high-order finite element advection
   - C++
   - MPI+RAJA/CUDA/HIP
   - Multi-node
   - RAJA, MFEM, Hypre
 * - MiniEM
   - Electro-Magnetics solver
   - C++
   - MPI+Kokkos
   - Multi-node
   - Kokkos, Trillinos

Please note that half of the RAJA kernels are Priority 1, and the other half are Priority 2.  Similarly, 2 of the Laghos problems are Priority 1, and the third is Priority 2.


.. _GlobalRunRules:

Run Rules Synopsis
==================

Source code modification categories:

1. Baseline: “out-of-the-box” performance
  * Code modifications not permitted
  * Compiler options can be modified, library substitutions permitted unless prohibited for a specific benchmark (see details on benchmark pages), problem decomposition may be changed
  * If provided code cannot run on the proposed architecture as-is, limited source code modifications are permitted to port and tune for the target architecture using directives or commonly used interfaces.
2. Optimized: "speed of light"
  * Aggressive code changes that enhance performance are permitted.  Optimizations that will be applicable to mission applications are of more value.
  * Algorithms fundamental to the program may not be replaced.  Wholesale algorithm changes or manual rewriting of loops that become strongly architecture specific are of less value.
  * The modified code must still pass validation tests.
  * Optimizations will be reviewed by subject matter experts for applicability to the larger application portfolio and other goals such as performance portability and programmer productivity.


**********
Priority 1
**********

.. toctree::
   :maxdepth: 1
   :numbered:

   ../11_kripke/kripke
   ../12_laghos/laghos
   ../13_rajaperf/rajaperf
   ../20_branson/branson
   ../31_sparta/sparta

**********
Priority 2
**********
   
.. toctree::
   :maxdepth: 1
   :numbered:

   ../10_amg/amg
   ../32_lammpsACE/lammpsACE
   ../13_rajaperf/rajaperf   
   ../40_remhos/remhos
   ../50_miniem/miniem

**************
MPI Benchmarks
**************
   
.. toctree::
   :maxdepth: 1
   :numbered:

   ../70_phloem/phloem
   ../71_omb/omb
   ../72_smb/smb
