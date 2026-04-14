******
MiniEM
******

This is the documentation for the Future Computing Resource (FCR) FY30
Benchmark MiniEM. The content herein was created by the following
authors (in alphabetical order).

- `Anthony M. Agelastos <mailto:amagela@sandia.gov>`_
- `James J. Elliott <mailto:jjellio@sandia.gov>`_
- `Christian A. Glusa <mailto:caglusa@sandia.gov>`_
- `Roger P. Pawlowski <mailto:rppawlo@sandia.gov>`_

This material is based upon work supported by the Sandia National Laboratories
(SNL), a multimission laboratory managed and operated by National Technology and
Engineering Solutions of Sandia under the U.S. Department of Energy's National
Nuclear Security Administration under contract DE-NA0003525. Content herein
considered unclassified with unlimited distribution under SAND2023-01069O.


Purpose
=======

MiniEM solves a first order formulation of Maxwell's equations of
electromagnetics. MiniEM is the [Trilinos]_ proxy driver for the
electromagnetics sub-problem solved by EMPIRE and exercises the relevant
Trilinos components (i.e., Tpetra, Belos, MueLu, Ifpack2, Intrepid2, Panzer).


Characteristics
===============

The goal is to utilize the specified version of MiniEM (see
:ref:`SPARTAApplicationVersion`) that runs the benchmark problem (see
:ref:`SPARTAProblem`) correctly (see :ref:`SPARTACorrectness` if
changes are made to SPARTA).


Problems
--------

Figure of Merit
---------------


Source code modifications
=========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications. 


Building
========

MiniEM and Trilinos prefer static versus dynamic linking for its
third-party libraries. Instructions for two systems will be provided
below. The first is for the Hops system whose compute nodes have two
Intel Xeon Sapphire Rapids processors each and a total of four Nvidia
H100 GPUs.


Hops
----

TPLs
^^^^

.. code-block:: sh

   git clone git@github.com:spack/spack
   git checkout v0.23.0

   spack env create miniem-hops-env
   spack cd -e miniem-hops-env
   spacktivate -p miniem-hops-env

   spack compiler find

   spack external find curl
   spack external find openssl
   spack external find openmpi
   spack external find gettext
   spack external find ncurses
   spack external find perl
   spack external find m4

   spack add ninja
   spack add cmake
   spack add yaml-cpp
   spack add blas
   spack add lapack
   spack add hdf5@1.10.9 api=v110
   spack add parallel-netcdf@1.12.3
   spack add netcdf-c@4.9+mpi+parallel-netcdf~szip~blosc~zstd

   spack concretize
   spack install


MiniEM
^^^^^^

#!/bin/bash

# This is set in the load_spack_cuda.sh file.

