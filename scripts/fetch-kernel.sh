#!/bin/sh
# ======================
# Prepare kernel
# ======================
set -e

KERNEL_OUT="external/kernel/vmlinuz"
VERSION_OUT="external/kernel/version"

if [ -f "$KERNEL_OUT" ] && [ -f "$VERSION_OUT" ]; then
    echo "==> Kernel already exists, skipping."
    exit 0
fi

echo "==> Preparing kernel..."
mkdir -p external/kernel

# Identify distro family
DISTRO="unknown"
if [ -f /etc/os-release ]; then
    OS_ID=$(struct_id=$(grep -E "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"') && echo "$struct_id")
    OS_LIKE=$(struct_like=$(grep -E "^ID_LIKE=" /etc/os-release | cut -d= -f2 | tr -d '"') && echo "$struct_like")
    OS_COMBINED=$(echo "$OS_ID $OS_LIKE" | tr '[:upper:]' '[:lower:]')

    case "$OS_COMBINED" in
        *arch*)                 DISTRO="arch" ;;
        *debian*|*ubuntu*)      DISTRO="debian" ;;
        *rhel*|*fedora*|*centos*) DISTRO="rhel" ;;
        *alpine*)               DISTRO="alpine" ;;
    esac
fi

KERNEL_VER=$(uname -r)
TARGET_KERNEL=""

# Try precise match first based on distro and running version
case "$DISTRO" in
    "arch")
        if [ -f /boot/vmlinuz-linux ]; then
            TARGET_KERNEL="/boot/vmlinuz-linux"
        fi
        ;;
    "debian"|"rhel")
        if [ -f "/boot/vmlinuz-$KERNEL_VER" ]; then
            TARGET_KERNEL="/boot/vmlinuz-$KERNEL_VER"
        fi
        ;;
esac

# Fallback matching
if [ -z "$TARGET_KERNEL" ]; then
    if [ -f /boot/vmlinuz-linux ]; then
        TARGET_KERNEL="/boot/vmlinuz-linux"
    elif ls /boot/vmlinuz-* > /dev/null 2>&1; then
        # Find closest match to current kernel, exclude rescue images
        MATCH=$(find /boot -maxdepth 1 -name "vmlinuz-*" ! -name "*rescue*" | grep "$KERNEL_VER" | head -n 1)
        if [ -n "$MATCH" ] && [ -f "$MATCH" ]; then
            TARGET_KERNEL="$MATCH"
        else
            TARGET_KERNEL=$(find /boot -maxdepth 1 -name "vmlinuz-*" ! -name "*rescue*" | head -n 1)
        fi
    fi
fi

if [ -n "$TARGET_KERNEL" ] && [ -f "$TARGET_KERNEL" ]; then
    cp "$TARGET_KERNEL" "$KERNEL_OUT"
    echo "${KERNEL_VER}-${DISTRO}" > "$VERSION_OUT"
else
    echo "ERROR: No kernel found in /boot" >&2
    exit 1
fi

echo "==> Kernel ready: $KERNEL_OUT"