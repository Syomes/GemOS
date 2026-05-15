#!/bin/sh
# ======================
# Download Alpine minirootfs
# ======================
set -e

MIRROR="https://dl-cdn.alpinelinux.org/alpine/latest-stable/releases/x86_64"
ROOTFS_TAR="external/rootfs/alpine-minirootfs.tar.gz"

mkdir -p external/rootfs

echo "==> Resolving latest Alpine minirootfs..."

YAML=$(curl -sf "$MIRROR/latest-releases.yaml")

FILENAME=$(echo "$YAML" \
    | grep -A5 'flavor: alpine-minirootfs' \
    | grep 'file:' \
    | awk '{print $2}')

SHA256=$(echo "$YAML" \
    | grep -A10 'flavor: alpine-minirootfs' \
    | grep 'sha256:' \
    | awk '{print $2}')

if [ -z "$FILENAME" ]; then
    echo "ERROR: Could not resolve minirootfs filename" >&2
    exit 1
fi

echo "==> Latest: $FILENAME"

# If exists and passes the check, skip download
if [ -f "$ROOTFS_TAR" ]; then
    echo "==> Verifying existing rootfs..."
    if echo "$SHA256  $ROOTFS_TAR" | sha256sum -c - > /dev/null 2>&1; then
        echo "==> Already up to date, skipping download."
        exit 0
    else
        echo "==> Checksum mismatch, re-downloading..."
    fi
fi

echo "==> Downloading $FILENAME..."
curl -Lf "$MIRROR/$FILENAME" -o "$ROOTFS_TAR"

echo "==> Verifying checksum..."
echo "$SHA256  $ROOTFS_TAR" | sha256sum -c -

echo "==> Rootfs ready: $ROOTFS_TAR"