************
Introduction
************

This is benchmark documentation for a Department of Energy (DOE)
National Nuclear Security Administration (NNSA) Advanced Simulation
and Computing (ASC) **Advanced Technology System 6 (ATS-6)**.


.. _GlobalRunRules:

Run Rules Synopsis
==================

Source code modification categories:

1. Baseline: “out-of-the-box” performance
  * Code modifications not permitted
  * Compiler options can be modified, library substitutions permitted unless prohibited for a specific benchmark (see details on benchmark pages), problem decomposition may be changed
  * If provided code cannot run on the proposed architecture as-is, limited source code modifications are permitted to port and tune for the target architecture using directives or commonly used interfaces.
2. Optimized: "speed of light"
  * Aggressive code changes that enhance performance are permitted.  Optimizations that will be applicable to mission applications are of more value.
  * Algorithms fundamental to the program may not be replaced.  Wholesale algorithm changes or manual rewriting of loops that become strongly architecture specific are of less value.  
  * The modified code must still pass validation tests.
  * Optimizations will be reviewed by subject matter experts for applicability to the larger application portfolio and other goals such as performance portability and programmer productivity.


Approvals
=========

- Benchmarks are released under the Creative Commons Attribution 4.0
  International Public License. For more details, see the
  https://github.com/LLNL/benchmarks/blob/develop/LICENSE 
  and
  https://github.com/LLNL/benchmarks/blob/develop/NOTICE 
  files. SPDX-License-Identifier: CC-BY-4.0.  LLNL-DATA-2007856.

- Content from Sandia National Laboratories considered unclassified with
  unlimited distribution under SAND2023-12176O, SAND2023-01069O, and
  SAND2023-01070O.

