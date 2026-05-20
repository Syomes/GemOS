#!/bin/sh
# ======================
# Extension selector ( # TODO: TUI )
# Hardcoding install all extensions
# ======================

for ext_dir in extensions/*/; do
    [ -f "$ext_dir/install.sh" ] && sh "$ext_dir/install.sh"
done