#!/bin/bash

# File per tracciare il progresso dell'installazione
PROGRESS_FILE="/var/log/arch_install_progress"
LOG_FILE="/var/log/arch_install.log"

# Funzione per il logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Funzione per salvare il progresso
save_progress() {
    echo "$1" > "$PROGRESS_FILE"
    log "Salvato progresso: Fase $1"
}

# Funzione per leggere il progresso
read_progress() {
    if [ -f "$PROGRESS_FILE" ]; then
        cat "$PROGRESS_FILE"
    else
        echo "0"
    fi
}

# Funzione per gestire errori
handle_error() {
    log "ERRORE nella fase $1: $2"
    exit 1
}

# Configurazione autostart
setup_autostart() {
    if ! grep -q "$0" /etc/rc.local 2>/dev/null; then
        echo "#!/bin/bash" > /etc/rc.local
        echo "$0 &" >> /etc/rc.local
        chmod +x /etc/rc.local
        systemctl enable rc-local.service
    fi
}

# Fase 1: Setup iniziale
phase_1() {
    log "Inizia Fase 1: Setup iniziale"
    
    # Ottimizzazione mirror
    pacman -Sy reflector --noconfirm || handle_error "1" "Installazione reflector fallita"
    reflector --verbose --country Italy,Germany,Spain --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
    
    # Installazione timeshift
    pacman -Syu --noconfirm
    pacman -S timeshift --noconfirm || handle_error "1" "Installazione timeshift fallita"
    
    # Primo backup
    timeshift --create --comments "Installazione base" || handle_error "1" "Backup iniziale fallito"
    
    # Installazione Desktop Environment
    pacman -S xorg xorg-server xfce4 xfce4-goodies lightdm lightdm-gtk-greeter --noconfirm
    systemctl enable lightdm
    
    # Configurazione LightDM
    sed -i 's/#greeter-session=example-gtk-gnome/greeter-session=lightdm-gtk-greeter/' /etc/lightdm/lightdm.conf
    
    save_progress "2"
    log "Fine Fase 1, riavvio..."
    reboot
}

# Fase 2: Driver e AUR
phase_2() {
    log "Inizia Fase 2: Installazione driver"
    
    # Backup pre-driver
    timeshift --create --comments "Installazione desktop"
    
    # Installazione driver
    pacman -S nvidia nvidia-utils nvidia-settings mesa xf86-video-intel intel-media-driver --noconfirm
    
    # Installazione yay
    if ! command -v yay &> /dev/null; then
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    fi
    
    # Installazione Chrome
    yay -S google-chrome --noconfirm
    
    save_progress "3"
    log "Fine Fase 2, riavvio..."
    reboot
}

# Fase 3: Utility e configurazione sistema base
phase_3() {
    log "Inizia Fase 3: Configurazione sistema base"
    
    # Pacchetti di rete
    pacman -S wireless_tools wpa_supplicant netctl dialog iw network-manager-applet \
              nm-connection-editor bluez bluez-utils blueman --noconfirm
    
    # Firewall
    pacman -S ufw --noconfirm
    systemctl enable ufw
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow out 22/tcp
    ufw allow out 443/tcp
    ufw enable
    
    # Fail2ban
    pacman -S fail2ban --noconfirm
    systemctl enable fail2ban
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    sed -i 's/bantime  = 10m/bantime  = 1h/' /etc/fail2ban/jail.local
    sed -i 's/findtime  = 10m/findtime  = 30m/' /etc/fail2ban/jail.local
    sed -i 's/maxretry = 5/maxretry = 3/' /etc/fail2ban/jail.local
    
    # Gestione energia
    pacman -S tlp thermald --noconfirm
    systemctl enable tlp
    systemctl enable thermald
    
    # Utility di sistema base
    pacman -S ntfs-3g gvfs gvfs-mtp gvfs-afc gvfs-smb file-roller \
              xf86-input-libinput xf86-input-synaptics \
              pulseaudio pulseaudio-bluetooth pavucontrol alsa-utils \
              psensor lm_sensors hddtemp htop neofetch \
              gparted wget curl unzip p7zip usbutils lsof ttf-liberation vlc ffmpeg --noconfirm
    
    save_progress "4"
    log "Fine Fase 3, riavvio..."
    reboot
}

