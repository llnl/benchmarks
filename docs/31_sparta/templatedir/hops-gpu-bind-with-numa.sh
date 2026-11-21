#!/usr/bin/env bash
#
# gpu_bind_static_v2.sh
#
# Static CPU-affinity -> GPU/NIC/memory-policy mapping for the hops
# Sapphire Rapids SNC4 / H100 nodes.
#
# Fixed placement slots:
#   slot 0: CPU NUMA 0+1 -> GPU 1 -> mlx5_0:1
#   slot 1: CPU NUMA 2+3 -> GPU 0 -> mlx5_0:1
#   slot 2: CPU NUMA 4+5 -> GPU 3 -> mlx5_1:1
#   slot 3: CPU NUMA 6+7 -> GPU 2 -> mlx5_1:1
#
# CPU affinity is inherited from mpirun/srun and is NEVER changed here.
#
# Default memory policy (GPU_BIND_MEMPOLICY=auto):
#   - rank touches one SNC NUMA in its slot:
#       --membind=<that NUMA>
#   - rank touches both SNC NUMAs in its slot:
#       --interleave=<both NUMAs>
#
# This makes the same wrapper suitable for, e.g.:
#   4 ranks/node: each rank spans two SNC domains -> interleave the pair
#   8 ranks/node: each rank normally occupies one SNC -> bind that SNC
#
# Usage:
#   mpirun ... ./gpu_bind_static_v2.sh ./app --args
#
# Environment:
#   GPU_BIND_VERBOSE=1
#       Print the selected slot/GPU/HCA/memory policy before exec.
#
#   GPU_BIND_STRICT=1
#       If CPU affinity spans more than one placement slot, fail instead of
#       warning and choosing the slot with the largest CPU overlap.
#
#   GPU_BIND_DRY_RUN=1
#       Print the mapping and exit without launching the application.
#
#   GPU_BIND_MEMPOLICY=auto|none|slot-interleave
#       auto             Default behavior described above.
#       none             Do not impose a NUMA memory policy.
#       slot-interleave  Always interleave both NUMAs of the selected slot.
#
# Notes:
# - Multiple ranks may occupy subsets of the same placement slot. They
#   intentionally receive the same GPU/HCA assignment.
# - No PCIe, hwloc, nvidia-smi, sysfs, or NIC topology probing is performed.
#   This wrapper encodes the known static machine topology.
#

set -u

prog="${0##*/}"
MEM_POLICY="${GPU_BIND_MEMPOLICY:-auto}"

usage()
{
    cat >&2 <<EOF
Usage: $prog command [args...]

Static mapping:
  slot 0: NUMA 0+1 -> CUDA_VISIBLE_DEVICES=1 -> UCX_NET_DEVICES=mlx5_0:1
  slot 1: NUMA 2+3 -> CUDA_VISIBLE_DEVICES=0 -> UCX_NET_DEVICES=mlx5_0:1
  slot 2: NUMA 4+5 -> CUDA_VISIBLE_DEVICES=3 -> UCX_NET_DEVICES=mlx5_1:1
  slot 3: NUMA 6+7 -> CUDA_VISIBLE_DEVICES=2 -> UCX_NET_DEVICES=mlx5_1:1

Memory policy:
  GPU_BIND_MEMPOLICY=auto
      one SNC NUMA in affinity  -> membind that NUMA
      both SNC NUMAs in slot    -> interleave those NUMAs

  GPU_BIND_MEMPOLICY=none
      leave inherited/default memory policy unchanged

  GPU_BIND_MEMPOLICY=slot-interleave
      interleave both NUMAs belonging to the selected slot

Other environment:
  GPU_BIND_VERBOSE=1
  GPU_BIND_STRICT=1
  GPU_BIND_DRY_RUN=1
EOF
}

if (( $# == 0 )); then
    usage
    exit 2
fi

case "$MEM_POLICY" in
    auto|none|slot-interleave) ;;
    *)
        echo "$prog: ERROR: GPU_BIND_MEMPOLICY must be auto, none, or slot-interleave" >&2
        exit 2
        ;;