.. code-block:: sh

   export OMPI_CXX=$BUILD_BASE_DIR/Trilinos/packages/kokkos/bin/nvcc_wrapper
   rm -rf CMake*
   cmake \
   -D Teuchos_ENABLE_DEBUG_RCP_NODE_TRACING=OFF \
   -G Ninja \
   -D Trilinos_ENABLE_Fortran:BOOL=OFF \
   -D PYTHON_EXECUTABLE:FILEPATH=python3 \
   -D CMAKE_INSTALL_PREFIX="$BUILD_BASE_DIR/install-trilinos" \
   -D Trilinos_ENABLE_EXPLICIT_INSTANTIATION:BOOL=ON \
   -D CMAKE_CXX_STANDARD="20" \
   -D Trilinos_ENABLE_CHECKED_STL:BOOL=OFF \
   -D Trilinos_ENABLE_TEUCHOS_TIME_MONITOR:BOOL=ON \
   -D Panzer_ENABLE_TEUCHOS_TIME_MONITOR:BOOL=ON \
   -D NOX_ENABLE_TEUCHOS_TIME_MONITOR:BOOL=ON \
   -D NOX_BUILD_PRERELEASE=ON \
   \
   -D NOX_ENABLE_TESTS=OFF \
   -D NOX_ENABLE_EXAMPLES=OFF \
   \
   -D Trilinos_ENABLE_INSTALL_CMAKE_CONFIG_FILES:BOOL=ON \
   -D Trilinos_ENABLE_ALL_PACKAGES:BOOL=OFF \
   -D Trilinos_ENABLE_ALL_OPTIONAL_PACKAGES:BOOL=OFF \
   -D Trilinos_ENABLE_EXAMPLES:BOOL=OFF \
   -D Trilinos_ENABLE_TESTS:BOOL=OFF \
   -D EpetraExt_ENABLE_HDF5:BOOL=OFF \
   -D Teuchos_ENABLE_FLOAT:BOOL=OFF \
   -D Teuchos_ENABLE_COMPLEX:BOOL=OFF \
   -D Teuchos_KOKKOS_PROFILING:BOOL=ON \
   -D Kokkos_ENABLE_PROFILING:BOOL=ON \
   -D Tpetra_INST_FLOAT:BOOL=OFF \
   -D Tpetra_INST_COMPLEX_FLOAT:BOOL=OFF \
   -D Tpetra_INST_COMPLEX_DOUBLE:BOOL=OFF \
   -D Tpetra_INST_INT_INT:BOOL=OFF \
   -D Xpetra_ENABLE_Epetra:BOOL=OFF \
   -D MueLu_ENABLE_Epetra:BOOL=OFF \
   -D Piro_ENABLE_MueLu:BOOL=OFF \
   -D SEACASExodus_ENABLE_MPI:BOOL=OFF \
   -D Trilinos_ENABLE_SEACASExodiff=ON \
   -D Trilinos_ENABLE_SEACASEpu=ON \
   -D Trilinos_ENABLE_SEACASNemspread=ON \
   -D Trilinos_ENABLE_SEACASNemslice=ON \
   -D Trilinos_ENABLE_SEACASAprepro:BOOL=ON \
   -D Trilinos_ENABLE_KokkosCore:BOOL=ON \
   -D Trilinos_ENABLE_KokkosAlgorithms:BOOL=ON \
   -D Trilinos_ENABLE_Tempus:BOOL=OFF \
   -D Trilinos_ENABLE_Zoltan2:BOOL=ON \
   -D Trilinos_ENABLE_Xpetra=ON \
   -D Trilinos_ENABLE_MueLu:BOOL=ON \
   -D MueLu_ENABLE_Kokkos_Refactor:BOOL=ON \
   -D Xpetra_ENABLE_Kokkos_Refactor:BOOL=ON \
   -D MueLu_ENABLE_Kokkos_Refactor_Use_By_Default:BOOL=ON \
   -D Trilinos_ENABLE_Ifpack2:BOOL=ON \
   -D Trilinos_ENABLE_Amesos2:BOOL=ON \
   -D Amesos2_ENABLE_LAPACK:BOOL=ON \
   -D Amesos2_ENABLE_KLU2:BOOL=ON \
   -D Trilinos_ENABLE_Pamgen:BOOL=ON \
   -D Intrepid2_ENABLE_TESTS=OFF \
   -D Phalanx_SHOW_DEPRECATED_WARNINGS:BOOL=ON \
   -D Phalanx_ENABLE_DEVICE_DAG=OFF \
   -D Phalanx_ENABLE_TESTS=OFF \
   -D Trilinos_ENABLE_Panzer:BOOL=ON \
   -D Trilinos_ENABLE_PanzerExprEval=ON \
   -D Sacado_ENABLE_HIERARCHICAL_DFAD=ON \
   -D Panzer_ENABLE_HESSIAN_SUPPORT:BOOL=OFF \
   -D Panzer_ENABLE_TESTS:BOOL=OFF \
   -D Panzer_ENABLE_EXAMPLES:BOOL=OFF \
   -D Trilinos_ENABLE_Percept=ON \
   -D Trilinos_ENABLE_SECONDARY_TESTED_CODE:BOOL=ON \
   -D Trilinos_ENABLE_TriKota:BOOL=OFF \
   -D TPL_ENABLE_MPI:BOOL=ON \
   -D MPI_EXEC_POST_NUMPROCS_FLAGS="-bind-to;None" \
   -D TPL_ENABLE_Boost:BOOL=OFF \
   -D TPL_ENABLE_HDF5:BOOL=ON \
   -D HDF5_INCLUDE_DIRS="$(spack location -i hdf5)/include" \
   -D HDF5_LIBRARY_DIRS="$(spack location -i hdf5)/lib64" \
   -D TPL_ENABLE_Zlib:BOOL=ON \
   -D TPL_ENABLE_Netcdf:BOOL=ON \
   -DTPL_ENABLE_Matio=OFF \
   -DTPL_ENABLE_X11=OFF \
   -D CMAKE_CXX_COMPILER:FILEPATH="mpicxx" \
   -D CMAKE_C_COMPILER:FILEPATH="mpicc" \
   -D CMAKE_Fortran_COMPILER:FILEPATH="mpifort" \
   -D CMAKE_CXX_FLAGS:STRING="-g1 -Wshadow -Wall -fdiagnostics-color=always -Wno-deprecated-declarations" \
   -D CMAKE_C_FLAGS:STRING="-g1" \
   -D CMAKE_Fortran_FLAGS:STRING="-g1" \
   -D CMAKE_EXE_LINKER_FLAGS:STRING="-lgfortran" \
   -D CMAKE_VERBOSE_MAKEFILE:BOOL=OFF \
   -D Trilinos_VERBOSE_CONFIGURE:BOOL=OFF \
   -D CMAKE_BUILD_TYPE:STRING=Release \
   -D Trilinos_ENABLE_DEBUG=OFF \
   -D Trilinos_ENABLE_DEBUG_SYMBOLS:BOOL=OFF \
   -D Kokkos_ENABLE_DEBUG:BOOL=OFF \
   -D Phalanx_ENABLE_DEBUG=OFF \
   -D BUILD_SHARED_LIBS:BOOL=OFF \
   -D Trilinos_ENABLE_COVERAGE_TESTING:BOOL=OFF \
   -D Trilinos_ENABLE_OpenMP:BOOL=OFF \
   -D Tpetra_ENABLE_CUDA=ON \
   -D Tpetra_INST_CUDA=ON \
   -D Tpetra_INST_SERIAL=ON \
   -D TPL_ENABLE_CUDA=ON \
   -D TPL_ENABLE_CUSPARSE=ON \
   -D CUDA_cublas_LIBRARY=${CUDA_LIBS}/libcublas.so \
   -D CUDA_cusparse_LIBRARY=${CUDA_LIBS}/libcusparse.so \
   -D CUDA_cusolver_LIBRARY=${CUDA_LIBS}/libcusolver.so \
   -D CUDA_cufft_LIBRARY=${CUDA_LIBS}/libcufft.so \
   -D Kokkos_ENABLE_CUDA=ON \
   -D Kokkos_ENABLE_DEBUG_BOUNDS_CHECK=OFF \
   -D Kokkos_ENABLE_CUDA_RELOCATABLE_DEVICE_CODE=ON \
   -D Kokkos_ARCH_HOPPER90=ON \
   \
   -D Trilinos_PARALLEL_LINK_JOBS_LIMIT=12 \
   \
   -D TPL_ENABLE_HDF5=ON \
   -D TPL_ENABLE_Netcdf:BOOL=ON \
   \
   -D Trilinos_AUTOGENERATE_TEST_RESOURCE_FILE=OFF \
   -D Trilinos_CUDA_NUM_GPUS=4 \
   -D Trilinos_CUDA_SLOTS_PER_GPU=3 \
   \
   -D Panzer_ADD_EXPENSIVE_CUDA_TESTS=ON \
   \
   $BUILD_BASE_DIR/Trilinos



