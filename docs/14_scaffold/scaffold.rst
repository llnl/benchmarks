##########
 ScaFFold
##########

ScaFFold is the Scale-free Fractal benchmark for deep learning.

The ScaFFold problem description and source are near-final.

Full source code and documentation is available on `GitHub
<https://github.com/LBANN/ScaFFold>`_.

.. important::

    ScaFFold supports configurable problem sizes. This benchmark is for *one* particular
    configuration (although others may be useful for prototyping).

*********
 Purpose
*********

ScaFFold is a proxy application and benchmark representative of deep learning surrogate
models that are trained on large, high-resolution, three-dimensional numerical
simulations. It is meant to support benchmarking at a variety of system scales and be
adaptable to future deep learning systems innovations. ScaFFold exercises much of the
deep learning systems stack: I/O, compute, fine- and coarse-grained communication, and
their integration in a framework.

*****************
 Characteristics
*****************

ScaFFold trains a 3D U-Net to perform semantic segmentation on a synthetic dataset
composed of 3D volumes containing different classes of fractals. The size of the problem
is controlled by a *scale* parameter, which varies the size and complexity of the
volumes and the depth of the U-Net. The scale parameter is exponential: each increase
roughly doubles the problem size; e.g., a scale 7 problem has a volume size of
:math:`128^3` for each sample. Using fractals enables large datasets to be generated
in-situ (rather than distributed) while ensuring a complex yet tractable semantic
segmentation problem.

The model is trained from a random initialization until convergence, which is defined to
be a validation Dice score of at least 0.95.

Problems
========

The task is a ScaFFold training problem of scale 11. The benchmark configuration is to
otherwise use the default values, subject to the source code modifications below.

Figure of Merit
===============

The Figure of Merit is the time (in seconds) to train the ScaFFold model to convergence
(validation Dice score of at least 0.95), inclusive of all I/O and other overheads (but
excluding dataset generation). Note that since the FOM depends on convergence, a given
FOM is specific to multiple problem and learning rate specification parameters. For
example, a FOM from a run at ``target_dice=0.9`` is not comparable to a FOM from a run
at ``target_dice=0.95``.

FOM constraints:

- The current requirements for parameters that cannot be varied for comparable FOMs is
  logged directly after the FOM is printed in the benchmark.
- FOM's must be reported as the median from at least 3 different ``seed``
  configurations.

***************************
 Source code modifications
***************************

See :ref:`GlobalRunRules` for general guidance on allowed modifications. For ScaFFold,
we permit the following modifications:

- In ``ScaFFold/configs/benchmark_default.yml``, any "External/user-facing" parameters
  may be freely changed.
- Changes to "External problem specification" and "External learning rate specification"
  from ``ScaFFold/configs/benchmark_default.yml`` may impact convergence and results may
  be incomparable to the baseline data we provide.
- The datatypes used may be changed.

We also explicitly note the following constraints:

- The training framework must be PyTorch.
- In the config ``ScaFFold/configs/benchmark_default.yml``, Parameters marked
  "Internal/dev use only" may not be changed.
- The random seed may not be fixed.

**********
 Building
**********

See the `ScaFFold README
<https://github.com/LBANN/ScaFFold/blob/main/README.md#setup>`__ for build and setup
instructions.

*********
 Running
*********

See the `ScaFFold README
<https://github.com/LBANN/ScaFFold/blob/main/README.md#running-the-benchmark>`__ for
full documentation.

In short, a benchmark run configuration file is first defined.

Then the synthetic dataset is generated in advance:

::

    scaffold generate_fractals -c /path/to/config.yml

Once the dataset is generated, the benchmark can be run:

::

    scaffold benchmark -c /path/to/config.yml

****************
 Run Parameters
****************

These are the parameters from ``ScaFFold/configs/benchmark_default.yml`` that are used
for the baseline data, aside from the "Internal/dev use only" parameters which should
not be modified.

- n_categories = 5
- n_instances_used_per_fractal: 145
- optimizer: "ADAM"
- starting_learning_rate: 0.001
- min_learning_rate: 0.0001
- T_0: 100
- T_mult: 2

The following are the ``unet_bottleneck_dim`` values that should be used at each
``problem_scale``

.. list-table::
    :header-rows: 1

    - - problem_scale
      - unet_bottleneck_dim
    - - 7
      - 3
    - - 8
      - 3
    - - 9
      - 4
    - - 10
      - 5
    - - 11
      - 6
    - - 12
      - 7

************
 Validation
************

The training is considered successful if the validation Dice score is at least 0.95.
ScaFFold will report this after each training epoch.

*****************************
 Example Scalability Results
*****************************

**************
 Memory Usage
**************

******************************
 Strong Scaling on El Capitan
******************************

Perform strong scaling by decreasing ``local_batch_size`` by 2x for each 2x increase in
resources. For example, if the highest number of resources is 1024 ranks,
``local_batch_size=1``. Then at 512 ranks, run ``local_batch_size=2``,
``local_batch_size=4`` for 256 ranks, etc. This will result in a constant global batch
size.

Keep the sharding configuration constant for a given scaling study, otherwise the global
batch size will vary.

****************************
 Weak Scaling on El Capitan
****************************

Perform weak scaling by keeping the ``local_batch_size`` parameter constant as the
number of resources increases. This results in the global batch size increasing by 2x
for each 2x increase in resources.

Keep the sharding configuration constant for a given scaling study, otherwise the global
batch size will vary.

************
 References
************