# Fase 4: Gaming e sviluppo
phase_4() {
    log "Inizia Fase 4: Gaming e sviluppo"
    
    # Gaming e Performance
    pacman -S gamemode vulkan-intel vulkan-icd-loader intel-undervolt powertop cpupower --noconfirm
    
    # Software sviluppo
    pacman -S python python-pip nodejs npm docker docker-compose --noconfirm
    systemctl enable docker
    
    # Configurazione tastiera italiana
    localectl set-x11-keymap it
    
    # Configurazione Optimus Manager
    yay -S optimus-manager optimus-manager-qt --noconfirm
    systemctl enable optimus-manager.service
    
    # Configurazione optimus-manager
    cat > /etc/optimus-manager/optimus-manager.conf << EOF
[optimus]
startup_mode=hybrid
switching=none
EOF
    
    save_progress "5"
    log "Fine Fase 4, riavvio..."
    reboot
}

# Fase 5: Configurazioni avanzate
phase_5() {
    log "Inizia Fase 5: Configurazioni avanzate"
    
    # Configurazione sensori
    sensors-detect --auto
    
    # Configurazione intel-undervolt
    cat > /etc/intel-undervolt.conf << EOF
# Enable: Y
# CPU Undervolting
undervolt 0 'CPU' -100
undervolt 1 'GPU' -50
undervolt 2 'CPU Cache' -100
undervolt 3 'System Agent' -50
undervolt 4 'Analog I/O' -50
EOF
    
    systemctl enable intel-undervolt
    
    # Configurazione monitor
    mkdir -p /etc/X11/xorg.conf.d/
    cat > /etc/X11/xorg.conf.d/10-monitor.conf << EOF
Section "Monitor"
    Identifier "HDMI-0"
    Option "Primary" "true"
    Option "PreferredMode" "1920x1080_144.00"
EndSection
EOF
    
    # Configurazione thermald
    cat > /etc/thermald/thermal-conf.xml << EOF
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
EOF
    
    # Setup backup automatico
    cat > /etc/systemd/system/timeshift-autobackup.service << EOF
[Unit]
Description=Timeshift Auto Backup

[Service]
Type=oneshot
ExecStart=/usr/bin/timeshift --create --comments "Auto Backup" --tags D

[Install]
WantedBy=multi-user.target
EOF
    
    cat > /etc/systemd/system/timeshift-autobackup.timer << EOF
[Unit]
Description=Timeshift Auto Backup Timer

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF
    
    systemctl enable timeshift-autobackup.timer
    systemctl start timeshift-autobackup.timer
    
    save_progress "6"
    log "Fine Fase 5, riavvio..."
    reboot
}

# Fase 6: Software aggiuntivo e finalizzazione
phase_6() {
    log "Inizia Fase 6: Software aggiuntivo e finalizzazione"
    
    # Installazione Flatpak
    pacman -S flatpak --noconfirm
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    # Installazione software aggiuntivo
    pacman -S steam libreoffice-fresh discord --noconfirm
    yay -S --noconfirm anydesk whatsdesk-bin telegram-desktop-bin spotify visual-studio-code-bin
    
    # Backup finale
    timeshift --create --comments "Installazione completa"
    
    # Configurazione pacman
    sed -i 's/#Color/Color/' /etc/pacman.conf
    sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
    echo "ILoveCandy" >> /etc/pacman.conf
    
    # Abilitare multilib
    sed -i '/\[multilib\]/,+1 s/^#//' /etc/pacman.conf
    
    # Aggiornamento finale
    pacman -Syyu --noconfirm
    
    # Installazione ZSH e Oh My Zsh
    pacman -S zsh --noconfirm
    chsh -s $(which zsh)
    
    # Installazione Oh My Zsh per l'utente corrente
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Installazione tema e plugin
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
    
    # Plugin e font
    pacman -S zsh-syntax-highlighting ttf-meslo-nerd-font-powerlevel10k --noconfirm
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    
    # Configurazione plugin
    sed -i 's/plugins=(git)/plugins=(git docker docker-compose sudo zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
    
    log "Installazione completata!"
    
    # Pulizia
    rm -f /etc/rc.local
    rm -f "$PROGRESS_FILE"
    
    save_progress "7"
    log "Riavvio finale..."
    reboot
}

# Main
main() {
    # Verifica privilegi root
    if [ "$EUID" -ne 0 ]; then 
        echo "Questo script deve essere eseguito come root"
        exit 1
    }
    
    setup_autostart
    
    # Leggi fase corrente
    PHASE=$(read_progress)
    
    case $PHASE in
        "0"|"")
            phase_1
            ;;
        "2")
            phase_2
            ;;
        "3")
            phase_3
            ;;
        "4")
            phase_4
            ;;
        "5")
            phase_5
            ;;
        "6")
            phase_6
            ;;
        "7")
            log "Installazione completata con successo!"
            exit 0
            ;;
    esac
}

main
