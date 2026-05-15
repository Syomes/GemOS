#!/bin/sh
# ======================
# Prepare kernel
# ======================
set -e

KERNEL_OUT="external/kernel/vmlinuz"

if [ -f "$KERNEL_OUT" ]; then
    echo "==> Kernel already exists, skipping."
    exit 0
fi

echo "==> Preparing kernel..."
mkdir -p external/kernel

if [ -f /boot/vmlinuz-linux ]; then
    cp /boot/vmlinuz-linux "$KERNEL_OUT"
elif ls /boot/vmlinuz-* > /dev/null 2>&1; then
    cp "$(find /boot -name "vmlinuz-*" | head -n 1)" "$KERNEL_OUT"
else
    echo "ERROR: No kernel found in /boot" >&2
    exit 1
fi

echo "==> Kernel ready: $KERNEL_OUT"