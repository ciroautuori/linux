# Arch Linux Installation Guide for Lenovo Legion Y520

This guide provides a complete step-by-step process to install and configure Arch Linux on a Lenovo Legion Y520.

---

## Prerequisites

- A bootable USB with the Arch Linux ISO.
- An active internet connection.
- Basic knowledge of Linux command-line operations.

---

## Installation Steps

### 1. Verify Internet Connection
```bash
ping -c 3 archlinux.org
```

### 2. Set Keyboard Layout
```bash
loadkeys it
```

### 3. Update System Clock
```bash
timedatectl set-ntp true
timedatectl set-timezone Europe/Rome
```

### 4. Optimize Mirrors
```bash
pacman -Sy reflector
reflector --country Italy,Germany,Spain --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

### 5. Partition the Disk
```bash
lsblk
fdisk -l
cfdisk /dev/nvme0n1
```

#### Partitioning Scheme:
- **512M** EFI System Partition (`/dev/nvme0n1p1`)
- **4096M** Swap Partition (`/dev/nvme0n1p2`)
- **50G** Root Partition (`/dev/nvme0n1p3`)
- Remaining space for Home Partition (`/dev/nvme0n1p4`)

### 6. Format Partitions
```bash
mkfs.fat -F32 /dev/nvme0n1p1
mkswap /dev/nvme0n1p2
swapon /dev/nvme0n1p2
mkfs.ext4 /dev/nvme0n1p3
mkfs.ext4 /dev/nvme0n1p4
```

### 7. Mount Partitions
```bash
mount /dev/nvme0n1p3 /mnt
mkdir /mnt/home
mount /dev/nvme0n1p4 /mnt/home
mkdir /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi
```

### 8. Install Base System
```bash
pacstrap /mnt base base-devel linux linux-firmware intel-ucode git networkmanager
```

### 9. Generate Fstab
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

### 10. Configure the System
```bash
arch-chroot /mnt
```

#### Set Timezone and Clock:
```bash
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
hwclock --systohc
```

#### Configure Locale:
```bash
nano /etc/locale.gen
locale-gen
echo "LANG=it_IT.UTF-8" > /etc/locale.conf
```

#### Set Keyboard Layout:
```bash
echo "KEYMAP=it" > /etc/vconsole.conf
```

#### Set Hostname:
```bash
echo "arch-y520" > /etc/hostname
```

#### Configure Hosts:
```bash
nano /etc/hosts
```
Add the following lines:
```
127.0.0.1   localhost
::1         localhost
127.0.1.1   arch-y520.localdomain arch-y520
```

#### Set Root Password:
```bash
passwd
```

### 11. Install and Configure GRUB
```bash
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

### 12. Enable NetworkManager
```bash
systemctl enable NetworkManager
```

### 13. Create a New User
```bash
useradd -m -G wheel,users -s /bin/bash utente
passwd utente
```

#### Grant Sudo Privileges:
```bash
echo "utente ALL=(ALL) ALL" | EDITOR=nano visudo
```
Uncomment:
```
%wheel ALL=(ALL) ALL
```

### 14. Exit Chroot and Reboot
```bash
exit
umount -R /mnt
reboot
```

---

## Post-Installation Steps

### Update the System
```bash
sudo pacman -Syu
```

### Install Xorg and XFCE
```bash
sudo pacman -S xorg xorg-server xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm.service
reboot
```

### Install NVIDIA Drivers
```bash
sudo pacman -S nvidia nvidia-utils nvidia-settings
sudo reboot
```

### Configure Firewall
```bash
sudo pacman -S ufw
sudo systemctl enable ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable
```

### Install Fail2Ban
```bash
sudo pacman -S fail2ban
sudo systemctl enable fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
nano /etc/fail2ban/jail.local
```
Modify:
```
bantime = 1h
findtime = 30m
maxretry = 3
```

### Install Additional Utilities
```bash
sudo pacman -S gparted wget curl unzip p7zip ntfs-3g vlc ffmpeg htop neofetch
```

### Configure Gaming and Performance
```bash
sudo pacman -S gamemode vulkan-intel vulkan-icd-loader intel-undervolt powertop cpupower
```

---

## Optimizations and Maintenance

### Backup System
```bash
sudo pacman -S rsync deja-dup timeshift
sudo timeshift --create --comments "Initial Backup"
```

### Configure Auto Backup
Create and enable a systemd service and timer for automatic backups:
```bash
sudo nano /etc/systemd/system/timeshift-autobackup.service
sudo nano /etc/systemd/system/timeshift-autobackup.timer
sudo systemctl enable timeshift-autobackup.timer
```

### Install Yay (AUR Helper)
```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd .. && rm -rf yay
```

---

## Testing

Verify the following components:
- **NVIDIA GPU**: `sudo nvidia-smi`
- **Sensors**: `sudo sensors`
- **Audio**: `sudo speaker-test -c 2`
- **Bluetooth**: `sudo bluetoothctl show`
- **Power Optimization**: `sudo powertop --auto-tune`

---

This concludes the Arch Linux installation guide for Lenovo Legion Y520. For further customization and troubleshooting, refer to the [Arch Wiki](https://wiki.archlinux.org/).
