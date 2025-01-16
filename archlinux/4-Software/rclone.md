### Guida Completa per Configurare `rclone` con Google Drive e Montarlo su Arch Linux

#### 1. **Installare `rclone`**
Per prima cosa, assicurati che `rclone` sia installato sul tuo sistema. Se non lo è, puoi farlo con il comando:

```bash
sudo pacman -S rclone
```

#### 2. **Configurazione del Remote (Google Drive)**

Per configurare un account Google Drive, segui questi passaggi:

1. Esegui il comando di configurazione di `rclone`:

   ```bash
   rclone config
   ```

2. Ti verrà chiesto di creare una nuova configurazione. Digita `n` per **nuovo remote**.

3. Assegna un nome al tuo remote, ad esempio `SOLISO`. Digita `SOLISO` e premi **Enter**.

4. Ti verrà chiesto di selezionare il tipo di storage. Seleziona **Google Drive**. Digita il numero corrispondente a **Google Drive** e premi **Enter**.

5. Ti verranno chieste una serie di informazioni. Per la maggior parte delle configurazioni predefinite, puoi semplicemente premere **Enter** per accettarle. Le principali opzioni sono:

   - **Client ID**: Puoi lasciare vuoto se non hai un client ID personalizzato.
   - **Client Secret**: Lascia anche questo vuoto per usare i valori di default.
   - **Scope**: Seleziona il tipo di accesso desiderato, ad esempio "full access" (`drive`).
   - **Root Folder ID**: Puoi lasciare vuoto a meno che tu non abbia una cartella specifica in Google Drive che vuoi usare come root.
   - **Service Account**: Lascia vuoto, a meno che tu non stia usando un account di servizio.
   - **Autenticazione**: Ti verrà chiesto di autorizzare `rclone` ad accedere al tuo Google Drive. Digita `y` per continuare.

6. Una volta completata la configurazione, `rclone` ti fornirà un URL. Aprilo nel tuo browser, concedi l'accesso a `rclone` e copia il codice di autorizzazione che ti viene mostrato.

7. Torna nel terminale e incolla il codice di autorizzazione quando richiesto.

8. Alla fine, ti verrà chiesto se vuoi testare la configurazione. Puoi digitare `y` per verificare che il remote sia configurato correttamente.

### 3. **Verifica della Configurazione**

Per verificare che la configurazione sia andata a buon fine, puoi eseguire il seguente comando per vedere il contenuto del tuo Google Drive:

```bash
rclone ls SOLISO:
```

Se tutto è configurato correttamente, vedrai i file e le cartelle presenti nel tuo Google Drive.

#### 4. **Esegui il Comando di Montaggio**
Una volta che il remote `SOLISO` è configurato, puoi montarlo direttamente con il seguente comando:

```bash
rclone mount SOLISO: ~/Desktop/Project/Soliso/
```

Questo comando monterà il tuo Google Drive nella cartella `~/Desktop/Project/Soliso/`.

#### 5. **Creare uno Script per Montare il Remote**
Per semplificare l'esecuzione del comando di montaggio, puoi creare uno script:

1. Crea un file di script, ad esempio `mount_soliso.sh`:

   ```bash
   nano ~/mount_soliso.sh
   ```

2. Aggiungi il seguente contenuto al file:

   ```bash
   #!/bin/bash
   rclone mount SOLISO: ~/Desktop/Project/Soliso/ --vfs-cache-mode writes
   ```

   L'opzione `--vfs-cache-mode writes` è utile per migliorare la gestione dei file montati.

3. Rendi eseguibile lo script:

   ```bash
   chmod +x ~/mount_soliso.sh
   ```

4. Ora puoi eseguire lo script con:

   ```bash
   ~/mount_soliso.sh
   ```

#### 6. **Esegui il Montaggio come Servizio (Opzionale)**
Se desideri montare automaticamente il remote all'avvio del sistema, puoi configurare un'unità `systemd`.

##### a) Crea un File di Unità `systemd`

1. Crea un file di unità per il servizio:

   ```bash
   sudo nano /etc/systemd/system/rclone-mount.service
   ```

2. Aggiungi il seguente contenuto:

   ```ini
   [Unit]
   Description=Rclone Mount SOLISO
   After=network-online.target

   [Service]
   Type=simple
   User=YOUR_USERNAME
   ExecStart=/usr/bin/rclone mount SOLISO: /home/YOUR_USERNAME/Desktop/Project/Soliso/ --vfs-cache-mode writes
   ExecStop=/bin/fusermount -u /home/YOUR_USERNAME/Desktop/Project/Soliso/
   Restart=on-failure
   RestartSec=30

   [Install]
   WantedBy=multi-user.target
   ```

   **Nota**: Sostituisci `YOUR_USERNAME` con il tuo nome utente.

##### b) Abilita e Avvia il Servizio

1. Ricarica `systemd` per leggere la nuova configurazione del servizio:

   ```bash
   sudo systemctl daemon-reload
   ```

2. Abilita il servizio per avviarlo automaticamente all'avvio:

   ```bash
   sudo systemctl enable rclone-mount.service
   ```

3. Avvia il servizio:

   ```bash
   sudo systemctl start rclone-mount.service
   ```

Ora, il remote `SOLISO` sarà montato automaticamente all'avvio del sistema.

---

### Riepilogo dei Comandi

1. **Installare `rclone`**:
    ```bash
    sudo pacman -S rclone
    ```

2. **Configurare il remote Google Drive**:
    ```bash
    rclone config
    ```

3. **Verifica del Remote**:
    ```bash
    rclone ls SOLISO:
    ```

4. **Creare lo script di montaggio** (opzionale):
    ```bash
    nano ~/mount_soliso.sh
    chmod +x ~/mount_soliso.sh
    ~/mount_soliso.sh
    ```

5. **Creare e abilitare il servizio `systemd`**:
    ```bash
    sudo nano /etc/systemd/system/rclone-mount.service
    sudo systemctl daemon-reload
    sudo systemctl enable rclone-mount.service
    sudo systemctl start rclone-mount.service
    ```