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
mkdir /mnt/boot/efi
mount /dev/nvme0n1p1 /mnt/boot/efi

# Installa il sistema base
pacstrap /mnt base base-devel linux linux-firmware intel-ucode nano git networkmanager

# Genera fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Entra nel sistema installato
arch-chroot /mnt /bin/bash

# Imposta timezone
ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime
hwclock --systohc

# Configura locale
nano /etc/locale.gen
# Decommentare it_IT.UTF-8 UTF-8
locale-gen
echo "LANG=it_IT.UTF-8" > /etc/locale.conf

# Imposta tastiera
echo "KEYMAP=it" > /etc/vconsole.conf

# Imposta hostname
echo "archlegion" > /etc/hostname

# Configura hosts
nano /etc/hosts
# Aggiungi:
# 127.0.0.1   localhost
# ::1         localhost
# 127.0.1.1   archlegion

# Imposta password root
passwd

# Installa GRUB
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Abilita NetworkManager
systemctl enable NetworkManager
systemctl start NetworkManager

# Crea un nuovo utente con privilegi sudo
useradd -m -G wheel,users -s /bin/bash utente  # Crea un utente chiamato "utente"
passwd utente  # Imposta la password per l'utente 
echo "utente ALL=(ALL) ALL" | EDITOR=nano visudo  # Decommentare: %wheel ALL=(ALL) ALL

# Esci da chroot
exit

# Smonta partizioni
umount -R /mnt

# Riavvia
reboot

# --- FINE PRIMO RIAVVIO ---
# Dopo il riavvio, esegui i seguenti comandi come utente (tuonome) con sudo:
# Ottimizza mirror
pacman -Sy reflector
reflector --verbose \
                 --country Italy,Germany,Spain \
                 --fastest 10 \
                 --threads $(nproc) \
                 --save /etc/pacman.d/mirrorlist
                 
# Installa timeshift per i vari backup
sudo pacman -Syu
sudo pacman -S timeshift

# Primo backup
sudo timeshift --create --comments "Installazione base"

# Dopo l'aggiornamento, esegui i comandi seguenti per configurare Xorg, XFCE e driver video:
sudo pacman -S xorg xorg-server --noconfirm
sudo pacman -S xfce4 xfce4-goodies --noconfirm
sudo pacman -S lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm
sudo nano /etc/lightdm/lightdm.conf #aggiungi lightdm-gtk-greeter in session
sudo reboot

# --- FINE SECONDO RIAVVIO ---
# Secondo backup
sudo timeshift --create --comments "Installazione desktop"

# Installa i driver di base
sudo pacman -S nvidia nvidia-utils nvidia-settings
sudo pacman -S mesa xf86-video-intel intel-media-driver
sudo reboot

# Clona il repository di yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
yay -S google-chrome

# --- FINE TERZO RIAVVIO ---
# Pacchetti base per il supporto wireless
sudo pacman -S wireless_tools wpa_supplicant netctl dialog iw network-manager-applet nm-connection-editor bluez bluez-utils blueman --noconfirm

# Installa e configura firewall
sudo pacman -S ufw
sudo systemctl enable ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow out 22/tcp
sudo ufw allow out 443/tcp
sudo ufw enable

# Installa e configura fail2ban
sudo pacman -S fail2ban
sudo systemctl enable fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
# Modifica:
[DEFAULT]
bantime = 1h
findtime = 30m
maxretry = 3

# Installa utility gestione energia
sudo pacman -S tlp thermald 
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
sudo systemctl enable docker            # enable docker daemon on system start
sudo usermod -a -G docker utente        # to be able to run docker as non-root
newgrp docker 

# Font essenziali
sudo pacman -S ttf-dejavu ttf-freefont ttf-liberation ttf-droid terminus-font --noconfirm
sudo pacman -S noto-fonts noto-fonts-emoji ttf-ubuntu-font-family ttf-roboto ttf-roboto-mono --noconfirm

# Installazione tastiera italiana 
sudo localectl set-x11-keymap it  

# Archlinux y520 
sudo reboot

# ----------------------
# POST INSTALLAZIONE
# ----------------------
# Terzo backup
sudo timeshift --create --comments "Installazione principale"

