******
Kripke
******

https://github.com/LLNL/Kripke

Kripke source code is near-final at this point. The problem to run is yet to be finalized.

Purpose
=======


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
