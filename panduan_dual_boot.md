# 🐧 Panduan Dual Boot: Windows + Linux

## Spesifikasi Laptop Anda

| Komponen | Detail |
|----------|--------|
| **Laptop** | Lenovo LOQ |
| **CPU** | Intel Core i5-13450HX (13th Gen) |
| **GPU** | NVIDIA GeForce RTX 3050 6GB + Intel UHD (Hybrid) |
| **RAM** | 20 GB |
| **Storage** | SK Hynix 512 GB NVMe SSD |
| **Free Space** | 53 GB tersisa |
| **Boot Mode** | UEFI + Secure Boot Enabled |
| **Partisi** | 1 partisi C: (475 GB) + Recovery (2 GB) |

> [!CAUTION]
> **Free space hanya 53 GB!** Ini sangat sempit untuk dual boot. Minimal Linux butuh 50 GB, idealnya 100 GB. Anda **HARUS** bersihkan disk atau beli SSD tambahan sebelum dual boot.

---

## 🤔 Distro Linux Mana yang Cocok?

### Perbandingan untuk Kasus Anda

| Kriteria | Ubuntu 24.04 LTS | Fedora 42 | Linux Mint 22 | Pop!_OS 24.04 |
|----------|:-:|:-:|:-:|:-:|
| **NVIDIA RTX 3050 support** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Beginner friendly** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Development tools** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Package freshness** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Community/Support** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Dual boot friendly** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Resource usage (RAM)** | ~1.5 GB | ~1.5 GB | ~1 GB | ~1.5 GB |
| **Mirip Windows** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Flutter/Android dev** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

### Detail Per Distro

#### 🟠 Ubuntu 24.04 LTS — "The Safe Choice"
- **Kelebihan:** Dokumentasi terbanyak, tutorial Flutter/Laravel paling banyak, setiap error pasti ada solusinya di StackOverflow
- **Kekurangan:** Snap packages (agak lambat), tampilan agak beda dari Windows
- **Desktop:** GNOME 46
- **Cocok jika:** Mau yang paling aman, tidak mau ribet troubleshooting

#### 🔵 Fedora 42 Workstation — "The Developer's Choice"
- **Kelebihan:** Package paling update, banyak dipakai Red Hat engineer, Wayland native (smooth)
- **Kekurangan:** NVIDIA driver sedikit lebih ribet install, komunitas Indonesia lebih kecil
- **Desktop:** GNOME 47
- **Cocok jika:** Mau cutting-edge, siap belajar lebih dalam

#### 🟢 Linux Mint 22 — "The Windows Refugee"
- **Kelebihan:** UI paling mirip Windows, ringan banget (~1 GB RAM), start menu familiar, no Snap
- **Kekurangan:** Sedikit lebih lambat dapat update, tampilan agak "jadul"
- **Desktop:** Cinnamon (kayak Windows 10)
- **Cocok jika:** Mau transisi sehalus mungkin dari Windows

#### 🔷 Pop!_OS 24.04 — "The NVIDIA King"
- **Kelebihan:** Installer khusus NVIDIA (driver langsung aktif), tiling window manager bawaan, dibuat oleh hardware company (System76)
- **Kekurangan:** Komunitas lebih kecil, kadang ada bug nirche
- **Desktop:** COSMIC / GNOME modified
- **Cocok jika:** Mau NVIDIA GPU langsung jalan tanpa ribet

---

## ⭐ REKOMENDASI FINAL

### 🟢 **Linux Mint 22 Cinnamon** — Untuk Anda yang Baru Pertama Kali

**Alasan:**
1. ✅ **UI mirip Windows** — Start menu, taskbar, system tray, file manager mirip banget
2. ✅ **Ringan** — Hanya pakai ~1 GB RAM (sisanya buat Android emulator & dev tools)
3. ✅ **NVIDIA support bagus** — Driver Manager bawaan (tinggal klik install)
4. ✅ **Berbasis Ubuntu** — Semua tutorial Ubuntu/Debian berlaku
5. ✅ **Tidak pakai Snap** — Lebih responsif
6. ✅ **Dual boot sangat mudah** — Installer auto-detect Windows

