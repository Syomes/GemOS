#!/bin/sh
# ======================
# Download BusyBox Binary
# ======================
set -e

BASE_URL="https://busybox.net/downloads/binaries"
PKGPATH="external/pkg"

mkdir -p $PKGPATH

echo "==> Resolving latest BusyBox (x86_64-musl)..."

# Fetch directory list and find the latest version
LATEST_DIR=$(curl -sf "$BASE_URL/" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+-x86_64-linux-musl/' | sort -V | tail -1)

if [ -z "$LATEST_DIR" ]; then
    echo "ERROR: Could not resolve latest BusyBox version" >&2
    exit 1
fi

DL_URL="$BASE_URL/${LATEST_DIR}busybox"
echo "==> Latest version found: ${LATEST_DIR%/}"

# Check if already downloaded
if [ -f "$PKGPATH/busybox" ]; then
    # TODO: sum check for version
    echo "==> busybox binary already exists, skipping download."
    exit 0
fi

echo "==> Downloading busybox from $DL_URL..."
curl -Lf "$DL_URL" -o "$PKGPATH/busybox"
chmod +x "$PKGPATH/busybox"

echo "==> BusyBox ready: $PKGPATH/busybox"
