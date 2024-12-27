#!/bin/bash

# ============================================
# GUIDA COMPLETA INSTALLAZIONE ARCH LINUX
# Per Lenovo Legion Y520 
# ============================================

# Verifica connessione
ping -c 3 archlinux.org

# Setta la tastiera in italiano
loadkeys it

# Aggiorna orologio di sistema
timedatectl set-ntp true
timedatectl set-timezone Europe/Rome

# Mostra dischi disponibili
lsblk

# Crea partizioni con cfdisk
cfdisk /dev/nvme0n1

# Formatta partizioni
mkfs.fat -F32 /dev/nvme0n1p1 	# /dev/nvme0n1p1: 512M   EFI   
mkswap /dev/nvme0n1p2	     	# /dev/nvme0n1p2: 4096M  swap   
swapon /dev/nvme0n1p2        
mkfs.ext4 /dev/nvme0n1p3     	# /dev/nvme0n1p3: 50G    root 
mkfs.ext4 /dev/nvme0n1p4     	# /dev/nvme0n1p4: ALL    home

# Monta partizioni
mount /dev/nvme0n1p3 /mnt
mkdir /mnt/home
mount /dev/nvme0n1p4 /mnt/home
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi

# Installa il sistema base
pacstrap /mnt base base-devel linux linux-firmware linux-headers intel-ucode nano git networkmanager

# Genera fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Entra nel sistema installato
arch-chroot /mnt /bin/bash

# Imposta timezone
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
hwclock --systohc

# Configura locale
nano /etc/locale.gen # Decommentare it_IT.UTF-8 UTF-8
locale-gen
echo "LANG=it_IT.UTF-8" > /etc/locale.conf

# Imposta tastiera
echo "KEYMAP=it" > /etc/vconsole.conf

# Imposta hostname
echo "archlegion" > /etc/hostname

# Configura hosts
nano /etc/hosts
# 127.0.0.1   localhost
# ::1         localhost
# 127.0.1.1   archlegion.localdomain    localhost

# Imposta password root
passwd

# Crea un nuovo utente con privilegi sudo
useradd -m -G wheel,storage,power,audio,video,users -s /bin/bash utente
passwd utente
echo "utente ALL=(ALL) ALL" | EDITOR=nano visudo

# Installa GRUB
pacman -S grub efibootmgr dosfstools mtools --noconfirm
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB 
nano /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet nvidia-drm.modeset=1 intel_iommu=on iommu=pt"
grub-mkconfig -o /boot/grub/grub.cfg

# Abilita NetworkManager
systemctl enable NetworkManager

# Esci da chroot
exit

# Smonta partizioni
umount -R /mnt

# Riavvia
reboot

# --- FINE PRIMO RIAVVIO ---

# Installazione tastiera italiana 
sudo localectl set-x11-keymap it  
sudo loadkeys it

# Ottimizza pacman 
sudo nano /etc/pacman.conf
# Aggiungi/modifica:
Color
ParallelDownloads = 5
ILoveCandy
[multilib]
Include = /etc/pacman.d/mirrorlist

# Installa timeshift per i backup
sudo pacman -Syu timeshift --noconfirm
sudo timeshift --create --comments "Installazione base"

# Installa Xorg e XFCE
sudo pacman -S xorg xorg-server --noconfirm
sudo pacman -S xfce4 xfce4-goodies --noconfirm
sudo pacman -S lightdm lightdm-gtk-greeter --noconfirm
sudo systemctl enable lightdm
sudo nano /etc/lightdm/lightdm.conf #edita in greeter-session=lightdm-gtk-greeter

# --- Driver Video per Legion Y520 ---
sudo pacman -S nvidia nvidia-utils nvidia-settings --noconfirm
sudo pacman -S mesa xf86-video-intel intel-media-driver --noconfirm

# Installa browser
sudo pacman -S firefox --noconfirm
sudo reboot

# --- FINE SECONDO RIAVVIO ---

# Secondo backup
sudo timeshift --create --comments "Installazione desktop"