### 🟠 Alternatif: **Ubuntu 24.04 LTS** — Jika Mau "Standar Industri"
Pilih ini jika ingin yang paling banyak dokumentasinya dan tidak peduli UI agak beda.

---

## 📋 STEP-BY-STEP DUAL BOOT

### FASE 1: PERSIAPAN (Sebelum Install)

#### Step 1: Bersihkan Disk Windows
Anda hanya punya **53 GB free**. Perlu minimal **100 GB free**.

```
Yang bisa dihapus dari Downloads (~15 GB bisa dihemat):
□ Installer .exe yang sudah terinstall (Chrome, Steam, VSCode, dll)
□ Anime .rar yang sudah diekstrak
□ File .opdownload yang gagal download
□ Film Fufafilm_*.mp4 (573 MB)
□ Duplikat file (Pert_1.pptx ada 3 copy)
□ Game files Broforce .rar (455 MB) jika sudah diekstrak
```

Jalankan juga:
```
Settings → System → Storage → Temporary Files → hapus semua
Settings → System → Storage → Cleanup Recommendations
```

#### Step 2: Backup Data (WAJIB!)
Ikuti `panduan_backup_sebelum_reset.md` yang sudah dibuat sebelumnya.

#### Step 3: Download ISO Linux Mint
- Buka: https://linuxmint.com/download.php
- Pilih **"Cinnamon Edition"** (64-bit)
- Ukuran: ~2.8 GB

#### Step 4: Buat Bootable USB
Butuh: **USB flashdisk minimal 4 GB** (isinya akan terhapus)

1. Download **Rufus**: https://rufus.ie
2. Buka Rufus
3. Pilih USB drive Anda
4. Klik **SELECT** → pilih file ISO Linux Mint
5. Partition scheme: **GPT** (karena laptop Anda UEFI)
6. Target system: **UEFI (non CSM)**
7. Klik **START** → tunggu selesai

#### Step 5: Shrink Partisi Windows
Buka **Disk Management** di Windows:

```
1. Klik kanan Start → Disk Management
2. Klik kanan partisi C: (474.7 GB)
3. Pilih "Shrink Volume"
4. Masukkan jumlah yang mau di-shrink:
   - Minimum: 51200 MB (50 GB) — sangat sempit
   - Rekomendasi: 102400 MB (100 GB) — ideal
   - Sweet spot: 76800 MB (75 GB)
5. Klik "Shrink"
6. Akan muncul "Unallocated Space" — JANGAN diformat, biarkan!
```

> [!WARNING]
> Jika Shrink gagal atau hanya bisa sedikit, jalankan **Defragment** dulu:
> `Settings → System → Storage → Optimize Drives → Optimize C:`

---

### FASE 2: BIOS SETUP

#### Step 6: Masuk BIOS Lenovo LOQ
```
1. Restart laptop
2. Tekan F2 berulang-ulang saat logo Lenovo muncul
   (atau: Novo Button kecil di samping kiri laptop)
3. Masuk ke BIOS Setup
```

#### Step 7: Ubah Pengaturan BIOS

| Setting | Ubah ke | Lokasi di BIOS |
|---------|---------|----------------|
| **Secure Boot** | **Disabled** | Security → Secure Boot |
| **Boot Mode** | Biarkan **UEFI** | Boot → Boot Mode |
| **Fast Boot** | **Disabled** (opsional) | Boot → Fast Boot |

```
Tekan F10 → Save & Exit
```

> [!IMPORTANT]
> Secure Boot HARUS di-disable agar Linux bisa boot. Bisa di-enable kembali nanti jika pakai distro yang support (Ubuntu/Mint sudah support signed boot).

