*************************************
RAJA Performance Suite Tier 2 Kernels
*************************************

This section provides information specific to the Tier 2 kernels in the RAJA Performance Suite.
The main :doc:`RAJA Performance Suite Benchmark documentation
<../13_rajaperf/rajaperf>` provides general information that applies to all kernels in the Benchmark,
both Tier 1 **and** Tier2, such as the purpose of the Benchmark, its characteristics, FOM, etc.

.. _rajaperf2_problems-label:

Problems
--------

Tier 2 kernels
^^^^^^^^^^^^^^^^^^^

The following list describes the Tier 2 kernels and the RAJA features they exercise.
In the RAJA Performance Suite repo, they are located in ``RAJAPerf/src`` sub-directories noted below (i.e., ``RAJAPerf/src/<subdir>/<kernel>``):

   #. **apps/CONVECTION3DPA** element-wise action of a 3D finite element volume convection operator via partial assembly and sum factorization *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **apps/DEL_DOT_VEC_2D** divergence of a vector field at a set of points on a mesh *(single loop, data access via indirection array, RAJA::forall API)*
   #. **apps/INTSC_HEXHEX** intersection between two 24-sided hexahedra, including volume and moment calculations *(multiple single-loop operations in sequence, RAJA::forall API)*
   #. **apps/LTIMES** one step of the source-iteration technique for solving the steady-state linear Boltzmann equation, multi-dimensional matrix product *(nested loops, RAJA::kernel API)*
   #. **apps/MASS3DPA** element-wise action of a 3D finite element mass matrix via partial assembly and sum factorization *(nested loops, GPU shared memory, RAJA::launch API)*
   #. **apps/MATVEC_3D_STENCIL** matrix-vector product based on a 3D mesh stencil *(single loop, data access via indirection array, RAJA::forall API)*
   #. **basic/MULTI_REDUCE** multiple reductions in a kernel, where number of reductions is set at run time *(single loop, irregular atomic contention, RAJA::forall API)*
   #. **basic/REDUCE_STRUCT** multiple reductions in a kernel, where number of reductions (6) is known at compile time *(single loop, multiple reductions, RAJA::forall API)*
   #. **basic/INDEXLIST_3LOOP** construction of set of indices used in other kernel executions *(single loops, vendor scan implementations, RAJA::forall API)*
   #. **comm/HALO_PACKING_FUSED** packing and unpacking MPI message buffers for point-to-point distributed memory halo data exchange for mesh-based codes *(overhead of launching many small kernels, GPU variants use RAJA::Workgroup concepts to execute multiple kernels with one launch)*

.. _rajaperf2_fom-label:

Figure of Merit
---------------

The FOM for each kernel in the RAJA Performance Suite Benchmark is described in :ref:`rajaperf_results-label`.
Please refer to that section for FOM definition and how it is determined.

For Tier 2 kernels, the saturation point is estimated based on compute rate data, except for two kernels
``INDEXLIST_3LOOP`` and ``HALO_PACKING_FUSED``. Those kernels perform no floating point operations, so
we estimate the saturation point for them based on memory bandwidth data.

.. _rajaperf2_codemod-label:

Source code modifications
=========================

Restrictions on source code modifications for Tier 2 kernels is identical to what is described in
:ref:`rajaperf_codemod-label`.

.. _rajaperf2_build-label:

Building, Running, Validation
==============================

Instructions for obtaining the Benchmark code for Tier 2 kernels, building it, running it, and validation are
the same as what is described in :ref:`rajaperf_build-label`, :ref:`rajaperf_run-label`, and 
:ref:`rajaperf_validation-label`, respectively.

.. _rajaperf2_results-label:

Benchmark Results for Tier 2 Kernels
====================================

The process of running the Tier 2 Benchmark kernels and generating FOM for them is essentially the
same as what is described in :ref:`_rajaperf_results-label` for the Tier 1 kernels. Here, we 
summarize the process as it applies to the Tier 2 kernels. 

