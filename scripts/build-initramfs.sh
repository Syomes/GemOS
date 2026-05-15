#!/bin/sh
# ======================
# Compose rootfs and capsulate to initramfs
# ======================
set -e

ROOTFS_TAR="external/rootfs/alpine-minirootfs.tar.gz"
RCS_TEMPLATE="config/rcS"
INITTAB_TEMPLATE="config/inittab"
OUTPUT="isoroot/boot/initramfs"
TMP="tmp_root"

if [ ! -f "$ROOTFS_TAR" ]; then
    echo "ERROR: $ROOTFS_TAR not found, run fetch-rootfs first" >&2
    exit 1
fi

echo "==> Assembling rootfs..."
rm -rf "$TMP"
mkdir -p "$TMP"

tar xzf "$ROOTFS_TAR" -C "$TMP"

echo "==> Installing init..."
mkdir -p "$TMP/etc/init.d" "$TMP/etc/syos/init.d" "$TMP/dev/pts"
cp "$RCS_TEMPLATE" "$TMP/etc/init.d/rcS"
cp "$INITTAB_TEMPLATE" "$TMP/etc/inittab"
chmod +x "$TMP/etc/init.d/rcS"

echo "==> Applying extensions..."
sh scripts/extensions.sh "$TMP"

echo "==> Packing initramfs..."
mkdir -p isoroot/boot
cd "$TMP" && find . -print0 \
    | cpio --null -ov --format=newc 2>/dev/null \
    | gzip -9 > "../$OUTPUT"
cd ..

rm -rf "$TMP"
echo "==> initramfs ready: $OUTPUT"