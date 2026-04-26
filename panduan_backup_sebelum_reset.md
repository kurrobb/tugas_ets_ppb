# 🛡️ Panduan Backup Sebelum Reset Laptop

> **Tanggal scan:** 20 April 2026  
> **Laptop:** LOQ  
> **Total data penting:** ~31 GB (estimasi)

---

## ⚠️ STATUS CLOUD SYNC

| Platform | Status | Detail |
|----------|--------|--------|
| **OneDrive** | ✅ Aktif | Documents (936 MB), Desktop (697 MB), Pictures (2.4 GB) — **SUDAH ter-sync** |
| **Google Drive** | ⚠️ Cek manual | Shortcut ada di Desktop, tapi tidak bisa verifikasi isi dari sini |
| **GitHub** | ⚠️ Hanya 1 repo | `sekolah-hebat-jakarta` → `github.com/kurrobb/sekolah_hebat_jakarta.git` |

> [!IMPORTANT]
> OneDrive sudah sync sebagian data, tapi **BANYAK folder penting TIDAK masuk OneDrive** (terutama `garapan` dan `sem_5/sem_6`). Harus backup manual!

---

## 🔴 PRIORITAS 1 — WAJIB BACKUP (Hilang = Tidak Bisa Diganti)

### 1. Tugas Kuliah Semester 5
```
📁 C:\Users\LOQ\Desktop\sem_5\
📊 Ukuran: 4.1 GB
```
| Subfolder | Isi |
|-----------|-----|
| `CP` | Competitive Programming |
| `KI` | Kecerdasan Intelektual / Knowledge |
| `PS` | Pemodelan & Simulasi |
| `grafkom` | Grafika Komputer |
| `kwn kel 7` | Tugas KWN |
| `pbkk` | Pemrograman Berbasis Kerangka Kerja |
| `rsbp` | RSBP |

---

### 2. Tugas Kuliah Semester 6
```
📁 C:\Users\LOQ\Desktop\sem_6\
📊 Ukuran: 4.0 GB
```
| Subfolder | Isi |
|-----------|-----|
| `ppb/tugas-ets` | **Tugas ETS PPB** (Parking Finder Flutter App) — yang sedang dikerjakan sekarang |
| `ppb/firebase_auth_pertemuan_6` | Firebase Auth Flutter |
| `ppb/pertemuan_5_crud` | CRUD Flutter |
| `ppb/tugas_2` | Tugas 2 PPB |
| `Tugas Agama Kelompok 4 2026.docx` | Tugas agama |

---

### 3. Folder Garapan (Proyek-Proyek)
```
📁 C:\Users\LOQ\Documents\garapan\
📊 Ukuran: 3.9 GB
```
| Subfolder | Isi | Git? |
|-----------|-----|------|
| `sekolah-hebat-jakarta/` | 🏫 Website sekolah Laravel — **SUDAH di GitHub** | ✅ |
| `trading/` | 🤖 AI Trading Bot (Python + Gemini) | ❌ **BELUM di Git!** |
| `capstone/` | 🎮 Flood simulation game + DEM SRTM data | ❌ **BELUM di Git!** |
| `TA/` | 📝 Tugas Akhir (Proposal, Blueeq, dll) | ❌ **BELUM di Git!** |
| `healthkathon/` | 🏥 DFU detection project | ❌ **BELUM di Git!** |
| `all_plan/` | Implementation plans | ❌ |
| `piyon/` | Java exercises | ❌ |
| `best.pt` | 🧠 **YOLOv8 trained model** (148 MB) — sangat penting! | — |
| `antigravity.zip` | Backup Antigravity sebelumnya (220 MB) | — |

> [!CAUTION]
> **`trading/`, `capstone/`, `TA/`, `healthkathon/`** — Ini proyek besar yang TIDAK ada backup di manapun! Prioritas tertinggi!

---

### 4. Dokumen Penting di Documents
```
📁 C:\Users\LOQ\Documents\
📊 File penting:
```
| File | Isi |
|------|-----|
| `Proposal TA kurob.docx/pdf` | 📝 **Proposal Tugas Akhir** |
| `Progres TA.pdf` | 📊 Progres TA |
| `Proposal Perempuan Madura(Mora) Nursyam.docx` | 📄 Proposal penelitian (59 MB!) |
| `Proposal Penelitian Identitas Perempuan Pesisir Madura*.docx` | 📄 Proposal versi lain |
| `final Madura.docx` | 📄 Final paper |
| `akademik.its.ac.id_rep_transkrip_sementara.php.pdf` | 📊 **Transkrip ITS** |
| `BABX_Nama_NIM[1].docx` | 📄 Bab TA |
| `ayah/` | 📁 Folder ayah (50 MB) |
| `GrafKom/` | 📁 Tugas Grafika Komputer |

---

### 5. SSH Keys & Git Config
```
📁 C:\Users\LOQ\.ssh\
📁 C:\Users\LOQ\.gitconfig
```
| File | Isi |
|------|-----|
| `.ssh/known_hosts` | SSH known hosts |
| `.gitconfig` | Git config: **kurrobb** / `k.syiful@gmail.com` |

> [!NOTE]
> Bisa diregenerate, tapi simpan agar tidak perlu setup ulang.

---

## 🟡 PRIORITAS 2 — PENTING (Bisa Didownload Ulang Tapi Repot)

### 6. Antigravity Chat History
```
📁 C:\Users\LOQ\.gemini\antigravity\
📊 Ukuran: 255 MB
```
Berisi semua 26 percakapan dengan AI. Sudah diexport ke `chat_export_antigravity.md`.

---

