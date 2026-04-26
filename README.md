+# Parking Finder 🅿️

Aplikasi crowdsourced untuk menemukan dan melaporkan ketersediaan parkir di sekitar lokasi pengguna.

## Screenshots

Aplikasi ini memiliki fitur:
- 🗺️ **Peta Interaktif** — Google Maps dengan marker parkiran berwarna
- 📝 **CRUD Parkiran** — Tambah, edit, hapus, dan update status parkiran
- ⭐ **Favorit** — Bookmark parkiran favorit
- 🔔 **Notifikasi** — Pengingat harian dan notifikasi kontribusi
- 👤 **Profil** — Kelola akun dan lihat kontribusi

## Tech Stack

- **Flutter** (latest stable)
- **Firebase Auth** (email & password)
- **Cloud Firestore** (database)
- **Firebase Storage** (upload foto)
- **Google Maps Flutter** (peta)
- **Geolocator** (GPS)
- **Flutter Local Notifications** (notifikasi)
- **Provider** (state management)

---

## 🔧 Setup Firebase

### 1. Buat Project Firebase

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik **"Add Project"** dan beri nama project
3. Ikuti wizard sampai project terbuat

### 2. Aktifkan Services

#### Authentication:
1. Di Firebase Console → **Authentication** → **Sign-in method**
2. Aktifkan **Email/Password**

#### Cloud Firestore:
1. Di Firebase Console → **Firestore Database** → **Create database**
2. Pilih **Start in test mode** (untuk development)
3. Pilih region terdekat (contoh: `asia-southeast2` untuk Jakarta)
4. **PENTING** — Set Firestore Rules agar app bisa read/write:
   - Buka tab **Rules** di Firestore
   - Paste rules berikut:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null;
       }
       match /parkings/{parkingId} {
         allow read: if true;
         allow create: if request.auth != null;
         allow update, delete: if request.auth != null;
       }
       match /favorites/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```
   - Klik **Publish**

#### Firebase Storage:
1. Di Firebase Console → **Storage** → **Get started**
2. Pilih **Start in test mode** (untuk development)
3. **PENTING** — Set Storage Rules:
   - Buka tab **Rules** di Storage
   - Paste rules berikut:
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
   - Klik **Publish**

### 3. Tambahkan Android App

1. Di Firebase Console → **Project settings** → **Add app** → **Android**
2. Masukkan package name: `com.parkingfinder.parking_finder`
3. Download file `google-services.json`
4. Letakkan file di: `android/app/google-services.json`

### 4. Generate Firebase Options (Alternatif)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Generate firebase_options.dart otomatis
flutterfire configure
```

### 5. Google Maps API Key

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. Aktifkan **Maps SDK for Android**
3. Buat API Key
4. Buka `android/app/src/main/AndroidManifest.xml`
5. Ganti `YOUR_GOOGLE_MAPS_API_KEY_HERE` dengan API key Anda

---

## 🏗️ Struktur Firestore

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
│   ├── constants/
│   │   └── app_colors.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── location_utils.dart
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
# 1. Install dependencies
flutter pub get

# 2. Pastikan google-services.json sudah ada di android/app/
# 3. Pastikan Google Maps API Key sudah di-set di AndroidManifest.xml

# 4. Jalankan aplikasi
flutter run
```

---

## 📋 AndroidManifest Permissions

Permission yang sudah dikonfigurasi:
- `INTERNET` — Akses internet
- `ACCESS_FINE_LOCATION` — GPS akurat
- `ACCESS_COARSE_LOCATION` — GPS kasar
- `CAMERA` — Akses kamera
- `READ_EXTERNAL_STORAGE` — Akses galeri
- `RECEIVE_BOOT_COMPLETED` — Notifikasi setelah reboot
- `VIBRATE` — Getaran notifikasi
- `SCHEDULE_EXACT_ALARM` — Penjadwalan notifikasi

---

## 🎨 Desain

- **Material 3** (`useMaterial3: true`)
- **Primary Color**: Biru tua `#1A237E`
- **Accent Color**: Kuning `#FFD600`
- **Font**: Poppins (via Google Fonts)
- **Cards**: Rounded corners 16px dengan shadow halus
- **Status Badge**: Hijau (kosong), Merah (penuh), Abu-abu (unknown)

---

## ⚠️ Catatan Penting

1. **Firebase Config**: Pastikan `google-services.json` sudah ditambahkan sebelum build
2. **Google Maps**: API key wajib diisi agar peta berfungsi
3. **Location**: Izinkan akses lokasi saat pertama kali dibuka
4. **minSdkVersion**: Project ini menggunakan `minSdk 21` (Android 5.0+)
