********
ScaFFold
********

ScaFFold is the Scale-free Fractal benchmark for deep learning.

The ScaFFold problem description and source are near-final.

Full source code and documentation is available on `GitHub <https://github.com/LBANN/ScaFFold>`_.

.. important:: ScaFFold supports configurable problem sizes.
               This benchmark is for *one* particular configuration (although others may be useful for prototyping).

Purpose
=======

ScaFFold is a proxy application and benchmark representative of deep learning surrogate models that are trained on large, high-resolution, three-dimensional numerical simulations.
It is meant to support benchmarking at a variety of system scales and be adaptable to future deep learning systems innovations.
ScaFFold exercises much of the deep learning systems stack: I/O, compute, fine- and coarse-grained communication, and their integration in a framework.

Characteristics
===============

ScaFFold trains a 3D U-Net to perform semantic segmentation on a synthetic dataset composed of 3D volumes containing different classes of fractals.
The size of the problem is controlled by a *scale* parameter, which varies the size and complexity of the volumes and the depth of the U-Net.
The scale parameter is exponential: each increase roughly doubles the problem size; e.g., a scale 7 problem has a volume size of :math:`128^3` for each sample.
Using fractals enables large datasets to be generated in-situ (rather than distributed) while ensuring a complex yet tractable semantic segmentation problem.

The model is trained from a random initialization until convergence, which is defined to be a validation Dice score of at least 0.95.

Problems
--------

The task is a ScaFFold training problem of scale 11.
The benchmark configuration is to otherwise use the default values, subject to the source code modifications below.

Figure of Merit
---------------

The Figure of Merit is the time (in seconds) to train the ScaFFold model to convergence (validation Dice score of at least 0.95), inclusive of all I/O and other overheads (but excluding dataset generation).

Source code modifications
=========================

See :ref:`GlobalRunRules` for general guidance on allowed modifications. For ScaFFold, we permit the following modifications:
* Hyperparameters (e.g., learning rate) may be changed.
* The datatypes used may be changed.

We also explicitly note the following constraints:
* The training framework must be PyTorch.
* The train/validation data split may not be changed, nor may other data generation parameters.
* The random seed may not be fixed.

Building
========

See the `ScaFFold README <https://github.com/LBANN/ScaFFold/blob/main/README.md#setup>`_ for build and setup instructions.

Running
=======

See the `ScaFFold README <https://github.com/LBANN/ScaFFold/blob/main/README.md#running-the-benchmark>`_ for full documentation.

In short, a benchmark run configuration file is first defined.

Then the synthetic dataset is generated in advance::

  scaffold generate_fractals -c /path/to/config.yml

Once the dataset is generated, the benchmark can be run::

  scaffold benchmark -c /path/to/config.yml

Validation
==========

The training is considered successful if the validation Dice score is at least 0.95.
ScaFFold will report this after each training epoch.

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
