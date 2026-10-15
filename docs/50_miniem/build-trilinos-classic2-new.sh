#!/usr/bin/env bash

default_atdm_env_prefix="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ATDM_ENV_PREFIX="${ATDM_ENV_PREFIX:=${default_atdm_env_prefix}}"

# echo "Using ENV script in ${ATDM_ENV_PREFIX}/jje_atdm2.sh"
echo "Using ENV script in ` pwd -P `/jje_atdm2-new.sh"

## EDIT THESE ##
## Point to your Trilinos
## SCRATCH_DIR is wherever you want to build, I ran out of space in HOME
##   and moved to /usr/WS1.  /p/lustre1 is pretty slow, I wouldn't build there
## ENV_SETUP is my script to source that will load modules that match
##   my TPL installs
TRILINOS_SRC=${TRILINOS_SRC:="$HOME/src/github/Trilinos"}
SCRATCH_DIR=${SCRATCH_DIR:="/tmp/${USER}/build"}
#ENV_SETUP=$PROJECT_DIR/src/jje_atdm.sh
# ENV_SETUP=${ATDM_ENV_PREFIX}/jje_atdm2.sh
ENV_SETUP=`pwd -P`/jje_atdm2-new.sh
# run tests implies build tests
RUN_TESTS=${RUN_TESTS:=false}
BUILD_TESTS=${BUILD_TESTS:=true}
CONFIGURE_ONLY=${CONFIGURE_ONLY:=false}
BUILD_SHARED=${BUILD_SHARED:=true}
JJE_INSTALL=${JJE_INSTALL:=false}
CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX:=""}

ENABLE_TEST_BINARIES=${ENABLE_TEST_BINARIES:=false}
ATDM_APPEND_SHA=${ATDM_APPEND_SHA:=false}

# Only prgenv_version=14.0.0 works now and gfx90a
# FULL ATDM is also required as it uses Ross's package include/exclude(s)
# PURE_CCE would not use HIPCC, but won't work unless you modify Kokkos's
#   HIP detection, as it requires hipcc atm
# BUILD_SERIAL is always true if HIP is true
# prgenv_toolchain only works with cray atm, as amd's modules aren't here yet.
# craype_arch can only be trento, this is a holdover from a bug in CCE that required rome.
#
# tldr, can leave all this alone
BUILD_OPENMP=${BUILD_OPENMP:=false}
BUILD_SERIAL=${BUILD_SERIAL:=false}
BUILD_HIP=${BUILD_HIP:=true}
BUILD_CUDA=${BUILD_CUDA:=false}
BUILD_PURE_CCE=${BUILD_PURE_CCE:=true}
BUILD_PURE_AMD=${BUILD_PURE_AMD:=false}
BUILD_AMDCLANG=${BUILD_AMDCLANG:=false}
FULL_ATDM=${FULL_ATDM:=true}
BUILD_COMPLEX=${BUILD_COMPLEX:=false}
# whether to add debug symbols
BUILD_DEBUG_SYM=${BUILD_DEBUG_SYM:=true}
ATDM_USE_DEVICE_TPLS=${ATDM_USE_DEVICE_TPLS:=true}
ATDM_ENABLE_OFFLOAD_NEW_DRIVER=${ATDM_ENABLE_OFFLOAD_NEW_DRIVER:=true}
ATDM_USE_HUGETLBFS=${ATDM_USE_HUGETLBFS:=false}

ENABLE_RDC=${ENABLE_RDC:=false}

CXX_STD=${CXX_STD:="20"}
# these are optmizations that hipcc adds by default
# we want to add them if not using hipcc
# or disable to see if we can dodge build errors
AMD_EARLY_INLINE_ALL=${AMD_EARLY_INLINE_ALL:=false}
AMD_FUNCTION_CALLS=${AMD_FUNCTION_CALLS:=false}
AMD_REPORT_KERNEL_USAGE=${AMD_REPORT_KERNEL_USAGE:=false}
GPU_INLINE_THRESHOLD=${GPU_INLINE_THRESHOLD:=false}

prgenv_toolchain=${prgenv_toolchain:="cray"}
prgenv_version=${prgenv_version:="20.0.0"}
cce_offload_target=${cce_offload_target:="gfx942"}

ATDM_BUILD_STATS=${ATDM_BUILD_STATS:=OFF}

function clean_it(){
  echo "Cleaning build tree"
  echo "$TRILINOS_BUILD"
  mkdir -p $TRILINOS_BUILD && cd $TRILINOS_BUILD || exit
  rm -rf trilinos Kokkos Kokkos-kernel src_dir &>/dev/null

  if [[ "$JJE_TRACK_STATS_ONLY" == "true" ]]; then
    echo "Doing Build stats tests: Copying source code to tmp"
    date
    cp -a $TRILINOS_SRC src_dir
    export TRILINOS_SRC=$PWD/src_dir
    date
    echo "TRILINOS_SRC=$TRILINOS_SRC"
  fi

  mkdir trilinos && cd trilinos

}

