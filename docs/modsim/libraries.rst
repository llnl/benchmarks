.. _libraries:

Appendix: Building Libraries
============================

When building without Spack, use the following commands to build the
libraries.

.. _library-adiak:

Adiak
^^^^^

.. code-block:: bash

    git clone --branch v0.5.0 --recurse-submodules https://github.com/LLNL/Adiak
    cd Adiak
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${ADIAK_INSTALL_PREFIX}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DMPI_C_COMPILER="${MPICC}" -DMPI_CXX_COMPILER="${MPICXX}" \
        -DENABLE_MPI=ON \
        -DBUILD_SHARED_LIBS=ON
    make -C build -j
    make -C build install

.. _library-caliper:

Caliper
^^^^^^^

.. code-block:: bash

    git clone --branch master --recurse-submodules https://github.com/LLNL/Caliper.git
    cd Caliper
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${CALIPER_INSTALL_PREFIX}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${HIPCC}" \
        -DCMAKE_HIP_COMPILER="${ROCM_PATH}/llvm/bin/amdclang++" \
        -DWITH_MPI=ON \
        -DMPI_C_COMPILER="${MPICC}" -DMPI_CXX_COMPILER="${MPICXX}" \
        -DWITH_ROCM=ON -DROCM_PATH="${ROCM_PATH}/llvm" \
        -Drocprofiler-sdk_DIR="${ROCM_PATH}/lib/cmake/rocprofiler-sdk" \
        -Drocprofiler-sdk-roctx_DIR="${ROCM_PATH}/lib/cmake/rocprofiler-sdk-roctx" \
        -DHIP_ROOT_DIR="${ROCM_PATH}" -DCMAKE_HIP_ARCHITECTURES="${ROCM_ARCH}" \
        -DWITH_ROCPROFILER=ON \
        -DWITH_ADIAK=ON \
        -Dadiak_DIR="${ADIAK_INSTALL_PREFIX}/lib/cmake/adiak"
    make -C build -j
    make -C build install

or

.. code-block:: bash

    git clone --branch master --recurse-submodules https://github.com/LLNL/Caliper.git
    cd Caliper
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${CALIPER_INSTALL_PREFIX}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_CUDA_COMPILER="${NVCC}" \
        -DWITH_MPI=ON \
        -DMPI_C_COMPILER="${MPICC}" -DMPI_CXX_COMPILER="${MPICXX}" \
        -DCMAKE_CUDA_ARCHITECTURES="${CUDA_ARCH}" -DWITH_CUPTI=ON -DWITH_NVTX=ON \
        -DWITH_ADIAK=ON \
        -Dadiak_DIR="${ADIAK_INSTALL_PREFIX}/lib/cmake/adiak"
    make -C build -j
    make -C build install

Set the ``CALI_CONFIG`` environment variable at runtime to generate the Caliper desired timings:

e.g., for HIP, MPI and CPU profiling, use:

.. code-block:: bash

    export CALI_CONFIG="spot(profile.hip,profile.mpi,time.exclusive)"

and for CUDA, MPI and CPU profiling, use:

.. code-block:: bash

    export CALI_CONFIG="spot(profile.cuda,profile.mpi,time.exclusive)"

.. _library-fmt:

fmt
^^^

.. code-block:: bash

    git clone --branch 12.1.0 --recurse-submodules https://github.com/fmtlib/fmt.git
    cd fmt
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${FMT_INSTALL_PREFIX}" \
        -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_CXX_STANDARD=11
    make -C build -j
    make -C build install

.. _library-camp:

camp
^^^^

.. code-block:: bash

    git clone --branch v2026.07.2 --recurse-submodules https://github.com/LLNL/camp.git
    cd camp
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${CAMP_INSTALL_PREFIX}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_HIP_COMPILER="${ROCM_PATH}/llvm/bin/clang++" \
        -DENABLE_HIP=ON -DCMAKE_HIP_ARCHITECTURES="${ROCM_ARCH}" \
        -DROCM_PATH="${ROCM_PATH}/llvm"
    make -C build -j
    make -C build install

or

.. code-block:: bash

    git clone --branch v2026.07.2 --recurse-submodules https://github.com/LLNL/camp.git
    cd camp
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${CAMP_INSTALL_PREFIX}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_CUDA_COMPILER="${NVCC}" \
        -DENABLE_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="${CUDA_ARCH}"
    make -C build -j
    make -C build install