.. important:: In the following sections, we present detailed results,
               including FOM tables and throughput plots for the Tier 2
               kernels described above. Data and plot files are included
               in the ``baseline_data`` directory of this benchmark
               repository for reference.

AMD MI300A throughput results (Tier 2 kernels)
----------------------------------------------------

For the MI300A architecture, we present two sets of throughput results. One is
run in ``SPX mode`` where we use 4 MPI ranks on a node, one for each MI300A APU,
thus treating each APU as a single GPU. The other is run in ``CPX mode`` where
we run with 24 MPI ranks on a node, six for each MI300A APU, treating each APU as
6 GPUs (i.e., one GPU = 1 XCD). For each mode, we run each kernel over a sequence
of problem sizes so that the saturation point is evident on its associated throughput curve.

SPX mode (Tier 2)
^^^^^^^^^^^^^^^^^^^^^^

For SPX mode (1 MPI rank per APU on a node), we choose the smallest
problem to use ~100,000 bytes of allocated memory and the largest problem
to use ~400MB of allocated memory, which is about 1.5 times the MALL
(Memory Attached Last-Level cache) size on the MI300A. The MALL is 256MB
(256 * 1024 * 1024 = 268,435,456 bytes).

Note that the two Tier 2 kernels, ``INDEXLIST_3LOOP`` and ``HALO_PACKING_FUSED``,
do not perform any floating point operations; thus, they have zero GFLOP/sec rates.
They represent recurring computational patterns in our applications that are important despite not
performing floating point operations. So, we consider bandwidth as an appropriate metric.

After building the code as described in :ref:`rajaperf_build_mi300a-label`, we
ran the ``Tier 2`` kernels in **SPX mode** as follows::

  $ cd path/to/RAJAPerf
  $ cd build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ cp ../../RPB-v2026.10.0/scripts/run_tier_mi300a.sh .
  $ ./run_tier_mi300a.sh spx tier2

This generates a directory named ``RPBenchmark_MI300A_tier2-SPX`` containing
output files for each kernel run over its range of problem sizes.

Then, we processed the data to generate more concise baseline results
by running a Python script we provide::

  $ cd path/to/RAJAPerf
  $ cd build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ cp ../../RPB-v2026.10.0/scripts/process_data.py .
  $ python3 ./process_data.py --root-dir ./RPBenchmark_MI300A_tier2-SPX --output-dir ./RPBenchmark_MI300A_tier2-SPX/Output --exclude-plot-variant Base_Seq

This generates throughput curve files for ``Base_HIP`` and ``RAJA_HIP``
variants of each kernel and summarizes the FOM (described in
:ref:`rajaperf_fom-label`) in a CSV file. We include the files generated by the
``process_data.py`` script in this repo in the directory
``./docs/13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-SPX``.

.. csv-table:: FOM results for Tier 2 kernels run on MI300A in SPX mode
   :file: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-SPX/FOM/combined_fom.csv
   :align: center
   :widths: auto
   :header-rows: 1

CPX mode (Tier 2)
^^^^^^^^^^^^^^^^^^^^^^

For CPX mode (run with 6 MPI ranks per APU on a node), we choose the
smallest problem to use ~50,000 bytes of allocated memory and the largest
problem to use ~75MB of allocated memory, which is slightly less than 1/3
the MALL size.

As noted earlier, two of the kernels ``INDEXLIST_3LOOP`` and ``HALO_PACKING_FUSED`` do not
perform any floating point operations. So, we consider the bandwidth
as the appropriate metric. We include the baseline data files for Tier 2
kernels run on the MI300A architecture in CPX mode in this repo in the
directory ``./docs/13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-CPX``.

Similar to the SPX mode description above, we run the ``Tier 2`` kernels in
**CPX mode** as follows::

  $ cd path/to/RAJAPerf
  $ cd build_lc_toss4-cray-mpich-9.0.1-amdclang-6.4.3-gfx942
  $ cp ../../RPB-v2026.10.0/scripts/run_tier_mi300a.sh .
  $ ./run_tier_mi300a.sh cpx tier2