# Zsh e plugin
sudo pacman -S zsh --noconfirm
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
nano ~/.zshrc
# Modifica:
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git docker docker-compose sudo zsh-autosuggestions zsh-syntax-highlighting)
# Installa repo
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
source ~/.zshrc
exec zsh
sudo reboot

# Pacchetti wireless e bluetooth
sudo pacman -S wireless_tools wpa_supplicant netctl dialog iw network-manager-applet nm-connection-editor bluez bluez-utils blueman --noconfirm

# Firewall
sudo pacman -S ufw --noconfirm
sudo systemctl enable ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow out 22/tcp
sudo ufw allow out 443/tcp
sudo ufw enable

# Fail2ban
sudo pacman -S fail2ban --noconfirm
sudo systemctl enable fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
# Modifica:
[DEFAULT]
bantime = 1h
findtime = 30m
maxretry = 3

# Gestione energia
sudo pacman -S tlp thermald --noconfirm
sudo systemctl enable tlp
sudo systemctl enable thermald

# Utility sistema
sudo pacman -S ntfs-3g gvfs gvfs-mtp gvfs-afc gvfs-smb file-roller --noconfirm
sudo pacman -S xf86-input-libinput xf86-input-synaptics --noconfirm
sudo pacman -S pulseaudio pulseaudio-bluetooth pavucontrol alsa-utils alsa-plugins --noconfirm
sudo pacman -S psensor lm_sensors hddtemp htop neofetch --noconfirm
sudo pacman -S gparted wget curl unzip p7zip ntfs-3g usbutils lsof tree vlc ffmpeg tree --noconfirm

# Gaming e Performance
sudo pacman -S gamemode vulkan-intel vulkan-icd-loader intel-undervolt powertop cpupower --noconfirm

# Programmazione
sudo pacman -S python python-pip nodejs npm docker docker-compose lua --noconfirm
sudo systemctl enable docker
sudo usermod -a -G docker utente
newgrp docker

# Font
sudo pacman -S ttf-dejavu ttf-freefont ttf-liberation ttf-droid terminus-font --noconfirm
sudo pacman -S noto-fonts noto-fonts-emoji ttf-ubuntu-font-family ttf-roboto ttf-roboto-mono --noconfirm

# --- Ottimizzazioni Avanzate ---
# Intel Undervolt
sudo nano /etc/intel-undervolt.conf
# Modifica:
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

sudo systemctl enable intel-undervolt
sudo systemctl start intel-undervolt

# Configurazione monitor
sudo nano /etc/X11/xorg.conf.d/10-monitor.conf
# Aggiungi:
Section "Monitor"
    Identifier "HDMI-0"
    Option "Primary" "true"
    Option "PreferredMode" "1920x1080_144.00"
EndSection

# Configurazione thermald
sudo nano /etc/thermald/thermal-conf.xml
# Aggiungi:
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

# Flatpak e AUR
sudo pacman -S flatpak --noconfirm
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
yay -S steam xfce4-docklike-plugin 0.4.3-1

# Applicazioni aggiuntive
sudo pacman -S --noconfirm libreoffice-fresh discord virtualbox virtualbox-host-modules-arch
yay -S --noconfirm anydesk whatsdesk-bin telegram-desktop-bin spotify visual-studio-code-bin

# VirtualBox setup
sudo usermod -aG vboxusers $USER
sudo modprobe vboxdrv
sudo modprobe vboxnetflt
sudo modprobe vboxnetadp
sudo systemctl enable vboxweb.service
sudo systemctl start vboxweb.service

# Configura sensori
sudo sensors-detect --auto

# Test componenti
sudo nvidia-smi
sudo sensors
sudo powertop --auto-tune

# Tema WhiteSur chiudi firefox
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
cd WhiteSur-gtk-theme
./install.sh -o solid -c dark
./tweaks.sh --firefox
cd ..
rm -rf WhiteSur-gtk-theme
sudo reboot

# Backup finale
sudo timeshift --create --comments "Installazione completa"
