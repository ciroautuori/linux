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
fdisk -l

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
useradd -m -G wheel,storage,power,audio,video,users -s /bin/bash utente  # Crea un utente chiamato "utente"
passwd utente  # Imposta la password per l'utente 
echo "utente ALL=(ALL) ALL" | EDITOR=nano visudo  # Decommentare: %wheel ALL=(ALL) ALL

# Installa GRUB
pacman -S grub efibootmgr dosfstools mtools  
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB #ose-prober no
grub-mkconfig -o /boot/grub/grub.cfg

# Abilita NetworkManager
systemctl enable NetworkManager
systemctl start NetworkManager

# Esci da chroot
exit

# Smonta partizioni
umount -R /mnt

# Riavvia
reboot

# --- FINE PRIMO RIAVVIO ---
# Dopo il riavvio, esegui i seguenti comandi come utente (tuonome) con sudo:
# Installazione tastiera italiana 
sudo localectl set-x11-keymap it  

# Ottimizza pacman 
sudo nano /etc/pacman.conf/
VerbosePkgLists
Color
ParallelDownloads = 5
ILoveCandy
# uncomment
[multilib]
Include = /etc/pacman.d/mirrorlist

# Ottimizza mirror
pacman -Syu reflector --noconfirm
reflector --verbose \
                 --country Italy,Germany,Spain \
                 --fastest 10 \
                 --threads $(nproc) \
                 --save /etc/pacman.d/mirrorlist
                 
# Installa timeshift per i vari backup
sudo pacman -Syu timeshift --noconfirm

# Primo backup Terzo backup
sudo timeshift --create --comments "Installazione principale"

sudo timeshift --create --comments "Installazione base"

# Dopo l'aggiornamento, esegui i comandi seguenti per configurare Xorg, XFCE e driver video:
sudo pacman -S xorg xorg-server --noconfirm
sudo pacman -S xfce4 xfce4-goodies --noconfirm
sudo pacman -S lightdm lightdm-gtk-greeter --noconfirm
sudo systemctl enable lightdm
sudo nano /etc/lightdm/lightdm.conf #edita in greeter-session=lightdm-gtk-greeter

# Installa i driver video di base e il browser
sudo pacman -S nvidia nvidia-utils nvidia-settings nvidia-prime --noconfirm
sudo pacman -S mesa xf86-video-intel intel-media-driver --noconfirm
sudo pacman -S firefox --noconfirm
sudo reboot

# --- FINE SECONDO RIAVVIO ---
# Secondo backup
sudo timeshift --create --comments "Installazione desktop"

# Zsh
sudo pacman -S zsh --noconfirm
chsh -s $(which zsh)
source ~/.zshrc  
# OhMyZsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Tema zsh "Powerlevel10k"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# Modifica tema
nano ~/.zshrc
# Sostituisci ZSH_THEME con:
ZSH_THEME="powerlevel10k/powerlevel10k"
# Configura plugin
plugins=(git docker docker-compose sudo zsh-autosuggestions zsh-syntax-highlighting)
# Plugin syntax highlighting + font Nerd
sudo pacman -S zsh-syntax-highlighting ttf-meslo-nerd-font-powerlevel10k
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# Plugin autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# Ricarica configurazione
source ~/.zshrc
exec zsh

# Pacchetti base per il supporto wireless
sudo pacman -S wireless_tools wpa_supplicant netctl dialog iw network-manager-applet nm-connection-editor bluez bluez-utils blueman --noconfirm

# Installa e configura firewall
sudo pacman -S ufw --noconfirm
sudo systemctl enable ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow out 22/tcp
sudo ufw allow out 443/tcp
sudo ufw enable

# Installa e configura fail2ban
sudo pacman -S fail2ban --noconfirm
sudo systemctl enable fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
# Modifica:
[DEFAULT]
bantime = 1h
findtime = 30m
maxretry = 3

# Installa utility gestione energia
sudo pacman -S tlp thermald --noconfirm
sudo systemctl enable tlp
sudo systemctl enable thermald