git_sha6() {
  local repo_path=$1

  if [ -z "$repo_path" ]; then
    return ""
  fi

  git -C "$repo_path" rev-parse --short=6 HEAD
}

function setup_env(){
  source ${ENV_SETUP}
  rc=$?

  # Check the exit status
  if [ $rc -ne 0 ]; then
    echo "Failed to load the environment mojo - I am stopping"
    exit -1;
  fi

  if [[ "$ATDM_APPEND_SHA" == "true" ]]; then
    build_id=$(atdm_get_build_id $(git_sha6 "$TRILINOS_SRC"))
  else
    build_id=$(atdm_get_build_id)
  fi
  export build_id
}


BUILD_SHARED_LIBS="ON"
if [[ "$BUILD_SHARED" == "false" ]]; then
  BUILD_SHARED_LIBS="OFF"
fi

ARGS=()

function atdm_generate_cmake(){
  local -n args=$1


  CMAKE_BUILD_TYPE="Release"
  if [[ "${BUILD_ASAN}" == "true" ]]; then
    CMAKE_BUILD_TYPE="None"
  fi

  args+=(
    "-GNinja"
    "-DPYTHON_EXECUTABLE=$(which python3)"
    "-DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}"

    # use my build statistics wrappers so we can see build times
    "-DTrilinos_ENABLE_TrilinosBuildStats=${ATDM_BUILD_STATS}"
    "-DTrilinos_ENABLE_BUILD_STATS=${ATDM_BUILD_STATS}"
    "-DTrilinosBuildStats_ENABLE_TESTS=${ATDM_BUILD_STATS}"

    "-DBUILD_SHARED_LIBS:BOOL=$BUILD_SHARED_LIBS"

    "-DTrilinos_ENABLE_Teuchos=ON"
    #"-DTeuchos_ENABLE_TESTS=ON"
    #"-DPercept_ENABLE_TESTS=OFF"
    "-DTrilinos_ENABLE_Panzer=ON"
    "-DTrilinos_ENABLE_Percept=ON"


    # these are current work arounds, both should be on
    # all-packages=on, so sacado will build, but percept will not
    "-DIntrepid2_ENABLE_TESTS=OFF"
  )

  if [[ "$ENABLE_TEST_BINARIES" == "true" ]]; then
    args+=(
    "-DTrilinos_ENABLE_PanzerMiniEM=ON"
    "-DPanzerMiniEM_ENABLE_EXAMPLES=ON"
    "-DPanzerMiniEM_ENABLE_TESTS=ON"
    "-DIfpack2_ENABLE_EXAMPLES=ON"
    )
  fi
  if [[ "$FULL_ATDM" == "true" ]]; then 
    args+=( "-DTrilinos_ENABLE_ALL_PACKAGES=ON")
  fi


  # set the arch, target, and compiler stuff
  atdm_set_compiler_and_arch "ARGS"
  # add the ATDM cmake w/out ATDMDevSettings
  atdm_set_disabled_packages "ARGS"
  atdm_add_tpls "ARGS"
}


setup_env

echo "${build_id}"

# cleanit depends on this..
TRILINOS_BUILD="$SCRATCH_DIR/${build_id}"

clean_it
atdm_generate_cmake "ARGS"
atdm_write_configure "ARGS" "$TRILINOS_SRC"

echo Build location: $PWD
echo "MPICC =$MPICC"
echo "MPICXX=$MPICXX"
echo "MPIF90=$MPIF90"
echo "mpicxx --version"
mpicxx --version
echo "cpus = $(numactl -s)"

dmesg &>pre-dmesg.log
./my_configure.sh
echo "-- Configure file: $PWD/my_configure.sh"


if [[ "$FIX_GFX940" == "true" ]]; then
  cp -a build.ninja build.ninja.orig
  sed -i -e 's|--offload-arch=gfx942|--offload-arch=gfx940|g' build.ninja
  sed -i -e 's|--offload-arch=gfx90a|--offload-arch=gfx940|g' build.ninja
  touch -r build.ninja.orig build.ninja
fi

cp -a build.ninja build.ninja.orig
sed -i -e 's| /opt/rocm-6.3.1/lib/llvm/lib/clang/18/lib/linux/libclang_rt.builtins-x86_64.a | |g' build.ninja
touch -r build.ninja.orig build.ninja
#
echo ===============================
echo checking for tcmalloc in build.ninja
grep tcmalloc build.ninja
if grep -q tcmalloc build.ninja; then
  echo "ERROR: tcmalloc found in build.ninja!"
  grep -n tcmalloc build.ninja
  echo "Purging tcmalloc from build.ninja"
  # purge tcmalloc WHY!
  cp -a build.ninja build.ninja.orig
  sed -i -e 's|-ltcmalloc_minimal||g' build.ninja
  touch -r build.ninja.orig build.ninja
