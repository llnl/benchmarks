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

.. list-table::

 * - **Benchmark**
   - **Description**
   - **Language**
   - **Parallelism**
   - **Libraries**
 * - ScaFFold
   - | Scale-Free Fractal Benchmark,
     | Proxy for emerging models such as
     | programmatic inverse-design projects
   - Python
   - | MPI/NCCL/RCCL
     | CUDA/HIP
   - PyTorch
 * - MLPerf
   - Llama 3.1 405B training
   - Python
   - NCCL+CUDA
   - NVIDIA NeMo

.. _AI4SIMRunRules:


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

   ../14_scaffold/scaffold

**********
Priority 2
**********

.. toctree::
   :maxdepth: 1
   :numbered:

	     
   ../60_mlperf/mlperf

***********
Collectives
***********

.. toctree::
   :maxdepth: 1
   :numbered:
   
   ../71_omb/omb



