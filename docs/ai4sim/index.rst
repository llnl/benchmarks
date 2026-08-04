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


***********
Procurement
***********

.. toctree::
   :maxdepth: 3
   :numbered:

   ../14_scaffold/scaffold

**********
Acceptance
**********

.. toctree::
   :maxdepth: 3
   :numbered:

	     
   ../60_mlperf/mlperf

***********
Collectives
***********
   
.. toctree::
   :maxdepth: 3
   :numbered:
   
   ../71_omb/omb

   
.. Indices and tables
   ==================
..   * :ref:`genindex`
..   * :ref:`modindex`
..   * :ref:`search`