# Configura sensori
sudo sensors-detect --auto

# Verifica componenti:
sudo nvidia-smi              # Test NVIDIA
sudo sensors                 # Test sensori
sudo powertop --auto-tune    # Ottimizza consumo energia

# Se preferisci riavvia dinuovo
# Configura optimus-manager
yay -S optimus-manager optimus-manager-qt
sudo systemctl enable optimus-manager.service
sudo systemctl start optimus-manager.service
sudo nano /etc/optimus-manager/optimus-manager.conf
# Modifica:
[optimus]
startup_mode=hybrid
switching=none

# --- Ottimizzazioni Avanzate ---
# Configura intel-undervolt
sudo pacman -S intel-undervolt
sudo nano /etc/intel-undervolt.conf

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

# Setup backup automatico
sudo nano /etc/systemd/system/timeshift-autobackup.service
[Unit]
Description=Timeshift Auto Backup
# 
[Service]
Type=oneshot
ExecStart=/usr/bin/timeshift --create --comments "Auto Backup" --tags D
#
[Install]
WantedBy=multi-user.target

sudo nano /etc/systemd/system/timeshift-autobackup.timer
[Unit]
Description=Timeshift Auto Backup Timer
#
[Timer]
OnCalendar=daily
Persistent=true
#
[Install]
WantedBy=timers.target
sudo systemctl enable timeshift-autobackup.timer
sudo systemctl start timeshift-autobackup.timer

# Installazione Flatpak
sudo pacman -S flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Aggiorna il sistema
echo "Aggiornamento del sistema..."
sudo pacman -Syu --noconfirm

# Installazione Browser
yay -S --noconfirm google-chrome
sudo reboot

# ----------------------
# INSTALLAZIONE COMPLETA
# ----------------------
# Installazione delle applicazioni
sudo pacman -S --noconfirm steam libreoffice-fresh discord xournalpp wireshark-qt
yay -S --noconfirm anydesk whatsdesk-bin telegram-desktop-bin spotify visual-studio-code-bin virtualbox virtualbox-guest-iso

# VirtualBox
sudo gpasswd -a $USER vboxusers
sudo modprobe vboxdrv
sudo modprobe vboxdrv
sudo modprobe -r kvm_intel  
sudo modprobe -r kvm        
sudo systemctl enable vboxweb.service
sudo systemctl start vboxweb.service
echo "blacklist kvm" | sudo tee /etc/modprobe.d/blacklist-kvm.conf
echo "blacklist kvm_intel" | sudo tee -a /etc/modprobe.d/blacklist-kvm.conf  
lsmod | grep -i vbox

# Terzo backup
sudo timeshift --create --comments "Installazione completa"

# Esempio per rimuovere pacchetti
sudo pacman -Rsn firefox
rm -rf ~/.mozilla/firefox/
#Questo comando rimuoverà tutte le dipendenze non più necessarie
sudo pacman -Rs $(pacman -Qdtq)

#Abilitare il repository multilib
sudo nano /etc/pacman.conf
[multilib]
Include = /etc/pacman.d/mirrorlist

#Aggiornare il sistema
sudo pacman -Syyu

#Installare Wine
sudo pacman -S wine winetricks wine-mono wine-gecko zenity

#Configurazione
wine --version
winecfg
winetricks settings fontsmooth=rgb

# Winetricks
git clone https://github.com/HansKristian-Work/vkd3d-proton.git
cd vkd3d-proton
tar -xvf vkd3d-proton-*.tar.zst
cp -r * ~/.wine
cd ..
sudo rm -rf vkd3d-proton
cd ~/.wine
./setup_vkd3d_proton.sh install --symlink
winetricks dxvk
winetricks vkd3d

# Terminale
sudo nano /etc/pacman.conf
Color
Parallel Download
ILoveCandy

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
plugins=(
    git 
    docker 
    docker-compose 
    sudo 
    zsh-autosuggestions 
    zsh-syntax-highlighting
)

# Plugin syntax highlighting + font Nerd
sudo pacman -S zsh-syntax-highlighting ttf-meslo-nerd-font-powerlevel10k
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Plugin autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Ricarica configurazione
source ~/.zshrc
exec zsh