This generates a directory named ``RPBenchmark_MI300A_tier2-CPX``, which
contains all the results files for each kernel run over its range of problem
sizes.

Then, we process the data for reporting the results here in a concise
form by running a Python script we provide::

  $ cd path/to/RAJAPerf
  $ cp ../../RPB-v2026.10.0/scripts/process_data.py .
  $ python3 ./process_data.py --root-dir ./RPBenchmark_MI300A_tier2-CPX --output-dir ./RPBenchmark_MI300A_tier2-CPX/Output --exclude-plot-variant Base_Seq

This generates throughput curve files for ``Base_HIP`` and ``RAJA_HIP``
variants of each kernel and summarizes the FOM (described in
:ref:`rajaperf_fom-label`) in a CSV file. These files are included in this repo in the
directory ``./docs/13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-CPX``.

.. csv-table:: FOM results for Tier 2 kernels run on MI300A in CPX mode
   :file: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-CPX/FOM/combined_fom.csv
   :align: center
   :widths: auto
   :header-rows: 1

AMD MI300A throughput plots (Tier 2)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This section contains throughput plots for each Tier 2 kernel run as described
above on the MI300A architecture in SPX mode (left column) and CPX mode (right column).
Each plot has multiple curves with GFLOP/sec (compute rate), or memory bandwidth (GB/sec) for
kernels with zero FLOPs, plotted as a function of problem size (allocated bytes).
The legend in each plot indicates the curves shown.

+----------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------+
| Tier 2 Kernels: MI300A Node Throughput (SPX Mode)                                                                    | Tier 2 Kernels: MI300A Node Throughput (CPX Mode)                                                                    |
+----------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------+
|                                                                                                                      |                                                                                                                      |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-SPX/figures/Apps_CONVECTION3DPA_flops.png          | .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-CPX/figures/Apps_CONVECTION3DPA_flops.png          |
|    :width: 100 %                                                                                                     |    :width: 100 %                                                                                                     |
|    :align: center                                                                                                    |    :align: center                                                                                                    |
+----------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------+
|                                                                                                                      |                                                                                                                      |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-SPX/figures/Apps_DEL_DOT_VEC_2D_flops.png          | .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-CPX/figures/Apps_DEL_DOT_VEC_2D_flops.png          |
|    :width: 100 %                                                                                                     |    :width: 100 %                                                                                                     |
|    :align: center                                                                                                    |    :align: center                                                                                                    |
+----------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------+
|                                                                                                                      |                                                                                                                      |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-SPX/figures/Apps_INTSC_HEXHEX_flops.png            | .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-CPX/figures/Apps_INTSC_HEXHEX_flops.png            |
|    :width: 100 %                                                                                                     |    :width: 100 %                                                                                                     |
|    :align: center                                                                                                    |    :align: center                                                                                                    |
+----------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------+
|                                                                                                                      |                                                                                                                      |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-SPX/figures/Apps_LTIMES_flops.png                  | .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-CPX/figures/Apps_LTIMES_flops.png                  |
|    :width: 100 %                                                                                                     |    :width: 100 %                                                                                                     |
|    :align: center                                                                                                    |    :align: center                                                                                                    |
+----------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------+
|                                                                                                                      |                                                                                                                      |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-SPX/figures/Apps_MASS3DPA_flops.png                | .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-CPX/figures/Apps_MASS3DPA_flops.png                |
|    :width: 100 %                                                                                                     |    :width: 100 %                                                                                                     |
|    :align: center                                                                                                    |    :align: center                                                                                                    |
+----------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------+
|                                                                                                                      |                                                                                                                      |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-SPX/figures/Apps_MATVEC_3D_STENCIL_flops.png       | .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-CPX/figures/Apps_MMATVEC_3D_STENCIL_flops.png      |
|    :width: 100 %                                                                                                     |    :width: 100 %                                                                                                     |
|    :align: center                                                                                                    |    :align: center                                                                                                    |
+----------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------+
|                                                                                                                      |                                                                                                                      |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-SPX/figures/Basic_INDEXLIST_3LOOP_bandwidth.png    | .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-CPX/figures/Basic_INDEXLIST_3LOOP_bandwidth.png    |
|    :width: 100 %                                                                                                     |    :width: 100 %                                                                                                     |
|    :align: center                                                                                                    |    :align: center                                                                                                    |
+----------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------+
|                                                                                                                      |                                                                                                                      |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-SPX/figures/Basic_MULTI_REDUCE_flops.png           | .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-CPX/figures/Basic_MULTI_REDUCE_flops.png           |
|    :width: 100 %                                                                                                     |    :width: 100 %                                                                                                     |
|    :align: center                                                                                                    |    :align: center                                                                                                    |
+----------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------+
|                                                                                                                      |                                                                                                                      |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-SPX/figures/Basic_REDUCE_STRUCT_flops.png          | .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-CPX/figures/Basic_NREDUCE_STRUCT_flops.png         |
|    :width: 100 %                                                                                                     |    :width: 100 %                                                                                                     |
|    :align: center                                                                                                    |    :align: center                                                                                                    |
+----------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------+
|                                                                                                                      |                                                                                                                      |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-SPX/figures/Comm_HALO_PACKING_FUSED_bandwidth.png  | .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_MI300A_tier2-CPX/figures/Comm_HALO_PACKING_FUSED_bandwidth.png  |
|    :width: 100 %                                                                                                     |    :width: 100 %                                                                                                     |
|    :align: center                                                                                                    |    :align: center                                                                                                    |
+----------------------------------------------------------------------------------------------------------------------+----------------------------------------------------------------------------------------------------------------------+


