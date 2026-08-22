.. raw:: html

   <div class="draft-watermark" aria-hidden="true">DRAFT</div>

**************
MLPerf Storage
**************

`MLPerf Storage <https://github.com/mlcommons/storage/blob/main/docs/README.md>`_ is a benchmark suite developed to test storage performance under AI-type workloads. MLPerf Storage is part of the standard ML Commons consortium.


Purpose
=======
Standard parallel high-performance storage benchmarks were written to test HPC workloads, including streaming sequential or random data. MLPerf Storage models I/O patterns representative of modern AI *training* and *checkpointing* workloads, including how contemporary accelerators might be impacted by a particular storage solution. 

Characteristics
===============

MLPerf Storage tests `Training <https://github.com/mlcommons/storage/blob/main/training/README.md>`_ and `Checkpointing <https://github.com/mlcommons/storage/blob/main/checkpointing/README.md>`_ I/O benchmarks for a given computer vision model, RetinaNet or UNet3D, across one or more client nodes using a specified number of *simulated* accelerators (GPUs) and I/O interface. The general benchmark command syntax is:

.. code-block::

   mlpstorage <closed|open|whatif> <benchmark> <model|algorithm> <command> <file|object> ...

        - The first argument is the *mode*: <open|closed>, allowing or disallowing customizations, respectively. All required FCR submissions will be *closed* runs.
        - The second argument is the benchmark to run: <checkpointing|training>
        - The third argument specifies the synthetic model to use, *RetinaNet* or *UNet3D*
        - The fourth argument denotes the benchmark action to perform: <datasize|datagen|run|configview>
        - The fifth argument specifies the I/O interface to use: <File|S3>
        - Additional parameters are supported to simulate different accelerators types and quantities, file/object counts, and more.

Code Version
------------
Submissions will use version 3.0.46 or later of the MLPerf Storage code:

.. code-block:: bash

   $ git clone https://github.com/mlcommons/storage.git
   cd storage
   $ $ ./mlpstorage version
   3.0.46

Problems
--------

FCR submissions are required to contain results for the following four benchmarks, each adhering to the configuration parameters in the sub-bullets. Respondents are required to perform and submit results for an unmodified *Closed* run for each benchmark and *may optionally* submit results for runs across multiple nodes or for modified *Open* runs, documenting any modifications in the submission.

    1) Training - RetinaNet - file
        - Mode: closed
        - Model: RetinaNet
        - Number of hosts: 1
        - Number of accelerators: 4
        - Accelerator type: b200
        - I/O interface: file
        - Num files: <specified by *datasize* command>
    2) Checkpointing - RetinaNet - file
        - Mode: closed
        - Model: Llama3-8b
        - Number of hosts: 1
        - Number of processes: 8
        - Accelerator type: b200
        - I/O interface: file
    3) Training - RetinaNet - object
        - Mode: closed
        - Model: RetinaNet
        - Number of hosts: 1
        - Number of accelerators: 4
        - Accelerator type: b200
        - I/O interface: object (s3)
        - Num objects: <specified by *datasize* command>
    4) Checkpointing - RetinaNet - object
        - Mode: closed
        - Model: Llama3-8b
        - Number of hosts: 1
        - Number of processes: 8
        - Accelerator type: b200
        - I/O interface: object (s3)


Figures of Merit
----------------

Figures of Merit (FoMs) are printed in the *dlio.log* files in each run's results directory. Those FoMs are identifed by the preceding text, "[METRIC]", as shown below.

* Training: For training runs, there are a total of 5 FoMs that all must be reported:

  * The specified number of simulated accelerators for the run
  * Utilization of the accelerators: :math:`AU\% = (compute\_time_{total}/benchmark\_running\_time_{total}) * 100`.
  * Training throughput 
  * Training I/O Throughput
  * Whether the run meets performance expectations

.. code-block::

    [METRIC] Number of Simulated Accelerators: 4
    [METRIC] Training Accelerator Utilization [AU] (%): 94.4286 (0.4908)
    [METRIC] Training Throughput (samples/second): 1903.7393 (9.8968)
    [METRIC] Training I/O Throughput (MiB/second): 586.3437 (3.0482)
    [METRIC] train_au_meet_expectation: success
..

* Checkpointing: Two results are reported for each Checkpointing test (write, read):

  * The specified number of simulated accelerators for the run
  * Duration: Maximum time across all processes
  * Throughput: Minimum throughput across all processes

.. code-block::

    [METRIC] ==========================================================
    [METRIC] Number of Simulated Accelerators: 8
    [METRIC] Checkpoint save duration (seconds): 47.7386 (0.9589)
    [METRIC] Checkpoint save I/O Throughput (GiB/second): 2.1942 (0.0441)
    [METRIC] ==========================================================
..

Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications. *Baseline* runs are equivalent to MLPerf Storage's *Closed* run mode and do not permit code modifications.

Installation
============

Installation of MLPerf Storage can be done by following the `Installation Instructions <https://github.com/mlcommons/storage#installation>`_.

MLPerf Storage is dependent on a working MPI environment and numerous Python package dependencies. The Python dependencies can generally be automatically installed with the included `setup_env.sh` script. Quick Install directions are:

.. code-block:: bash

  $ git clone https://github.com/mlcommons/storage.git mlp_storage && cd mlp_storage
  $ ./setup_env.sh && source .venv/bin/activate
  $ (mlpstorage) $ 

Running
=======

`Detailed documentation on command line options <https://github.com/mlcommons/storage/blob/main/README.md#cli-structure>` provides information on the various options to the `mlperf_storage` binary; however, sample command lines for the different benchmarks are provided below.

Sample tests provided here were performed under the following software environment:
  * TOSS 4.8 (RHEL 8.10) x86_64
    * kernel v4.18.0-553.144.1
  * Python v3.13.2 
  * OpenMPI 4.1.8
  * Flux resource scheduler

Checkpointing
-------------

    1. Create and initialize a folder for mlpstorage test results. (Only performed once for all benchmarks)
        1. :code:`mkdir -p ${results_dir}`
        2. :code:`mlpstorage init <orgname> ${results_dir}`
    3. Define and create a folder or bucket for checkpoint data I/O.
        1. :code:`mkdir -p ${chkpt_dir}`
    4. Run `mlpstorage` with the pre-defined destinations and parameter values from the `Problems <Problems>` section, along with the amount of system memory on the machine running the test.

*Important*: Caches should be flushed between Write and Read phases of the checkpoint benchmark with :code:`echo 3 > /proc/sys/vm/drop_caches`. If the Checkpointing run is unable to automatically flush the caches, the write and read phases can be run separately to allow a manual clearing. To split phases, specify the :code:`--num-checkpoints-read=0` option for the Write phase and :code:`--num-checkpoints-write=0` for the Read phase.

Sample POSIX File I/O-based Checkpoint test with split phases:

.. code-block:: bash

    # Set up mlpstorage run environment
    (mlpstorage) $ systemname=$(hostname)-file
    (mlpstorage) $ chkpt_dir=/path/to/file system/checkpointing
    (mlpstorage) $ results_dir=$HOME/mlperf_storage_results/ # Different f/s from $datadir
    (mlpstorage) $ mkdir -p ${chkpt_dir}
    (mlpstorage) $ mkdir -p ${results_dir}
    (mlpstorage) $ mlpstorage init $(hostname -d) ${results_dir} # If not done previously

    # Write phase
    (mlpstorage) $ TMPDIR=${chkpt_dir} mlpstorage closed checkpointing run file \
                   --systemname ${systemname} \
                   --client-host-memory-in-gb 502 \
                   --model llama3-8b \
                   --num-processes 8 \
                   --checkpoint-folder ${chkpt_dir} \
                   --results-dir ${results_dir} \
                   --num-checkpoints-read=0

    # Clear the cache (This might require admin access to the system)
    (mlpstorage) $ sudo echo 3 > /proc/sys/vm/drop_caches

    # Read phase
    (mlpstorage) $ TMPDIR=${chkpt_dir} mlpstorage closed checkpointing run file \
                   --systemname ${systemname} \
                   --client-host-memory-in-gb 502 \
                   --model llama3-8b \
                   --num-processes 8 \
                   --checkpoint-folder ${chkpt_dir} \
                   --results-dir ${results_dir} \
                   --num-checkpoints-write=0

..

Sample S3 Object I/O-based Checkpoint test with split phases:

.. code-block:: bash

    # Set up AWS environment and pre-create bucket (if necessary)
    (mlpstorage) $ export AWS_ACCESS_KEY_ID=<access key id>
    (mlpstorage) $ export AWS_SECRET_ACCESS_KEY==<secret access key>
    (mlpstorage) $ export AWS_ENDPOINT_URL=https://<s3.domain>
    (mlpstorage) $ export BUCKET=mlp-storage
    (mlpstorage) $ aws s3api create-bucket --bucket ${BUCKET}

    # Set up mlpstorage run environment
    (mlpstorage) $ systemname=$(hostname)-s3
    (mlpstorage) $ chkpt_bkt="s3://${BUCKET}" # s3:// prefix is necessary
    (mlpstorage) $ results_dir=$HOME/mlperf_storage_results/ # Different f/s from $datadir
    (mlpstorage) $ mkdir -p ${results_dir}
    (mlpstorage) $ mlpstorage init $(hostname -d) ${results_dir} # If not done previously

    # Write phase
    (mlpstorage) $ mlpstorage closed checkpointing run object \
                   --systemname ${systemname} \
                   --client-host-memory-in-gb 502 \
                   --model llama3-8b \
                   --num-processes 8 \
                   --checkpoint-folder ${chkpt_bkt} \
                   --results-dir ${results_dir} \
                   --num-checkpoints-read=0

    # Clear the cache (This might require admin access to the system)
    (mlpstorage) $ sudo echo 3 > /proc/sys/vm/drop_caches

    # Read phase
    (mlpstorage) $ mlpstorage closed checkpointing run object \
                   --systemname ${systemname} \
                   --client-host-memory-in-gb 502 \
                   --model llama3-8b \
                   --num-processes 8 \
                   --checkpoint-folder ${chkpt_bkt} \
                   --results-dir ${results_dir} \
                   --num-checkpoints-write=0

