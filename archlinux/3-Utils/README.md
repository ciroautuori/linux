# Arch Linux: Zsh, System Optimizations, and Essential Software for Lenovo Legion Y520

This guide provides the steps to install **Zsh**, essential software, optimize the system for performance and battery life, and install necessary drivers on **Arch Linux** for the **Lenovo Legion Y520**. This includes setting up **Oh My Zsh**, configuring power management, installing wireless and Bluetooth tools, and much more.

## Prerequisites

Before proceeding, make sure you have:
- A working installation of **Arch Linux**.
- A stable internet connection.
- Administrative (sudo) access.

## Table of Contents

- [1. Create a Backup with Timeshift](#1-create-a-backup-with-timeshift)
- [2. Install and Configure Zsh](#2-install-and-configure-zsh)
- [3. Install Wireless and Bluetooth Packages](#3-install-wireless-and-bluetooth-packages)
- [4. Configure Firewall](#4-configure-firewall)
- [5. Install and Configure Fail2ban](#5-install-and-configure-fail2ban)
- [6. Install Power Management Tools](#6-install-power-management-tools)
- [7. Install System Utilities](#7-install-system-utilities)
- [8. Install Gaming and Performance Tools](#8-install-gaming-and-performance-tools)
- [9. Install Development Tools](#9-install-development-tools)
- [10. Install Fonts](#10-install-fonts)
- [11. Advanced Optimizations](#11-advanced-optimizations)
- [12. Configure Monitor and Thermal Settings](#12-configure-monitor-and-thermal-settings)
- [13. Install Flatpak and AUR](#13-install-flatpak-and-aur)

---

## 1. Create a Backup with Timeshift

Before starting the optimization process, create a system backup with **Timeshift**:

```bash
sudo pacman -Syu timeshift --noconfirm
sudo timeshift --create --comments "base"
```

This step ensures you have a recovery point in case something goes wrong during the installation.

---

## 2. Install and Configure Zsh

Install **Zsh** and set it as the default shell:

```bash
sudo pacman -S zsh --noconfirm
chsh -s $(which zsh)
```

Next, install **Oh My Zsh** for enhanced Zsh functionality:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Install the **Powerlevel10k** theme and useful plugins:

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

Edit your `.zshrc` file to set the theme and plugins:

```bash
nano ~/.zshrc
```

Modify the file as follows:

```bash
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git docker docker-compose sudo zsh-autosuggestions zsh-syntax-highlighting)
```

Install the plugins:

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

Activate your changes:

```bash
source ~/.zshrc
exec zsh
```

Reboot the system for changes to take effect:

```bash
sudo reboot
```

---

## 3. Install Wireless and Bluetooth Packages

Install packages for **wireless** and **Bluetooth** connectivity:

```bash
sudo pacman -S wireless_tools wpa_supplicant netctl dialog iw network-manager-applet nm-connection-editor bluez bluez-utils blueman --noconfirm
sudo systemctl enable bluetooth
sudo systemctl start bluetooth
```

---

## 4. Configure Firewall

Install and configure **UFW** (Uncomplicated Firewall):

```bash
sudo pacman -S ufw --noconfirm
sudo systemctl enable ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow out 22/tcp
sudo ufw allow out 443/tcp
sudo ufw enable
```

This setup ensures your system is secure by default, only allowing necessary connections.

---

## 5. Install and Configure Fail2ban

Install **Fail2ban** to protect your system from brute-force attacks:

```bash
sudo pacman -S fail2ban --noconfirm
sudo systemctl enable fail2ban
```

Copy and modify the configuration file:

```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
```

Modify the default settings as follows:

```bash
[DEFAULT]
bantime = 1h
findtime = 30m
maxretry = 3
```

---

## 6. Install Power Management Tools

To enhance battery life and thermal performance, install the following tools:

```bash
sudo pacman -S tlp thermald --noconfirm
sudo systemctl enable tlp
sudo systemctl enable thermald
```

---

## 7. Install System Utilities

Install various useful utilities:

```bash
sudo pacman -S ntfs-3g gvfs gvfs-mtp gvfs-afc gvfs-smb file-roller --noconfirm
sudo pacman -S xf86-input-libinput xf86-input-synaptics --noconfirm
sudo pacman -S pulseaudio pulseaudio-bluetooth pavucontrol alsa-utils alsa-plugins --noconfirm
sudo pacman -S psensor lm_sensors hddtemp htop neofetch --noconfirm
sudo pacman -S gparted wget curl unzip p7zip ntfs-3g usbutils lsof tree vlc ffmpeg --noconfirm
```

These tools are essential for managing system hardware, audio, and files.

---

## 8. Install Gaming and Performance Tools

Install tools for **gaming** and **performance tuning**:

```bash
sudo pacman -S gamemode vulkan-intel vulkan-icd-loader intel-undervolt powertop cpupower --noconfirm
```

---

## 9. Install Development Tools

Install essential programming tools:

```bash
sudo pacman -S python python-pip nodejs npm docker docker-compose lua --noconfirm
sudo systemctl enable docker
sudo usermod -a -G docker username
newgrp docker
```

---

## 10. Install Fonts

Install popular fonts for better readability:

```bash
sudo pacman -S ttf-dejavu ttf-freefont ttf-liberation ttf-droid terminus-font --noconfirm
sudo pacman -S noto-fonts noto-fonts-emoji ttf-ubuntu-font-family ttf-roboto ttf-roboto-mono --noconfirm
```

---

## 11. Advanced Optimizations

### Intel Undervolt

For better power efficiency, configure **Intel Undervolt**:

```bash
sudo nano /etc/intel-undervolt.conf
```

Modify the file as follows:

```bash
enable no
undervolt 0 'CPU' -80
undervolt 1 'GPU' -50
undervolt 2 'CPU Cache' -75
undervolt 3 'System Agent' -50
undervolt 4 'Analog I/O' -25
power package 45 30
tjoffset -20
hwphint force load:single:0.8 performance balance_performance
interval 5000
```

Enable **Intel Undervolt**:

```bash
sudo systemctl enable intel-undervolt
sudo systemctl start intel-undervolt
```

---

## 12. Configure Monitor and Thermal Settings

### Monitor Configuration

For better monitor performance, configure the display settings:

```bash
sudo nano /etc/X11/xorg.conf.d/10-monitor.conf
```

Add the following configuration:

```bash
Section "Monitor"
    Identifier "HDMI-0"
    Option "Primary" "true"
    Option "PreferredMode" "1920x1080_144.00"
EndSection
```

### Thermal Configuration

Configure **Thermald** for better temperature management:

```bash
sudo nano /etc/thermald/thermal-conf.xml
```

Add the

```xml
<ThermalConfiguration>
    <Platform>
        <Name>Legion Y520</Name>
        <ProductName>Lenovo Legion Y520</ProductName>
        <Preference>QUIET</Preference>
        <ThermalZones>
            <ThermalZone>
                <Type>cpu</Type>
                <TripPoints>
                    <TripPoint>
                        <SensorType>thermal</SensorType>
                        <Temperature>75000</Temperature>
                        <type>passive</type>
                        <ControlType>SEQUENTIAL</ControlType>
                    </TripPoint>
                </TripPoints>
            </ThermalZone>
        </ThermalZones>
    </Platform>
</ThermalConfiguration>
```

---

## 13. Install Flatpak and AUR

Install **Flatpak** and add the **Flathub** repository:

```bash
sudo pacman -S flatpak --noconfirm
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

---
Certainly! Here's how to incorporate the additional steps for sensor configuration and component testing into the guide.

---

## 14. Install System Utilities (Updated)

In addition to the utilities previously mentioned, it's a good idea to configure sensors and test system components for better performance and monitoring.

### Configure Sensors

Run **sensors-detect** to automatically detect available sensors on your system:

```bash
sudo sensors-detect --auto
```

This will scan for hardware sensors and enable them for monitoring CPU temperature, fan speed, and other components.

---

## 15. Test System Components

Test the components to ensure everything is working properly:

### NVIDIA GPU Status

If you have an NVIDIA GPU, check its status using **nvidia-smi**:

```bash
sudo nvidia-smi
```

This command will display information about the NVIDIA graphics card, including temperature, GPU utilization, and memory usage.

### Sensors

To check the status of sensors (such as temperature, fan speed, etc.), run:

```bash
sudo sensors
```

This will display a list of available sensors and their current readings.

### Power Management

For power management, run **powertop** and automatically tune your system for better power efficiency:

```bash
sudo powertop --auto-tune
```

This command adjusts various power-related settings to optimize battery life.

---