NVIDIA H100 throughput results (Tier 2 kernels)
----------------------------------------------------

For the NVIDIA H100 architecture, we present one set of throughput results, where we ran with
4 MPI ranks on a node -- one for each H100 GPU. We ran each ``Tier 1``
kernel over a sequence of problem sizes such that the saturation point is
evident on its associated throughput curve.

We choose the smallest problem to use ~50,000 bytes of allocated memory and
the largest problem to use ~150MB of allocated memory, which is about 3 times
the L2 cache size on the H100 GPU.  The L2 cache is 50MB
(50 * 1024 * 1024 = 52,428,800 bytes).

After building the code as described in :ref:`rajaperf_build_h100-label`, we
run the ``Tier 2`` kernels as follows::

  $ cd path/to/RAJAPerf
  $ cd build_lc_toss4-mvapich2-2.3.7-nvcc-13.1.1-90-gcc-10.3.1
  $ cp ../../RPB-v2026.10.0/scripts/run_tier_h100.sh .
  $ ./run_tier_h100.sh tier2

This generates a directory named ``RPBenchmark_H100_tier2``, which contains
the results files for each kernel run over its range of problem sizes.

Then, we process the data for reporting the results here in a concise form
by running the Python script we provide::

  $ cd path/to/RAJAPerf
  $ cd build_lc_toss4-mvapich2-2.3.7-nvcc-13.1.1-90-gcc-10.3.1
  $ cp ../../RPB-v2026.10.0/scripts/process_data.py .
  $ python3 ./process_data.py --root-dir ./RPBenchmark_H100_tier2 --output-dir ./RPBenchmark_H100_tier2/Output --exclude-plot-variant Base_Seq

This generates throughput curve files for ``Base_CUDA`` and ``RAJA_CUDA``
variants of each kernel and summarizes the FOM (described in
:ref:`rajaperf_fom-label`) in a CSV file.  We include
the files generated by the ``process_data.py`` script in this repo in the
directory ``./docs/13_rajaperf/baseline_data/RPBenchmark_H100_tier2``.