---

### FASE 3: INSTALASI LINUX

#### Step 8: Boot dari USB
```
1. Colok USB bootable
2. Restart laptop
3. Tekan F12 berulang saat logo Lenovo (Boot Menu)
4. Pilih USB drive Anda (UEFI mode)
5. Linux Mint akan boot ke Live Desktop
```

#### Step 9: Test Dulu (Live Mode)
Sebelum install, cek semuanya berjalan:
```
□ WiFi bisa connect?
□ Layar tampil normal? (tidak stretched/blank)
□ Touchpad berfungsi?
□ Keyboard normal?
□ Sound ada?
```

Jika semua OK → lanjut install. Jika ada masalah (terutama display), kemungkinan perlu boot option tambahan: `nomodeset`.

#### Step 10: Install Linux Mint
```
1. Double-click "Install Linux Mint" di desktop
2. Pilih bahasa: English (atau Indonesian)
3. Keyboard layout: English (US)
4. Connect WiFi (jika belum)
5. Centang ☑ "Install multimedia codecs"
```

#### Step 11: Partisi (PALING PENTING!)

Pilih: **"Something else"** (Manual partitioning)

Cari **free space / unallocated** yang tadi dibuat dari Windows (75-100 GB).

Buat partisi berikut dari free space:

| Partisi | Ukuran | Type | Mount Point | Keterangan |
|---------|--------|------|-------------|------------|
| **EFI** | JANGAN buat baru | — | — | Gunakan EFI yang sudah ada dari Windows! |
| **swap** | 4 GB | linux-swap | — | Virtual RAM (setengah RAM cukup) |
| **/** (root) | 30 GB | ext4 | `/` | Sistem operasi Linux |
| **/home** | Sisanya (~41-66 GB) | ext4 | `/home` | Data pribadi Anda |

> [!CAUTION]
> **JANGAN FORMAT partisi Windows (NTFS)!** Hanya gunakan "free space" yang unallocated.
> 
> **Bootloader:** Pilih install bootloader di disk utama (`/dev/sda` atau `/dev/nvme0n1`) — BUKAN di partisi.

#### Step 12: Selesaikan Instalasi
```
1. Set timezone: Asia/Jakarta (WIB)
2. Buat user:
   - Name: (nama Anda)
   - Computer name: loq-mint
   - Username: kurob (atau sesuai keinginan)
   - Password: (buat password)
3. Tunggu instalasi selesai (~10-15 menit)
4. Restart → cabut USB saat diminta
```

---

### FASE 4: FIRST BOOT & SETUP

#### Step 13: GRUB Boot Menu
Setelah restart, akan muncul menu **GRUB**:
```
┌────────────────────────────┐
│  Linux Mint 22             │  ← Default
│  Advanced options          │
│  Windows Boot Manager      │  ← Pilih ini untuk masuk Windows
│  UEFI Firmware Settings    │
└────────────────────────────┘
```

Anda bisa pilih OS mana yang mau diboot setiap kali nyala.

#### Step 14: Install NVIDIA Driver
Setelah masuk Linux Mint:
```
1. Buka "Driver Manager" (dari Start Menu)
2. Akan terdeteksi: nvidia-driver-xxx (recommended)
3. Pilih driver recommended → Apply
4. Restart
```

Verifikasi:
```bash
nvidia-smi
```
Harus muncul info RTX 3050 Anda.

#### Step 15: Update Sistem
```bash
sudo apt update && sudo apt upgrade -y
```

---

### FASE 5: SETUP DEVELOPMENT ENVIRONMENT

#### A. Essential Tools
```bash
# Git
sudo apt install git curl wget build-essential -y
git config --global user.name "kurrobb"
git config --global user.email "k.syiful@gmail.com"

# VS Code
sudo snap install code --classic
# ATAU (tanpa snap, untuk Mint):
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update && sudo apt install code -y
```