.. _library-umpire:

Umpire
^^^^^^

.. code-block:: bash

    git clone --branch v2026.07.2 --recurse-submodules https://github.com/LLNL/Umpire.git
    cd Umpire
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${UMPIRE_INSTALL_PREFIX}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_HIP_COMPILER="${ROCM_PATH}/llvm/bin/amdclang++" \
        -Dcamp_DIR="${CAMP_INSTALL_PREFIX}" \
        -Dfmt_DIR="${FMT_INSTALL_PREFIX}" \
        -DENABLE_MPI=ON \
        -DMPI_C_COMPILER="${MPICC}" -DMPI_CXX_COMPILER="${MPICXX}" \
        -DENABLE_HIP=ON -DCMAKE_HIP_ARCHITECTURES="${ROCM_ARCH}" \
        -DROCM_PATH="${ROCM_PATH}/llvm" \
        -DBUILD_SHARED_LIBS=ON
    make -C build -j
    make -C build install

or

.. code-block:: bash

    git clone --branch v2026.07.2 --recurse-submodules https://github.com/LLNL/Umpire.git
    cd Umpire
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${UMPIRE_INSTALL_PREFIX}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_CUDA_COMPILER="${NVCC}" \
        -Dcamp_DIR="${CAMP_INSTALL_PREFIX}" \
        -Dfmt_DIR="${FMT_INSTALL_PREFIX}" \
        -DENABLE_MPI=ON \
        -DMPI_C_COMPILER="${MPICC}" -DMPI_CXX_COMPILER="${MPICXX}" \
        -DENABLE_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="${CUDA_ARCH}" \
        -DBUILD_SHARED_LIBS=ON
    make -C build -j
    make -C build install

.. _library-raja:

RAJA
^^^^

.. code-block:: bash

    git clone --branch v2026.07.1 --recurse-submodules https://github.com/LLNL/RAJA.git
    cd RAJA
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${RAJA_INSTALL_PREFIX}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_HIP_COMPILER="${ROCM_PATH}/llvm/bin/amdclang++" \
        -Dcamp_DIR="${CAMP_INSTALL_PREFIX}" \
        -DENABLE_HIP=ON -DCMAKE_HIP_ARCHITECTURES="${ROCM_ARCH}" \
        -DROCM_PATH="${ROCM_PATH}/llvm"
    make -C build -j
    make -C build install

or

.. code-block:: bash

    git clone --branch v2026.07.1 --recurse-submodules https://github.com/LLNL/RAJA.git
    cd RAJA
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${RAJA_INSTALL_PREFIX}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_CUDA_COMPILER="${NVCC}" \
        -Dcamp_DIR="${CAMP_INSTALL_PREFIX}" \
        -DENABLE_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="${CUDA_ARCH}"
    make -C build -j
    make -C build install

.. _library-chai:

CHAI
^^^^

.. code-block:: bash

    git clone --branch v2026.07.1 --recurse-submodules https://github.com/LLNL/CHAI.git
    cd CHAI
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${CHAI_INSTALL_PREFIX}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_HIP_COMPILER="${ROCM_PATH}/llvm/bin/amdclang++" \
        -DRAJA_DIR="${RAJA_INSTALL_PREFIX}" \
        -Dumpire_DIR="${UMPIRE_INSTALL_PREFIX}" \
        -DENABLE_HIP=ON -DCMAKE_HIP_ARCHITECTURES="${ROCM_ARCH}" \
        -DROCM_PATH="${ROCM_PATH}/llvm" \
        -DCHAI_ENABLE_RAJA_PLUGIN=ON \
        -DBUILD_SHARED_LIBS=ON
    make -C build -j
    make -C build install

or

.. code-block:: bash

    git clone --branch v2026.07.1 --recurse-submodules https://github.com/LLNL/CHAI.git
    cd CHAI
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${CHAI_INSTALL_PREFIX}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_CUDA_COMPILER="${NVCC}" \
        -DRAJA_DIR="${RAJA_INSTALL_PREFIX}" \
        -Dumpire_DIR="${UMPIRE_INSTALL_PREFIX}" \
        -DENABLE_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="${CUDA_ARCH}" \
        -DCHAI_ENABLE_RAJA_PLUGIN=ON \
        -DBUILD_SHARED_LIBS=ON
    make -C build -j
    make -C build install