..

Training
-------------

Running the Training benchmark is a 3-stage process, with each stage requiring a sub-command with certain parameters. Those sub-commands are:
    1. `datasize`: Determine the problem size 
    2. `datagen`: Generate the training data
    3. `run`: Simulate training the data on accelerators


    1. Create and initialize a folder for mlpstorage test results. (Only performed once for all benchmarks)
        1. :code:`mkdir -p ${results_dir}`
        2. :code:`mlpstorage init <orgname> ${results_dir}`
    3. Define and create a folder or bucket for checkpoint data I/O.
        1. :code:`mkdir -p ${chkpt_dir}`
    4. Run `mlpstorage` with the pre-defined destinations and parameter values from the `Problems <Problems>` section, along with the amount of system memory on the machine running the test.

*Important*: Caches should be flushed between Write and Read phases of the checkpoint benchmark with :code:`echo 3 > /proc/sys/vm/drop_caches`. If the Checkpointing run is unable to automatically flush the caches, the write and read phases can be run separately to allow a manual clearing. To split phases, specify the :code:`--num-checkpoints-read=0` option for the Write phase and :code:`--num-checkpoints-write=0` for the Read phase.

Sample POSIX File I/O-based Training run:

.. code-block:: bash

    # Set up mlpstorage run environment
    (mlpstorage) $ systemname=$(hostname)-file
    (mlpstorage) $ data_dir=/path/to/file system/training
    (mlpstorage) $ results_dir=$HOME/mlperf_storage_results/ # Different f/s from $datadir
    (mlpstorage) $ mkdir -p ${data_dir}
    (mlpstorage) $ mkdir -p ${results_dir} 
    (mlpstorage) $ mlpstorage init $(hostname -d) ${results_dir} # If not done previously

    # Run datasize command to determine size of dataset to generate 
    (mlpstorage) $ mlpstorage closed training retinanet datasize \
                   --hosts 127.0.0.1 \
                   --client-host-memory-in-gb 252 \
                   --num-client-hosts 1 \
                   --max-accelerators 4 \
                   --accelerator-type b200 \
                   --systemname ${systemname} \
                   --results-dir ${resultsdir}

    # Run datagen command to generate dataset
    (mlpstorage) $ mlpstorage closed training retinanet datagen file \
                   --hosts 127.0.0.1 \
                   --client-host-memory-in-gb 252 \
                   --num-client-hosts 1 \
                   --max-accelerators 4 \
                   --accelerator-type b200 \
                   --systemname ${systemname} \
                   --results-dir ${resultsdir}

    # Clear the cache (This might require admin access to the system)
    (mlpstorage) $ sudo echo 3 > /proc/sys/vm/drop_caches

    # Execute the training run
    (mlpstorage) $ mlpstorage closed training retinanet run file \
                   --hosts 127.0.0.1 \
                   --client-host-memory-in-gb 252 \
                   --num-client-hosts 1 \
                   --max-accelerators 4 \
                   --accelerator-type b200 \
                   --systemname ${systemname} \
                   --results-dir ${resultsdir}

..

Sample S3 Object I/O-based Checkpoint test with split phases:

.. code-block:: bash

    # Set up AWS environment and pre-create bucket (if necessary)
    (mlpstorage) $ export AWS_ACCESS_KEY_ID=<access key id>
    (mlpstorage) $ export AWS_SECRET_ACCESS_KEY==<secret access key>
    (mlpstorage) $ export AWS_ENDPOINT_URL=https://<s3.domain>
    (mlpstorage) $ export BUCKET=mlp-storage
    (mlpstorage) $ aws s3api create-bucket --bucket ${BUCKET}

    # Set up mlpstorage run environment
    (mlpstorage) $ systemname=$(hostname)-s3
    (mlpstorage) $ chkpt_bkt="s3://${BUCKET}" # s3:// prefix is necessary
    (mlpstorage) $ results_dir=$HOME/mlperf_storage_results/ # Different f/s from $datadir
    (mlpstorage) $ mkdir -p ${results_dir} # If not done previously
    (mlpstorage) $ mlpstorage init $(hostname -d) ${results_dir} # If not done previously

    # Write phase
    (mlpstorage) $ mlpstorage closed checkpointing run object \
                   --systemname ${systemname} \
                   --client-host-memory-in-gb 502 \
                   --model llama3-8b \
                   --num-processes 8 \
                   --checkpoint-folder ${chkpt_bkt} \
                   --results-dir ${results_dir} \
                   --num-checkpoints-read=0

    # Clear the cache (This might require admin access to the system)
    (mlpstorage) $ sudo echo 3 > /proc/sys/vm/drop_caches

    # Read phase
    (mlpstorage) $ mlpstorage closed checkpointing run object \
                   --systemname ${systemname} \
                   --client-host-memory-in-gb 502 \
                   --model llama3-8b \
                   --num-processes 8 \
                   --checkpoint-folder ${chkpt_bkt} \
                   --results-dir ${results_dir} \
                   --num-checkpoints-write=0

..

Example Scalability Results
===========================


Memory Usage
============


References
==========
