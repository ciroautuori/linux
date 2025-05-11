# Arch Linux Installation Guide for Lenovo Legion Y520

This is a step-by-step guide to install **Arch Linux** on the **Lenovo Legion Y520** laptop. The process is fully UEFI-based and includes all the essential steps to configure the system properly. This guide is intended for advanced users who are familiar with Linux systems.

## Prerequisites

Before starting the installation, ensure you have:

- A bootable **Arch Linux USB drive**.
- An active internet connection.
- Backup of any important data from the device (installation will wipe all data on the disk).
- Access to UEFI/BIOS settings to boot from USB.

## Table of Contents

- [1. Verify System Connection](#1-verify-system-connection)
- [2. Set Keyboard Layout](#2-set-keyboard-layout)
- [3. Update System Clock](#3-update-system-clock)
- [4. Partitioning the Disk](#4-partitioning-the-disk)
- [5. Format the Partitions](#5-format-the-partitions)
- [6. Mount the Partitions](#6-mount-the-partitions)
- [7. Install Base System](#7-install-base-system)
- [8. Configure the System](#8-configure-the-system)
- [9. Install Bootloader (GRUB)](#9-install-bootloader-grub)
- [10. Network Configuration](#10-network-configuration)
- [11. Finalizing the Installation](#11-finalizing-the-installation)

---

## 1. Verify System Connection

To ensure the internet connection is working properly, run:

```bash
ping -c 3 archlinux.org
```

---

## 2. Set Keyboard Layout

Set the keyboard layout to Italian (or your preferred layout) by running:

```bash
loadkeys it
```

---

## 3. Update System Clock

Synchronize the system clock with NTP:

```bash
timedatectl set-ntp true
```

Set the system timezone to Europe/Rome:

```bash
timedatectl set-timezone Europe/Rome
```

---

## 4. Partitioning the Disk

Use **`cfdisk`** or another partitioning tool to create the following partitions on your disk (`/dev/nvme0n1` is used as an example):

- **EFI** (512MB)
- **Swap** (4GB)
- **Root** (`/`) (50GB)
- **Home** (`/home`) (Remaining space)

```bash
cfdisk /dev/nvme0n1
```

---

## 5. Format the Partitions

Format the partitions with the following commands:

```bash
mkfs.fat -F32 /dev/nvme0n1p1  # EFI Partition
mkswap /dev/nvme0n1p2        # Swap Partition
swapon /dev/nvme0n1p2        # Activate swap
mkfs.ext4 /dev/nvme0n1p3      # Root Partition
mkfs.ext4 /dev/nvme0n1p4      # Home Partition
```

---

## 6. Mount the Partitions

Mount the root partition and create directories for other partitions:

```bash
mount /dev/nvme0n1p3 /mnt
mkdir /mnt/home
mount /dev/nvme0n1p4 /mnt/home
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi
```

---

## 7. Install Base System

Install the base system packages:

```bash
pacstrap /mnt base base-devel linux linux-firmware linux-headers intel-ucode nano git networkmanager
```

Generate the `fstab` file:

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

Chroot into the new system:

```bash
arch-chroot /mnt /bin/bash
```

---

## 8. Configure the System

### Set Timezone:

```bash
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
hwclock --systohc
```

### Configure Locale:

Edit `/etc/locale.gen` and uncomment `it_IT.UTF-8 UTF-8`:

```bash
nano /etc/locale.gen
```

Generate locales:

```bash
locale-gen
```

Set the default language:

```bash
echo "LANG=it_IT.UTF-8" > /etc/locale.conf
```

### Set Keyboard Layout:

```bash
echo "KEYMAP=it" > /etc/vconsole.conf
```

### Set Hostname:

```bash
echo "archlegion" > /etc/hostname
```

### Configure Hosts File:

```bash
nano /etc/hosts
```

Add the following lines:

```
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlegion.localdomain    archlegion
```

### Set Password for Root:

```bash
passwd
```

### Create a New User:

Create a new user with sudo privileges:

```bash
useradd -m -G wheel,storage,power,audio,video,users -s /bin/bash username
passwd username
```

Edit the sudoers file to grant sudo privileges:

```bash
echo "username ALL=(ALL) ALL" | EDITOR=nano visudo
```

---

## 9. Install Bootloader (GRUB)

Install GRUB and related tools:

```bash
pacman -S grub efibootmgr dosfstools mtools --noconfirm
```

Install GRUB to the system:

```bash
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
```

Generate the GRUB configuration:

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

---

## 10. Network Configuration

Enable **NetworkManager** for managing network connections:

```bash
systemctl enable NetworkManager
```

---

## 11. Finalizing the Installation

Exit chroot:

```bash
exit
```

Unmount all partitions:

```bash
umount -R /mnt
```

Reboot the system:

```bash
reboot
```

Remove the installation media to boot into the newly installed Arch Linux system.

---
