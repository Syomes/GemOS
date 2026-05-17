#!/bin/sh
# ======================
# Compose minimal rootfs
# ======================
set -e

BUSYBOX_BIN="external/rootfs/busybox"
RCS_TEMPLATE="config/rcS"
INITTAB_TEMPLATE="config/inittab"
OUTPUT="isoroot/boot/initramfs"
TMP="tmp_root"

if [ ! -f "$BUSYBOX_BIN" ]; then
    echo "ERROR: $BUSYBOX_BIN not found, run fetch-busybox first" >&2
    exit 1
fi

echo "==> Assembling rootfs..."
rm -rf "$TMP"
mkdir -p "$TMP"

# Create directory tree
mkdir -p "$TMP/bin" "$TMP/sbin" "$TMP/etc" "$TMP/proc" "$TMP/sys" "$TMP/dev" "$TMP/tmp" "$TMP/lib" "$TMP/root" "$TMP/run"
mkdir -p "$TMP/usr/bin" "$TMP/usr/sbin" "$TMP/etc/init.d" "$TMP/etc/syos/init.d"

# Install BusyBox
cp "$BUSYBOX_BIN" "$TMP/bin/busybox"
chmod +x "$TMP/bin/busybox"

# Create symlinks for all applets
echo "==> Installing BusyBox applets..."
cd "$TMP"
./bin/busybox --list-full | while read -r applet; do
    mkdir -p "$(dirname "$applet")"
    ln -sf /bin/busybox "$applet"
done
cd ..

# Install Init scripts
echo "==> Installing init config..."
cp "$RCS_TEMPLATE" "$TMP/etc/init.d/rcS"
cp "$INITTAB_TEMPLATE" "$TMP/etc/inittab"
chmod +x "$TMP/etc/init.d/rcS"

# Applying extensions
echo "==> Applying extensions..."
sh scripts/extensions.sh "$TMP"

# Packing initramfs
echo "==> Packing initramfs..."
mkdir -p isoroot/boot
cd "$TMP" && find . -print0 \
    | cpio --null -ov --format=newc 2>/dev/null \
    | gzip -9 > "../$OUTPUT"
cd ..

rm -rf "$TMP"
echo "==> initramfs ready: $OUTPUT"