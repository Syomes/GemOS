#!/bin/sh
# ======================
# Extension: Disk Utils
# ======================

PKGPATH="external/pkg/disk"
KERNEL_VERSION="$(uname -r)"
ROOT_PATH="$(pwd)/tmp/slash"
PKGFORGE_URL="https://pkgs.pkgforge.dev/dl/bincache/x86_64-linux"
MODULE_PATH="tmp/slash/lib/modules/$KERNEL_VERSION"
INIT_D_DIR="tmp/slash/etc/gemos/init.d"

fetch() {
    if [ -f "$PKGPATH/$2" ]; then
        echo "$2 exists, skipping..."
    else
        echo "Downloading $2..."
        curl -fL --progress-bar "$PKGFORGE_URL/$1/nixpkgs/$2/raw.dl" -o "$PKGPATH/$2"
    fi
    cp "$PKGPATH/$2" "$ROOT_PATH/bin/$2"
    chmod +x "$ROOT_PATH/bin/$2"
}

echo "Installing extension: Disk"
mkdir -p "$PKGPATH"

for i in lsblk sfdisk cfdisk findmnt wipefs; do
    fetch "util-linux" "$i"
done

for i in mkfs.ext4 fsck.ext4; do
    fetch "e2fsprogs" "$i"
done

grab_module() {
    name=$1
    
    _mod_info_out=$(modinfo -b / -k "$KERNEL_VERSION" "$name" 2>/dev/null)
    _raw_path=$(echo "$_mod_info_out" | grep '^filename:' | awk '{print $2}')

    # Skip builtin module
    if [ -z "$_raw_path" ] || [ "$_raw_path" = "(builtin)" ]; then
        return
    fi

    # Copy module
    _clean_path="/$(echo "$_raw_path" | sed 's|^/\+||')"
    _rel_path="${_clean_path#/}"
    echo "Copying $name from $_clean_path..."
    (cd / && cp --parents "$_rel_path" "$ROOT_PATH/")
    find "$MODULE_PATH" -name "*.ko.zst" -exec unzstd -f --rm {} \;
    
    # Grab dependencies
    deps=$(echo "$_mod_info_out" | grep '^depends:' | awk '{print $2}')
    for dep in $deps; do
        grab_module "$dep"
    done
}

echo "==> Grabbing modules..."
for main_mod in "usb-storage" "uas" "ahci" "nvme" "nvme_auth" "nvme_keyring" "sd_mod" "loop" "isofs" "vfat" "ext4" "ntfs3"; do
    grab_module "$main_mod"
done

echo "==> Writing init script..."
cat << 'EOF' > "$INIT_D_DIR/01-storage.sh"
#!/bin/sh
echo "=== Loading GemOS Hardware Drivers ==="

modprobe loop 2>/dev/null
modprobe sd_mod 2>/dev/null
modprobe ahci 2>/dev/null
modprobe usb-storage 2>/dev/null
modprobe uas 2>/dev/null
modprobe hkdf 2>/dev/null
modprobe nvme_keyring 2>/dev/null
modprobe nvme_auth 2>/dev/null
modprobe nvme 2>/dev/null
modprobe isofs 2>/dev/null
modprobe vfat 2>/dev/null
modprobe ext4 2>/dev/null
modprobe ntfs3 2>/dev/null

mdev -s 2>/dev/null || true

echo "=== Storage Hardware Ready ==="
EOF
chmod +x "$INIT_D_DIR/01-storage.sh"