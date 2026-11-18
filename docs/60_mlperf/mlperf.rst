#################################
 MLPerf Training: Llama 3.1 405B
#################################

`MLPerf Training <https://mlcommons.org/benchmarks/training/>`_ is the MLCommons
industry benchmark suite for training machine learning models to a target quality. This
benchmark uses the Llama 3.1 405B large language model (LLM) pretraining benchmark from
MLPerf Training v6.0. Published results are on the `MLCommons results site
<https://results.mlcommons.org/training#view=reports&round=v6.0>`__.

.. note:: For any questions about ATS-6 SI4Sim benchmarks, please contact ATS6-SI-Benchmarks <ats6-si-benchmarks@llnl.gov>.

.. important::

    Performance projections are for Llama 3.1 405B as defined in
    MLPerf Training v6.0. For acceptance testing, the benchmark will be
    augmented by a mixture-of-experts (MoE) pretraining task based on
    a then-current LLNS-designated reasonable state-of-the-art MoE
    architecture. The MoE benchmark in MLPerf Training v6.0 and v6.1 does not
    meet the benchmark requirements and will not be used. See
    :ref:`mlperf-moe-acceptance`.

*********
 Purpose
*********

This benchmark measures how well a system trains large transformer
models, and later MoE models, at scale. Training a model with hundreds
of billions of dense parameters (and, in the future, an MoE model with
about 1 trillion total parameters and many tens of billions of active
parameters) exercises the whole deep learning systems stack:

* Dense matrix multiplication at low precision (BF16, FP8, and FP4 formats).
* High-bandwidth memory capacity, to hold model weights, optimizer state, and activations.
* The scale-up interconnect, which carries tensor- and context-parallel communication,
  and pipeline-parallel communication when a model replica fits within one scale-up
  domain.
* The scale-out network, which carries data-parallel gradient reduction between model
  replicas, and pipeline-parallel communication when a replica spans scale-up domains.
* The software stack (framework, communication libraries, and kernels) that integrates
  these components.

Because MLPerf is an industry benchmark, the reference result comes from a published
MLPerf submission rather than from El Capitan. See :ref:`mlperf-reference-result`.

*********
 Problem
*********

The benchmark continues pretraining of Llama 3.1 405B from Meta's BF16 checkpoint on the
C4 dataset until the validation log perplexity reaches the quality target. The model
follows the `Llama 3.1 paper <https://arxiv.org/abs/2407.21783>`__ except that it uses the
Mixtral 8x22B tokenizer instead of the paper's TikToken-based tokenizer.

.. list-table:: Model
    :header-rows: 1

    - - Property
      - Value
    - - Parameters
      - 405 billion
    - - Layers
      - 126
    - - Model dimension
      - 16,384
    - - Feed-forward hidden dimension
      - 53,248
    - - Attention
      - Grouped-query attention, 128 heads, 8 key/value heads
    - - Positional embedding
      - RoPE
    - - Activation and normalization
      - SwiGLU and RMSNorm
    - - Tokenizer
      - Mixtral 8x22B (vocabulary size 32,000)
    - - Sequence length
      - 8,192 tokens

.. list-table:: Dataset and quality target
    :header-rows: 1

    - - Property
      - Value
    - - Training data
      - C4 (``c4/en/3.0.1``), training files 768–1023 of 1024, pretokenized
    - - Validation data
      - First 5,760 sequences (47,185,920 tokens) of a fixed, unshuffled subset of the
        C4 validation split
    - - Starting point
      - Meta Llama 3.1 405B BF16 checkpoint, converted to NeMo format
        (``opt_init_checkpoint_step`` = 0)
    - - Quality metric
      - Validation log perplexity
    - - Quality target
      - 5.6
    - - Evaluation frequency
      - Every 18,432 sequences. The first ``FLOOR(0.0026 * global_batch_size + 12)``
        evaluations are skipped.

The pretokenized dataset, tokenizer, and checkpoint are distributed by MLCommons. The
checkpoint is available only to MLCommons members; see `Checkpoint download
<https://github.com/mlcommons/training/tree/master/retired_benchmarks/large_language_model_pretraining/nemo#checkpoint-download>`__.

*****************
 Figure of Merit
*****************

The figure of merit (FOM) is the MLPerf Training score: the wall-clock time, in minutes,
to train the model to the quality target. Lower is better. Scoring follows the MLPerf
Training v6.0 rules:

* Each benchmark result needs at least three runs. With three runs, the score is the
  median run time (the olympic mean of three runs).
* Convergence is compared with the reference convergence points (RCPs) for the global
  batch size used. A result that converges faster than the RCP mean, but within the
  allowed statistical range, has its score normalized to the RCP mean. A result that
  converges faster than the allowed range fails the RCP check.

See :ref:`mlperf-timing` for what the timed region includes and excludes.

***************************
 Source code modifications
***************************

This benchmark is governed only by the `MLPerf Training v6.0 rules`_; the general ATS-6
run rules do not apply. The required projection must follow the closed-division rules.
In summary:

* The model architecture, dataset, tokenizer, starting checkpoint, quality target, and
  evaluation schedule are fixed.
* Hyperparameters are fixed or constrained as described in
  :ref:`mlperf-performance-projections`. Hyperparameter borrowing is not allowed for
  this benchmark.
* The framework, parallelization strategy, kernels, and communication libraries may be
  changed, provided the run reaches the quality target and passes the compliance and
  RCP checks.
* Numerical formats may be changed to any of the MLPerf pre-approved formats (including
  BF16, FP8, MXFP4, and NVFP4) with numerically safe techniques; other formats need
  approval from the MLPerf Training working group.

An open-division result may be reported in addition to the closed result. See
:ref:`mlperf-open-division`.

**********
 Building
**********

Any implementation that meets the closed-division rules may be used. Two starting points
are recommended:

* The `MLCommons reference implementation
  <https://github.com/mlcommons/training/tree/master/retired_benchmarks/large_language_model_pretraining/nemo>`__,
  based on NVIDIA NeMo. The v6.0 hyperparameter rules refer to commit
  ``a70765e9885ec1cba8e69a842ecfbdea750336c4`` of the ``mlcommons/training`` repository.
* The implementation used for the reference result, in the `Azure submission
  <https://github.com/mlcommons/training_results_v6.0/tree/main/Azure/benchmarks/llama31_405b/implementations/2048xAzure_GB200>`__
  of ``mlcommons/training_results_v6.0``. Its ``README.md`` describes building the
  container and preparing data. The NVIDIA base configurations are in
  ``configs/nvidia/``. The Azure configurations in ``configs/azure/`` and the launcher
  described in ``README_azure.md`` add settings specific to the Azure system (network
  interfaces, MPI modules, and hard-coded data and container paths).

The reference result used the following software stack:

.. list-table:: Reference result software stack
    :header-rows: 1

    - - Component
      - Version
    - - Framework
      - NVIDIA NeMo Framework Release 25.09
    - - CUDA
      - 13.0.1 (driver 580.95.09)
    - - NCCL
      - 2.28.3
    - - cuBLAS
      - 13.0.2.14
    - - cuDNN
      - 9.13.1
    - - Open MPI
      - 4.1.7
    - - Operating system
      - Ubuntu 24.04.4 LTS, Linux 6.8.0-1029-azure-nvidia

*********
 Running
*********

The steps below follow the reference result's implementation. Other implementations
must reproduce the same data, model, and hyperparameters.

#. Download the pretokenized C4 dataset and tokenizer with ``data_scripts/download.sh``.
   Allow at least 2.5 TB of storage.

#. Download the NeMo-formatted Llama 3.1 405B checkpoint (more than 1.5 TB).

#. Select a configuration and submit the job. The NVIDIA flow sources a configuration
   file and submits ``run.sub`` with Slurm. This example reproduces the reference
   result's run configuration by starting from the NVIDIA base configuration it was
   derived from:

   ::

       source configs/nvidia/config_GB200_640x4x24xtp4pp8cp2_cg_fp4.sh
       export DGXNNODES=2048
       export MINIBS=8
       export DATADIR=<path/to/dataset>
       export LOAD_CHECKPOINTS_PATH=<path/to/checkpoint>
       export LOAD_CHECKPOINT=/load_checkpoints/405b
       export LOGDIR=<path/to/logs>
       export CONT=<container image>
       sbatch -N ${DGXNNODES} --time=${WALLTIME} run.sub

