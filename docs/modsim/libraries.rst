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
        -DCMAKE_INSTALL_PREFIX="${ADIAK_DIR}" \
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
        -DCMAKE_INSTALL_PREFIX="${CALIPER_DIR}" \
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
        -Dadiak_DIR="${ADIAK_DIR}/lib/cmake/adiak"
    make -C build -j
    make -C build install

or

.. code-block:: bash

    git clone --branch master --recurse-submodules https://github.com/LLNL/Caliper.git
    cd Caliper
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${CALIPER_DIR}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_CUDA_COMPILER="${NVCC}" \
        -DWITH_MPI=ON \
        -DMPI_C_COMPILER="${MPICC}" -DMPI_CXX_COMPILER="${MPICXX}" \
        -DCMAKE_CUDA_ARCHITECTURES="${CUDA_ARCH}" -DWITH_CUPTI=ON -DWITH_NVTX=ON \
        -DWITH_ADIAK=ON \
        -Dadiak_DIR="${ADIAK_DIR}/lib/cmake/adiak"
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
        -DCMAKE_INSTALL_PREFIX="${FMT_DIR}" \
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
        -DCMAKE_INSTALL_PREFIX="${CAMP_DIR}" \
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
        -DCMAKE_INSTALL_PREFIX="${CAMP_DIR}" \
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
        -DCMAKE_INSTALL_PREFIX="${UMPIRE_DIR}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_HIP_COMPILER="${ROCM_PATH}/llvm/bin/amdclang++" \
        -Dcamp_DIR="${CAMP_DIR}" \
        -Dfmt_DIR="${FMT_DIR}" \
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
        -DCMAKE_INSTALL_PREFIX="${UMPIRE_DIR}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_CUDA_COMPILER="${NVCC}" \
        -Dcamp_DIR="${CAMP_DIR}" \
        -Dfmt_DIR="${FMT_DIR}" \
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
        -DCMAKE_INSTALL_PREFIX="${RAJA_DIR}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_HIP_COMPILER="${ROCM_PATH}/llvm/bin/amdclang++" \
        -Dcamp_DIR="${CAMP_DIR}" \
        -DENABLE_HIP=ON -DCMAKE_HIP_ARCHITECTURES="${ROCM_ARCH}" \
        -DROCM_PATH="${ROCM_PATH}/llvm"
    make -C build -j
    make -C build install

or

.. code-block:: bash

    git clone --branch v2026.07.1 --recurse-submodules https://github.com/LLNL/RAJA.git
    cd RAJA
    cmake -S . -B build \
        -DCMAKE_INSTALL_PREFIX="${RAJA_DIR}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_CUDA_COMPILER="${NVCC}" \
        -Dcamp_DIR="${CAMP_DIR}" \
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
        -DCMAKE_INSTALL_PREFIX="${CHAI_DIR}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_HIP_COMPILER="${ROCM_PATH}/llvm/bin/amdclang++" \
        -DRAJA_DIR="${RAJA_DIR}" \
        -Dumpire_DIR="${UMPIRE_DIR}" \
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
        -DCMAKE_INSTALL_PREFIX="${CHAI_DIR}" \
        -DCMAKE_C_COMPILER="${CC}" -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_CUDA_COMPILER="${NVCC}" \
        -DRAJA_DIR="${RAJA_DIR}" \
        -Dumpire_DIR="${UMPIRE_DIR}" \
        -DENABLE_CUDA=ON -DCMAKE_CUDA_ARCHITECTURES="${CUDA_ARCH}" \
        -DCHAI_ENABLE_RAJA_PLUGIN=ON \
        -DBUILD_SHARED_LIBS=ON
    make -C build -j
    make -C build install

.. _library-hypre:

Hypre
^^^^^

.. code-block:: bash

    git clone --branch v3.2.0 --recurse-submodules https://github.com/hypre-space/hypre.git
    cd hypre
    cmake -S ./src -B build \
      -DCMAKE_INSTALL_PREFIX="${HYPRE_DIR}" \
      -DCMAKE_C_COMPILER="${CC}" \
      -DCMAKE_CXX_COMPILER="${CXX}" \
      -DHYPRE_ENABLE_HIP=ON \
      -DCMAKE_HIP_COMPILER="${ROCM_PATH}/llvm/bin/clang++" \
      -DCMAKE_HIP_ARCHITECTURES="${ROCM_ARCH}" \
      -DBUILD_SHARED_LIBS=ON \
      -DHYPRE_ENABLE_MPI=ON \
      -DHYPRE_ENABLE_GPU_AWARE_MPI=ON \
      -DHYPRE_ENABLE_MIXEDINT=ON \
      -DHYPRE_ENABLE_HYPRE_BLAS=ON \
      -DHYPRE_ENABLE_HYPRE_LAPACK=ON \
      -DHYPRE_ENABLE_UMPIRE=ON \
      -DTPL_UMPIRE_INCLUDE_DIRS="${UMPIRE_DIR}/include" \
      -DTPL_UMPIRE_LIBRARIES="${UMPIRE_DIR}/lib64/libumpire.so" \
      -DHYPRE_ENABLE_CALIPER=ON \
      -Dcaliper_DIR="${CALIPER_DIR}/share/cmake/caliper"
    make -C build -j
    make -C build install

