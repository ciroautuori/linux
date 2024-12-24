# Minimal Debian 12 Setup Script for Lenovo Legion Y-520

This script automates the setup of a minimal Debian 12 (Bookworm) installation on a Lenovo Legion Y-520 laptop. It includes essential packages, desktop environment, NVIDIA drivers (if detected), utilities, Docker, and Node.js.

## Technical Specifications

This script targets the following hardware configuration (common for Lenovo Legion Y-520 models):

- **Laptop Model:** Lenovo Legion Y-520
- **Operating System:** Debian 12 (Bookworm) - Minimal Installation
- **Target Use Case:** General purpose development and personal usage with a lightweight desktop environment.

**Hardware:**

- **CPU:** Intel Core i5-7300HQ or Intel Core i7-7700HQ
- **RAM:** 8GB or 16GB DDR4
- **GPU:** NVIDIA GeForce GTX 1050 or GTX 1050 Ti (driver detection and installation is part of the script)
- **Storage:** SSD or HDD

**Software Components:**

- **Desktop Environment:** XFCE4 (lightweight and resource efficient)
- **Display Manager:** LightDM (with GTK greeter)
- **Base Utilities:** `sudo`, `htop`, `curl`, `wget`, `ufw`, `gnupg`, `apt-transport-https`, `ca-certificates`, `lsb-release`, `software-properties-common`, `debian-archive-keyring`
- **Additional Utilities:** `gnome-disk-utility`, `neofetch`, `powertop`, `firefox-esr`, `git`, `mousepad`, `synaptic`, `network-manager-gnome`, `firmware-iwlwifi`, `iw`, `pavucontrol`, `python3`, `python3-pip`, `gnome-screenshot`, `arc-theme`, `faenza-icon-theme`, `ffmpeg`, `gstreamer1.0-libav`, `bleachbit`, `timeshift`, `xdg-utils`, `xarchiver`, `tlp`, `gvfs`, `gvfs-backends`, `gvfs-daemons`, `gvfs-fuse`
- **Containerization:** Docker CE (with user setup)
- **JavaScript Runtime:** Node.js (v20.x)
- **NVIDIA Driver Support:** Automatically installs NVIDIA drivers if an NVIDIA GPU is detected

## Script Overview

The script performs the following tasks:

1. **Prerequisites Check:** Ensures the script is run with root privileges.
2. **Backup:** Creates a backup of the `/etc/apt/sources.list` file.
3. **System Update:** Updates and upgrades the system packages.
4. **Base Package Installation:** Installs essential system packages.
5. **Desktop Environment Installation:** Installs XFCE4 with minimal recommendations.
6. **NVIDIA Driver Installation:** Installs NVIDIA drivers if a compatible GPU is detected.
7. **Additional Utilities Installation:** Installs a wide range of useful utilities.
8. **Docker Installation and Setup:** Installs Docker CE and adds the specified user to the docker group, and ensures a sudo entry.
9. **Node.js Installation:** Installs Node.js (version 20.x).
10. **LightDM Configuration:** Configures LightDM to show the power option in the greeter.
11. **Network Restart:** Restarts NetworkManager for changes to take effect.
12. **Final System Update:** Performs a final update and upgrade.
13. **Cleanup:** Removes unnecessary packages and cleans up apt cache.
14. **Success Indicator:** Creates a file to indicate successful setup completion.
15. **Reboot:** Reboots the system after 10 seconds.

## Usage

1. **Prepare Debian 12 (Minimal) Installation:** Start with a minimal installation of Debian 12. Ensure you have network connectivity.
2. **Download Script:** Copy the `setup.sh` script to the Debian machine.
3. **Make Script Executable:**

    ```bash
    chmod +x setup.sh
    ```

4. **Run the Script:**

    ```bash
    sudo ./setup.sh
    ```

    The script will ask you to input your username during execution.

5. **Reboot:** After the script completes, the system will reboot automatically.
6. **Post-Reboot:** Log in with the specified user. You might need to log out and back in for the docker group changes to take effect.

## Important Notes

- The script now requests the username during execution. This user will be added to the sudo and docker groups.
- The script installs `nvidia-driver`, `nvidia-kernel-dkms`, and `nvidia-kernel-source`. Be sure to check your system's NVIDIA card for compatibility.
- This script was designed for a specific hardware configuration but can be adapted for other systems.

## Contributing

Feel free to contribute to this project by submitting pull requests. If you have any issues or feature requests, please open an issue on GitHub.

## License

This project is licensed under the [MIT License](LICENSE) - see the `LICENSE` file for details.