.. list-table::
    :header-rows: 1

    - - Argument
      - Meaning
    - - ``config_GB200_640x4x24xtp4pp8cp2_cg_fp4.sh``
      - NVIDIA GB200 configuration: TP = 4, PP = 8, CP = 2, NVFP4, and CUDA graphs.
        As named, it is for 640 nodes with ``MINIBS`` = 24.
    - - ``DGXNNODES=2048``, ``MINIBS=8``
      - Override the node count and mini-batch size. With 64 GPUs per model replica,
        2,048 nodes give 128 data-parallel replicas and a global batch size of
        128 × 8 = 1,024. These are the values the Azure ``run_sweep.sh 128 8`` sets.
    - - ``DATADIR``, ``LOAD_CHECKPOINTS_PATH``, ``LOGDIR``, ``CONT``
      - Dataset, checkpoint, and log locations and the container image. Set them after
        sourcing the configuration, because some configurations (including the Azure
        ones) set their own values.
    - - ``WALLTIME``
      - Job time limit, set by the configuration.
    - - ``run.sub``
      - Slurm batch script that starts the container on every node (Pyxis and Enroot)
        and runs ``run_and_time.sh``.

The reference result itself was launched with the Azure wrapper ``launch_405b.py``, which
sources ``configs/azure/run_sweep.sh``. That script sources the Azure configuration and
sets the number of nodes to 16 times the number of data-parallel replicas.

Each job writes MLPerf log lines (prefixed ``:::MLLOG``) to a ``result_*.txt`` file in
``LOGDIR``. These logs are the input to the compliance checker (see `Validation`_).

.. _mlperf-run-parameters:

Runtime parameters
------------------

Configuration files are named
``config_<SYSTEM>_<NODES>x<GPUS/NODE>x<MINIBS>xtp<TP>pp<PP>cp<CP>.sh``. The following
parameters determine how the work is divided:

``TENSOR_MODEL_PARALLEL`` (TP), ``PIPELINE_MODEL_PARALLEL`` (PP), ``CONTEXT_PARALLEL`` (CP)
    Model parallelism. One model replica spans TP × PP × CP accelerators. The reference
    result uses TP = 4, PP = 8, and CP = 2, so each replica spans 64 GPUs (16 nodes).

Data parallelism (DP)
    The number of model replicas: the total number of accelerators divided by
    TP × PP × CP.

``MINIBS``
    Sequences per data-parallel replica per optimizer step. The global batch size (GBS)
    is ``MINIBS`` × DP.

``MICRO_BATCH_SIZE``
    Sequences per forward and backward pass. It does not change the GBS; it sets the
    number of gradient accumulation steps, ``MINIBS`` / ``MICRO_BATCH_SIZE``.

``INTERLEAVED_PIPELINE``
    Virtual pipeline stages (VP). The GBS should be divisible by DP × VP, and the
    pipeline layers should be divisible by PP × VP. The reference result uses PP = 8 and
    VP = 8 and sets ``ASYM_PP_EMBED`` and ``ASYM_PP_LOSS``, which count the embedding
    and the loss as pipeline layers. That gives 126 + 2 = 128 layers, which divides
    evenly into 64 stages.

The GBS determines the learning rate schedule (see :ref:`mlperf-required-parameters`).

************
 Validation
************

A run is valid if:

* It reaches a validation log perplexity of 5.6 or lower using the required parameters.
* Its ``result_*.txt`` log passes the MLPerf v6.0 compliance checker in the
  `mlperf_logging <https://github.com/mlcommons/logging>`__ package.
* The set of runs passes the RCP checker for the GBS used, or is normalized as described
  in `Figure of Merit`_.

**************
 Memory usage
**************

The model state is large compared with accelerator memory, so memory capacity sets the
minimum size of a model replica. At about 16 to 18 bytes per parameter for BF16 weights,
FP32 gradients, FP32 master weights, and AdamW moments, the weights and optimizer state
take about 6.5 to 7.3 TB before activations. This is an estimate, not a measurement. A
distributed optimizer can also shard the optimizer state across data-parallel replicas.
Activation memory grows with the sequence length (8,192) and the micro-batch size, and
is reduced by context parallelism and activation recomputation.

The reference result has 189,471 MiB of HBM3e per GPU and 1.7 TB of host memory per node.
Each 64-GPU model replica therefore has about 12.7 TB (11.6 TiB) of HBM.

.. _mlperf-reference-result:

**********************************************
 Reference result: MLPerf v6.0 entry 6.0-0001
**********************************************

The reference result is MLPerf Training v6.0 entry 6.0-0001, a closed-division submission
by Azure. There is no El Capitan baseline for this benchmark.

