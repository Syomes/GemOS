# GemOS
GemOS is a lightweight, customizable, extensible operating system based on Linux built by your own machine. It constructs a minimal, UEFI-bootable ISO image using the host's kernel and a static BusyBox binary.

> [!NOTE]
> This project is still a work in progress. Contributions to improve hardware compatibility are highly welcome!

## Features
- **Minimalist**: Extremely small footprint, focusing only on essential components.
- **UEFI Support**: Built-in support for UEFI booting via GRUB.
- **Extension System**: Modular design allowing for easy addition of features (e.g., disk installation).

## Prerequisites
To build and run GemOS, you need the following tools installed on your system:

- `curl`: To download packages.
- `xorriso`: For ISO image creation.
- `grub-common`: Specifically `grub-mkimage` for creating the EFI bootloader.
- `mtools` & `dosfstools`: For manipulating EFI system partition images.
- `binutils`: For `strip` to minimize binary sizes.
- (Optional)`qemu-system-x86_64` & `ovmf`: To run the resulting ISO in a virtual environment.

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install curl xorriso grub-common mtools dosfstools binutils qemu-system-x86_64 ovmf
```

### Arch Linux
```bash
sudo pacman -S curl xorriso grub mtools dosfstools binutils qemu-desktop ovmf
```

## Getting Started
### Build the ISO
Simply run the following command to fetch the kernel/busybox and build the ISO:
```bash
make build
```
The output will be located at `build/gemos.iso`. With no extensions, its size could be about 40MB.

### Run in QEMU
To test GemOS in a virtual machine:
```bash
make run
```
*Note: This requires `OVMF` to be installed at `/usr/share/ovmf/x64/OVMF.4m.fd` (standard on most distros).*

### Cleanup
To remove build artifacts:
```bash
make clean
```
To remove all downloaded files as well:
```bash
make clean-all
```
