# for update
# export ATDM_ENV_PREFIX="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ATDM_ENV_PREFIX="/tscratch/jjellio/trilinos-dev/spack/config"

export BUILD_SHARED=${BUILD_SHARED:=true}
export BUILD_OPENMP=${BUILD_OPENMP:=false}
export BUILD_SERIAL=${BUILD_SERIAL:=false}
export BUILD_HIP=${BUILD_HIP:=true}
export BUILD_CUDA_ANSEL=${BUILD_CUDA_ANSEL:=false}
export BUILD_PURE_CCE=${BUILD_PURE_CCE:=true}
export BUILD_PURE_AMD=${BUILD_PURE_AMD:=false}
export BUILD_AMDCLANG=${BUILD_AMDCLANG:=false}
export FULL_ATDM=${FULL_ATDM:=true}
export ATDM_ENABLE_FORTRAN=${ATDM_ENABLE_FORTRAN:=false}
export BUILD_COMPLEX=${BUILD_COMPLEX:=false}
# whether to add debug symbols
export BUILD_DEBUG_SYM=${BUILD_DEBUG_SYM:=true}
export BUILD_ASAN=${BUILD_ASAN:=false}
export ATDM_USE_DEVICE_TPLS=${ATDM_USE_DEVICE_TPLS:=true}

export ATDM_USE_WRAPPERS=${ATDM_USE_WRAPPERS:="mpi"}
export ATDM_USE_HUGETLBFS=${ATDM_USE_HUGETLBFS:=false}

export ENABLE_RDC=${ENABLE_RDC:=false}
export ATDM_THIN_JOBS=${ATDM_THIN_JOBS:=16}
export CXX_STD=${CXX_STD:="20"}

export prgenv_toolchain=${prgenv_toolchain:="cray"}
export prgenv_version=${prgenv_version:="20.0.0"}
export cce_offload_target=${cce_offload_target:="gfx942"}

export RUN_TESTS=${RUN_TESTS:=false}
export BUILD_TESTS=${BUILD_TESTS:=true}

export PERFORMANCE_TEST=${PERFORMANCE_TEST=false}

export ATDM_DUCT_TAPE_USE_FUDGE_LINK=${ATDM_DUCT_TAPE_USE_FUDGE_LINK:=false}
export ATDM_DUCT_TAPE_ADD_CRAYPE_LD_LIBRARY=${ATDM_DUCT_TAPE_ADD_CRAYPE_LD_LIBRARY:=true}
export ATDM_DUCT_TAPE_USE_FC=${ATDM_DUCT_TAPE_USE_FC:="crayftn"}
export ATDM_ENABLE_OFFLOAD_NEW_DRIVER=${ATDM_ENABLE_OFFLOAD_NEW_DRIVER:=true}
export ATDM_DUCT_TAPE_SET_OFFLOAD_ARCH=${ATDM_DUCT_TAPE_SET_OFFLOAD_ARCH:=false}
export ATDM_DUCT_TAPE_SET_ROCM_PATH=${ATDM_DUCT_TAPE_SET_ROCM_PATH:=false}
export ATDM_DUCT_TAPE_ADD_MPI_INCLIBS=${ATDM_DUCT_TAPE_ADD_MPI_INCLIBS:=false}

export ATDM_LTO_THIN=${ATDM_LTO_THIN:=false}

# these are optmizations that hipcc adds by default
# we want to add them if not using hipcc
# or disable to see if we can dodge build errors
export AMD_EARLY_INLINE_ALL=${AMD_EARLY_INLINE_ALL:=false}
export AMD_FUNCTION_CALLS=${AMD_FUNCTION_CALLS:=false}
export AMD_REPORT_KERNEL_USAGE=${AMD_REPORT_KERNEL_USAGE:=false}
export GPU_INLINE_THRESHOLD=${GPU_INLINE_THRESHOLD:=false}
export ROCM_VERSION=${ROCM_VERSION:=6.4.2}

have_apu=false;
if [[ "$cce_offload_target" == *_APU ]]; then
have_apu=true;
cce_offload_target="${cce_offload_target%_APU}"
fi


export ATDM_MODULE_PREFIX=""

unset path_append
unset path_prepend
unset path_remove
path_append ()  { path_remove $1; export PATH="$PATH:$1"; }
path_prepend () { path_remove $1; export PATH="$1:$PATH"; }
path_remove ()  { export PATH=`echo -n $PATH | awk -v RS=: -v ORS=: '$0 != "'$1'"' | sed 's/:$//'`; }
export -f path_append
export -f path_prepend
export -f path_remove


## We now need a way to find installed software because
#  paths are getting all over the place
# find_toolchain_path "rocmcc" "6.4.1"
#   returns a path, or 
# Global variable containing potential installation prefixes
ATDM_CANDIDATE_PREFIXES=(
"/usr/workspace/trilinos-dev/spack"
"/pscratch/jjellio/trilinos-dev/spack"
"/tscratch/jjellio/trilinos-dev/spack"
)

JJE_DEBUG=${JJE_DEBUG:=false}
function jje_debug_print() {
  if [[ "$JJE_DEBUG" == "true" ]]; then
    echo "$1" 1>&2
  fi
}

