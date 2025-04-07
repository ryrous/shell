#!/bin/bash

# --- Configuration ---
# Set to 1 to enable debug messages
DEBUG=0

# --- Functions ---
log_info() {
    echo "[INFO] $1"
}

log_warn() {
    echo "[WARNING] $1" >&2
}

log_error() {
    echo "[ERROR] $1" >&2
    exit 1
}

debug() {
    if [[ "$DEBUG" -eq 1 ]]; then
        echo "[DEBUG] $1" >&2
    fi
}

# --- Sanity Checks ---
# Must run as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root."
fi

# Check for required commands
command -v parted >/dev/null 2>&1 || log_error "'parted' command not found. Please install it."
command -v lsblk >/dev/null 2>&1 || log_error "'lsblk' command not found. Please install it (usually part of 'util-linux')."
# Optional: Add checks for filesystem resize tools if you were to integrate them
# command -v resize2fs >/dev/null 2>&1 || log_warn "'resize2fs' not found. Needed for ext2/3/4 resizing."
# command -v xfs_growfs >/dev/null 2>&1 || log_warn "'xfs_growfs' not found. Needed for XFS resizing."

# --- Argument Parsing ---
if [[ $# -lt 2 ]] || [[ $# -gt 3 ]]; then
    echo "Usage: $0 <device> <partition_number> [apply]"
    echo "  <device>: The disk device (e.g., /dev/sda, /dev/nvme0n1)."
    echo "  <partition_number>: The number of the partition to resize (e.g., 4 for /dev/sda4)."
    echo "  [apply]: Optional. If set to 'apply', changes will be made. Otherwise, it runs in dry-run mode."
    exit 1
fi

DEVICE="$1"
PARTNR="$2"
APPLY_MODE="dry-run"
if [[ "$3" == "apply" ]]; then
    APPLY_MODE="apply"
fi

PARTITION="${DEVICE}${PARTNR}" # Construct full partition path (e.g. /dev/sda4)
# Handle potential separators like p for nvme (e.g. /dev/nvme0n1p4)
if [[ "$DEVICE" == *nvme* ]] && ! [[ "$PARTITION" =~ p[0-9]+$ ]]; then
    PARTITION="${DEVICE}p${PARTNR}"
fi


# --- Validation ---
# Check if device looks like a block device path
if [[ ! "$DEVICE" == /dev/* ]]; then
    log_warn "Device '$DEVICE' does not look like a device path (e.g., /dev/sda). Proceeding anyway."
fi

# Check if device exists
if [[ ! -b "$DEVICE" ]]; then
    log_error "Device '$DEVICE' not found or is not a block device."
fi

# Check if partition number is numeric
if ! [[ "$PARTNR" =~ ^[0-9]+$ ]]; then
    log_error "Partition number '$PARTNR' is not a valid number."
fi

# Check if partition exists
if [[ ! -b "$PARTITION" ]]; then
    log_error "Partition '$PARTITION' not found or is not a block device."
fi

# --- Get Information ---
# Get current partition size in MiB using lsblk (more reliable parsing)
# -b: bytes, -n: no header, -o SIZE: only show size column, -p: full paths
CURRENTSIZE_B=$(lsblk -b -n -o SIZE "$PARTITION" 2>/dev/null)
if [[ -z "$CURRENTSIZE_B" ]]; then
    log_error "Could not determine current size of partition '$PARTITION' using lsblk."
fi
CURRENTSIZE_MB=$((CURRENTSIZE_B / 1024 / 1024))

# Use parted to get the total disk size in MB (for informational display)
# Using 'print free' might show available space, but targeting 100% is simpler for resizepart
TOTALDISK_MB_STR=$(parted -s -- "$DEVICE" unit MB print | grep "^Disk ${DEVICE}:" | awk '{print $3}' | sed 's/MB//')
if ! [[ "$TOTALDISK_MB_STR" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
     log_warn "Could not reliably determine total disk size in MB for informational display."
     TOTALDISK_MB="N/A"
else
     # Use awk for potential floating point MB reported by parted
     TOTALDISK_MB=$(awk "BEGIN {printf \"%.0f\", $TOTALDISK_MB_STR}")
fi


# --- Display Plan ---
log_info "Device: $DEVICE"
log_info "Partition number: $PARTNR ($PARTITION)"
log_info "Current partition size: ${CURRENTSIZE_MB} MiB"
log_info "Total disk size: ${TOTALDISK_MB} MiB (approx)"
log_info "Action: Will attempt to resize partition $PARTNR to use the maximum available space on $DEVICE (extend to end of disk)."

# --- Execute ---
if [[ "$APPLY_MODE" == "apply" ]]; then
    log_info "Applying resize operation..."
    # Use '100%' as the end target for parted resizepart to automatically use the maximum available space
    # Using '-s' for script mode and '--' to signify end of options
    if parted -s -- "$DEVICE" resizepart "$PARTNR" 100%; then
        log_info "Partition table resize successful for $PARTITION."
        log_warn "--------------------------------------------------------------------"
        log_warn "IMPORTANT: The partition table has been updated, BUT the filesystem"
        log_warn "           *inside* the partition HAS NOT been resized yet."
        log_warn "           You MUST run the appropriate filesystem resize command,"
        log_warn "           e.g., 'resize2fs $PARTITION' (for ext2/3/4) or"
        log_warn "           'xfs_growfs $PARTITION' (for XFS - if mounted) or"
        log_warn "           other tools depending on your filesystem type."
        log_warn "--------------------------------------------------------------------"
    else
        # parted should have printed an error, set -e handles exit
        log_error "Parted command failed to resize partition $PARTITION."
    fi
else
    log_warn "Sandbox mode: No changes were made."
    log_warn "Run with 'apply' as the third argument to execute the resize."
    log_info "(Command that would be run: parted -s -- \"$DEVICE\" resizepart \"$PARTNR\" 100%)"
fi

log_info "[Script finished]"
exit 0