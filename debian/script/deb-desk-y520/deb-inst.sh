#!/bin/bash

# Exit on error and undefined variables
set -eu

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

# Error function
error() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    error "This script must be run as root"
fi

# Ask user to input username
read -p "Inserisci il tuo nome utente: " username

# Print username for verification
echo "Il tuo nome utente è: $username"

# Backup sources.list
log "Backing up sources.list..."
cp /etc/apt/sources.list /etc/apt/sources.list.backup

# Update system
log "Updating package lists..."
apt update || error "Failed to update package lists"
apt upgrade -y || error "Failed to upgrade packages"

# Install essential packages
log "Installing base system packages..."
base_packages=(
    apt-transport-https
    ca-certificates
    curl
    debian-archive-keyring
    gnupg
    htop
    lsb-release
    software-properties-common
    sudo
    ufw
    wget
)

apt install -y "${base_packages[@]}" || error "Failed to install base packages"

# Install desktop environment with minimal recommendations
log "Installing XFCE desktop environment..."
desktop_packages=(
    lightdm
    lightdm-gtk-greeter
    xfce4
    xfce4-goodies
    xorg
)

apt install -y --no-install-recommends "${desktop_packages[@]}" || error "Failed to install desktop packages"

# Install NVIDIA drivers if needed
if lspci | grep -i nvidia > /dev/null; then
    log "NVIDIA card detected, installing drivers..."
    apt install -y nvidia-driver nvidia-kernel-dkms nvidia-kernel-source || error "Failed to install NVIDIA drivers"
fi

# Install additional utilities
log "Installing additional utilities..."
utility_packages=(
    arc-theme
    bleachbit
    faenza-icon-theme
    ffmpeg
    firmware-iwlwifi
    git
    gnome-disk-utility
    gnome-screenshot
    gstreamer1.0-libav
    gvfs
    gvfs-backends
    gvfs-daemons
    gvfs-fuse
    iw
    mousepad
    neofetch
    network-manager-gnome
    pavucontrol
    powertop
    python3
    python3-pip
    synaptic
    timeshift
    tlp
    xarchiver
    xdg-utils
)

apt install -y "${utility_packages[@]}" || error "Failed to install utility packages"

# Install and configure Docker
install_docker() {
    local username="$1" # Il primo argomento passato alla funzione diventa il nome utente
    log "Installing Docker..."

    # Ensure the specified user is in the sudo group
    log "Adding $username to sudo group..."
    usermod -aG sudo "$username" || error "Failed to add $username to sudo group"

    if ! command -v docker &> /dev/null; then
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg

        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        tee /etc/apt/sources.list.d/docker.list > /dev/null

        apt update
        apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || error "Failed to install Docker"

        # Add the specified user to docker group
        usermod -aG docker "$username" || error "Failed to add $username to docker group"
        log "User $username added to docker group"

        # Notify about logout requirement
        log "Please logout and login again for docker group changes to take effect"
    else
        log "Docker is already installed"
        # Ensure user is in docker group even if Docker was already installed
        usermod -aG docker "$username" || error "Failed to add $username to docker group"
    fi
}

# Install Node.js
install_nodejs() {
    log "Installing Node.js..."
    if ! command -v node &> /dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt install -y nodejs || error "Failed to install Node.js"
    else
        log "Node.js is already installed"
    fi
}

# Install and configure system tools
install_docker "$username" #Passa username come argomento
install_nodejs

# Configure LightDM
log "Configuring LightDM..."
sed -i 's/#greeter-show-power=false/greeter-show-power=true/' /etc/lightdm/lightdm.conf
systemctl enable lightdm || error "Failed to enable LightDM"

# Restart network manager
log "Restarting NetworkManager..."
systemctl restart NetworkManager || error "Failed to restart NetworkManager"

# Final system update
log "Performing final system update..."
apt update && apt upgrade -y || error "Failed to perform final system update"

# Clean up
log "Cleaning up..."
apt autoremove -y
apt clean

# Create success file
touch /root/.debian_setup_complete

log "Installation completed successfully!"
log "System will reboot in 10 seconds..."
sleep 10
reboot