function jje_version_ge() {
  [[ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" == "$2" ]]
}


# Function to find the installation path
function find_toolchain_path() {
  local toolchain_combined="$1"  # Combined toolchain name and version
  local arch_triple="$2"          # Optional architecture triple

  # Loop over candidate prefixes.
  for prefix in "${ATDM_CANDIDATE_PREFIXES[@]}"; do
    # Skip prefixes that do not exist.
    if [[ ! -d "$prefix" ]]; then
      continue
    fi

    # Use find with a maximum depth of 5.
    # We look for directories named exactly "$toolchain_combined".
    while IFS= read -r found_dir; do

      # The expected structure is:
      #   .../modules/<linux-os-arch>/<toolchain_combined>/some-name
      #
      # So, get:
      #   toolchain_dir   = the directory containing <toolchain_combined>
      #   arch_dir        = directory containing some_name_dir (i.e. the arch triple directory)
      #   modules_dir     = parent of arch_dir, which must be named "modules"

      jje_debug_print "Searching: $found_dir"
      local toolchain_n=$(basename "$found_dir")
      local toolchain_d=$(dirname "$found_dir")
      local arch_n=$(basename "$toolchain_d")
      local arch_d=$(dirname "$toolchain_d")
      local modules_n=$(basename "$arch_d")

      # require modules as the modules directory
      if [[ "$modules_n" != "modules" ]]; then
        jje_debug_print "Skipping because $modules_n != modules"
        continue;
      fi

      # if we have an arch_triple constraint, apply it
      if [[ -n "$arch_triple" ]]; then
        if [[ "$arch_n" != "$arch_triple" ]]; then
          jje_debug_print "Skipping because $arch_n != $arch_triple"
          continue
        fi
      else
        # Otherwise, check that the arch candidate matches a defined pattern.
        # This regex requires three groups separated by dashes.
        if [[ ! "$arch_n" =~ ^[a-zA-Z0-9]+-[a-zA-Z0-9]+-[a-zA-Z0-9]+$ ]]; then
          jje_debug_print "Skipping because $arch_n does not match the arch regex"
          continue
        fi
      fi

      # this should be true by virtue of the find command
      if  [[ "$toolchain_combined" != "$toolchain_n" ]]; then
        echo "ERROR: find searched for $toolchain_combined, but the final directory of $found_dir is $toolchain_n" 1>&2
        continue;
      fi

      # Once a valid directory is found, print the arch directory and stop processing.
      echo "$toolchain_d"
      return 0

    done < <(find "$prefix" -maxdepth 4 -not  \( -path .git -o -path cache \) -type d -name "$toolchain_combined" 2>/dev/null)
  done

  echo "No valid installation found for ${toolchain_combined}." >&2
  return 1
}

#-g -O1 --offload-arch=gfx90a:xnack+ -fsanitize=address -shared-libsan
#module use /p/lustre1/jjellio/EMPIRE-work/amd-my-modules

if [[ "$BUILD_PURE_AMD" == "true" ]]; then
  BUILD_AMDCLANG=true
fi

Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;zip;hdf5_hl;hdf5"

module_arch_string="linux-rhel8-zen3"
module_ver_string=""

_rocm_version_before=$ROCM_VERSION
compiler_specific_tpl_names=()
module purge
if [[ "$BUILD_PURE_AMD" == "true" ]]; then
  amd_rocm_version=${ROCM_VERSION}
  export prgenv_toolchain="amd"
  export ATDM_LAPACK_LIBRARY_NAMES="openblas;omp;pthread"
  export ATDM_BLAS_LIBRARY_NAMES="openblas;omp;pthread"
  export ATDM_MPI_LIB="mpi_amd"

  #path_prepend "$ROCM_PATH/llvm/bin"
  if [[ "$ROCM_VERSION" == "5.3.0" ]]; then
    module_ver_string="rocmcc-5.3.0"
  elif [[ "$ROCM_VERSION" == "5.4.0" ]]; then
    module_ver_string="rocmcc-5.4.0"
  elif [[ "$ROCM_VERSION" == "5.4.3" ]]; then
    module_ver_string="rocmcc-5.4.3"
    export ATDM_LAPACK_LIBRARY_NAMES="sci_amd"
    export ATDM_BLAS_LIBRARY_NAMES="sci_amd"
    compiler_specific_tpl_names=(
      "cray-libsci"
      "python/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      "libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
    )
  elif [[ "$ROCM_VERSION" == "5.6.0" ]]; then
    module_ver_string="rocmcc-5.6.0"
    compiler_specific_tpl_names=(
      "python/${module_ver_string}"
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      "libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
    )
  elif [[ "$ROCM_VERSION" == "5.6.1" ]]; then
    module_ver_string="rocmcc-5.6.1"
    #export ATDM_LAPACK_LIBRARY_NAMES="sci_amd"
    #export ATDM_BLAS_LIBRARY_NAMES="sci_amd"
    compiler_specific_tpl_names=(
      #"cray-libsci"
      "python/${module_ver_string}"
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      "libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
    )
  elif [[ "$ROCM_VERSION" == "5.7.0" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    module_ver_string="rocmcc-5.7.0"
    compiler_specific_tpl_names=(
      "python/${module_ver_string}"
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      "libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
    )
  elif [[ "$ROCM_VERSION" == "5.7.1" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    module_ver_string="rocmcc-5.7.1"
    compiler_specific_tpl_names=(
      "python/${module_ver_string}"
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      "libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
    )
  elif [[ "$ROCM_VERSION" == "6.1.0" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    module_ver_string="rocmcc-6.1.0"
    compiler_specific_tpl_names=(
      #"python/${module_ver_string}"
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      "libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
      "py-h5py/${module_ver_string}"
    )
  elif [[ "$ROCM_VERSION" == "6.1.2" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    module_ver_string="rocmcc-6.1.2"
    compiler_specific_tpl_names=(
      "python/${module_ver_string}"
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
      #"py-h5py/${module_ver_string}"
    )
    if [[ "$cce_offload_target" == "gfx942" ]]; then
      module_arch_string="linux-rhel8-zen4"
      Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;hdf5_hl;hdf5"
      #compiler_specific_tpl_names+=(
      #  "libzip/${module_ver_string}")
    else
      echo "Mi250X builds are not supported here"
      exit -1
    fi
  elif [[ "$ROCM_VERSION" == "6.2.0" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    if [[ "$cce_offload_target" == "gfx942" ]]; then
      module_arch_string="linux-rhel8-zen4"
    fi
    module_ver_string="rocmcc-6.2.0"
    compiler_specific_tpl_names=(
      #"python/${module_ver_string}"
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      "libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
      "py-h5py/${module_ver_string}"
    )
  elif [[ "$ROCM_VERSION" == "6.2.1" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    if [[ "$cce_offload_target" == "gfx942" ]]; then
      module_arch_string="linux-rhel8-zen4"
    fi
    Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;hdf5_hl;hdf5"
    # the prior load of amd/6.2.1beta2 failed, which deactives mpich...
    # load a working AMD module. then load the plain rocm module
    module load amd/6.2.4
    module_ver_string="rocmcc-6.2.1"
    compiler_specific_tpl_names=(
      #"python/${module_ver_string}"
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      #"libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
      "py-h5py/${module_ver_string}"
    )
  elif [[ "$ROCM_VERSION" == "6.2.4" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    if [[ "$cce_offload_target" == "gfx942" ]]; then
      module_arch_string="linux-rhel8-zen4"
    fi
    Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;hdf5_hl;hdf5"
    module_ver_string="rocmcc-6.2.4"
    compiler_specific_tpl_names=(
      #"python/${module_ver_string}"
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      #"libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
      #"py-h5py/${module_ver_string}"
    )
  elif [[ "$ROCM_VERSION" == "6.3.1" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    if [[ "$cce_offload_target" == "gfx942" ]]; then
      module_arch_string="linux-rhel8-zen4"
    fi
    Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;hdf5_hl;hdf5"
    module_ver_string="rocmcc-6.3.1"
    compiler_specific_tpl_names=(
      "cray-mpich/8.1.32"
      #"python/${module_ver_string}"
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      #"libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
      #"py-h5py/${module_ver_string}"
      "rocm/${ROCM_VERSION}hangfix"
    )
  elif [[ "$ROCM_VERSION" == "6.4.0" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;hdf5_hl;hdf5"
    module_ver_string="rocmcc-6.4.0"
    compiler_specific_tpl_names=(
      "cray-mpich/8.1.33"
      #"python/${module_ver_string}"
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      #"libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
      #"py-h5py/${module_ver_string}"
      "rocm/${ROCM_VERSION}"
    )
  elif [[ "$ROCM_VERSION" == "6.4.1" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;hdf5_hl;hdf5"
    module_ver_string="rocmcc-6.4.1"
    compiler_specific_tpl_names=(
      "cray-mpich/9.0.1"
      "${module_ver_string}/openblas"
      "${module_ver_string}/boost"
      "${module_ver_string}/cmake"
      "${module_ver_string}/hdf5"
      "${module_ver_string}/metis-32bit"
      "${module_ver_string}/netcdf-c"
      "${module_ver_string}/ninja"
      "${module_ver_string}/parallel-netcdf"
      "${module_ver_string}/parmetis-32bit"
      "${module_ver_string}/superlu-dist"
      "${module_ver_string}/cgns"
      "${module_ver_string}/zlib-ng"
      "rocm/${ROCM_VERSION}"
    )
  elif [[ "$ROCM_VERSION" == "6.4.2" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;hdf5_hl;hdf5"
    module_ver_string="rocmcc-6.4.2"
    compiler_specific_tpl_names=(
      "cray-mpich/9.0.1"
      #"python"
      "${module_ver_string}/openblas"
      "${module_ver_string}/boost"
      "${module_ver_string}/cmake"
      "${module_ver_string}/hdf5"
      "${module_ver_string}/metis-32bit"
      "${module_ver_string}/netcdf-c"
      "${module_ver_string}/ninja"
      "${module_ver_string}/parallel-netcdf"
      "${module_ver_string}/parmetis-32bit"
      "${module_ver_string}/superlu-dist"
      "${module_ver_string}/cgns"
      "${module_ver_string}/zlib-ng"
      #"py-h5py"
      "rocm/${ROCM_VERSION}"
    )
  elif [[ "$ROCM_VERSION" == "6.4.3" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;hdf5_hl;hdf5"
    module_ver_string="rocmcc-6.4.3"
    amd_rocm_version=6.4.3
    compiler_specific_tpl_names=(
      "cray-mpich/9.0.1"
      #"python/${module_ver_string}"
      "${module_ver_string}/openblas"
      "${module_ver_string}/boost"
      "${module_ver_string}/cmake"
      "${module_ver_string}/hdf5"
      "${module_ver_string}/metis-32bit"
      "${module_ver_string}/netcdf-c"
      "${module_ver_string}/ninja"
      "${module_ver_string}/parallel-netcdf"
      "${module_ver_string}/parmetis-32bit"
      #"${module_ver_string}/superlu-dist"
      "${module_ver_string}/cgns"
      "${module_ver_string}/zlib-ng"
      #"py-h5py/${module_ver_string}"
      "rocm/6.4.3"
    )
  elif [[ "$ROCM_VERSION" == "7.0.0beta2" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;hdf5_hl;hdf5"
    module_ver_string="rocmcc-6.4.2"
    # current rocm 7 is a beta and has no amd module
    amd_rocm_version=6.4.3

    compiler_specific_tpl_names=(
      "cray-mpich/9.0.1"
      #"python/${module_ver_string}"
      "${module_ver_string}/openblas"
      "${module_ver_string}/boost"
      "${module_ver_string}/cmake"
      "${module_ver_string}/hdf5"
      "${module_ver_string}/metis-32bit"
      "${module_ver_string}/netcdf-c"
      "${module_ver_string}/ninja"
      "${module_ver_string}/parallel-netcdf"
      "${module_ver_string}/parmetis-32bit"
      "${module_ver_string}/superlu-dist"
      "${module_ver_string}/cgns"
      "${module_ver_string}/zlib-ng"
      #"py-h5py/${module_ver_string}"
      "rocm/7.0.0beta2"
    )
  elif [[ "$ROCM_VERSION" == "7.0.0" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;hdf5_hl;hdf5"
    module_ver_string="rocmcc-6.4.2"
    # current rocm 7 is a beta and has no amd module
    amd_rocm_version=6.4.3

    compiler_specific_tpl_names=(
      "cray-mpich/9.0.1"
      #"python/${module_ver_string}"
      "${module_ver_string}/openblas"
      "${module_ver_string}/boost"
      "${module_ver_string}/cmake"
      "${module_ver_string}/hdf5"
      "${module_ver_string}/metis-32bit"
      "${module_ver_string}/netcdf-c"
      "${module_ver_string}/ninja"
      "${module_ver_string}/parallel-netcdf"
      "${module_ver_string}/parmetis-32bit"
      "${module_ver_string}/superlu-dist"
      "${module_ver_string}/cgns"
      "${module_ver_string}/zlib-ng"
      #"py-h5py/${module_ver_string}"
      "rocm/7.0.0"
    )
  elif [[ "$ROCM_VERSION" == "7.0.1" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;hdf5_hl;hdf5"
    module_ver_string="rocmcc-6.4.2"
    # current rocm 7 is a beta and has no amd module
    amd_rocm_version=6.4.3

    compiler_specific_tpl_names=(
      "cray-mpich/9.0.1"
      #"python/${module_ver_string}"
      "${module_ver_string}/openblas"
      "${module_ver_string}/boost"
      "${module_ver_string}/cmake"
      "${module_ver_string}/hdf5"
      "${module_ver_string}/metis-32bit"
      "${module_ver_string}/netcdf-c"
      "${module_ver_string}/ninja"
      "${module_ver_string}/parallel-netcdf"
      "${module_ver_string}/parmetis-32bit"
      "${module_ver_string}/superlu-dist"
      "${module_ver_string}/cgns"
      "${module_ver_string}/zlib-ng"
      #"py-h5py/${module_ver_string}"
      "rocm/7.0.1"
    )
  elif [[ "$ROCM_VERSION" == "7.0.2" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;hdf5_hl;hdf5"
    module_ver_string="rocmcc-6.4.2"
    # current rocm 7 is a beta and has no amd module
    amd_rocm_version=6.4.3

    compiler_specific_tpl_names=(
      "cray-mpich/9.0.1"
      #"python/${module_ver_string}"
      "${module_ver_string}/openblas"
      "${module_ver_string}/boost"
      "${module_ver_string}/cmake"
      "${module_ver_string}/hdf5"
      "${module_ver_string}/metis-32bit"
      "${module_ver_string}/netcdf-c"
      "${module_ver_string}/ninja"
      "${module_ver_string}/parallel-netcdf"
      "${module_ver_string}/parmetis-32bit"
      "${module_ver_string}/superlu-dist"
      "${module_ver_string}/cgns"
      "${module_ver_string}/zlib-ng"
      #"py-h5py/${module_ver_string}"
      "rocm/7.0.2"
    )
  elif [[ "$ROCM_VERSION" == "7.2.0" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;hdf5_hl;hdf5"
    module_ver_string="rocmcc-6.4.3"
    # current rocm 7 is a beta and has no amd module
    amd_rocm_version=6.4.3

    compiler_specific_tpl_names=(
      "cray-mpich/9.0.1"
      #"python/${module_ver_string}"
      "${module_ver_string}/openblas"
      "${module_ver_string}/boost"
      "${module_ver_string}/cmake"
      "${module_ver_string}/hdf5"
      "${module_ver_string}/metis-32bit"
      "${module_ver_string}/netcdf-c"
      "${module_ver_string}/ninja"
      "${module_ver_string}/parallel-netcdf"
      "${module_ver_string}/parmetis-32bit"
      "${module_ver_string}/superlu-dist"
      "${module_ver_string}/cgns"
      "${module_ver_string}/zlib-ng"
      #"py-h5py/${module_ver_string}"
      "rocm/7.2.0"
    )
  elif [[ "$ROCM_VERSION" == "7.13.0" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;hdf5_hl;hdf5"
    module_ver_string="rocmcc-6.4.3"
    # current rocm 7 is a beta and has no amd module
    amd_rocm_version=6.4.3

    compiler_specific_tpl_names=(
      "cray-mpich/9.0.1"
      "${module_ver_string}/openblas"
      "${module_ver_string}/boost"
      "${module_ver_string}/cmake"
      "${module_ver_string}/hdf5"
      "${module_ver_string}/metis-32bit"
      "${module_ver_string}/netcdf-c"
      "${module_ver_string}/ninja"
      "${module_ver_string}/parallel-netcdf"
      "${module_ver_string}/parmetis-32bit"
      "${module_ver_string}/superlu-dist"
      "${module_ver_string}/cgns"
      "${module_ver_string}/zlib-ng"
      #"py-h5py/${module_ver_string}"
    )
    # pull in the  nightly install 
    source /tscratch/jjellio/trilinos-dev/nightly-amd/sourceme-7.13.0a20260326-gfx94X.sh
  elif [[ "$ROCM_VERSION" == "6.3.0" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    if [[ "$cce_offload_target" == "gfx942" ]]; then
      module_arch_string="linux-rhel8-zen4"
    fi
    Netcdf_LIBRARY_NAMES="netcdf;pnetcdf;z;hdf5_hl;hdf5"
    module_ver_string="rocmcc-6.3.0"
    compiler_specific_tpl_names=(
      #"python/${module_ver_string}"
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      #"libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
      #"py-h5py/${module_ver_string}"
      "rocm/${ROCM_VERSION}hangfix"
    )
  elif [[ "$ROCM_VERSION" == "6.0.3" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    module_ver_string="rocmcc-6.0.2"
    compiler_specific_tpl_names=(
      "python/${module_ver_string}"
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      "libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
      "py-h5py/${module_ver_string}"
    )
  elif [[ "$ROCM_VERSION" == "6.0.2" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    module_ver_string="rocmcc-6.0.2"
    compiler_specific_tpl_names=(
      "python/${module_ver_string}"
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      "libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
      "py-h5py/${module_ver_string}"
    )
  elif [[ "$ROCM_VERSION" == "6.0.0" ]]; then
    export ATDM_DUCT_TAPE_REMOVE_HIP_PATH=true
    module_ver_string="rocmcc-6.0.0"
    compiler_specific_tpl_names=(
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      "libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
    )
  elif [[ "$ROCM_VERSION" == "5.5.1" ]]; then
    module_ver_string="rocmcc-5.7.0"
    compiler_specific_tpl_names=(
      "python/${module_ver_string}"
      "openblas/${module_ver_string}"
      "boost/${module_ver_string}"
      "cmake/${module_ver_string}"
      "hdf5/${module_ver_string}"
      "metis-32bit/${module_ver_string}"
      "netcdf-c/${module_ver_string}"
      "libzip/${module_ver_string}"
      "ninja/${module_ver_string}"
      "parallel-netcdf/${module_ver_string}"
      "parmetis-32bit/${module_ver_string}"
      "superlu-dist/${module_ver_string}"
      "cgns/${module_ver_string}"
      "zlib-ng/${module_ver_string}"
    )
  fi

  module rm rocm &>/dev/null
  module load PrgEnv-amd
  module load amd/${amd_rocm_version}
  module rm cray-libsci

# end of PURE AMD = TRUE
elif [[ "$BUILD_CUDA_ANSEL" == "true" ]]; then

  export LLNL_USE_OMPI_VARS=y
  export BUILD_OPENMP=${BUILD_OPENMP:=false}
  export BUILD_HIP=false
  export BUILD_PURE_CCE=false
  export BUILD_PURE_AMD=false
  export BUILD_AMDCLANG=false
  #openblas/0.3.21/
  prgenv_toolchain="ansel-gnu"
  module load spectrum-mpi/rolling-release
  module load gcc/7.3.1
  module_ver_string=gcc-7.3.1
  atdm_module_path=${JJE_SPACK_MODULES}/linux-rhel7-power9le/
else
  module load PrgEnv-cray
  module load cce/${prgenv_version}
  module load rocm/${ROCM_VERSION}
  export prgenv_toolchain="cray"
  export ATDM_LAPACK_LIBRARY_NAMES="sci_cray"
  export ATDM_BLAS_LIBRARY_NAMES="sci_cray"
  export ATDM_MPI_LIB="mpi"

  module_ver_string="cce-${prgenv_version}"
  compiler_specific_tpl_names=(  
    "python/${module_ver_string}"
    "cray-libsci"
    "boost/${module_ver_string}"
    "cmake/${module_ver_string}"
    "hdf5/${module_ver_string}"
    "metis-32bit/${module_ver_string}"
    "netcdf-c/${module_ver_string}"
    "libzip/${module_ver_string}"
    "ninja/${module_ver_string}"
    "parallel-netcdf/${module_ver_string}"
    "parmetis-32bit/${module_ver_string}"
    "superlu-dist/${module_ver_string}"
    "cgns/${module_ver_string}"
    "zlib-ng/${module_ver_string}"
  )
  export BLAS_ROOT="${CRAY_LIBSCI_PREFIX_DIR}"
  export LAPACK_ROOT="$BLAS_ROOT"
fi

atdm_module_path=$(find_toolchain_path "${module_ver_string}" "${module_arch_string}")
rc=$?

# Check the exit status
if [ $rc -eq 0 ]; then
    echo "Successfully found the installation path: ${atdm_module_path}"
else
    echo "Error: Module path detection: ${atdm_module_path}"
    return -1;
fi

module use ${atdm_module_path}

if [[ "$BUILD_CUDA_ANSEL" == "true" ]]; then

module load \
  openblas/0.3.21/${module_ver_string} \
  boost/1.79.0/${module_ver_string} \
  cmake/3.24.2/${module_ver_string} \
  hdf5/1.10.7/${module_ver_string} \
  metis-32bit/5.1.0/${module_ver_string} \
  netcdf-c/4.8.1/${module_ver_string} \
  libzip/1.2.0/${module_ver_string} \
  ninja/kitware/${module_ver_string} \
  parallel-netcdf/1.12.3/${module_ver_string} \
  parmetis-32bit/4.0.3/${module_ver_string} \
  superlu-dist/6.4.0/${module_ver_string} \
  cgns/4.3.0/${module_ver_string} \
  zlib/1.2.12/${module_ver_string}

export ZLIB_ROOT="${ATDM_ZLIB_ROOT}"
export HDF5_ROOT="${ATDM_HDF5_ROOT}"
export CGNS_ROOT="${ATDM_CGNS_ROOT}"
export NETCDF_ROOT="${ATDM_NETCDF_C_ROOT}"
export PNETCDF_ROOT="${ATDM_PARALLEL_NETCDF_ROOT}"
export BOOST_ROOT="${ATDM_BOOST_ROOT}"
export METIS_ROOT="${ATDM_METIS_ROOT}"
export PARMETIS_ROOT="${ATDM_PARMETIS_ROOT}"
export SUPERLUDIST_ROOT="${ATDM_SUPERLU_DIST_ROOT}"
export BLAS_ROOT="${ATDM_OPENBLAS_ROOT}"
export LAPACK_ROOT="$BLAS_ROOT"
export BINUTILS_ROOT="${ATDM_BINUTILS_ROOT}"
export LIBZIP_ROOT="$ATDM_LIBZIP_ROOT"

else

echo ""
echo "Loaded Modules"
module list
echo ""
echo "loading: ${compiler_specific_tpl_names[@]}"
echo "Module path set to: ${atdm_module_path}"
echo "Calling module load: craype-x86-trento craype-network-ofi libfabric cray-mpich ${compiler_specific_tpl_names[@]}"

# So far, this loads the correct compiler versions of the TPLs based on PrgEnv
module load \
  craype-x86-trento \
  craype-network-ofi \
  libfabric  \
  cray-mpich \
  "${compiler_specific_tpl_names[@]}" \

module_load_failed=$?
if [ "$module_load_failed" == "1" ] && [ x"$ATDM_IGNORE_MODULE_ERRORS" == "x" ]; then
  echo "-----------------------------------------------------------" 1>&2
  echo "----- " 1>&2
  echo "----- " 1>&2
  echo "----- ERROR ----- ERROR ----- ERROR ----- ERROR ----- ERROR" 1>&2
  echo -e "\n\n\n\n" 1>&2;
  echo "module load returned false - something is wrong, the script is stopping rather than leading you to further misery" 1>&2
  echo "you can forcefully skip this error check with ATDM_IGNORE_MODULE_ERRORS=true" 1>&2
  echo -e "\n\n\n\n" 1>&2;
  echo "----- ERROR ----- ERROR ----- ERROR ----- ERROR ----- ERROR" 1>&2
  echo "----- " 1>&2
  echo "----- " 1>&2
  echo "-----------------------------------------------------------" 1>&2
  return
fi

if [[ "$_rocm_version_before" != "$ROCM_VERSION" ]]; then

  if [[ "$ROCM_VERSION" != "7.13.0" ]]; then
    echo "WARNING: the rocm version you requested ROCM_VERSION=$_rocm_version_before was changed to $ROCM_VERSION"
  fi

fi
  if [[ "$_rocm_version_before" == "7.13.0" ]]; then
    # pull in the  nightly install 
    echo "Loading nightly ROCM..."
    ROCM_VERSION=7.13.0
    source /tscratch/jjellio/trilinos-dev/nightly-amd/sourceme-7.13.0a20260326-gfx94X.sh
  fi


if [ -z "${ROCM_PATH+x}" ]; then
  export ROCM_PATH=$(dirname $(dirname $(which amdclang)))
fi
echo "ROCM_PATH=$ROCM_PATH"
export MPICH_CXX=$(which amdclang++)
export MPICH_CC=$(which amdclang)

if [[ "$USE_LLVM" == "true" ]]; then
  # /collab/usr/global/tools/llvm/toss_4_x86_64_ib_cray/llvm_current
  export PATH="/collab/usr/global/tools/llvm/toss_4_x86_64_ib_cray/llvm_current/bin:$PATH"
  export LD_LIBRARY_PATH="/collab/usr/global/tools/llvm/toss_4_x86_64_ib_cray/llvm_current/lib:$LD_LIBRARY_PATH"
  export MPICH_CXX=$(which clang++)
  export MPICH_CC=$(which clang)
  echo "using LLVM: /collab/usr/global/tools/llvm/toss_4_x86_64_ib_cray/llvm_current"
  echo "MPICH_CXX=$MPICH_CXX"
fi

#module rm openblas/rocmcc-5.6.1/0.3.23
#unset ATDM_OPENBLAS_ROOT

# fix me these can't be set until modules are loaded
export ZLIB_ROOT="${ATDM_ZLIB_NG_ROOT}"
export HDF5_ROOT="${ATDM_HDF5_ROOT}"
export CGNS_ROOT="${ATDM_CGNS_ROOT}"
export NETCDF_ROOT="${ATDM_NETCDF_C_ROOT}"
export PNETCDF_ROOT="${ATDM_PARALLEL_NETCDF_ROOT}"
export BOOST_ROOT="${ATDM_BOOST_ROOT}"
export METIS_ROOT="${ATDM_METIS_ROOT}"
export PARMETIS_ROOT="${ATDM_PARMETIS_ROOT}"
export SUPERLUDIST_ROOT="${ATDM_SUPERLU_DIST_ROOT}"
export BINUTILS_ROOT="${ATDM_BINUTILS_ROOT:=}"
export LIBZIP_ROOT="${ATDM_LIBZIP_ROOT:=}"
# some of these depend on the compilers ... ugh
export BLAS_ROOT="${ATDM_OPENBLAS_ROOT:=${CRAY_LIBSCI_PREFIX_DIR}}"
export LAPACK_ROOT="$BLAS_ROOT"

#setup the python stuff
#echo "Loading my Python"
#echo "module --ignore_cache load py-h5py/${module_ver_string}"
#module --ignore_cache load py-h5py/${module_ver_string}

#echo "Removing the cruft"
#module rm hdf5-shared/${module_ver_string}/1.10.7 \
#          python/${module_ver_string}/3.9.13.1 \
#          cray-mpich/${module_ver_string}/8.1.26


#module rm openblas/rocmcc-5.6.1/0.3.23
#unset ATDM_OPENBLAS_ROOT

#atdm_lib_path="${HDF5_ROOT}/lib:${CGNS_ROOT}/lib:${NETCDF_ROOT}/lib"
#atdm_lib_path+=":${PNETCDF_ROOT}/lib:${BOOST_ROOT}/lib:${METIS_ROOT}/lib:${PARMETIS_ROOT}/lib"
#atdm_lib_path+=":${SUPERLUDIST_ROOT}/lib:${BLAS_ROOT}/lib:${LAPACK_ROOT}/lib:${BINUTILS_ROOT}/lib"
# would be nice to try w/out... we are rpathing most things
if [[ "$ATDM_DUCT_TAPE_ADD_CRAYPE_LD_LIBRARY" == "true" ]]; then
  echo "DUCT-TAPE: adding CrayPE library to LD_LIBRARY_PATH ($CRAY_LD_LIBRARY_PATH)"
  echo "           DISABLE with ATDM_DUCT_TAPE_ADD_CRAYPE_LD_LIBRARY != true "
  export LD_LIBRARY_PATH="$CRAY_LD_LIBRARY_PATH:${LD_LIBRARY_PATH}"
fi
module rm binutils/2.38

fi

#this is the workaround for ELCAP-XXX:
if [[ "$ATDM_DUCT_TAPE_REMOVE_HIP_PATH" == "true" ]]; then
  echo "DUCT-TAPE: unset HIP_PATH"
  echo "           DISABLE with ATDM_DUCT_TAPE_REMOVE_HIP_PATH != true "
  unset HIP_PATH
fi

echo "ROCM_PATH=$ROCM_PATH"
echo "Setting HSA_XNACK=1"
export HSA_XNACK=1

echo "LAPACK_ROOT=${LAPACK_ROOT}"
echo "BLAS_ROOT=${BLAS_ROOT}"
echo "ZLIB_ROOT=${ZLIB_ROOT}"
echo "HDF5_ROOT=${HDF5_ROOT}"
echo "CGNS_ROOT=${CGNS_ROOT}"
echo "NETCDF_ROOT=${NETCDF_ROOT}"
echo "PNETCDF_ROOT=${PNETCDF_ROOT}"
echo "BOOST_ROOT=${BOOST_ROOT}"
echo "METIS_ROOT=${METIS_ROOT}"
echo "PARMETIS_ROOT=${PARMETIS_ROOT}"
echo "SUPERLUDIST_ROOT=${SUPERLUDIST_ROOT}"
echo "BINUTILS_ROOT=${BINUTILS_ROOT}"
echo "LIBZIP_ROOT=$LIBZIP_ROOT"

# 
#  TPL_BinUtils_LIBRARIES
#  TPL_BLAS_LIBRARIES
#  TPL_Boost_LIBRARIES
#  TPL_BoostLib_LIBRARIES
#  TPL_METIS_LIBRARIES
#  TPL_ParMETIS_LIBRARIES
#  TPL_HWLOC_LIBRARIES
#  TPL_LAPACK_LIBRARIES
#  TPL_CGNS_LIBRARIES
#  TPL_HDF5_LIBRARIES
#  TPL_Netcdf_LIBRARIES
#  TPL_SuperLUDist_LIBRARIES
#  TPL_DLlib_LIBRARIES
##
function atdm_add_tpls(){
  # edit array in place
  # https://stackoverflow.com/questions/10582763/how-to-return-an-array-in-bash-without-using-globals
  # input should be the name of the variable to append to
  local -n args=$1
  args+=(
    # see if this avoids lib m getting stuffed in the link flags
    "-DMATH_LIBRARY_IS_SUPPLIED:BOOL=TRUE" 
	  # binutils
    "-DTPL_ENABLE_BinUtils:BOOL=OFF"
    "-DBinUtils_INCLUDE_DIRS=$BINUTILS_ROOT/include"
    "-DBinUtils_LIBRARY_DIRS=$BINUTILS_ROOT/lib"
    # blas/lapack
	  "-DTPL_ENABLE_BLAS:BOOL=ON"
	  "-DTPL_ENABLE_LAPACK:BOOL=ON"
	  "-DBLAS_LIBRARY_NAMES=$ATDM_BLAS_LIBRARY_NAMES"
	  "-DBLAS_INCLUDE_DIRS=$BLAS_ROOT/include"
	  "-DBLAS_LIBRARY_DIRS=$BLAS_ROOT/lib"
	  "-DLAPACK_LIBRARY_NAMES=$ATDM_LAPACK_LIBRARY_NAMES"
	  "-DLAPACK_INCLUDE_DIRS=$BLAS_ROOT/include"
	  "-DLAPACK_LIBRARY_DIRS=$BLAS_ROOT/lib"
    # Boost/BoostLib
	  "-DTPL_ENABLE_Boost:BOOL=ON"
	  "-DTPL_ENABLE_BoostLib:BOOL=ON"
	  "-DBoost_INCLUDE_DIRS=$BOOST_ROOT/include"
	  "-DBoost_LIBRARY_DIRS=$BOOST_ROOT/lib"
	  "-DBoostLib_INCLUDE_DIRS=$BOOST_ROOT/include"
	  "-DBoostLib_LIBRARY_DIRS=$BOOST_ROOT/lib"
	  # Metis / ParMetis
	  "-DTPL_ENABLE_METIS:BOOL=ON"
	  "-DTPL_ENABLE_ParMETIS:BOOL=ON"
	  "-DMETIS_INCLUDE_DIRS=$METIS_ROOT/include"
	  "-DMETIS_LIBRARY_DIRS=$METIS_ROOT/lib"
	  "-DParMETIS_INCLUDE_DIRS=$PARMETIS_ROOT/include;$METIS_ROOT/include"
	  "-DParMETIS_LIBRARY_DIRS=$PARMETIS_ROOT/lib;$METIS_ROOT/lib"
	  # CGNS
	  "-DTPL_ENABLE_CGNS:BOOL=ON"
	  "-DCGNS_INCLUDE_DIRS=$CGNS_ROOT/include"
	  "-DCGNS_LIBRARY_DIRS=$CGNS_ROOT/lib"
    # HDF5
	  "-DTPL_ENABLE_HDF5:BOOL=ON"
	  "-DHDF5_LIBRARY_DIRS=${HDF5_ROOT}/lib;${ZLIB_ROOT}/lib"
	  "-DHDF5_INCLUDE_DIRS=${HDF5_ROOT}/include"
	  "-DHDF5_LIBRARY_NAMES=hdf5_hl;hdf5;z;dl"
    # NetCDF
	  "-DTPL_ENABLE_Netcdf:BOOL=ON"
    "-DNetcdf_LIBRARY_DIRS=${ZLIB_ROOT}/lib;${BOOST_ROOT}/lib;${NETCDF_ROOT}/lib;${PNETCDF_ROOT}/lib;${HDF5_ROOT}/lib;${LIBZIP_ROOT}/lib"
	  "-DNetcdf_LIBRARY_NAMES=${Netcdf_LIBRARY_NAMES}"
	  "-DNetcdf_INCLUDE_DIRS=${NETCDF_ROOT}/include;${PNETCDF_ROOT}/include"
	  # SuperLU_dist
	  "-DTPL_ENABLE_SuperLUDist:BOOL=OFF"
	  "-DSuperLUDist_INCLUDE_DIRS=${SUPERLUDIST_ROOT}/include"
	  "-DSuperLUDist_LIBRARY_DIRS=${SUPERLUDIST_ROOT}/lib"

	  # disables ...
	  "-DTPL_ENABLE_Matio=OFF"
    "-DTPL_ENABLE_X11=OFF"

    #"-DTrilinos_MAKE_INSTALL_GROUP=elcapnda"
    #"-DTrilinos_MAKE_INSTALL_GROUP_READABLE:BOOL=TRUE"
    #"-DTrilinos_MAKE_INSTALL_GROUP_WRITABLE:BOOL=FALSE"
    #"-DTrilinos_MAKE_INSTALL_WORLD_READABLE:BOOL=TRUE"
  )

  if [[ "$BUILD_CUDA_ANSEL" == "true" ]]; then
    args+=(
      # MPI
  	  "-DTPL_ENABLE_MPI:BOOL=ON"
  	  "-DMPI_USE_COMPILER_WRAPPERS=ON"
      "-DMPI_EXEC_NUMPROCS_FLAG=-M;gpu;-r4;c8;-g1;-p"
      # we may have to wrap slurm ... so we can cleanup after it =\
      "-DMPI_EXEC=jsrun" 
      # we do this so we have rocms libs added. this should go away once rocm is a TPL
  	  "-DTPL_ENABLE_DLlib:BOOL=ON"
    )
  else
    if [[ "$cce_offload_target" == "gfx90a" ]]; then
    args+=(
      "-DMPI_EXEC_NUMPROCS_FLAG=run;-c;8;-g;1;-n"
      "-DMPI_EXEC=flux"
    )
    elif [[ "$cce_offload_target" == "gfx942" ]]; then
    args+=(
      "-DMPI_EXEC_NUMPROCS_FLAG=run;-x;-N;1;-n"
      #"-DMPI_EXEC_NUMPROCS_FLAG=run;-o;mpibind=off;-o;cpu-affinity=per-task;-c2;-n"
      #"-DMPI_EXEC_POST_NUMPROCS_FLAGS=${ATDM_ENV_PREFIX}/../tools/gpu_to_cpumask.sh"
      #"-DMPI_EXEC_NUMPROCS_FLAG=run;-o;exit-timeout=10s;-N;1;-o;mpibind=off;-o;cpu-affinity=per-task;-o;gpu-affinity=per-task;-c6;--gpus-per-task=1;-n"
      "-DMPI_EXEC=flux"
    )
    fi
    args+=(
      # MPI
  	  "-DTPL_ENABLE_MPI:BOOL=ON"
  	  "-DMPI_USE_COMPILER_WRAPPERS=OFF"
      #"-DMPI_EXEC_NUMPROCS_FLAG=--srun_clean;--srun_pause=1;--mpibind=off;--exclusive;-c8;--gpus-per-task=1;-n"
      # a tool for injecting a wrapper around the executable if needed
      #"-DMPI_EXEC_POST_NUMPROCS_FLAGS=/usr/WS1/jjellio/rzvernal/src/trilinos_launch"
      # we may have to wrap slurm ... so we can cleanup after it =\
      #"-DMPI_EXEC=/p/lustre1/jjellio/spack/srun_wrap"
      #"-DMPI_EXEC_NUMPROCS_FLAG=run;-o;exit-timeout=10s;-N;1;-o;mpibind=off;-n"
  
      # we do this so we have rocms libs added. this should go away once rocm is a TPL
  	  "-DTPL_ENABLE_DLlib:BOOL=ON"
    )
    if [[ "$BUILD_HIP" == "true" ]]; then
      args+=(
  	  "-DDLlib_INCLUDE_DIRS=${ROCM_PATH}/include"
  	  "-DDLlib_LIBRARY_DIRS=${ROCM_PATH}/lib"
      # DO NOT link the GTL, as if it brings in a differnet ROCM you  are hosed ${CRAY_MPICH_ROOTDIR}/gtl/lib/
      # mpi_gtl_hsa
      # even if we TPL enable the ROCM libs,  we still want to include amdhip64 for MPI
  	  "-DDLlib_LIBRARY_NAMES=dl;m"
      )
    fi

    if [[ "${ATDM_USE_DEVICE_TPLS}" == "true" ]]; then
     args+=(
      # we do this so we have rocms libs added. this should go away once rocm is a TPL
  	  "-DKokkosKernels_ENABLE_TPL_ROCBLAS:BOOL=ON"
  	  "-DTPL_ENABLE_ROCBLAS:BOOL=ON"
  	    "-DROCBLAS_INCLUDE_DIRS=${ROCM_PATH}/include"
  	    "-DROCBLAS_LIBRARY_DIRS=${ROCM_PATH}/lib"
      )

     # this was patched on Dec 2
     #if [[ "$ROCM_VERSION" != "6.4.3" ]]; then
     args+=(
  	  "-DKokkosKernels_ENABLE_TPL_ROCSOLVER:BOOL=ON"
  	  "-DTPL_ENABLE_ROCSOLVER:BOOL=ON"
  	    "-DROCSOLVER_INCLUDE_DIRS=${ROCM_PATH}/include"
  	    "-DROCSOLVER_LIBRARY_DIRS=${ROCM_PATH}/lib"
        )
     args+=(
  	  "-DKokkosKernels_ENABLE_TPL_ROCSPARSE:BOOL=ON"
  	  "-DTPL_ENABLE_ROCSPARSE:BOOL=ON"
  	    "-DROCSPARSE_INCLUDE_DIRS=${ROCM_PATH}/include"
  	    "-DROCSPARSE_LIBRARY_DIRS=${ROCM_PATH}/lib"
     )
    else
      # tacho requires them
      args+=("-DTrilinos_ENABLE_ShyLU_NodeTacho=OFF")
    fi
  fi

  if [[ "$CMAKE_INSTALL_PREFIX" != "" ]]; then
    args+=(
      "-DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}/$build_id/trilinos"
    )
  else
    args+=(
      "-DCMAKE_INSTALL_PREFIX=/pscratch/${USER}/installs/$build_id/trilinos"
    )
  fi
}

# set all 

function atdm_set_compiler_and_arch_hip(){
  local -n args=$1

  ATDM_CONFIG_F_FLAGS=""
  ATDM_CONFIG_C_FLAGS=""
  ATDM_CONFIG_CXX_FLAGS=""
  Trilinos_EXTRA_LINK_FLAGS=""

  if [[ "$ATDM_USE_WRAPPERS" == "mpi" ]]; then
    MPICC=$(which mpicc)
    MPICXX=$(which mpicxx)
    MPIF90=$(which mpif90)
  elif [[ "$ATDM_USE_WRAPPERS" == "cray" ]]; then
    MPICC=$(which cc)
    MPICXX=$(which CC)
    MPIF90=$(which ftn)
  elif [[ "$ATDM_USE_WRAPPERS" == "none" ]]; then
    MPICC=$(which amdclang)
    MPICXX=$(which amdclang++)
    MPIF90=$(which amdflang)
  fi
  CMAKE_LINKER="$MPICXX"

  if [[ "$ATDM_ENABLE_FORTRAN" == "true" ]]; then
  if [ "$ATDM_DUCT_TAPE_USE_FC" == "newflang" ]; then
    export MPICH_FC="/usr/tce/packages/rocm/rocm-flangbeta4/bin/flang-new"
    echo "DUCT-TAPE: ATDM_DUCT_TAPE_USE_FC=newflang"
    echo "           Setting MPICH_FC=$MPICH_FC"
  elif [ "$ATDM_DUCT_TAPE_USE_FC" == "crayftn" ]; then
    export MPICH_FC="/opt/cray/pe/cce/17.0.1/bin/crayftn"
    echo "DUCT-TAPE: ATDM_DUCT_TAPE_USE_FC=crayftn"
    echo "           Setting MPICH_FC=$MPICH_FC"
    CMAKE_LINKER+=" -L/opt/cray/pe/cce/17.0.1/cce/x86_64/lib/ -lf"
  fi
  fi

  args+=( 
  )


  if [[ "$BUILD_SERIAL" == "true" ]]; then
  args+=(
    "-DTpetra_INST_SERIAL:BOOL=ON"
  )

  else
  args+=(
    "-DTpetra_INST_SERIAL:BOOL=OFF"
  )

  fi

# add openmp if it was requested
  if [[ "$BUILD_OPENMP" == "true" ]]; then
    args+=( 
            "-DKokkos_ENABLE_OPENMP:BOOL=ON"
            "-DTpetra_INST_OPENMP:BOOL=ON"
            "-DTrilinos_ENABLE_OpenMP:BOOL=ON"
    )
  else
    args+=( 
            "-DKokkos_ENABLE_OPENMP:BOOL=OFF"
            "-DTpetra_INST_OPENMP:BOOL=OFF"
            "-DTrilinos_ENABLE_OpenMP:BOOL=OFF"
    )
  fi


  linker_flags=""
  if [[ "$ATDM_ENABLE_OFFLOAD_NEW_DRIVER" == "true" ]]; then
    ATDM_CONFIG_CXX_FLAGS+="--offload-new-driver "
    linker_flags+="--offload-new-driver "
  fi

  if [[ "$ATDM_ENABLE_SPLITTING" == "true" ]]; then
    ATDM_CONFIG_CXX_FLAGS+="-Xoffload-linker --lto-partitions=10 -mllvm -amdgpu-module-splitting-max-depth=2 "
    linker_flags+="-Xoffload-linker --lto-partitions=10 -mllvm -amdgpu-module-splitting-max-depth=2 "

    args+=( "-DCMAKE_AR=$(which llvm-ar)"
            "-DCMAKE_LD=$(which lld)"
            "-DCMAKE_RANLIB=$(which llvm-ranlib)" )
  fi

  if [[ "$ATDM_LTO_THIN" == "true" ]]; then
    ATDM_CONFIG_CXX_FLAGS+="--offload-new-driver -foffload-lto=thin "
    linker_flags+="--offload-new-driver -foffload-lto=thin "

    #linker_flags+="-flto-jobs=${ATDM_THIN_JOBS} "
    args+=( "-DCMAKE_AR=$(which llvm-ar)"
            "-DCMAKE_LD=$(which lld)"
            "-DCMAKE_RANLIB=$(which llvm-ranlib)" )
  fi

  # add the HIP
  if [[ "$BUILD_HIP" == "true" ]]; then
    args+=( 
            "-DKokkos_ENABLE_HIP:BOOL=ON" 
            "-DTpetra_INST_HIP:BOOL=ON"
          "-DKokkosKernels_ENABLE_TPL_BLAS:BOOL=ON"
  	      "-DKokkosKernels_ENABLE_TPL_LAPACK:BOOL=ON"
          "-DSacado_ENABLE_HIERARCHICAL_DFAD=ON"
    )
    if [[ "$cce_offload_target" == "gfx90a" ]]; then
      args+=("-DKokkos_ARCH_VEGA90A:BOOL=ON"
             "-DKokkos_ARCH_ZEN3:BOOL=ON")
    elif [[ "$cce_offload_target" == "gfx906" ]]; then
      args+=("-DKokkos_ARCH_VEGA906:BOOL=ON")
    elif [[ "$cce_offload_target" == "gfx940" ]]; then
      args+=("-DKokkos_ARCH_AMD_GFX940:BOOL=ON")
    elif [[ "$cce_offload_target" == "gfx942" ]]; then
    	if [[ "$have_apu" == "true" ]]; then
      		args+=("-DKokkos_ARCH_AMD_GFX942_APU:BOOL=ON")
	else
      		args+=("-DKokkos_ARCH_AMD_GFX942:BOOL=ON")
	fi
        args+=("-DKokkos_ARCH_NATIVE:BOOL=ON")
    fi
  
    # top level flags that can be set always
    # it's okay to have this with hipcc, amdclang or crayclang
    if [[ "$ATDM_DUCT_TAPE_SET_OFFLOAD_ARCH" == "true" ]]; then
      echo "DUCT-TAPE: adding CXX_FLAGS+=--offload-arch=${cce_offload_target}"
      echo "           DISABLE with ATDM_DUCT_TAPE_SET_OFFLOAD_ARCH != true"
      ATDM_CONFIG_CXX_FLAGS+="--offload-arch=${cce_offload_target} "
    fi
    if [[ "$ATDM_DUCT_TAPE_SET_ROCM_PATH" == "true" ]]; then
      echo "DUCT-TAPE: adding CXX_FLAGS+=--rocm-path=$ROCM_PATH"
      echo "           DISABLE with ATDM_DUCT_TAPE_SET_ROCM_PATH != true"
      ATDM_CONFIG_CXX_FLAGS+="--rocm-path=$ROCM_PATH "
    fi

    linker_flags+="-x none --hip-link "
    if [[ "$ENABLE_RDC" == "true" ]]; then
      args+=( "-DKokkos_ENABLE_HIP_RELOCATABLE_DEVICE_CODE:BOOL=ON" )
    fi

    # optional use old 2M pages
    #if [[ "$ATDM_USE_HUGETLBFS" == "true" ]]; then
    linker_flags+="-fuse-ld=lld -Wl,--image-base=0x20000000 -Wl,-z,common-page-size=0x200000 -Wl,-z,max-page-size=0x200000 -Wl,--whole-archive,-lhugetlbfs,--no-whole-archive "
    echo "Adding hugetlbfs linker flags: -Wl,--image-base=0x20000000 -Wl,--whole-archive,-lhugetlbfs,--no-whole-archive" 
    #fi

    ATDM_CONFIG_CXX_FLAGS+="-x hip "
    # with CCE, we need to setup the linker (to ignore hip) and CXX flags to target hip
    if [[ "$BUILD_PURE_CCE" == "true" ]]; then
      export MPICXX=$(which CC)
      
      # this is to work around Cray failures - it should not be used regularly
      if [[ "$USE_CRAY_FIXES" == "true" ]]; then
        ATDM_CONFIG_CXX_FLAGS+="-fno-cray "
      fi
    else
      # with non-CCE - if we use amdclang, then we need similar settings to CCE
      if [[ "$BUILD_AMDCLANG" == "true" ]]; then
        #export MPICXX=$(which amdclang++)
        #export MPICC=$(which amdclang)
        #export MPIF90=$(which amdflang)
        : # nothing
      else
        # we don't need to deal with linker flags with hipcc, but because we
        # need cray to link (because we use crayfortran, we'll set the linker explicitly below
        export MPICXX=$(which hipcc)
      fi
    fi

    # this is a mess.  To work around cray linking tcmalloc (because Fortran keeps bringing it in)
    # I need to override the full linker definition, because you can't have the cray-specific flags on
    # amd's link line, because Cmake uses CMAKE_*_FLAGS during the compiler tests during setup
    # So, if you set the flags in the FLAGS variables, you can't configure w/AMD.
    # instead, we define the linker rules and drop Cray's -hsystem_alloc flag in there.
    #
    # if we do a PURE_AMD build - then this likely will not be needed for that
    # but I'll need to see if flang can handle things first

    if [[ "$ENABLE_RDC" == "true" ]]; then
    if [[ "$ATDM_DUCT_TAPE_USE_FUDGE_LINK" == "true" ]]; then
      echo "DUCT-TAPE: adding fudge-link.sh as linker"
      echo "           DISABLE with ATDM_DUCT_TAPE_USE_FUDGE_LINK != true"
    args+=(
            "-DCMAKE_CXX_LINK_EXECUTABLE=/p/lustre1/jjellio/EMPIRE-work/fudge-link.sh <CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>"
            #"-DCMAKE_CXX_CREATE_SHARED_LIBRARY=<CMAKE_LINKER> <CMAKE_SHARED_LIBRARY_CXX_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <SONAME_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>"
            "-DCMAKE_Fortran_LINK_EXECUTABLE=<CMAKE_Fortran_COMPILER> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>"
            # no -x none here, because the linker is the fortran compiler
            "-DCMAKE_Fortran_CREATE_SHARED_LIBRARY=<CMAKE_Fortran_COMPILER> <CMAKE_SHARED_LIBRARY_Fortran_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS> <SONAME_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>"
          )
    fi
    fi
    # -mllvm -amdgpu-early-inline-all=true -mllvm -amdgpu-function-calls=false
    # if we aren't using hipcc, we need to control the amd optimization flags
    if [ "$BUILD_PURE_CCE" == "true" ]  || [ "$BUILD_AMDCLANG" == "true" ]; then
      if [ "$AMD_EARLY_INLINE_ALL" == "true" ]; then
        ATDM_CONFIG_CXX_FLAGS+="-mllvm -amdgpu-early-inline-all=true "
      else
        ATDM_CONFIG_CXX_FLAGS+="-mllvm -amdgpu-early-inline-all=false "
      fi
      if [ "$AMD_FUNCTION_CALLS" == "true" ]; then
        ATDM_CONFIG_CXX_FLAGS+="-mllvm -amdgpu-function-calls=true "
      else
        ATDM_CONFIG_CXX_FLAGS+="-mllvm -amdgpu-function-calls=false "
      fi
      if [ "$GPU_INLINE_THRESHOLD" != "false" ]; then
        ATDM_CONFIG_CXX_FLAGS+="-fgpu-inline-threshold=${GPU_INLINE_THRESHOLD} "
      fi
    fi

    if [ "$AMD_REPORT_KERNEL_USAGE" == "true" ]; then
      ATDM_CONFIG_CXX_FLAGS+="-Rpass-analysis=kernel-resource-usage "
    fi
  
  else
    args+=( 
            "-DKokkos_ENABLE_HIP:BOOL=OFF"
            "-DTpetra_INST_HIP:BOOL=OFF"
    )
  fi
  if [[ "${linker_flags}" != "" ]]; then
  args+=( "-DCMAKE_EXE_LINKER_FLAGS=${linker_flags} "
          "-DCMAKE_SHARED_LINKER_FLAGS=${linker_flags} " )
  fi
  # end of add hip

  if [ "$ROCM_VERSION" == "7.1.0" ] | [ "$ROCM_VERSION" == "7.2.0" ]; then
    args+=( "-DKokkos_ENABLE_IMPL_HIP_MALLOC_ASYNC=OFF" )
  fi

  if [[ "${BUILD_ASAN}" == "true" ]]; then
    ATDM_CONFIG_CXX_FLAGS+=" -g -O1 --offload-arch=gfx90a:xnack+ -fsanitize=address -shared-libsan "
  fi

  # Trilinos does not provide a way to set MPI's libs/includes, so we have to stitch that in
  if [[ "$ATDM_DUCT_TAPE_ADD_MPI_INCLIBS" == "true" ]]; then
     echo "DUCT TAPE: Adding -I${CRAY_MPICH_DIR}/include -I${ROCM_PATH}/include to C, CXX and Ftn"
     echo "DUCT TAPE: Adding -L${CRAY_MPICH_DIR}/lib -Wl,-rpath,${CRAY_MPICH_DIR}/lib -l${ATDM_MPI_LIB}"
     echo "DUCT TAPE: Adding -L${CRAY_MPICH_ROOTDIR}/gtl/lib -Wl,-rpath,${CRAY_MPICH_ROOTDIR}/gtl/lib -lmpi_gtl_hsa "
     echo "           DISABLE with ATDM_DUCT_TAPE_ADD_MPI_INCLIBS != true"
     ATDM_CONFIG_CXX_FLAGS+="-I${CRAY_MPICH_DIR}/include -I${ROCM_PATH}/include "
     ATDM_CONFIG_C_FLAGS+="-I${CRAY_MPICH_DIR}/include -I${ROCM_PATH}/include "
     ATDM_CONFIG_F_FLAGS+="-I${CRAY_MPICH_DIR}/include -I${ROCM_PATH}/include "
  
  fi
  Trilinos_EXTRA_LINK_FLAGS+="-L${CRAY_MPICH_DIR}/lib -Wl,-rpath,${CRAY_MPICH_DIR}/lib -l${ATDM_MPI_LIB} -lxpmem "
  Trilinos_EXTRA_LINK_FLAGS+="-L${CRAY_MPICH_ROOTDIR}/gtl/lib -Wl,-rpath,${CRAY_MPICH_ROOTDIR}/gtl/lib -lmpi_gtl_hsa "


  echo "DUCT TAPE: Adding -L${ROCM_PATH}/lib -Wl,-rpath,${ROCM_PATH}/lib -Wl,-rpath,${ROCM_PATH}/llvm/lib "
  Trilinos_EXTRA_LINK_FLAGS+="-L${ROCM_PATH}/lib -Wl,-rpath,${ROCM_PATH}/lib -Wl,-rpath,${ROCM_PATH}/llvm/lib "
  Trilinos_EXTRA_LINK_FLAGS+="-Wl,--disable-new-dtags,--as-needed,-lpthread,-lm,--no-as-needed"

  #if [[ "$ATDM_DUCT_TAPE_ADD_CLANG_BUILTIN" == "true" ]]; then
  #  builtin_path=$(find $ROCM_PATH/lib/llvm/lib -name "libclang_rt.builtins-x86_64.a")
  #  builtin_dir=$(dirname "$builtin_path")
  #  echo "DUCT TAPE: adding: ${builtin_path}"
  #  echo "           DISABLE with ATDM_DUCT_TAPE_ADD_CLANG_BUILTIN != true"
  #
  #  Trilinos_EXTRA_LINK_FLAGS+="${builtin_path} "
  #fi

  #if [[ "${ATDM_DUCT_TAPE_ADD_CLANG17_BUILTIN}" == "true" ]]; then
  #  builtin_path=$(find /opt/rocm-6.0.2/lib/llvm/lib -name "libclang_rt.builtins-x86_64.a")
  #  builtin_dir=$(dirname "$builtin_path")
  #  echo "DUCT TAPE: adding: ${builtin_path} "
  #  echo "           DISABLE with ATDM_DUCT_TAPE_ADD_CLANG17_BUILTIN != true"
  #  Trilinos_EXTRA_LINK_FLAGS+="${builtin_path} "
  #fi

  echo ROCM_VERSION=$ROCM_VERSION
  if jje_version_ge "$ROCM_VERSION" "7.2"; then
    echo "Adding -Xclang -fno-cuda-host-device-constexpr"
    args+=("-DThyraCore_CXX_FLAGS=-Xclang -fno-cuda-host-device-constexpr"
           #"-DThyra_CXX_FLAGS=-Xclang -fno-cuda-host-device-constexpr"
          )

    # kokkos that I have spams lots of deprecated messages...
    ATDM_CONFIG_CXX_FLAGS+="-Wno-deprecated-attributes "
  fi

  #if [[ "$ATDM_ENABLE_FORTRAN" == "false" ]]; then
    args+=(
      "-DFC_FN_UNDERSCORE=UNDER"
      #"STKUtil_CXX_FLAGS=-DFORTRAN_ONE_UNDERSCORE"
      #"STKCoupling_CXX_FLAGS=-DFORTRAN_ONE_UNDERSCORE"
      #"STKMath_CXX_FLAGS=-DFORTRAN_ONE_UNDERSCORE"
      #"STKSimd_CXX_FLAGS=-DFORTRAN_ONE_UNDERSCORE"
      #"STKTopology_CXX_FLAGS=-DFORTRAN_ONE_UNDERSCORE"
      #"STKMesh_CXX_FLAGS=-DFORTRAN_ONE_UNDERSCORE"
      #"STKIO_CXX_FLAGS=-DFORTRAN_ONE_UNDERSCORE"
      #"STKSearch_CXX_FLAGS=-DFORTRAN_ONE_UNDERSCORE"
      #"STKTransfer_CXX_FLAGS=-DFORTRAN_ONE_UNDERSCORE"
      #"STKTools_CXX_FLAGS=-DFORTRAN_ONE_UNDERSCORE"
      #"STKBalance_CXX_FLAGS=-DFORTRAN_ONE_UNDERSCORE"
      #"STKExprEval_CXX_FLAGS=-DFORTRAN_ONE_UNDERSCORE"
      #"STKEmend_CXX_FLAGS=-DFORTRAN_ONE_UNDERSCORE"
      #"STK_CXX_FLAGS=-DFORTRAN_ONE_UNDERSCORE"
      )
  #fi


  if [[ "$BUILD_DEBUG_SYM" == "true" ]]; then
    if [ "$ENABLE_RDC" == "true" ]; then
      if [ "$ROCM_VERSION" == "6.4.2" ] || [ "$ROCM_VERSION" == "6.4.3" ]; then
        ATDM_CONFIG_CXX_FLAGS+="-gline-tables-only "
      else
        ATDM_CONFIG_CXX_FLAGS+="-g "
      fi
    else
      ATDM_CONFIG_CXX_FLAGS+="-g "
    fi
  fi

  # fix for Cray tcmalloc problem
  if [[ "$MPIF90" =~ "ftn" ]]; then
    if [[ "$BUILD_PURE_AMD" != "true" ]]; then

      if [[ "$ATDM_DUCT_TAPE_FORTRAN_ALLOC" == "true" ]]; then
        echo "DUCT-TAPE: ADDING Fortran flag: -hsystem_alloc, DISABLE ATDM_DUCT_TAPE_FORTRAN_ALLOC != true"
        ATDM_CONFIG_F_FLAGS+="-hsystem_alloc "
      fi
      if [[ "$ATDM_DUCT_TAPE_FORTRAN_M2244" == "true" ]]; then
        echo "DUCT-TAPE: ADDING Fortran flag: -M2244, DISABLE ATDM_DUCT_TAPE_FORTRAN_M2244 != true"
        ATDM_CONFIG_F_FLAGS+="-M2244 "
      fi
    fi
  fi

  # these can't handle RDC atm, because they have no HIP
  if [ "$ENABLE_RDC" == "true" ]; then
  if [ "$ROCM_VERSION" == "5.3.0" ] || [ "$ROCM_VERSION" == "5.4.0" ] || [ "$ROCM_VERSION" == "5.4.3" ] || [ "$ROCM_VERSION" == "5.5.0" ]; then
  echo "DUCT TAPE: removing RDC flags from SEACAS packages"
  args+=(
    "-DSEACASExodus_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASNemesis_CXX_FLAGS=-fno-gpu-rdc"
    #"-DSEACASIoss_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASChaco_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASAprepro_lib_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASSuplibC_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASSuplibCpp_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASAprepro_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASConjoin_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASEjoin_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASEpu_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASCpup_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASExodiff_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASExomatlab_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASExo_format_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASNas2exo_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASZellij_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASNemslice_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASNemspread_CXX_FLAGS=-fno-gpu-rdc"
    #"-DSEACASSlice_CXX_FLAGS=-fno-gpu-rdc"
    #"-DSEACAS_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASNemesis_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASExo_format_CXX_FLAGS=-fno-gpu-rdc"
    "-DSEACASExodiff_CXX_FLAGS=-fno-gpu-rdc"
    )  
  fi
  fi
}


function atdm_set_compiler_and_arch_cuda(){
  local -n args=$1

  ATDM_CONFIG_CXX_FLAGS=""

  MPICC=$(which mpicc)
  MPICXX=$(which mpicxx)
  MPIF90=$(which mpif90)


  args+=( 
    "-DKokkos_ARCH_POWER9:BOOL=ON"
    "-DKokkos_ENABLE_SERIAL:BOOL=ON"
    "-DTpetra_INST_SERIAL:BOOL=ON"
    "-DKokkos_ENABLE_CUDA:BOOL=ON" 
    "-DTpetra_INST_CUDA:BOOL=ON"
    "-DKokkos_ARCH_VOLTA70:BOOL=ON"
  )

  
  # enable RDC
  if [[ "$ENABLE_RDC" == "true" ]]; then
    args+=( "-DKokkos_ENABLE_CUDA_RELOCATABLE_DEVICE_CODE:BOOL=ON" )
  fi

  if [[ "$BUILD_DEBUG_SYM" == "true" ]]; then
    ATDM_CONFIG_CXX_FLAGS+="-g "
  fi

  args+=( "-DCMAKE_EXE_LINKER_FLAGS=-lgfortran "
          "-DCMAKE_SHARED_LINKER_FLAGS=-lgfortran " )
                              
}

function atdm_set_compiler_and_arch(){
  local -n args=$1
  if [[ "$BUILD_CUDA_ANSEL" == "true" ]]; then
    atdm_set_compiler_and_arch_cuda "$1"
  else
    atdm_set_compiler_and_arch_hip "$1"
  fi

  # finally, set the compilers and flags, since we know it all now
  args+=(
    "-DCMAKE_CXX_COMPILER=$MPICXX"
    "-DCMAKE_C_COMPILER=$MPICC"
    "-DCMAKE_Fortran_COMPILER=$MPIF90"
    "-DCMAKE_CXX_FLAGS=${ATDM_CONFIG_CXX_FLAGS}"
    "-DCMAKE_Fortran_FLAGS=${ATDM_CONFIG_F_FLAGS}"
    "-DCMAKE_C_FLAGS=${ATDM_CONFIG_C_FLAGS}"
    "-DCMAKE_LINKER=$CMAKE_LINKER"

    "-DTrilinos_EXTRA_LINK_FLAGS=${Trilinos_EXTRA_LINK_FLAGS}"
  )


  if [[ "$CXX_STD" != "14" ]]; then
    args+=( "-DCMAKE_CXX_STANDARD=${CXX_STD}" )
  fi
}

function atdm_set_disabled_packages(){
  local -n args=$1

  if [[ "$ATDM_ENABLE_FORTRAN" == "true" ]];then
    args+=( 
      # enables..
      # we luv u (but not as much as the C children)
      "-DTrilinos_ENABLE_Fortran:BOOL=ON"
    )
  else
    args+=( 
      "-DTrilinos_ENABLE_Fortran:BOOL=OFF"
      "-DAztecOO_C_FLAGS=-Wno-implicit-function-declaration"
    )
  fi

  args+=(
    # package disables
	  # taken from cmake/std/atdm/ATDMDisables.cmake
	  "-DTrilinos_ENABLE_TrilinosATDMConfigTests:BOOL=OFF"

	  "-DTrilinos_ENABLE_TrilinosFrameworkTests=OFF"
    #"-DTrilinos_ENABLE_MiniTensor=OFF"
    "-DTrilinos_ENABLE_Isorropia=OFF"
    "-DTrilinos_ENABLE_KokkosExample=OFF"
    "-DTrilinos_ENABLE_Domi=OFF"
    "-DTrilinos_ENABLE_Pliris=OFF"
    "-DTrilinos_ENABLE_Komplex=OFF"
    "-DTrilinos_ENABLE_FEI=OFF"
    "-DTrilinos_ENABLE_TriKota=OFF"
    "-DTrilinos_ENABLE_Compadre=OFF"
    #"-DTrilinos_ENABLE_STKClassic=OFF"
    #"-DTrilinos_ENABLE_STKSearchUtil=OFF"
    #"-DTrilinos_ENABLE_STKUnit_tests=OFF"
    #"-DTrilinos_ENABLE_STKDoc_tests=OFF"
    #"-DTrilinos_ENABLE_STKExp=OFF"
    "-DTrilinos_ENABLE_Moertel=OFF"
    "-DTrilinos_ENABLE_Stokhos=OFF"
    "-DTrilinos_ENABLE_MOOCHO=OFF"
    "-DTrilinos_ENABLE_PyTrilinos=OFF"
    "-DTrilinos_ENABLE_TrilinosCouplings=OFF"
    "-DTrilinos_ENABLE_Pike=OFF"

    "-DTrilinos_ENABLE_Krino=OFF"
    "-DShyLU_DD_ENABLE_BDDC=OFF"
    "-DTrilinos_ENABLE_PyTrilinos=OFF"

    # deprecated
    "-DTrilinos_ENABLE_ThyraEpetraExtAdapters=OFF"
    "-DTrilinos_ENABLE_ThyraEpetraAdapters=OFF"
    "-DTrilinos_ENABLE_ML=OFF"
    "-DTrilinos_ENABLE_Ifpack=OFF"
    "-DTrilinos_ENABLE_EpetraExt=OFF"
    "-DTrilinos_ENABLE_Epetra=OFF"
    "-DTrilinos_ENABLE_AztecOO=OFF"
    "-DTrilinos_ENABLE_Amesos=OFF"

    # krino depends on Gtest
    #"-DKrino_ENABLE_TESTS=OFF"
    "-DROL_ENABLE_TESTS=OFF"
    "-DROL_ENABLE_EXAMPLES=OFF"
    "-DTPL_ENABLE_Gtest=OFF"
    "-DTrilinos_ENABLE_Gtest=OFF"
    "-DTPL_ENABLE_gtest=OFF"
    "-DTrilinos_ENABLE_gtest=OFF"

    ## disabling this, as libsci does *not* return std::complex
    ## enabling will trigger spam as KK returns std::complex from C-functions
    "-DKokkosKernels_TPL_BLAS_RETURN_COMPLEX=OFF"
    # from Kyungjoo for his Tacho test
    "-DTacho_ENABLE_INT_INT:BOOL=ON"

    "-DTPL_ENABLE_gtest=OFF"
  )

  if [[ "$BUILD_TESTS" == "true" ]]; then
    args+=( "-DTrilinos_ENABLE_TESTS:BOOL=ON"
            #"-DTrilinos_TEST_CATEGORIES=NIGHTLY;PERFORMANCE"
            "-DPanzerMiniEM_ENABLE_EXAMPLES=ON"
            "-DPanzerMiniEM_ENABLE_TESTS=ON"
            # these do not work, unless I figure out their perl launcher
            "-DZoltan_ENABLE_TESTS=OFF"
    )
  fi
  if [[ "$PERFORMANCE_TEST" == "true" ]]; then
    args+=(
            "-DPanzerMiniEM_ENABLE_EXAMPLES=ON"
            "-DPanzerMiniEM_ENABLE_TESTS=ON"
            "-DTrilinos_TEST_CATEGORIES=PERFORMANCE"
    )
  fi


  if [[ "$BUILD_FOR_EMPIRE" == "true" ]]; then
  args+=(
    #EMPIRE brings Tempus as a TPL...
    "-DTrilinos_ENABLE_Tempus=OFF"
    #"-DTrilinos_ENABLE_Percept=ON"
    "-DTPL_ENABLE_Gtest=OFF"
    "-DTrilinos_ENABLE_Gtest=OFF"
    "-DTPL_ENABLE_gtest=OFF"
    "-DTrilinos_ENABLE_gtest=OFF"
    "-DTrilinos_ENABLE_Triutils=ON"
    "-DTrilinos_ENABLE_Shards=ON"
    #"-DTrilinos_ENABLE_AztecOO=OFF"
    #"-DTrilinos_ENABLE_Epetra=OFF"
    )
  fi
  
  if [[ "$BUILD_COMPLEX" == "true" ]]; then
    args+=( "-DTrilinos_ENABLE_COMPLEX_DOUBLE:BOOL=ON" )

    echo "DUCT TAPE: Disabling Amesos2 LAPACK due to complex bug"
    args+=( "-DAmesos2_ENABLE_LAPACK=OFF" )
  fi
}


function atdm_get_build_id(){
  local optional_sha="$1"
  build_id=""

  if [[ "$prgenv_toolchain" == "cray" ]]; then
    build_id+="cce-${CRAY_CC_VERSION}"
  elif [[ "$prgenv_toolchain" == "amd" ]]; then
    build_id+="amd-${CRAY_AMD_COMPILER_VERSION}"
  elif [[ "$prgenv_toolchain" == "ansel-gnu" ]]; then
    build_id+="gnu-${LMOD_FAMILY_COMPILER_VERSION}"
  else
    echo "unrecognized prgenv_toolchain = $prgenv_toolchain"; exit
  fi
  
  if [[ "$BUILD_CUDA_ANSEL" == "false" ]]; then
  build_id+="_prgenv-${prgenv_toolchain}_$(basename $ROCM_PATH)_mpich-${CRAY_MPICH_VERSION}"
  else
  build_id+="_prgenv-${prgenv_toolchain}_cuda-${LMOD_FAMILY_CUDA_VERSION}_smpi-rolling"
  fi
  
  if [[ "$BUILD_OPENMP" == "true" ]]; then
    build_id+="_openmp"
  fi
  
  if [[ "$BUILD_PURE_CCE" == "true" ]]; then
    build_id+="_pure-cce"
  elif [[ "$BUILD_PURE_AMD" == "true" ]]; then
    build_id+="_pure-amd"
  fi

  if [[ "$BUILD_HIP" == "true" ]]; then
    build_id+="_hip"
  
    if [ "$BUILD_PURE_CCE" == "true" ]  || [ "$BUILD_AMDCLANG" == "true" ]; then
      build_id+="_amd"
      if [ "$AMD_EARLY_INLINE_ALL" == "true" ]; then
        build_id+="-inlall"
      else
        build_id+="-NOinlall"
      fi
      if [ "$GPU_INLINE_THRESHOLD" != "false" ]; then
        build_id+="-gpuThresh-${GPU_INLINE_THRESHOLD}"
      fi
      if [ "$AMD_FUNCTION_CALLS" == "true" ]; then
        build_id+="-func"
      else
        build_id+="-NOfunc"
      fi
    else
      #hipcc has these always
      build_id+="_amd-inlall-NOfunc"
    fi
  
    build_id+="-${cce_offload_target}"
  fi

  # if serial is enabled at the tpetra level
  if [[ "$BUILD_SERIAL" == "true" ]]; then
    build_id+="_serial"
  fi
  
  if [[ "$FULL_ATDM" == "true" ]]; then 
    build_id+="_atdm"
  fi
 
  if [[ "$BUILD_COMPLEX" == "true" ]]; then
    build_id+="_complex"
  fi

  if [[ "$ATDM_USE_DEVICE_TPLS" == "true" ]]; then
    build_id+="_devtpls"
  fi

  if [[ "$BUILD_DEBUG_SYM" == "true" ]]; then
    build_id+="_opt-g"
  fi

  if [[ "$CXX_STD" != "14" ]]; then
    build_id+="_cxx${CXX_STD}"
  fi

  if [[ "$BUILD_TESTS" == "false" ]]; then
    build_id+="_libonly"
  fi

  if [[ "$BUILD_SHARED" == "false" ]]; then
    build_id+="_static"
  fi

  if [[ "$ATDM_LTO_THIN" == "true" ]]; then
    build_id+="_thin${ATDM_THIN_JOBS}"
  fi

  if [[ "$ENABLE_RDC" == "true" ]]; then
    build_id+="_rdc"
  fi

  if [[ "$ATDM_ENABLE_SPLITTING" == "true" ]]; then
    build_id+="_rdc_s"
  fi

  # this is to work around Cray failures - it should not be used regularly
  if [[ "$USE_CRAY_FIXES" == "true" ]]; then
    build_id+="-FIXES"
  fi

  if [[ "$USE_LLVM" == "true" ]]; then
    build_id+="-llvm"
  fi

  if [[ "$optional_sha" != "" ]]; then
    build_id+="_${optional_sha}"
  fi

  echo "$build_id"
}

function atdm_write_configure(){
  local -n args=$1
  local src_dir="$2"

  echo "PWD = $PWD"

  printf 'cmake \\\n' > ./my_configure.sh
  printf ' "%s" \\\n' "${args[@]}" >> ./my_configure.sh
  echo "$src_dir 2>&1 | tee configure_trilinos_performance.log " >> ./my_configure.sh

  chmod +x ./my_configure.sh
  echo "Wrote configure script to: $PWD/my_configure.sh"

  if [[ "$ROCM_VERSION" == "6.2.1" ]]; then
     cp -a build.ninja build.ninja.orig
     sed -i -e "s|${ROCM_PATH}/lib/llvm/lib/clang/18/lib/linux/libclang_rt.builtins-x86_64.a||g" build.ninja
     touch -r build.ninja.orig build.ninja
     echo "DUCT TAPE: Removed ${ROCM_PATH}/lib/llvm/lib/clang/18/lib/linux/libclang_rt.builtins-x86_64.a from build.ninja"
  fi

  if [[ "$USE_LLVM" == "true" ]]; then
     echo "" >> ./my_configure.sh
     echo "# BUG: using LLVM native compilers, removing clang_rt.builtins" >> ./my_configure.sh
     echo "cp -a build.ninja build.ninja.orig" >> ./my_configure.sh
     echo "sed -i -e 's|/collab/usr/global/tools/llvm/toss_4_x86_64_ib_cray/llvm_current/lib/clang/23/lib/x86_64-unknown-linux-gnu/libclang_rt.builtins.a||g' build.ninja" >> ./my_configure.sh
     echo "touch -r build.ninja.orig build.ninja" >> ./my_configure.sh
     echo "DUCT TAPE: Removed /collab/usr/global/tools/llvm/toss_4_x86_64_ib_cray/llvm_current/lib/clang/23/lib/x86_64-unknown-linux-gnu/libclang_rt.builtins.a"
    #/collab/usr/global/tools/llvm/toss_4_x86_64_ib_cray/llvm_current/lib/clang/23/lib/x86_64-unknown-linux-gnu/libclang_rt.builtins.a
    #/collab/usr/global/tools/llvm/toss_4_x86_64_ib_cray/llvm_current/lib/clang/22/lib/x86_64-unknown-linux-gnu/libclang_rt.builtins.a
  fi

  # write a load-jje-env.sh
  
  echo "export RUN_TESTS=$RUN_TESTS"             > ./load-jje-env.sh
  echo "export BUILD_TESTS=$BUILD_TESTS"         >> ./load-jje-env.sh
  echo "export CONFIGURE_ONLY=$CONFIGURE_ONLY"   >> ./load-jje-env.sh
  echo "export BUILD_OPENMP=$BUILD_OPENMP"       >> ./load-jje-env.sh
  echo "export BUILD_SERIAL=$BUILD_SERIAL"       >> ./load-jje-env.sh
  echo "export BUILD_HIP=$BUILD_HIP"             >> ./load-jje-env.sh
  echo "export BUILD_PURE_CCE=$BUILD_PURE_CCE"   >> ./load-jje-env.sh
  echo "export BUILD_PURE_AMD=$BUILD_PURE_AMD"   >> ./load-jje-env.sh
  echo "export BUILD_AMDCLANG=$BUILD_AMDCLANG"   >> ./load-jje-env.sh
  echo "export FULL_ATDM=$FULL_ATDM"             >> ./load-jje-env.sh
  echo "export BUILD_COMPLEX=$BUILD_COMPLEX"     >> ./load-jje-env.sh
  echo "export BUILD_DEBUG_SYM=$BUILD_DEBUG_SYM" >> ./load-jje-env.sh
  echo "export CXX_STD=$CXX_STD"                 >> ./load-jje-env.sh
  echo "export AMD_FUNCTION_CALLS=$AMD_FUNCTION_CALLS" >> ./load-jje-env.sh
  echo "export AMD_EARLY_INLINE_ALL=${AMD_EARLY_INLINE_ALL}" >> ./load-jje-env.sh
  echo "export GPU_INLINE_THRESHOLD=${GPU_INLINE_THRESHOLD}" >> ./load-jje-env.sh
  echo "export prgenv_toolchain=\"$prgenv_toolchain\""     >> ./load-jje-env.sh
  echo "export prgenv_version=\"$prgenv_version\""         >> ./load-jje-env.sh
  echo "export cce_offload_target=\"$cce_offload_target\"" >> ./load-jje-env.sh
  echo "export BUILD_SHARED=$BUILD_SHARED"                 >> ./load-jje-env.sh
  echo "export ROCM_VERSION=$ROCM_VERSION"  >> ./load-jje-env.sh
  echo "export ENABLE_RDC=${ENABLE_RDC}"    >> ./load-jje-env.sh
  echo "export AMD_REPORT_KERNEL_USAGE=${AMD_REPORT_KERNEL_USAGE}"         >> ./load-jje-env.sh
  echo "export ATDM_USE_DEVICE_TPLS=${ATDM_USE_DEVICE_TPLS}" >> ./load-jje-env.sh
  echo "export JJE_INSTALL=${JJE_INSTALL}" >> ./load-jje-env.sh
  echo "export CMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}" >> ./load-jje-env.sh
  echo "export PERFORMANCE_TEST=${PERFORMANCE_TEST}" >>  ./load-jje-env.sh
  echo "export ATDM_ENABLE_OFFLOAD_NEW_DRIVER=${ATDM_ENABLE_OFFLOAD_NEW_DRIVER}" >> ./load-jje-env.sh
  echo "export ATDM_USE_HUGETLBFS=${ATDM_USE_HUGETLBFS}" >> ./load-jje-env.sh
  echo "export USE_LLVM=${USE_LLVM}" >> ./load-jje-env.sh
  echo "source ${ENV_SETUP}" >> ./load-jje-env.sh
}

export -f atdm_write_configure
export -f atdm_set_disabled_packages
export -f atdm_add_tpls
export -f atdm_set_compiler_and_arch
export -f atdm_get_build_id

module -t list
echo Cmake:
which cmake
