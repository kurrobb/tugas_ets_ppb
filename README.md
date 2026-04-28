# Parking Finder 🅿️

Aplikasi mobile untuk menemukan dan melaporkan ketersediaan parkir di sekitar lokasi pengguna. Dibuat menggunakan Flutter dan Firebase sebagai tugas Mini Project.

## 📹 Demo Video

> **[Klik di sini untuk menonton demo video aplikasi](LINK_VIDEO_DEMO)**

---

## ✅ Pemenuhan Persyaratan Mini Project

| Persyaratan | Implementasi |
|-------------|-------------|
| **CRUD** | Tambah, lihat, edit, hapus, dan update status parkiran di Cloud Firestore |
| **Firebase Authentication** | Login dan Register menggunakan email & password |
| **Storing Data in Firebase** | Data parkiran & user disimpan di Cloud Firestore, foto parkiran di Firebase Storage |
| **Notifications** | Notifikasi lokal saat berhasil menambahkan parkiran baru |
| **Smartphone Resource** | GPS (lokasi pengguna & hitung jarak) dan Kamera (ambil foto parkiran) |

---

## 📱 Fitur Aplikasi

- **Peta Interaktif** — Menampilkan marker parkiran berwarna berdasarkan status (hijau = tersedia, merah = penuh, abu-abu = unknown)
- **Pencarian & Filter** — Cari parkiran berdasarkan nama/alamat dan filter berdasarkan status
- **CRUD Parkiran** — Tambah, edit, hapus parkiran dan update status (tersedia/penuh)
- **Map Picker** — Pilih lokasi parkiran dengan tap langsung di peta
- **Favorit/Bookmark** — Simpan parkiran favorit untuk akses cepat
- **Notifikasi** — Muncul saat berhasil menambahkan parkiran baru
- **Profil** — Lihat akun, kontribusi, dan logout
- **Autentikasi** — Login & register dengan email dan password

---

## 🛠️ Tech Stack

| Teknologi | Kegunaan |
|-----------|----------|
| Flutter | Framework UI |
| Firebase Auth | Autentikasi |
| Cloud Firestore | Database |
| Firebase Storage | Upload foto |
| flutter_map + OpenStreetMap | Peta interaktif |
| Geolocator | GPS & lokasi |
| Image Picker | Kamera & galeri |
| Flutter Local Notifications | Notifikasi lokal |

---

## 🔧 Setup

### 1. Setup Project

```bash
# Clone project
git clone <repository-url>
cd tugas-ets

# Install dependencies
flutter pub get

# Generate firebase_options.dart  
flutterfire configure
```

### 2. Setup Firebase

Di [Firebase Console](https://console.firebase.google.com/), siapkan:

**Authentication:**
- Aktifkan **Email/Password** di menu Authentication → Sign-in method

**Cloud Firestore:**
- Buat database baru
- Set Rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }
    match /parkings/{parkingId} {
      allow read: if true;
      allow create, update, delete: if request.auth != null;
    }
    match /favorites/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

**Firebase Storage:**
- Aktifkan Storage
- Set Rules:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /parkings/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 3. Struktur Firestore

```
users/{userId}
  - name: String
  - email: String
  - photoUrl: String

parkings/{parkingId}
  - name: String
  - address: String
  - lat: double
  - lng: double
  - type: String ('motor' | 'mobil' | 'both')
  - capacity: int
  - status: String ('kosong' | 'penuh' | 'unknown')
  - photoUrl: String
  - addedBy: String (userId)
  - updatedAt: Timestamp

favorites/{userId}
  - parkingIds: List<String>
```

---

## 📁 Struktur Folder

```
lib/
├── main.dart
├── firebase_options.dart
├── core/
│   ├── app_colors.dart
│   ├── app_theme.dart
│   └── location_utils.dart
├── data/
│   ├── models/
│   │   ├── parking_model.dart
│   │   └── user_model.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── parking_repository.dart
│       └── favorite_repository.dart
├── presentation/
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── parking_list_screen.dart
│   │   ├── parking_detail_screen.dart
│   │   ├── add_parking_screen.dart
│   │   ├── edit_parking_screen.dart
│   │   ├── map_picker_screen.dart
│   │   ├── favorites_screen.dart
│   │   └── profile_screen.dart
│   └── widgets/
│       ├── parking_card.dart
│       ├── status_badge.dart
│       └── custom_bottom_sheet.dart
└── services/
    ├── notification_service.dart
    └── storage_service.dart
```

---

## 🚀 Cara Menjalankan

```bash
# 1. Pastikan google-services.json sudah ada di android/app/

# 2. Install dependencies
flutter pub get

# 3. Jalankan aplikasi
flutter run
```

---

## 📌 Catatan

1. File `google-services.json` harus sudah ditaruh di `android/app/` sebelum build
2. Firestore Rules dan Storage Rules wajib di-set sesuai contoh di atas agar aplikasi bisa berjalan
3. Saat pertama kali dibuka, izinkan akses lokasi agar fitur peta dan jarak berfungsi
4. Jika Firebase Storage belum diaktifkan, parkiran tetap bisa disimpan tanpa foto
5. Minimum Android SDK: 21 (Android 5.0+)