esac

# The static logical-GPU map assumes CUDA devices are enumerated by PCI bus ID.
export CUDA_DEVICE_ORDER=PCI_BUS_ID

cpulist="$(awk '/^Cpus_allowed_list:/ {print $2; exit}' /proc/self/status)"
if [[ -z "$cpulist" ]]; then
    echo "$prog: ERROR: could not read Cpus_allowed_list from /proc/self/status" >&2
    exit 2
fi

# Static SNC4 CPU -> NUMA map for this platform.
numa_for_cpu()
{
    local cpu=$1

    if   (( (cpu >=   0 && cpu <=  13) || (cpu >= 112 && cpu <= 125) )); then printf '0\n'
    elif (( (cpu >=  14 && cpu <=  27) || (cpu >= 126 && cpu <= 139) )); then printf '1\n'
    elif (( (cpu >=  28 && cpu <=  41) || (cpu >= 140 && cpu <= 153) )); then printf '2\n'
    elif (( (cpu >=  42 && cpu <=  55) || (cpu >= 154 && cpu <= 167) )); then printf '3\n'
    elif (( (cpu >=  56 && cpu <=  69) || (cpu >= 168 && cpu <= 181) )); then printf '4\n'
    elif (( (cpu >=  70 && cpu <=  83) || (cpu >= 182 && cpu <= 195) )); then printf '5\n'
    elif (( (cpu >=  84 && cpu <=  97) || (cpu >= 196 && cpu <= 209) )); then printf '6\n'
    elif (( (cpu >=  98 && cpu <= 111) || (cpu >= 210 && cpu <= 223) )); then printf '7\n'
    else
        printf '%s\n' '-1'
    fi
}

slot_for_numa()
{
    local numa=$1
    if   (( numa == 0 || numa == 1 )); then printf '0\n'
    elif (( numa == 2 || numa == 3 )); then printf '1\n'
    elif (( numa == 4 || numa == 5 )); then printf '2\n'
    elif (( numa == 6 || numa == 7 )); then printf '3\n'
    else printf '%s\n' '-1'
    fi
}

slot_counts=(0 0 0 0)
numa_counts=(0 0 0 0 0 0 0 0)
unknown=0

IFS=',' read -r -a fields <<< "$cpulist"
for field in "${fields[@]}"; do
    if [[ "$field" =~ ^([0-9]+)-([0-9]+)$ ]]; then
        first=${BASH_REMATCH[1]}
        last=${BASH_REMATCH[2]}
    elif [[ "$field" =~ ^[0-9]+$ ]]; then
        first=$field
        last=$field
    else
        echo "$prog: ERROR: cannot parse CPU affinity element '$field' from '$cpulist'" >&2
        exit 2
    fi

    for (( cpu=first; cpu<=last; cpu++ )); do
        numa="$(numa_for_cpu "$cpu")"
        if (( numa < 0 )); then
            unknown=$(( unknown + 1 ))
            continue
        fi

        slot="$(slot_for_numa "$numa")"
        numa_counts[$numa]=$(( numa_counts[$numa] + 1 ))
        slot_counts[$slot]=$(( slot_counts[$slot] + 1 ))
    done
done

if (( unknown != 0 )); then
    echo "$prog: WARNING: affinity '$cpulist' contains $unknown CPU(s) outside the static 0-223 topology" >&2
fi

active_slots=0
best_slot=-1
best_count=-1
active_desc=""

for slot in 0 1 2 3; do
    count=${slot_counts[$slot]}
    if (( count > 0 )); then
        active_slots=$(( active_slots + 1 ))
        if [[ -n "$active_desc" ]]; then
            active_desc+=","
        fi
        active_desc+="${slot}:${count}"

        if (( count > best_count )); then
            best_count=$count
            best_slot=$slot
        fi
    fi
done

if (( best_slot < 0 )); then
    echo "$prog: ERROR: affinity '$cpulist' does not intersect any configured placement slot" >&2
    exit 2
fi

