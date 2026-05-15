#!/bin/sh
# ======================
# Extension: util-linux
# ======================
set -e

ROOTFS_DIR="$(realpath "$1")"
MIRROR="https://dl-cdn.alpinelinux.org/alpine/latest-stable/main"
APK_TOOLS_DIR="$(pwd)/external/tools/apk-tools"
APK_STATIC="$APK_TOOLS_DIR/sbin/apk.static"
APK_CACHE="$(pwd)/external/cache/apk"

if [ -z "$ROOTFS_DIR" ]; then
    echo "ERROR: ROOTFS_DIR not specified" >&2
    exit 1
fi

# --- Fetch apk.static ---
if [ ! -f "$APK_STATIC" ]; then
    echo "==> Fetching apk.static..."
    mkdir -p "$APK_TOOLS_DIR"
    APKTOOLS_URL=$(curl -sf "$MIRROR/x86_64/" \
        | grep -o 'apk-tools-static-[0-9][^"]*\.apk' \
        | sort -V | tail -1)
    curl -sf "$MIRROR/x86_64/$APKTOOLS_URL" -o "$APK_TOOLS_DIR/apk-tools-static.apk"
    tar xzf "$APK_TOOLS_DIR/apk-tools-static.apk" -C "$APK_TOOLS_DIR" 2>/dev/null || true
fi

echo "==> Installing extension: util-linux"
mkdir -p "$APK_CACHE"

# --- Use apk.static to install into rootfs ---
"$APK_STATIC" \
    -X "$MIRROR" \
    -U \
    --allow-untrusted \
    --root "$ROOTFS_DIR" \
    --cache-dir "$APK_CACHE" \
    --no-scripts \
    --usermode \
    add lsblk blkid sfdisk cfdisk findmnt wipefs util-linux-misc e2fsprogs

echo "==> util-linux extension installed."