or

.. code-block:: bash

    git clone --branch v3.2.0 --recurse-submodules https://github.com/hypre-space/hypre.git
    cd hypre
    cmake -S ./src -B build \
        -DCMAKE_INSTALL_PREFIX="${HYPRE_DIR}" \
        -DCMAKE_C_COMPILER="${CC}" \
        -DCMAKE_CXX_COMPILER="${CXX}" \
        -DHYPRE_ENABLE_CUDA=ON \
        -DCMAKE_CUDA_COMPILER="${NVCC}" -DCMAKE_CUDA_HOST_COMPILER="${CXX}" \
        -DCMAKE_CUDA_ARCHITECTURES="${CUDA_ARCH}" \
        -DCUDAToolkit_ROOT="${CUDA_ROOT}" \
        -DBUILD_SHARED_LIBS=ON \
        -DHYPRE_ENABLE_MPI=ON \
        -DHYPRE_ENABLE_GPU_AWARE_MPI=OFF \ # if GPU-awre MPI is needed
        -DHYPRE_ENABLE_MIXEDINT=ON \
        -DHYPRE_ENABLE_HYPRE_BLAS=ON \
        -DHYPRE_ENABLE_HYPRE_LAPACK=ON \
        -DHYPRE_ENABLE_UMPIRE=ON \
        -DTPL_UMPIRE_INCLUDE_DIRS="${UMPIRE_DIR}/include" \
        -DTPL_UMPIRE_LIBRARIES="${UMPIRE_DIR}/lib64/libumpire.so" \
        -DHYPRE_ENABLE_CALIPER=ON \
        -Dcaliper_DIR="${CALIPER_DIR}/share/cmake/caliper"
    make -C build -j
    make -C build install

.. _library-mfem:

MFEM
^^^^

.. code-block:: bash

    git clone --branch v4.10 --recurse-submodules https://github.com/mfem/mfem.git
    cd mfem
    make -j1 config \
      PREFIX="${MFEM_DIR}" \
      CXX="${CXX}" MPICXX="${MPICXX}" \
      MFEM_DEBUG=NO MFEM_USE_MPI=YES MFEM_USE_HIP=YES \
      HIP_CXX="${HIPCC}" HIP_ARCH="${ROCM_ARCH}" HIP_DIR="${ROCM_PATH}" \
      MFEM_USE_METIS=NO MFEM_USE_METIS_5=NO \
      HYPRE_OPT="-I${HYPRE_DIR}/include -I${UMPIRE_DIR}/include" \
      HYPRE_LIB="-L${HYPRE_DIR}/lib64 -lHYPRE" \
      MFEM_USE_RAJA=YES \
      RAJA_OPT="-I${RAJA_DIR}/include -I${CAMP_DIR}/include" \
      RAJA_LIB="-L${RAJA_DIR}/lib -lRAJA" \
      MFEM_USE_UMPIRE=YES \
      UMPIRE_OPT="-I${UMPIRE_DIR}/include -I${CAMP_DIR}/include -I${FMT_DIR}/include" \
      UMPIRE_LIB="-L${UMPIRE_DIR}/lib64 -lumpire" \
      MFEM_USE_CALIPER=YES \
      CALIPER_DIR="${CALIPER_DIR}" ADIAK_DIR="${ADIAK_DIR}"
    make -j
    make install

or

.. code-block:: bash

    git clone --branch v4.10 --recurse-submodules https://github.com/mfem/mfem.git
    cd mfem
    make -j1 config \
      PREFIX="${MFEM_DIR}" \
      CXX="${CXX}" MPICXX="${MPICXX}" \
      MFEM_DEBUG=NO MFEM_USE_MPI=YES MFEM_USE_CUDA=YES \
      CUDA_CXX="${NVCC}" CUDA_ARCH="sm_${CUDA_ARCH}" \
      MFEM_USE_METIS=NO MFEM_USE_METIS_5=NO \
      HYPRE_OPT="-I${HYPRE_DIR}/include -I${UMPIRE_DIR}/include" \
      HYPRE_LIB="-L${HYPRE_DIR}/lib64 -Xlinker=-rpath,${HYPRE_DIR}/lib64 -lHYPRE -L${CUDA_ROOT}/lib64 -Xlinker=-rpath,${CUDA_ROOT}/lib64 -lcusolver -lcusparse -lcurand -lcublas" \
      MFEM_USE_RAJA=YES \
      RAJA_OPT="-I${RAJA_DIR}/include -I${CAMP_DIR}/include" \
      RAJA_LIB="-L${RAJA_DIR}/lib -lRAJA" \
      MFEM_USE_UMPIRE=YES \
      UMPIRE_OPT="-I${UMPIRE_DIR}/include -I${CAMP_DIR}/include -I${FMT_DIR}/include" \
      UMPIRE_LIB="-L${UMPIRE_DIR}/lib64 -Xlinker=-rpath,${UMPIRE_DIR}/lib64 -lumpire" \
      MFEM_USE_CALIPER=YES \
      CALIPER_DIR="${CALIPER_DIR}" ADIAK_DIR="${ADIAK_DIR}"
    make -j
    make install