El Capitan
----------


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

.. [Trilinos] M. A. Heroux and R. A. Bartlett and V. E. Howle and R. J. Hoekstra
              and J. J. Hu and T. G. Kolda and R. B. Lehoucq and K. R. Long
              and R. P. Pawlowski and E. T. Phipps and A. G. Salinger and H. K.
              Thornquist and R. S. Tuminaro and J. M. Willenbring and A.
              Williams and K. S. Stanley, 'An Overview of the Trilinos Project',
              2005, ACM Trans. Math. Softw., Volume 31, No. 3, ISSN 0098-3500.
.. [TrilinosBuild] R. A. Bartlett, 'Trilinos Configure, Build, Test, and Install
                   Reference Guide', 2023. [Online]. Available:
                   https://docs.trilinos.org/files/TrilinosBuildReference.html.
                   [Accessed: 26- Mar- 2023]
.. [Maxwell-Large] Trilinos developers, 'maxwell-large.xml', 2024. [Online]. Available: https://github.com/trilinos/Trilinos/blob/master/packages/panzer/mini-em/example/BlockPrec/maxwell-large.xml. [Accessed: 22- Feb- 2024]
.. [Maxwell-AnalyticSolution] Trilinos developers, 'maxwell-analyticSolution.xml', 2024. [Online]. Available: https://github.com/trilinos/Trilinos/blob/master/packages/panzer/mini-em/example/BlockPrec/maxwell-analyticSolution.xml. [Accessed: 22- Feb- 2024]
.. [Intel-8260] Intel. 'Intel Xeon Platinum 8260 Processor 35.75M Cache 2.40 GHz Product Specifications', 2024. [Online]. Available: https://ark.intel.com/content/www/us/en/ark/products/192474/intel-xeon-platinum-8260-processor-35-75m-cache-2-40-ghz.html. [Accessed: 18- Mar- 2024]
