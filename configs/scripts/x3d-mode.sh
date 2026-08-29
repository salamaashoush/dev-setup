#!/usr/bin/env bash

# Switch the CCD preference on asymmetric AMD X3D CPUs (7950X3D, 9950X3D, ...).
#
# These parts have two CCDs: one with 3D V-Cache (large L3, lower clock) and one
# without (higher clock). The amd_x3d_vcache driver decides which CCD the
# scheduler prefers.
#
#   cache      -> prefer the V-Cache CCD. Better for games (L3-bound).
#   frequency  -> prefer the high-clock CCD. Better for compiling (throughput).
#
# Usage:
#   x3d-mode              show current mode
#   x3d-mode cache        gaming
#   x3d-mode frequency    compiling
#
# Writing the mode needs root; the script re-executes itself with sudo.

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

find_sysfs_node() {
    local node
    for node in /sys/bus/platform/drivers/amd_x3d_vcache/*/amd_x3d_mode; do
        [[ -f "$node" ]] && { echo "$node"; return 0; }
    done
    return 1
}

NODE=$(find_sysfs_node) || {
    echo -e "${RED}No amd_x3d_vcache interface found.${NC}" >&2
    echo "This CPU is not an asymmetric X3D part, or the driver is not loaded." >&2
    exit 1
}

current() { cat "$NODE"; }

case "${1:-show}" in
    show)
        echo -e "${CYAN}X3D mode:${NC} $(current)"
        echo "  cache     = prefer V-Cache CCD (gaming)"
        echo "  frequency = prefer high-clock CCD (compiling)"
        ;;
    cache|frequency)
        if [[ $EUID -ne 0 ]]; then
            exec sudo -- "$0" "$1"
        fi
        echo "$1" > "$NODE"
        echo -e "${GREEN}✓${NC} X3D mode set to $(current)"
        ;;
    *)
        echo "usage: x3d-mode [show|cache|frequency]" >&2
        exit 1
        ;;
esac
