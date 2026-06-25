****
MLPerf Storage
****

`MLPerf Storage <https://github.com/mlcommons/storage>`_ is a benchmark suite developed to test storage performance under AI-type workloads. MLPerf Storage is part of the standard ML Commons consortium.


Purpose
=======
Standard parallel high-performance storage benchmarks were written to test HPC workloads, including streaming or random IOs. MLPerf Storage models modern AI workloads for *training*, *inference* and *checkpointing* in tandem with many-core accelerators -- uniqe workloads that haven't not been well emulated in legacy benchmarks

Characteristics
===============

MLPerf Storage performs I/O from a specified number of physical client nodes, modeling a specified number of *simulated* accelerators (GPUs) to operate on a chosen synthetic dataset. Different accelerators types may be simulated, such as the Nvidia A100 and H100.

Problems
--------

FCR runs should include a combination of runs across all three provided synthetic datasets:

* 3D U-Net
* CosmoFlow
* ResNet-50
* LLama-3 (Checkpointing)

Figure of Merit
---------------
For a given number of client nodes, accelerators type and number of simulated accelerators, each run will produce a throughput result, measured in GiB/s, as the main figure of merit. 

Submitted results should include a row for each run configuration, including:

* # clients
* # and size of local storage devices in the compute nodes, if any
* Accerlator type
* # of simulated accelerators
* Synthetic model (3D-Unet, CosmoFlow, ResNet-50)
* Resultant throughput


Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications. 

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


Weak Scaling on El Capitan
==========================


References
==========
