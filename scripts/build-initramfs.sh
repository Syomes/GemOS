#!/bin/sh
# ======================
# Compose minimal rootfs
# ======================
set -e

ROOT_PATH="$(pwd)"
BUSYBOX_BIN="external/pkg/busybox"
RCS_TEMPLATE="config/rcS"
INITTAB_TEMPLATE="config/inittab"
OUTPUT_PATH="tmp/isoroot/boot"
TMP_SLASH="tmp/slash"

if [ ! -f "$BUSYBOX_BIN" ]; then
    echo "ERROR: $BUSYBOX_BIN not found, run fetch-busybox first" >&2
    exit 1
fi

echo "==> Assembling rootfs..."
rm -rf "$TMP_SLASH"
mkdir -p "$TMP_SLASH"

# Create directory tree
mkdir -p "$TMP_SLASH/bin" "$TMP_SLASH/sbin" "$TMP_SLASH/etc" "$TMP_SLASH/proc" "$TMP_SLASH/sys" "$TMP_SLASH/dev" "$TMP_SLASH/tmp" "$TMP_SLASH/lib" "$TMP_SLASH/root" "$TMP_SLASH/run"
mkdir -p "$TMP_SLASH/usr/bin" "$TMP_SLASH/usr/sbin" "$TMP_SLASH/etc/init.d" "$TMP_SLASH/etc/syos/init.d"

# Install BusyBox
cp "$BUSYBOX_BIN" "$TMP_SLASH/bin/busybox"
chmod +x "$TMP_SLASH/bin/busybox"

# Create symlinks for all applets
echo "==> Installing BusyBox applets..."
cd "$TMP_SLASH"
./bin/busybox --list-full | while read -r applet; do
    mkdir -p "$(dirname "$applet")"
    ln -sf /bin/busybox "$applet"
done
cd "$ROOT_PATH"

# Install Init scripts
echo "==> Installing init config..."
cp "$RCS_TEMPLATE" "$TMP_SLASH/etc/init.d/rcS"
cp "$INITTAB_TEMPLATE" "$TMP_SLASH/etc/inittab"
chmod +x "$TMP_SLASH/etc/init.d/rcS"

# Applying extensions
echo "==> Applying extensions..."
sh scripts/extensions.sh "$TMP_SLASH"

depmod -b "$TMP_SLASH" "$(uname -r)"

# Packing initramfs
echo "==> Packing initramfs..."
mkdir -p $OUTPUT_PATH
cd "$TMP_SLASH" && find . -print0 \
    | cpio --null -ov --format=newc 2>/dev/null \
    | gzip -9 > "initramfs"
cd "$ROOT_PATH"
mv "$TMP_SLASH/initramfs" "$OUTPUT_PATH"

echo "==> initramfs ready: $OUTPUT_PATH"