#!/bin/sh
if test ! -d "${SPACK_ROOT}" ; then
    git clone --branch v1.1.1 git@github.com:spack/spack "${SPACK_ROOT}"
fi
