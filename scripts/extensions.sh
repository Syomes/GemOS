#!/bin/sh
# ======================
# Extension selector ( # TODO: TUI )
# Hardcoding install all extensions
# ======================

ROOTFS_DIR="${1:-tmp_root}"

for ext_dir in config/extensions/*/; do
    [ -f "$ext_dir/install.sh" ] && sh "$ext_dir/install.sh" "$ROOTFS_DIR"
done