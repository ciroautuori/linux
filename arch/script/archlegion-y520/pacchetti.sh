# GRUPPO: base-devel
 Include i seguenti pacchetti essenziali per compilare software da sorgente:
 - autoconf: Strumento per generare script di configurazione.
 - automake: Strumento per creare makefile portabili.
 - binutils: Utility per la gestione di file binari (linker, assembler, ecc.)
 - bison: Generatore di parser per linguaggi.
 - fakeroot: Permette di simulare privilegi di root durante la creazione di pacchetti.
 - file: Identifica il tipo di file in base al contenuto.
 - findutils: Strumenti per cercare file (es. find)
 - flex: Generatore di scanner per linguaggi.
 - gawk: Implementazione avanzata del linguaggio di scripting awk.
 - gcc: Compilatore GNU per linguaggi come C e C++.
 - gettext: Utility per la gestione delle traduzioni nei software.
 - grep: Strumento per cercare testo in file.
 - groff: Formattatore di testo utilizzato principalmente per documentazione man.
 - gzip: Compressione e decompressione di file.
 - libtool: Gestione delle librerie condivise durante la compilazione.
 - m4: Preprocessore di macro utilizzato da autoconf.
 - make: Utility per automatizzare la compilazione dei programmi.
 - pacman: Gestore di pacchetti di Arch Linux.
 - patch: Applicazione di modifiche ai file sorgente.
 - pkgconf: Utility per gestire le dipendenze delle librerie durante la compilazione.
 - sed: Editor di testo basato su script.
 - tar: Strumento per creare e gestire archivi compressi.
 - texinfo: Strumenti per documentazione formattata.
 - util-linux: Raccolta di utility fondamentali per sistemi Linux (es. fdisk, mkfs)

# linux
 Kernel Linux ufficiale, necessario per il funzionamento del sistema operativo.

# linux-firmware
 Collezione di firmware per dispositivi hardware, inclusi:
 - Driver per schede Wi-Fi.
 - Firmware per GPU (NVIDIA, AMD, Intel)
 - Supporto per periferiche specializzate.

# linux-headers
 Include i file header necessari per compilare moduli kernel o driver hardware.

# git
 Sistema di controllo di versione distribuito:
 - git-core: Componenti principali di git.
 - git-man: Pagine di manuale per git.

# intel-ucode
 Pacchetto contenente microcode per processori Intel:
 - Aggiunge aggiornamenti di sicurezza e correzioni di bug a livello di CPU.

# os-prober
 Strumento per rilevare sistemi operativi installati:
 - Supporta Windows, Linux e altri OS compatibili con GRUB.

# efibootmgr
 Strumento per gestire voci di boot UEFI:
 - `efibootcreate`: Aggiunge nuove voci di avvio.
 - `efibootdelete`: Elimina vecchie voci di avvio.

# networkmanager
 Sistema di gestione rete, include:
 - nmcli: Interfaccia a riga di comando per gestire connessioni.
 - nmtui: Interfaccia testuale per configurare le connessioni.

# network-manager-applet
 Applet grafico per NetworkManager:
 - Utilizzabile su desktop environment come GNOME o XFCE.

# wireless_tools
 Collezione di strumenti CLI per gestire Wi-Fi:
 - iwconfig: Configura i parametri delle interfacce wireless.
 - iwlist: Mostra le reti wireless disponibili.

# dialog
 Crea interfacce a menu in terminale, utile per script e installer.

# mtools
 Utility per interagire con file system FAT:
 - mcopy: Copia file da/verso dispositivi FAT.
 - mdir: Elenca il contenuto di dischi FAT.

# dosfstools
 Utility per creare e riparare file system FAT:
 - mkfs.fat: Crea file system FAT12, FAT16 o FAT32.
 - fsck.fat: Controlla e ripara file system FAT.

# GRUB
 Bootloader principale:
 - grub: Installazione e gestione del bootloader.
 - grub-mkconfig: Genera il file di configurazione GRUB.

# Xorg e driver grafici
 - xorg: Server grafico principale per sistemi Linux.
 - xorg-server: Componente centrale del server Xorg.
 - xorg-xinit: Utility per inizializzare sessioni X.
 - mesa: Implementazione open-source delle API grafiche OpenGL/Vulkan.
 - nvidia: Driver proprietari NVIDIA per schede grafiche.
 - nvidia-prime: Strumenti per il supporto PRIME (multi-GPU NVIDIA/Intel)
 - nvidia-settings: Strumento per configurare opzioni avanzate NVIDIA
 - bbswitch: Gestione dell accensione/spegnimento GPU NVIDIA per risparmio energetico.

# XFCE4 e LightDM
 - xfce4: Desktop environment leggero e altamente personalizzabile.
 - xfce4-goodies: Plugin e strumenti aggiuntivi per XFCE4.
 - lightdm: Display manager leggero e versatile.
 - lightdm-gtk-greeter: Tema GTK per LightDM.

# Pacchetti multimediali e strumenti aggiuntivi
 - firefox: Browser web open-source.
 - pulseaudio: Server audio.
 - pavucontrol: Interfaccia grafica per gestire PulseAudio.
 - vlc: Lettore multimediale versatile.
 - wget: Strumento per scaricare file da terminale.
 - curl: Client per trasferimenti HTTP/FTP da terminale.

# Strumenti di archiviazione e file system
 - unzip: Estrazione di file ZIP.
 - zip: Creazione di file ZIP.
 - tar: Archiviazione e compressione di file.
 - gzip: Compressione dei file.
 - p7zip: Strumento per gestire archivi 7z.
 - ntfs-3g: Supporto per file system NTFS.
 - exfatprogs: Strumenti per file system exFAT.
 - btrfs-progs: Strumenti per file system Btrfs.
 - f2fs-tools: Strumenti per file system F2FS.

# Strumenti di sviluppo
 - nodejs: Runtime JavaScript per server.
 - npm: Gestore di pacchetti per Node.js.
 - python: Linguaggio di programmazione Python.
 - python-pip: Gestore di pacchetti per Python.

# Strumenti per sviluppo web e grafica
 - gimp: Editor di immagini avanzato.
 - audacity: Editor audio multitraccia.
 - obs-studio: Strumento per registrazione e streaming.

# Strumenti di rete
 - openvpn: Supporto per VPN.
 - networkmanager-openvpn: Integrazione OpenVPN con NetworkManager.
 - networkmanager-pptp: Supporto PPTP per NetworkManager.
 - networkmanager-l2tp: Supporto L2TP/IPsec per NetworkManager.

# Utility di sistema
 - htop: Monitor di sistema interattivo.
 - neofetch: Mostra informazioni di sistema in terminale.
 - nano: Editor di testo semplice.
 - vim: Editor di testo avanzato.
 - bash-completion: Completamento automatico per shell Bash.

# Supporto Bluetooth
 - bluez: Stack Bluetooth ufficiale per Linux.
 - bluez-utils: Utility per gestire dispositivi Bluetooth.
 - blueman: Interfaccia grafica per Bluetooth.

# Supporto per stampanti e scanner
 - cups: Server di stampa.
 - cups-pdf: Driver per stampare file PDF.
 - system-config-printer: Strumento grafico per configurare stampanti.
 - sane: Libreria per scanner.

# Gestione pacchetti AUR
 - yay: Helper per installare pacchetti dall'Arch User Repository (AUR).