### 7. File Desktop Penting
```
📁 C:\Users\LOQ\Desktop\
```
| File | Isi |
|------|-----|
| `lampiran pkm.docx` | Lampiran PKM |
| `DeveloperGroupPolicy.json` | Dev config |

---

### 8. Downloads — Dokumen Penting
```
📁 C:\Users\LOQ\Downloads\
📊 Ukuran total: 18.8 GB (sebagian besar installer & video)
```

**Yang WAJIB backup dari Downloads:**

| File | Keterangan |
|------|-----------|
| `Proposal TA kurob*.pdf/docx` | Proposal TA |
| `Kelompok 7 KWN.pdf` | Tugas KWN (39 MB) |
| `5025231026_*.pdf/mp4` | File tugas dengan NIM |
| `Kasyiful kurob_*GRAMMAR*.docx` | Tugas Bahasa Inggris |
| `Jadwal Perkuliahan IF Genap 25-26.xlsx` | Jadwal kuliah |
| `Pendahuluan_Kasyiful Kurob_Kelompok 2.pdf` | Tugas kelompok |
| `Review Paper - 5025231026.pdf` | Review paper |
| `Kel 4_KPL_Tugas 2.*` | Tugas KPL |
| `Tugas Agama Kelompok 4 2026.docx` | Tugas agama |
| `Tugas Pemsim Final.xlsx` | Tugas Pemsim |
| `Proposal Penelitian*.pdf` | Proposal penelitian |
| `CV Kurob_2.docx`, `CV.pdf` | **CV kamu** |
| `Surat Pengantar.pdf` | Surat pengantar |
| `Transkrip_Mata_Kuliah.doc` | **Transkrip kuliah** |
| `Spesifikasi_Website_Sekolah_v2.docx` | Spek website |
| `labsuser.pem` | AWS Lab key |
| `15. DEM SRTM 30m Provinsi Jawa Timur.zip` | Data GIS (65 MB) |

**Yang BISA diabaikan dari Downloads (~15+ GB installer/game):**
- `*.exe` installer (Chrome, Steam, VSCode, dll) — download ulang
- `*.rar` anime (CotE, Akame, dll) — download ulang
- `Fufafilm_*.mp4` — film (573 MB)
- Game files (Broforce, Satisfactory saves, dll)

---

## 🟢 PRIORITAS 3 — OPSIONAL

### 9. OneDrive (Sudah Aman di Cloud)
```
📁 C:\Users\LOQ\OneDrive\
📊 Documents: 936 MB | Desktop: 697 MB | Pictures: 2.4 GB
```
✅ Sudah auto-sync — **tidak perlu backup manual** selama akun Microsoft aktif.

### 10. Game Saves (jika penting)
- `Thomz_*.sav` di Downloads (Satisfactory saves)
- `Phase 3 Iron Only*.sbp` (Satisfactory blueprint)

### 11. Android SDK/Emulator Config
```
📁 C:\Users\LOQ\.android\
```
Bisa di-setup ulang, tapi config bisa disimpan untuk mempercepat.

---

## 📋 CHECKLIST BACKUP

### Langkah 1: Siapkan Media (USB/Hard Disk/Google Drive)
Butuh minimal **~15 GB** ruang kosong untuk semua data penting.

### Langkah 2: Copy Folder Utama
```
☐ Desktop\sem_5\                    → 4.1 GB
☐ Desktop\sem_6\                    → 4.0 GB  
☐ Documents\garapan\                → 3.9 GB
☐ Documents\Proposal TA kurob.*     → 0.5 MB
☐ Documents\Progres TA.pdf          → 1.2 MB
☐ Documents\akademik*.pdf           → 0.3 MB (transkrip)
☐ Documents\Proposal Perempuan*     → 60 MB
☐ Documents\ayah\                   → 50 MB
☐ Documents\GrafKom\                → 23 MB
☐ .gemini\antigravity\              → 255 MB (opsional, chat history)
☐ .ssh\                             → < 1 MB
☐ .gitconfig                        → < 1 MB
```

### Langkah 3: Copy File Penting dari Downloads
```
☐ CV Kurob_2.docx + CV.pdf
☐ Transkrip_Mata_Kuliah.doc
☐ Surat Pengantar.pdf
☐ Jadwal Perkuliahan IF Genap 25-26.xlsx
☐ Semua file tugas (5025231026_*, Kel 4_KPL_*, dll)
☐ labsuser.pem (AWS key)
☐ DEM SRTM Jawa Timur.zip (jika capstone masih aktif)
```

### Langkah 4: Push Git Repos
```
☐ sekolah-hebat-jakarta → sudah di GitHub ✅
☐ trading/ → PUSH KE GITHUB BARU ⚠️
☐ capstone/ → PUSH KE GITHUB BARU ⚠️
☐ tugas-ets (Parking Finder) → PUSH KE GITHUB ⚠️
```

### Langkah 5: Verifikasi
```
☐ Cek Google Drive sudah sync
☐ Cek OneDrive sudah sync  
☐ Cek semua file terbuka & terbaca di media backup
☐ Catat semua password/akun yang tersimpan di browser
```

---

## 🔑 JANGAN LUPA

1. **Password browser** — Export dari Chrome/Edge (`chrome://settings/passwords`)
2. **Bookmarks browser** — Export dari Chrome/Edge
3. **VPN config** — `myitsvpn-5025231026@student.its.ac.id.ovpn`
4. **Extension VS Code** — Catat list extension yang terinstall
5. **Environment variables** — Catat PATH custom jika ada
6. **Firebase/API keys** — File `.env` di proyek-proyek
