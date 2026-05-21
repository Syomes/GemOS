SHELL        := /bin/sh
BUILD_DIR    := build
ISO_FILE     := $(BUILD_DIR)/gemos.iso
OVMF_PATH    := /usr/share/ovmf/x64/OVMF.4m.fd
QEMU         := qemu-system-x86_64

.PHONY: build run clean fetch clean-all

build: fetch
	@sh scripts/build-initramfs.sh
	@sh scripts/build-iso.sh

fetch:
	@sh scripts/fetch-kernel.sh
	@sh scripts/fetch-busybox.sh

run:
	@if [ ! -f "$(ISO_FILE)" ]; then \
		sh scripts/fetch-kernel.sh && \
		sh scripts/fetch-busybox.sh && \
		sh scripts/build-initramfs.sh && \
		sh scripts/build-iso.sh; \
	fi
	@echo "==> Starting QEMU..."
	@$(QEMU) \
		-bios $(OVMF_PATH) \
		-cdrom $(ISO_FILE) \
		-m 512M \
		-vga std \
		-drive file=build/disk.img,format=raw,if=virtio 2>/dev/null || \
	$(QEMU) \
		-bios $(OVMF_PATH) \
		-cdrom $(ISO_FILE) \
		-m 512M \
		-vga std

clean:
	@echo "==> Cleaning build artifacts..."
	@rm -rf $(BUILD_DIR) tmp
	@echo "==> Done."

clean-all: clean
	@echo "==> Cleaning downloaded files..."
	@rm -rf external