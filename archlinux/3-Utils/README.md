# Arch Linux: Zsh, System Optimizations, and Essential Software for Lenovo Legion Y520

This guide provides the steps to install **Zsh**, essential software, optimize the system for performance and battery life, and install necessary drivers on **Arch Linux** for the **Lenovo Legion Y520**. This includes setting up **Oh My Zsh**, configuring power management, installing wireless and Bluetooth tools, and much more.

## Prerequisites

Before proceeding, make sure you have:
- A working installation of **Arch Linux**.
- A stable internet connection.
- Administrative (sudo) access.

## Table of Contents

- [1. Configure Italian Keyboard](#1-configure-italian-keyboard)
- [2. Optimize Pacman](#2-optimize-pacman)
- [3. Optimize Mirror List](#3-optimize-mirror-list)
- [4. Create a Backup with Timeshift](#4-create-a-backup-with-timeshift)
- [5. Install and Configure Zsh](#5-install-and-configure-zsh)
- [6. Install Wireless and Bluetooth Packages](#6-install-wireless-and-bluetooth-packages)
- [7. Configure Firewall](#7-configure-firewall)
- [8. Install and Configure Fail2ban](#8-install-and-configure-fail2ban)
- [9. Install Power Management Tools](#9-install-power-management-tools)
- [10. Install System Utilities](#10-install-system-utilities)
- [11. Install Gaming and Performance Tools](#11-install-gaming-and-performance-tools)
- [12. Install Development Tools](#12-install-development-tools)
- [13. Install Fonts](#13-install-fonts)
- [14. Advanced Optimizations](#14-advanced-optimizations)
- [15. Configure Monitor and Thermal Settings](#15-configure-monitor-and-thermal-settings)
- [16. Install Flatpak and AUR](#16-install-flatpak-and-aur)
- [17. Install WhiteSur Theme](#17-install-whitesur-theme)
- [18. Configure Sensors](#18-configure-sensors)
- [19. Test System Components](#19-test-system-components)

---

## 1. Configure Italian Keyboard

Set the keyboard layout to Italian:

```bash
sudo localectl set-x11-keymap it
```

---

## 2. Optimize Pacman

Modify **pacman.conf** for better performance:

```bash
sudo nano /etc/pacman.conf
```

Ensure the following options are enabled:

```bash
VerbosePkgLists
Color
ParallelDownloads = 5
ILoveCandy
```

Enable **multilib** support:

```bash
[multilib]
Include = /etc/pacman.d/mirrorlist
```

---

## 3. Optimize Mirror List

Install **reflector** to get the best mirrors:

```bash
sudo pacman -Syu reflector --noconfirm
reflector --verbose --country Italy,Germany,Spain --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

---

## 4. Create a Backup with Timeshift

Before proceeding with optimizations, create a system backup with **Timeshift**:

```bash
sudo pacman -Syu timeshift --noconfirm
sudo timeshift --create --comments "base"
```

---

## 5. Install and Configure Zsh

Install **Zsh** and set it as the default shell:

```bash
sudo pacman -S zsh --noconfirm
chsh -s $(which zsh)
```

Install **Oh My Zsh**, **Powerlevel10k** theme, and essential plugins:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Edit `.zshrc` and apply the theme and plugins:

```bash
nano ~/.zshrc
```

Modify the file:

```bash
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git docker docker-compose sudo zsh-autosuggestions zsh-syntax-highlighting)
```

Install plugins:

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
source ~/.zshrc
exec zsh
```

---

## 6. Install Wireless and Bluetooth Packages

```bash
sudo pacman -S wireless_tools wpa_supplicant netctl dialog iw network-manager-applet nm-connection-editor bluez bluez-utils blueman --noconfirm
sudo systemctl enable bluetooth
sudo systemctl start bluetooth
```

---

## 7. Configure Firewall

```bash
sudo pacman -S ufw --noconfirm
sudo systemctl enable ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow out 22/tcp
sudo ufw allow out 443/tcp
sudo ufw enable
```

---

## 8. Install and Configure Fail2ban

```bash
sudo pacman -S fail2ban --noconfirm
sudo systemctl enable fail2ban
```

---

## 9. Install Power Management Tools

```bash
sudo pacman -S tlp thermald --noconfirm
sudo systemctl enable tlp
sudo systemctl enable thermald
```

---

## 17. Install WhiteSur Theme

```bash
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
cd WhiteSur-gtk-theme
./install.sh -o solid -c light
./tweaks.sh --firefox
cd ..
rm -rf WhiteSur-gtk-theme
```

---

## 18. Configure Sensors

Run **sensors-detect** to detect available hardware sensors:

```bash
sudo sensors-detect --auto
```

---

## 19. Test System Components

### NVIDIA GPU Status

```bash
sudo nvidia-smi
```

### Check Sensors

```bash
sudo sensors
```

### Power Management Optimization

```bash
sudo powertop --auto-tune
```

