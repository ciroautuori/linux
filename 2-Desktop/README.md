# Arch Linux: Installing Xorg, XFCE, NVIDIA Drivers, and Optimus Manager for Lenovo Legion Y520

This guide walks you through the process of installing **Xorg**, **XFCE**, **NVIDIA drivers**, and **Optimus Manager** on **Arch Linux** for the **Lenovo Legion Y520**. This setup allows you to switch between the integrated Intel GPU and the dedicated NVIDIA GPU, offering flexibility for power saving or performance as needed.

## Prerequisites

Before starting, ensure you have:
- A working installation of **Arch Linux**.
- A stable internet connection.
- Administrative (sudo) access.

## Table of Contents

- [Arch Linux: Installing Xorg, XFCE, NVIDIA Drivers, and Optimus Manager for Lenovo Legion Y520](#arch-linux-installing-xorg-xfce-nvidia-drivers-and-optimus-manager-for-lenovo-legion-y520)
  - [Prerequisites](#prerequisites)
  - [Table of Contents](#table-of-contents)
  - [1. Install Xorg and XFCE](#1-install-xorg-and-xfce)
  - [2. Install and Configure LightDM](#2-install-and-configure-lightdm)
  - [3. Install NVIDIA and Intel Drivers](#3-install-nvidia-and-intel-drivers)
  - [4. Install Yay and Browser](#4-install-yay-and-browser)
  - [5. Install and Configure Optimus Manager](#5-install-and-configure-optimus-manager)
  - [6. Switch Between GPUs](#6-switch-between-gpus)
    - [Switch to Intel GPU (Power Saving Mode):](#switch-to-intel-gpu-power-saving-mode)
    - [Switch to NVIDIA GPU (Performance Mode):](#switch-to-nvidia-gpu-performance-mode)
  - [7. Final Remarks](#7-final-remarks)
    - [Post-Installation Tips](#post-installation-tips)
  - [License](#license)
    - [Key Features of the README:](#key-features-of-the-readme)
    - [You can now copy this **README.md** to your GitHub repository. Let me know if you need further adjustments!](#you-can-now-copy-this-readmemd-to-your-github-repository-let-me-know-if-you-need-further-adjustments)

---

## 1. Install Xorg and XFCE

Install **Xorg**, the display server, and **XFCE**, the lightweight desktop environment:

```bash
sudo pacman -S xorg xorg-server --noconfirm
sudo pacman -S xfce4 xfce4-goodies --noconfirm
```

This installs the core components for running a graphical environment.

---

## 2. Install and Configure LightDM

Install **LightDM**, a display manager to handle login:

```bash
sudo pacman -S lightdm lightdm-gtk-greeter --noconfirm
```

Enable and start LightDM:

```bash
sudo systemctl enable lightdm
```

Edit the LightDM configuration to use the GTK greeter:

```bash
sudo nano /etc/lightdm/lightdm.conf
```

Find the line `greeter-session=` and set it to:

```
greeter-session=lightdm-gtk-greeter
```

---

## 3. Install NVIDIA and Intel Drivers

For optimal performance, you need both the **NVIDIA drivers** for the discrete GPU and **Intel drivers** for the integrated GPU. Run the following commands:

```bash
sudo pacman -S nvidia nvidia-utils nvidia-settings opencl-nvidia --noconfirm
sudo pacman -S mesa xf86-video-intel intel-media-driver --noconfirm
```

- `nvidia` installs the proprietary NVIDIA driver.
- `mesa`, `xf86-video-intel`, and `intel-media-driver` install the necessary drivers for Intel GPUs.

---

## 4. Install Yay and Browser

To easily install packages from the AUR (Arch User Repository), we’ll install **yay**, an AUR helper:

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
```

After installing yay, you can install additional software such as **Google Chrome** and **Optimus Manager**:

```bash
yay -S google-chrome optimus-manager
```

This will install Google Chrome as your web browser and **Optimus Manager**, which allows you to switch between the Intel and NVIDIA GPUs.

---

## 5. Install and Configure Optimus Manager

**Optimus Manager** allows you to switch between the Intel and NVIDIA GPUs. Enable and start the **Optimus Manager** service:

```bash
sudo systemctl enable optimus-manager.service
sudo systemctl start optimus-manager.service
```

After the installation, reboot your system for the changes to take effect:

```bash
sudo reboot
```

---

## 6. Switch Between GPUs

Once the system is back up, you can switch between the integrated Intel GPU and the dedicated NVIDIA GPU using the following commands:

### Switch to Intel GPU (Power Saving Mode):

```bash
optimus-manager --switch intel
```

### Switch to NVIDIA GPU (Performance Mode):

```bash
optimus-manager --switch nvidia
```

After switching, the system will prompt you to log out or restart to apply the changes.

---

## 7. Final Remarks

You now have a fully functional Arch Linux system running **XFCE** with **LightDM** as the display manager and the ability to switch between the **Intel** and **NVIDIA** GPUs using **Optimus Manager**. This setup provides both power efficiency (Intel GPU) and high performance (NVIDIA GPU) depending on your needs.

### Post-Installation Tips

- **Power Saving**: Switching to the Intel GPU is highly recommended when running on battery to save power.
- **NVIDIA Performance**: Switch to the NVIDIA GPU for graphics-intensive tasks such as gaming or 3D rendering.
- **Update System Regularly**: Keep your system up-to-date by running `sudo pacman -Syu` regularly.

---
