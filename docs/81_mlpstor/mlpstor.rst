****
MLPerf Storage
****

`MLPerf Storage <https://github.com/mlcommons/storage>`_ is a benchmark suite developed to test storage performance under AI-type workloads. MLPerf Storage is part of the standard ML Commons consortium.


Purpose
=======
Standard parallel high-performance storage benchmarks were written to test HPC workloads, including streaming or random IOs. MLPerf Storage models modern AI workloads for *training* and *checkpointing* in tandem with many-core accelerators -- unique workloads that haven't not been well emulated in legacy benchmarks

Characteristics
===============

MLPerf Storage performs I/O from a specified number of physical client nodes, modeling a specified number of *simulated* accelerators (GPUs) to operate on a chosen synthetic dataset. Different accelerators types may be simulated, such as the Nvidia A100 and H100.

Problems
--------

MLPerf Storage presents multiple workload types that can be tested. FCR runs should be performed for both `Training <https://github.com/mlcommons/storage/blob/main/training/README.md>`_ and `Checkpointing https://github.com/mlcommons/storage/blob/main/checkpointing/README.md`_

For the Training run, respondents should run on the following two models:
* unet3d
* resnet50

For the Checkpointing run, the *default* operation mode should be tested for all shared storage systems. If a node-local storage system is proposed, the *subset* operation mode should be tested as well.

Respondents are required to run an unmodified *Closed* run for each test and *may optionally* run modified *Open* runs, documenting any modifications in the submission.

Figure of Merit
---------------
* Training: For training runs, there are 2 figures of merit: the accelerator utilization (AU) and the total compute time. Both numbers should be reported.

  * AU (percentage) = (total_compute_time/total_benchmark_running_time) * 100
  * total_compute_time = (records_per_file * total_files) / simulated_accelerators / batch_size * computation_time * epochs

* Checkpointing: Two results are reported for Checkpointing tests

  * Duration: Maximum time across all processes
  * Throughput: Minimum throughput across all processes

Note that a Checkpointing submission must include 10 checkpoints written and read along with logs.

Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications. 

Building
========

Installation of MLPerf Storage can be done by following the `Installation Instructions <https://github.com/mlcommons/storage#installation>`_.

Running
=======

.. code-block:: bash

# Perform checkpoint writes  (make sure the number of hosts is WORLD_SIZE/num_processes_per_host)
mlpstorage checkpointing run --model llama3-405b \
  --hosts ip1 ip2 .... \
  --num-processes 512 \
  --num-checkpoints-read 0 \
  --checkpoint-folder ./checkpoint_data1 \
  --results-dir ./mlpstorage_results \
  --client-host-memory-in-gb 64
# Clear the cache (This might require admin access to the system)
... 

# perform checkpoint reads
mlpstorage checkpointing run --model llama3-405b \
  --hosts ip1 ip2 .... \
  --num-processes 512 \
  --num-checkpoints-write 0 \
  --checkpoint-folder ./checkpoint_data1 \
  --results-dir ./mlpstorage_results \
  --client-host-memory-in-gb 64

..

.. code-block:: bash

subset mode (on a single host with 8 simulated accelerators)

# Perform checkpoint writes (data parallelism must match Table 2)
mlpstorage checkpointing run --model llama3-405b \
  --hosts ip1 \
  --num-processes 8 \
  --num-checkpoints-read 0 \
  --checkpoint-folder ./checkpoint_data1 \
  --results-dir ./mlpstorage_results \
  --client-host-memory-in-gb 64
# Clear the cache 
... 
# Perform checkpoint read (data parallelism must match Table 2)
mlpstorage checkpointing run --model llama3-405b \
  --hosts ip1 \
  --num-processes 8 \
  --num-checkpoints-write 0 \
  --checkpoint-folder ./checkpoint_data1 \
  --results-dir ./mlpstorage_results \
  --client-host-memory-in-gb 64

..


Example Scalability Results
===========================


Memory Usage
============


Strong Scaling on El Capitan
============================


Weak Scaling on El Capitan
==========================


References
==========