# Hardisk e utils
sudo pacman -S ntfs-3g gvfs gvfs-mtp gvfs-afc gvfs-smb file-roller --noconfirm

# Input
sudo pacman -S xf86-input-libinput xf86-input-synaptics --noconfirm

# Audio
sudo pacman -S pulseaudio pulseaudio-bluetooth pavucontrol alsa-utils alsa-plugins --noconfirm

# Monitoraggio Sistema 
sudo pacman -S psensor lm_sensors hddtemp htop neofetch --noconfirm

# Utility Sistema 
sudo pacman -S gparted wget curl unzip p7zip ntfs-3g usbutils lsof tree vlc ffmpeg tree --noconfirm

# Gaming e Performance 
sudo pacman -S gamemode vulkan-intel vulkan-icd-loader intel-undervolt powertop cpupower --noconfirm

# Installa software di programmazione 
sudo pacman -S python python-pip nodejs npm docker docker-compose lua --noconfirm 
sudo systemctl enable docker 
sudo usermod -a -G docker utente        
newgrp docker 

# Font essenziali
sudo pacman -S ttf-dejavu ttf-freefont ttf-liberation ttf-droid terminus-font --noconfirm
sudo pacman -S noto-fonts noto-fonts-emoji ttf-ubuntu-font-family ttf-roboto ttf-roboto-mono --noconfirm

# --- Ottimizzazioni Avanzate ---
# Configura intel-undervolt
sudo pacman -S intel-undervolt --noconfirm
sudo nano /etc/intel-undervolt.conf
# Aggiungi:

    # Disabilita i triggers
    enable no
    # CPU Undervolting
    undervolt 0 'CPU' -100
    undervolt 1 'GPU' -50
    undervolt 2 'CPU Cache' -75
    undervolt 3 'System Agent' -50
    undervolt 4 'Analog I/O' -25
    # Modifica dei limiti di potenza
    power package 45 35
    # Modifica della temperatura critica
    tjoffset -20
    # Preferenze di energia vs prestazioni
    hwphint force load:single:0.8 performance balance_performance
    # Aggiornamento del daemon ogni 5 secondi
    interval 5000

sudo systemctl enable intel-undervolt
sudo systemctl start intel-undervolt

# Configurazione refresh rate ottimale
sudo nano /etc/X11/xorg.conf.d/10-monitor.conf
# Aggiungi:
Section "Monitor"
    Identifier "HDMI-0"
    Option "Primary" "true"
    Option "PreferredMode" "1920x1080_144.00"
EndSection

# Configurazione profilo thermald per Y520
sudo nano /etc/thermald/thermal-conf.xml
# Aggiungi configurazione specifica per Y520:
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

# Installazione Flatpak
sudo pacman -S flatpak --noconfirm
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Clona il repository di yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
yay -S steam    #conf nvidia

# Installazione delle applicazioni
sudo pacman -S --noconfirm libreoffice-fresh discord virtualbox virtualbox-host-modules-arch
yay -S --noconfirm anydesk whatsdesk-bin telegram-desktop-bin spotify visual-studio-code-bin 

# VirtualBox
sudo usermod -aG vboxusers $USER
sudo modprobe vboxdrv
sudo modprobe vboxnetflt
sudo modprobe vboxnetadp
echo "blacklist kvm" | sudo tee /etc/modprobe.d/blacklist-kvm.conf
echo "blacklist kvm_intel" | sudo tee -a /etc/modprobe.d/blacklist-kvm.conf
sudo systemctl enable vboxweb.service
sudo systemctl start vboxweb.service

# Tema WhiteSur
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git --depth=1
cd WhiteSur-gtk-theme
./install.sh -o solid -c dark
./tweaks.sh --firefox
cd ..
rm -rf WhiteSur-gtk-theme

# Configura sensori
sudo sensors-detect --auto

# Verifica componenti:
sudo nvidia-smi              # Test NVIDIA
sudo sensors                 # Test sensori
sudo powertop --auto-tune    # Ottimizza consumo energia

# Terzo backup
sudo timeshift --create --comments "Installazione completa"

# --- Archlinux y520  ---
sudo reboot

