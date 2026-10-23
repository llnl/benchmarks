********
MPI: OMB
********

https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-7.2.tar.gz


Purpose
=======

The OSU Microbenchmarks (OMB) are widely used to measure and evaluate the performance of MPI operations for point-to-point, multi-pair, collective, and one-sided communications.

Characteristics
===============

* Official site: `OSUMB <https://mvapich.cse.ohio-state.edu/static/media/mvapich/README-OMB.txt>`_

Problem
-------

The OSU benchmarks are a suite of microbenchmarks designed to measure network characteristics on HPC systems.

Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications.


Building
========

On GPU enabled systems add these flags to the following configure lines:

.. code-block:: bash

    --enable-cuda
    --with-cuda-include=/path/to/cuda/include
    --with-cuda-libpath=/path/to/cuda/lib

Build and install the benchmarks.

.. code-block:: bash

    ./configure --prefix=$INSTALL_DIR
    make -j
    make -j install


Before configuring make sure your CXX and CC environment variables are set to an
MPI compiler or wrapper.
On most systems this will look like:

.. code-block:: bash

    export CC=mpicc CXX=mpicxx

Special Considerations for Cray Systems
---------------------------------------

HPE-Cray systems may use custom wrappers:

.. code-block:: bash

    export CC=cc CXX=CC

If using ``mpicc`` and ``mpicxx``, note that you may need to add ``-lmpi_gtl_hsa`` or
``-lmpi_gtl_cuda`` at link time in order to get GPU-Aware Cray MPICH. If building the OSU
benchmarks with Spack (recommended), then there is a convenience wrapper package located in the
`Phloem repository <https://github.com/llnl/phloem/blob/2f9c8ce38c14f6eb29b053efcb841c38ecb096cc/var/spack_repo/phloem/packages/cray_mpich_gtl/package.py>`_.

Running
=======

Required: Project the output of `osu_init` for the total number of Host CPU Cores in your SU. You
may use a low-noise configuration, but you must document that configuration and use it for ALL
BENCHMARKS. For example, if you have 96 physical cores, but you have sequestered 12 of them for
noisy system processes, then you would run with 84 processes per node:

.. code-block:: bash

    srun -N 384 -n 32256 osu_init

Not Required: You are encouraged to use the OSU micro-benchmarks to compare against the output of
Phloem as follows:

Latency and Bidirectional Bandwidth:

.. code-block:: bash

    srun -N 1 -n 2 osu_latency
    srun -N 1 -n 2 osu_latency D D
    srun -N 1 -n 2 osu_bibw
    srun -N 1 -n 2 osu_latency D D
    srun -N 2 -n 2 -w host1,host2 osu_latency
    srun -N 2 -n 2 -w host1,host2 osu_latency D D
    srun -N 2 -n 2 -w host1,host2 osu_bibw
    srun -N 2 -n 2 -w host1,host2 osu_latency D D
    srun -N 2 -n 2 -w host1,host9001 osu_latency
    srun -N 2 -n 2 -w host1,host9001 osu_latency D D
    srun -N 2 -n 2 -w host1,host9001 osu_bibw
    srun -N 2 -n 2 -w host1,host9001 osu_latency D D

Barrier

.. code-block:: bash

    srun -N 384 -n 32256 osu_barrier
    srun -N 384 -n 1536 osu_barrier -d openacc

Broadcast

.. code-block:: bash

    srun -N 384 -n 32256 osu_bcast
    srun -N 384 -n 1536 osu_bcast -d openacc

Allreduce

.. code-block:: bash

    srun -N 384 -n 32256 osu_allreduce
    srun -N 384 -n 1536 osu_allreduce -d openacc

Scaling on El Capitan
=====================

References
==========
