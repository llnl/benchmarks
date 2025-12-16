******
Kripke
******

https://github.com/LLNL/Kripke

Kripke source code is near-final at this point. The problem to run is yet to be finalized.

Purpose
=======

Kripke is a simple, scalable, 3D Sn deterministic particle transport code.
Its primary purpose is to research how data layout, programming paradigms and architectures affect the implementation and performance of Sn transport.
A main goal of Kripke is to investigate how different data-layouts affect instruction, thread, and task level parallelism, and the implications on overall solver performance.

Kripke supports storage of angular fluxes (Psi) using all six striding orders (or "nestings") of Directions (D), Groups (G), and Zones (Z), and provides computational kernels specifically written for each of these nestings.
Most Sn transport codes are designed around one of these nestings, which is an inflexibility that leads to software engineering compromises when porting to new architectures and programming paradigms.

Early research has found that the problem dimensions (zones, groups, directions, scattering order) and the scaling (number of threads and MPI tasks), can make a profound difference in the performance of each of these nestings.
To our knowledge, this is a capability unique to Kripke, and should provide key insight into how data-layout affects Sn solver performance.
An asynchronous MPI-based parallel sweep algorithm is provided, which employs the concepts of Group Sets (GS), Zone Sets (ZS), and Direction Sets (DS), borrowed from the [Texas A&M code PDT](https://parasol.tamu.edu/asci/).

As we explore new architectures and programming paradigms with Kripke, we will be able to incorporate these findings and ideas into our larger codes.
The main advantages of using Kripke for this exploration is that it's light-weight (i.e. easily refactored and modified), and it gets us closer to the real question we want answered: "What is the best way to layout and traverse data in parallel in an Sn code on a given architecture+programming-model?" instead of the more commonly asked question "What is the best way to map my existing Sn code to a given architecture+programming-model?".

Characteristics
===============

Problems
--------

Figure of Merit
---------------

Source code modifications
==========================

Please see :ref:`GlobalRunRules` for general guidance on allowed modifications.
For Kripke, we define the following restrictions on source code modifications:

* Kripke uses RAJA as the portability library, available at https://github.com/LLNL/RAJA .  While source code changes to RAJA can be proposed, RAJA in Kripke may not be removed or replaced with any other library.

* Kripke also uses CHAI as a copy-hiding array abstraction to automatically migrate data between memory spaces.  CHAI is available at https://github.com/llnl/chai .

* Kripke also uses Camp, a compiler agnostic metaprogramming library providing concepts, type operations and tuples for C++ and cuda.  Available at https://github.com/llnl/camp .

Building
========

The easiest way to get Kripke running, is to directly invoke CMake and take whatever system defaults you have for compilers and let CMake find MPI for you.

*  Step 1:  Create a build space (assuming you are starting in the Kripke root directory)
        
        mkdir build

*  Step 2: Run CMake in that build space
        
        cd build
        cmake ..

        For a number of platforms, we have CMake cache files that make things easier:

        cd build
        cmake .. -C ../host-configs/llnl-bgqos-clang.cmake -DCMAKE_BUILD_TYPE=Release

*  Step 3: Now make Kripke:
         
        make -j8
  

Running
=======


Validation
==========


Example Scalability Results
===========================


Memory Usage
============


Strong Scaling
==============

Please see :ref:`ElCapitanSystemDescription` for El Capitan system description.


Weak Scaling on El Capitan
==========================


References
==========