.. list-table:: Reference system
    :header-rows: 1

    - - Property
      - Value
    - - System
      - Azure GB200 (128x NVIDIA GB200 NVL72)
    - - Availability
      - Available in the cloud
    - - Nodes
      - 2,048
    - - Accelerators
      - 8,192 NVIDIA Blackwell GPUs (GB200), 4 per node
    - - Accelerator memory
      - 189,471 MiB HBM3e per GPU
    - - Accelerator interconnect
      - NVLink Gen5 (1,800 GB/s) and NVSwitch Gen5
    - - Host processors
      - 2 Neoverse-V2 (72 cores each) per node
    - - Host memory
      - 1.7 TB per node
    - - Host networking
      - 4x ConnectX-8 800 Gb/s Ethernet (MRC) per node
    - - Local storage
      - 5x 3.84 TB + 1x 960 GB NVMe SSD per node

.. list-table:: Reference run configuration
    :header-rows: 1

    - - Parameter
      - Value
    - - Parallelism
      - TP = 4, PP = 8, VP = 8, CP = 2, DP = 128
    - - Global batch size
      - 1,024 sequences (``MINIBS`` = 8, ``MICRO_BATCH_SIZE`` = 1)
    - - Base learning rate
      - 7.11 × 10\ :sup:`-5` (8 × 10\ :sup:`-5` × 1,024 / 1,152)
    - - Warmup and decay steps
      - 9,000 and 1,341,000
    - - Numeric format
      - NVFP4 for linear layers (``FP4_RECIPE=nvfp4``)

.. list-table:: Reference result
    :header-rows: 1

    - - Run
      - Time to train (minutes)
      - Sequences to converge
      - Final log perplexity
    - - 0
      - 7.21
      - 331,776
      - 5.596
    - - 1
      - 6.64
      - 313,344
      - 5.586
    - - 2
      - 7.07
      - 331,776
      - 5.580
    - - **Score**
      - **7.07**
      -
      -

The score is the median of the three runs. Run times are measured from ``run_start`` to
``run_stop`` in the published logs. Initialization, including loading the starting
checkpoint, took 8.5 to 8.7 minutes per run and is not part of the score.

.. _mlperf-performance-projections:

*************************
 Performance projections
*************************

Project the MLPerf Training score (time to train, in minutes) of Llama 3.1 405B on the
proposed system, following the closed-division rules. Report the score as the median of
at least three runs.

.. _mlperf-required-parameters:

Required parameters
-------------------

The following hyperparameters are fixed or derived from the GBS by the MLPerf Training
v6.0 rules:

.. list-table::
    :header-rows: 1

    - - Hyperparameter
      - Required value
    - - Optimizer
      - AdamW, β\ :sub:`1` = 0.9, β\ :sub:`2` = 0.95, ε = 10\ :sup:`-5`, weight decay 0.1
    - - Gradient clipping norm
      - 1.0
    - - Dropout
      - 0.0
    - - Sequence length
      - 8,192
    - - ``global_batch_size``
      - Unconstrained, but must pass the RCP check (see below)
    - - ``opt_base_learning_rate``
      - Set by the GBS: 8 × 10\ :sup:`-5` at 1,152, 16 × 10\ :sup:`-5` at 2,304,
        32 × 10\ :sup:`-5` at 4,608, and 64 × 10\ :sup:`-5` at 9,216
    - - ``opt_end_learning_rate``
      - 8 × 10\ :sup:`-7`
    - - ``opt_learning_rate_warmup_steps``
      - ``ceil(8000 * 1152 / global_batch_size)``
    - - ``opt_learning_rate_decay_steps``
      - ``ceil(1_200_000 * 1152 / global_batch_size) - ceil(8000 * 1152 / global_batch_size)``
    - - Learning rate schedule
      - Linear warmup, then cosine decay
    - - ``opt_init_checkpoint_step``
      - 0
    - - Gradient accumulation steps
      - Unconstrained

The v6.0 RCPs cover GBS values of 1,152, 2,304, and 4,608. Under the MLPerf rules, a GBS
between two RCPs is checked against an interpolated RCP. A GBS smaller than the smallest
RCP is checked against that RCP, and if the check fails, the submitter must supply new
RCPs from the reference implementation. A GBS larger than the largest RCP always needs
new RCPs.

The reference result used GBS 1,024, below the smallest RCP, with a base learning rate of
8 × 10\ :sup:`-5` scaled linearly by 1,024 / 1,152.

