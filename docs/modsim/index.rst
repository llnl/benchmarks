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

ModSim Procurement
^^^^^^^^^^^^^^^^^^

.. list-table::

 * - **Benchmark**
   - **Description**
   - **Language**
   - **Parallelism**
   - **Libraries**
 * - Kripke
   - | Scalable 3D Sn deterministic
     | particle transport code
   - C++
   - MPI+RAJA
   - RAJA, CHAI, Camp
 * - Laghos
   - | LAGrangian High-Order Solver,
     | unstructured high-order finite
     | element compressible gas dynamics
   - C++
   - MPI+RAJA/CUDA/HIP
   - RAJA, MFEM, Hypre
 * - RAJA Performance Suite
   - | Collection of loop-based computational
     | kernels found in HPC applications
   - C++
   - | MPI+RAJA
     | /CUDA/HIP/OpenMP
   - RAJA
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

ModSim Acceptance
^^^^^^^^^^^^^^^^^

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
 * - LAMMPS ACE
   - | Molecular dynamics using
     | Atomic Cluster Expansion (ACE)
   - C++
   - MPI+Kokkos
   - Kokkos
 * - Remhos
   - | REMap High-Order Solver, unstructured
     | high-order finite element advection
   - C++
   - MPI+RAJA/CUDA/HIP
   - RAJA, MFEM, Hypre
 * - MiniEM
   - Electro-Magnetics solver
   - C++
   - MPI+Kokkos
   - Kokkos, Trillinos

Please note that half of the RAJA kernels are Priority 1, and the other half are Priority 2.  Similarly, 2 of the Laghos problems are Priority 1, and the third is Priority 2.



***********
Procurement
***********

.. toctree::
   :maxdepth: 3
   :numbered:

   ../11_kripke/kripke
   ../12_laghos/laghos
   ../13_rajaperf/rajaperf
   ../20_branson/branson
   ../31_sparta/sparta

**********
Acceptance
**********
   
.. toctree::
   :maxdepth: 3
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
   :maxdepth: 3
   :numbered:

   ../70_phloem/phloem
   ../71_omb/omb
   ../72_smb/smb

.. Indices and tables
   ==================
..   * :ref:`genindex`
..   * :ref:`modindex`
..   * :ref:`search`