#### B. Flutter & Android Development
```bash
# Install Flutter via snap (easiest)
sudo snap install flutter --classic
flutter doctor

# Install Android Studio
sudo snap install android-studio --classic

# Accept Android licenses
flutter doctor --android-licenses

# Chrome for web dev
sudo apt install chromium-browser -y
```

#### C. PHP & Laravel
```bash
# PHP + extensions
sudo apt install php php-cli php-mbstring php-xml php-curl php-zip php-mysql php-gd unzip -y

# Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Node.js (via nvm - RECOMMENDED)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts

# Verify
node --version
npm --version
php --version
composer --version
```

#### D. Python & AI Tools
```bash
# Python (biasanya sudah terinstall)
python3 --version

# pip
sudo apt install python3-pip python3-venv -y

# Virtual environment (per project)
python3 -m venv myenv
source myenv/bin/activate
```

#### E. Database
```bash
# MySQL
sudo apt install mysql-server -y
sudo mysql_secure_installation

# ATAU SQLite (lebih ringan, untuk dev)
sudo apt install sqlite3 -y
```

#### F. Docker (Opsional tapi recommended)
```bash
sudo apt install docker.io docker-compose -y
sudo usermod -aG docker $USER
# Logout & login kembali
```

---

## 🔧 TIPS DUAL BOOT

### Akses File Windows dari Linux
```bash
# Windows partition auto-mount di /media/
ls /media/$USER/
# Anda bisa baca/tulis file Windows dari Linux!
```

### Ubah Default Boot OS
```bash
# Edit GRUB config
sudo nano /etc/default/grub

# Ubah baris ini:
GRUB_DEFAULT=0          # 0 = Linux (default), 2 = Windows (biasanya urutan ke-3)
GRUB_TIMEOUT=10         # Waktu tunggu di boot menu (detik)

# Apply
sudo update-grub
```

### Sinkronisasi Waktu (Fix jam yang berubah-ubah)
```bash
# Linux dan Windows beda cara baca hardware clock
# Fix dari Linux:
timedatectl set-local-rtc 1
```

### Jika Windows Tidak Muncul di GRUB
```bash
sudo os-prober
sudo update-grub
```

---

## ⚠️ OPSI ALTERNATIF: Beli SSD Tambahan

Karena SSD Anda hanya **512 GB** dan sudah penuh, opsi terbaik sebenarnya:

| Opsi | Harga (est.) | Kelebihan |
|------|-------------|-----------|
| **SSD NVMe M.2 256 GB** | Rp 300-400rb | Linux terpisah, aman, tidak ganggu Windows |
| **SSD NVMe M.2 512 GB** | Rp 500-700rb | Lebih lega |
| **SSD NVMe M.2 1 TB** | Rp 800rb-1.2jt | Paling ideal |

Lenovo LOQ biasanya punya **2 slot M.2** — cek manual laptop Anda. Jika ada slot kosong, **beli SSD tambahan** dan install Linux di SSD terpisah. Ini cara **paling aman** karena kedua OS 100% terpisah.

---

## 📊 Ringkasan Keputusan

| Keputusan | Rekomendasi |
|-----------|-------------|
| **Distro** | 🟢 Linux Mint 22 Cinnamon |
| **Ukuran partisi Linux** | 75-100 GB |
| **SSD tambahan?** | Sangat disarankan (Rp 300rb+) |
| **Dual boot vs WSL?** | Dual boot (performa native, NVIDIA full) |

> [!TIP]
> **Alternatif tanpa dual boot:** Jika hanya butuh terminal Linux untuk development, coba **WSL2** (Windows Subsystem for Linux) dulu — sudah built-in di Windows 11, tidak perlu partisi, bisa jalankan `apt`, `git`, `node`, `php` dll. Tapi tidak bisa pakai GPU NVIDIA secara penuh dan tidak ada GUI native.