System scale
------------

The projection must use at least as many accelerators as the reference result: 8,192. The
reference result's 2,048 nodes are given for context only; the number of accelerators per
node may differ on the proposed system. The number of nodes, accelerators per node, and
parallelism (TP, PP, CP, DP) may be chosen freely, as long as the GBS meets the
requirements above.

.. _mlperf-open-division:

Optional open-division result
-----------------------------

An open-division result may be reported as a secondary, optimized result. It does not
replace the closed-division projection. For each open-division result, describe every
difference from the closed-division rules, such as hyperparameters, model changes, or
initialization time beyond 30 minutes (open division allows up to 4 hours).

Reporting
---------

For each projection, report:

* The score in minutes and the time to train of each run that supports it.
* The node and accelerator counts and the TP, PP, CP, VP, and DP values.
* The GBS, micro-batch size, and learning rate schedule.
* The numeric formats used for weights, activations, gradients, and communication.
* The hardware, system software, framework, communication library and kernel library
  versions, and build options.
* Any source code modifications and how they comply with the `MLPerf Training v6.0
  rules`_.

Identify the measurements used to support each projection and describe the extrapolation
method and its assumptions. When comparing with the reference result, state how the
proposed system's configuration differs from it.

.. _mlperf-moe-acceptance:

*******************************************
 Planned MoE benchmark for acceptance tests
*******************************************

Acceptance testing will add an MoE pretraining benchmark to Llama 3.1
405B, so that sparse expert models are represented as well as dense
transformers. The MoE model will be based on a then-current
LLNS-designated reasonable state-of-the-art MoE architecture. The MoE
pretraining benchmark in MLPerf Training v6.0 and v6.1 does not meet
the benchmark requirements and will not be used.

The model, dataset, quality target, and run rules for the MoE benchmark will be provided
in a later update to this document.

.. _mlperf-appendix:

**********
 Appendix
**********

.. _mlperf-timing:

MLPerf timing details
---------------------

The MLPerf Training rules define the timed region. The clock starts at ``run_start`` and
stops at ``run_stop``, as recorded in the MLPerf log.

.. list-table:: Work included in the FOM
    :header-rows: 1

    - - Included work
      - What it involves
    - - Data access
      - Reading training data. The clock must start before any part of the system
        touches the dataset.
    - - Model training
      - Forward passes, loss calculation, backward passes, gradient clipping, and
        optimizer updates.
    - - Evaluation
      - Each scheduled evaluation on the 5,760 validation sequences, including the one
        that reaches the quality target.
    - - Distributed communication
      - Tensor-, pipeline-, context-, and data-parallel communication during training
        and evaluation.
    - - Excess initialization
      - Any initialization time beyond the allowed maximum (30 minutes in the closed
        division).

.. list-table:: Work excluded from the FOM
    :header-rows: 1

    - - Excluded work
      - What it involves
    - - Initialization
      - Up to 30 minutes of constructing the model, loading the starting checkpoint,
        compiling, and setting up communication, as long as the dataset is not touched.
    - - Data preparation
      - Downloading and pretokenizing the dataset, and converting the checkpoint. Using
        dataset metadata (document counts and sizes) without accessing tokens is also
        allowed outside the timed region.
    - - Final processing
      - Work after the quality target is reached.

The clock cannot be paused during a run.

************
 References
************

* `MLPerf Training v6.0 rules`_ (``mlcommons/training_policies`` at commit
  ``ee11d795cc9cc43dc37b083d252516fa279e0821``, the last revision before v6.1 changes)
* `MLCommons Llama 3.1 405B reference implementation
  <https://github.com/mlcommons/training/tree/master/retired_benchmarks/large_language_model_pretraining/nemo>`__
* `MLPerf Training v6.0 results <https://results.mlcommons.org/training#view=reports&round=v6.0>`__
* `MLPerf Training v6.0 submissions repository <https://github.com/mlcommons/training_results_v6.0>`__
* `MLPerf logging and compliance checker <https://github.com/mlcommons/logging>`__
* A. Grattafiori et al., "The Llama 3 Herd of Models," 2024,
  `arXiv:2407.21783 <https://arxiv.org/abs/2407.21783>`__

.. _MLPerf Training v6.0 rules: https://github.com/mlcommons/training_policies/blob/ee11d795cc9cc43dc37b083d252516fa279e0821/training_rules.adoc