fi
echo ===============================


if [[ "$CONFIGURE_ONLY" == "true" ]]; then
  echo ""
  echo "============================================================================"
  echo "============================================================================"
  echo ""
  echo "Configuring only - assuming it all worked"
  echo "Now,"
  echo "    1) cd to the configure directory"
  echo "    cd $PWD"
  echo "    # see ./my-configure.sh if you are curious"
  echo "    2) source my ENV setup file - it will load modules."
  echo "       you may need to start with a standard set of modules"
  echo "       I do not attempt to resolve detect or resolve module issues"
  echo "    2) we use ninja. So, from the build dir, run the ninja command"
  echo "       from the issue"
  echo ""
  echo "My script writes a CMake configure file ..."
  echo "  If you want to tweak/change/redo a build, copy my_configure.sh"
  echo "  edits - then make sure you load my ENV and you and rebuild where/with tweaks"
  echo ""
  echo "My builds stage in /tmp by default - they will not persist between allocations"
  echo "You can tweak the locations and the source directories:"
  echo "Set: TRILINOS_SRC=/path/to/your/Trilinos"
  echo "     SCRATCH_DIR=/tmp/$USER - this is where your build will be configured."
  echo "     (you could point this to your home/shared FS)"
  echo ""
  echo "To get the ENV, run:"
  echo ""
  cat ./load-jje-env.sh
  exit 0
fi


t0=${SECONDS}
ninja -k0
t1=${SECONDS}
duration=$((t1-t0))
echo First pass build time: $(date -u -d @"$duration" +'%-Hhr %-Mm %-Ss') | tee total_time.log
# give the failed a second chance for more memory
# spread out the load over the sockets
#ninja_j=$(seq -s, 0 1 63 | tr ',' '\n' | wc -l)
#numa_C=$(seq -s, 0 1 63)
#echo relaunching with "numactl -C ${numa_C} ninja -k0 -j${ninja_j}"
#numactl -C ${numa_C} ninja -k0 -j${ninja_j}
#t2=${SECONDS}
#duration=$((t2-t1))
#echo Second pass build time: $(date -u -d @"$duration" +'%-Hhr %-Mm %-Ss')
#duration=$((t2-t0))
echo Total build time: $(date -u -d @"$duration" +'%-Hhr %-Mm %-Ss') | tee total_time.log

# gather unbuildable targets
ninja -j1 -n -k0 &> unbuildable_targets.txt

dmesg &>post-dmesg.log

if [[ "$JJE_INSTALL" == "true" ]]; then
  prefix=$(grep CMAKE_INSTALL_PREFIX ./my_configure.sh | tr -d '"' | cut -f2 -d= | cut -f1 -d' ')
  if [[ "$JJE_TRACK_STATS_ONLY" == "true" ]]; then
    mkdir -p "$prefix"
  else
    ninja install
  fi
  cp -f ./my_configure.sh ${prefix}/ &>/dev/null
  cp -f ./load-jje-env.sh ${prefix}/ &>/dev/null
  cp -f ./packages/ifpack2/example/Ifpack2_BlockTriDiagonalSolver.exe ${prefix}/example &>/dev/null
  cp -f *.{log,txt} ${prefix}/ &>/dev/null
  cp -fa ./packages/muelu/test/scaling/ ${prefix}/example &>/dev/null

  if [[ "$ATDM_BUILD_STATS" == "true" ]]; then
    # delete empty output files
    ${ATDM_ENV_PREFIX}/clean_empty_errs.sh
    cp -f *.csv ${prefix}/ &>/dev/null
    cp -f build_stat*.sh ${prefix}/bin/ &>/dev/null
    mkdir ${prefix}/stats
    find ./ \( -name "*.err" -o -name "*.out" -o -name "*.timing" \) -print0 | xargs -0 --no-run-if-empty cp -f --parents "--target-directory=${prefix}/stats"
  fi
fi

exit

if [[ "$RUN_TESTS" == "true" ]]; then
  echo running tests...
  echo "starting 16 flux deamons"
  flux start -s 16
  t0=${SECONDS}
  /p/lustre1/jjellio/spack/run_tests
  t1=${SECONDS}
  duration=$((t1-t0))
  echo Total testing time: $(date -u -d @"$duration" +'%-Hhr %-Mm %-Ss')
fi

#ninja PanzerMiniEM_BlockPrec  && ninja PanzerMiniEM_CopyBlockPrecFiles