Note that the two Tier2 kernels, ``INDEXLIST_3LOOP`` and ``HALO_PACKING_FUSED``,
do not perform any floating point operations; thus, they have zero GFLOP/sec rates.
They represent recurring computational patterns in our applications that are important despite not
performing floating point operations. So, we consider bandwidth as an appropriate metric.
We include the baseline data files for Tier 2 kernels run on the H100 architecture
in this repo in the directory ``./docs/13_rajaperf/baseline_data/RPBenchmark_H100_tier2-SPX``.

.. csv-table:: FOM results for Tier 2 kernels run on H100
   :file: ../13_rajaperf/baseline_data/RPBenchmark_H100_tier2/FOM/combined_fom.csv
   :align: center
   :widths: auto
   :header-rows: 1


NVIDIA H100 throughput plots (Tier 2)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This section contains throughput plots for each Tier 2 kernel run as described
above on the H100 architecture. Each plot has multiple curves with GFLOP/sec (compute rate),
or memory bandwidth (GB/sec) for kernels with zero FLOPs, plotted as a function of problem
size (allocated bytes). The legend in each plot indicates the curves shown.

+-------------------------------------------------------------------------------------------------------------------+
| Tier 2 Kernels H100 Node Throughput                                                                               |
+-------------------------------------------------------------------------------------------------------------------+
|                                                                                                                   |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_H100_tier2/figures/Apps_CONVECTION3DPA_flops.png             |
|    :width: 100 %                                                                                                  |
|    :align: center                                                                                                 |
+-------------------------------------------------------------------------------------------------------------------+
|                                                                                                                   |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_H100_tier2/figures/Apps_DEL_DOT_VEC_2D_flops.png             |
|    :width: 100 %                                                                                                  |
|    :align: center                                                                                                 |
+-------------------------------------------------------------------------------------------------------------------+
|                                                                                                                   |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_H100_tier2/figures/Apps_INTSC_HEXHEX_flops.png               |
|    :width: 100 %                                                                                                  |
|    :align: center                                                                                                 |
+-------------------------------------------------------------------------------------------------------------------+
|                                                                                                                   |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_H100_tier2/figures/Apps_LTIMES_flops.png                     |
|    :width: 100 %                                                                                                  |
|    :align: center                                                                                                 |
+-------------------------------------------------------------------------------------------------------------------+
|                                                                                                                   |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_H100_tier2/figures/Apps_INTSC_HEXRECT_flops.png              |
|    :width: 100 %                                                                                                  |
|    :align: center                                                                                                 |
+-------------------------------------------------------------------------------------------------------------------+
|                                                                                                                   |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_H100_tier2/figures/Apps_MASS3DEA_flops.png                   |
|    :width: 100 %                                                                                                  |
|    :align: center                                                                                                 |
+-------------------------------------------------------------------------------------------------------------------+
|                                                                                                                   |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_H100_tier2/figures/Apps_MASS3DPA_ATOMIC_flops.png            |
|    :width: 100 %                                                                                                  |
|    :align: center                                                                                                 |
+-------------------------------------------------------------------------------------------------------------------+
|                                                                                                                   |
| .. figure:: ../13_rajaperf/baseline_data/baseline_data/RPBenchmark_H100_tier2/figures/Apps_MASSVEC3DPA_flops.png  |
|    :width: 100 %                                                                                                  |
|    :align: center                                                                                                 |
+-------------------------------------------------------------------------------------------------------------------+
|                                                                                                                   |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_H100_tier2/figures/Apps_NODAL_ACCUMULATION_3D_flops.png      |
|    :width: 100 %                                                                                                  |
|    :align: center                                                                                                 |
+-------------------------------------------------------------------------------------------------------------------+
|                                                                                                                   |
| .. figure:: ../13_rajaperf/baseline_data/RPBenchmark_H100_tier2/figures/Apps_VOL3D_flops.png                      |
|    :width: 100 %                                                                                                  |
|    :align: center                                                                                                 |
+-------------------------------------------------------------------------------------------------------------------+