if (( active_slots > 1 )); then
    msg="$prog: WARNING: CPU affinity '$cpulist' spans $active_slots placement slots (slot:cpu-count=$active_desc); selecting slot $best_slot with largest overlap"
    if [[ "${GPU_BIND_STRICT:-0}" == "1" ]]; then
        echo "${msg/WARNING/ERROR}" >&2
        exit 3
    else
        echo "$msg" >&2
    fi
fi

gpu_by_slot=(1 0 3 2)
hca_by_slot=("mlx5_0:1" "mlx5_0:1" "mlx5_1:1" "mlx5_1:1")
slot_numa_a=(0 2 4 6)
slot_numa_b=(1 3 5 7)

gpu=${gpu_by_slot[$best_slot]}
hca=${hca_by_slot[$best_slot]}
numa_a=${slot_numa_a[$best_slot]}
numa_b=${slot_numa_b[$best_slot]}
slot_numas="${numa_a},${numa_b}"

old_cuda="${CUDA_VISIBLE_DEVICES-}"
old_ucx_net="${UCX_NET_DEVICES-}"

export CUDA_VISIBLE_DEVICES="$gpu"
export UCX_NET_DEVICES="$hca"

# Determine the memory policy without changing CPU affinity.
numa_a_count=${numa_counts[$numa_a]}
numa_b_count=${numa_counts[$numa_b]}
mem_desc="none"
numactl_args=()

case "$MEM_POLICY" in
    none)
        ;;

    slot-interleave)
        mem_desc="interleave:${slot_numas}"
        numactl_args=(--interleave="$slot_numas")
        ;;

    auto)
        if (( numa_a_count > 0 && numa_b_count > 0 )); then
            mem_desc="interleave:${slot_numas}"
            numactl_args=(--interleave="$slot_numas")
        elif (( numa_a_count > 0 )); then
            mem_desc="membind:${numa_a}"
            numactl_args=(--membind="$numa_a")
        elif (( numa_b_count > 0 )); then
            mem_desc="membind:${numa_b}"
            numactl_args=(--membind="$numa_b")
        else
            echo "$prog: ERROR: selected slot $best_slot has no CPUs in the inherited affinity '$cpulist'" >&2
            exit 2
        fi
        ;;
esac

if (( ${#numactl_args[@]} > 0 )) && ! command -v numactl >/dev/null 2>&1; then
    echo "$prog: ERROR: numactl is required for GPU_BIND_MEMPOLICY=$MEM_POLICY" >&2
    exit 2
fi

if [[ "${GPU_BIND_VERBOSE:-0}" == "1" ]]; then
    host="$(hostname -s 2>/dev/null || hostname 2>/dev/null || printf '?')"
    printf '%s: host=%s pid=%d cpus=%s slot=%d slot_numas=%s gpu=%s hca=%s mempolicy=%s' \
        "$prog" "$host" "$$" "$cpulist" "$best_slot" "$slot_numas" \
        "$CUDA_VISIBLE_DEVICES" "$UCX_NET_DEVICES" "$mem_desc" >&2

    if [[ -n "$old_cuda" && "$old_cuda" != "$CUDA_VISIBLE_DEVICES" ]]; then
        printf ' previous_CUDA_VISIBLE_DEVICES=%s' "$old_cuda" >&2
    fi
    if [[ -n "$old_ucx_net" && "$old_ucx_net" != "$UCX_NET_DEVICES" ]]; then
        printf ' previous_UCX_NET_DEVICES=%s' "$old_ucx_net" >&2
    fi
    printf '\n' >&2
fi

if [[ "${GPU_BIND_DRY_RUN:-0}" == "1" ]]; then
    printf 'slot=%d cpus=%s slot_numas=%s CUDA_VISIBLE_DEVICES=%s UCX_NET_DEVICES=%s mempolicy=%s\n' \
        "$best_slot" "$cpulist" "$slot_numas" "$CUDA_VISIBLE_DEVICES" \
        "$UCX_NET_DEVICES" "$mem_desc"
    exit 0
fi

if (( ${#numactl_args[@]} > 0 )); then
    exec numactl "${numactl_args[@]}" "$@"
else
    exec "$@"
fi