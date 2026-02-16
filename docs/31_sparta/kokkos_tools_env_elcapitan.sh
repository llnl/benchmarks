#!/bin/bash

dir_root="`git rev-parse --show-toplevel`"
export KOKKOS_TOOLS_LIBS="${dir_root}/docs/31_sparta/kokkos-tools/profiling/space-time-stack/kp_space_time_stack.so"
