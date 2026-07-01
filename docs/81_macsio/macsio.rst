******
MACSio
******


Purpose
=======
`MACSio <https://github.com/llnl/MACSio>`_ will emulate the HDF5 Write/Read patterns used by many multi-physics codes. It can be used to test and evaluate performance with different data models, I/O library interfaces and parallel I/O paradigms.

Characteristics
===============

Problems
--------

To best test LLNL multi-physics codes MACSio will be used to perform HDF5 I/O using MPI in a file-per-process (FPP) I/O pattern.

Figure of Merit
--------------


Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications. 

Building
========

Installation instructions for MACSio code are available at `https://github.com/llnl/MACSio>`. Per that page, it recommends building with `Spack <https://spack.readthedocs.io>`_, but the code may be build manually per `https://github.com/llnl/MACSio/blob/master/INSTALLING.md>`.

#. Download and install `json-cwx <https://github.com/LLNL/json-cwx>`_: json-c with extensions
#. Download and install `Silo <https://github.com/llnl/Silo.git>`_
#. Create a build directory

.. code:: bash

   % mkdir build
   % cd build

#. Use CMake to build MACSio and any of the desired plugins (builds with silo by default)

.. code:: bash

      % cmake -DCMAKE_INSTALL_PREFIX=[desired-install-location] -DWITH_JSON-CWX_PREFIX=[path to json-cwx] -DWITH_SILO_PREFIX=[path to silo] -DENABLE_HDF5_PLUGIN=ON -DWITH_HDF5_PREFIX=[path to HDF5] ..
      % make
      % make install

* Additional plugins are available to build into MACSio, per the website.

Running
=======

MACSio can be run with multiple options affecting file layout, interface, and more. For the FCR benchmarks, the following tests should be run:

* FPP-HDF5, 512 processes, 1MB request size, 128 files

.. code-block:: bash

 $ mpirun -np 128 macsio --interface hdf5 --parallel_file_mode MIF 8 --part_size 10M 128

..

Validation
==========

MACSio runs are logged, producing two files with standard logging

* macsio-log.log: Summary of run stages with bandwidth and timings
* macsio-timings.log: Detailed per-process metrics


Example Scalability Results
===========================


Memory Usage
============


References
==========
