# Use the UBI8 base image

FROM ubi8



# Set the working directory

WORKDIR /app



# Install development tools and Python

RUN dnf update -y

RUN dnf install -y gcc gcc-c++ python38 python38-pip python38-devel unzip vim && dnf clean all

RUN dnf install -y git openssl-devel bzip2-devel libffi-devel openssh-server

RUN dnf groupinstall -y "Development Tools"

RUN dnf install -y openmpi openmpi-devel iproute net-tools iputils sshpass

RUN dnf config-manager --set-enabled codeready-builder-for-rhel-8-x86_64-rpms

RUN dnf update -y

RUN dnf install -y netcdf-devel

RUN dnf install -y lapack-devel blas-devel

RUN dnf install -y cmake vim

RUN dnf install -y boost boost-devel matio matio-devel libX11-devel openmpi openmpi-devel mpich  hdf5-devel hdf5-static



RUN echo "export PATH=/usr/local/example/PanzerMiniEM:/usr/lib64/openmpi/bin:$PATH" >> ~/.bashrc

RUN echo "export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib:$LD_LIBRARY_PATH">> ~/.bashrc

RUN echo "export C_INCLUDE_PATH=/usr/include/openmpi-x86_64:$C_INCLUDE_PATH">> ~/.bashrc

RUN echo "export CPLUS_INCLUDE_PATH=/usr/include/openmpi-x86_64:$CPLUS_INCLUDE_PATH">> ~/.bashrc

RUN source ~/.bashrc



# Build a trilinos program

RUN git clone https://github.com/trilinos/Trilinos.git -v && \

    cd Trilinos && \

    mkdir build && \

    cd build && \

    cmake \

        -DTrilinos_ENABLE_PanzerMiniEM=ON \

        -DTPL_ENABLE_MPI=ON \

        -DTrilinos_ENABLE_Kokkos=ON \

        -DTrilinos_ENABLE_Panzer=ON \

        -DPanzerMiniEM_ENABLE_EXAMPLES=ON \

        -DPanzerMiniEM_ENABLE_TESTS=ON .. && \

    make -j$(nproc) install

RUN mkdir examples_miniEM

RUN cp /app/Trilinos-master/packages/panzer/mini-em/example/BlockPrec/* ./examples_miniEM/
