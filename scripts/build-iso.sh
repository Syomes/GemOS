#!/bin/sh
# ======================
# Generate ISO
# ======================
set -e

KERNEL_SRC="external/kernel/vmlinuz"
KERNEL_DST="tmp/isoroot/boot/vmlinuz"
INITRAMFS_SRC="tmp/isoroot/boot/initramfs"
GRUB_CFG="grub.cfg"
EFI_IMG="tmp/isoroot/boot/efi.img"
EFI_EFI="tmp/isoroot/boot/BOOTx64.EFI"
ISO_OUT="build/syos.iso"

if [ ! -f "$KERNEL_SRC" ]; then
    echo "ERROR: Kernel not found at $KERNEL_SRC" >&2
    exit 1
fi

if [ ! -f "$INITRAMFS_SRC" ]; then
    echo "ERROR: initramfs not found, run build-initramfs first" >&2
    exit 1
fi

# Kernel
echo "==> Copying kernel..."
mkdir -p build
cp "$KERNEL_SRC" "$KERNEL_DST"

# EFI
echo "==> Building GRUB EFI..."
grub-mkstandalone \
    --format=x86_64-efi \
    --output="$EFI_EFI" \
    "boot/grub/grub.cfg=$GRUB_CFG" > /dev/null 2>&1

echo "==> Building EFI image..."
dd if=/dev/zero of="$EFI_IMG" bs=1M count=16 2>/dev/null
mkfs.vfat "$EFI_IMG" > /dev/null
mmd -i "$EFI_IMG" ::/EFI ::/EFI/BOOT
mcopy -i "$EFI_IMG" "$EFI_EFI" ::/EFI/BOOT/BOOTx64.EFI

# ISO
echo "==> Building ISO..."
xorriso -as mkisofs \
    -V "SYOS" \
    -o "$ISO_OUT" \
    -J -R \
    -partition_offset 16 \
    --eltorito-alt-boot \
    -e --interval:appended_partition_2:all:: \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -append_partition 2 0xef "$EFI_IMG" \
    tmp/isoroot > /dev/null 2>&1

echo "==> cleaning up..."
rm -rf tmp
echo "==> ISO ready: $ISO_OUT"