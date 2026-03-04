# Syathiby App

Aplikasi absensi dan manajemen staff untuk Ma'had Tahfizh al-Qur'an al-Imam as-Syathiby.

Enhanced and customized version of Syathiby Vendor App [https://github.com/creatorb/flutter-syathiby-vendor](https://github.com/creatorb/flutter-syathiby-vendor)

> 📋 **Changelog**: Lihat [CHANGELOG.md](CHANGELOG.md) untuk riwayat update lengkap

---

## 📑 Table of Contents

- [Quick Start](#-quick-start)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Setup URL Environment](#-setup-url-environment-local--production)
- [Development](#-development)
- [Building & Deployment](#-building--deployment)
- [Features](#-features)
- [Environment Indicators](#-environment-indicators)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)

---

## 🚀 Quick Start

```bash
# 1. Clone repository
git clone https://github.com/creatorb/flutter_syathiby.git
cd flutter_syathiby

# 2. Install dependencies
fvm flutter pub get

# 3. Generate code
fvm flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run app (PROD flavor - otomatis pakai URL production)
fvm flutter run --flavor prod --dart-define=FLAVOR=prod

# 5. Run app (LOCAL flavor - otomatis pakai URL local)
fvm flutter run --flavor local --dart-define=FLAVOR=local
```

---

## 📋 Prerequisites

- **Flutter SDK**: Managed via [FVM](https://fvm.app/)
- **Android Studio** / **Xcode** (untuk build Android/iOS)
- **ADB** (Android Debug Bridge) untuk deployment ke device
- **Git**

### Install FVM (Flutter Version Manager)

```bash
# Windows (PowerShell)
choco install fvm

# macOS
brew tap leoafarias/fvm
brew install fvm

# Linux / Manual
dart pub global activate fvm
```

---

## 🔧 Installation

### 1. Setup FVM dan Flutter SDK

```bash
# Install Flutter version yang digunakan project
fvm install

# Use Flutter version dari FVM
fvm use
```

### 2. Install Dependencies

```bash
fvm flutter pub get
```

### 3. Generate Model & URL Environment

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. (Optional) Setup Keystore untuk Release Build

Lihat section [Keystore](#-keystore) di bawah.

---

## 🌐 Setup URL Environment (Flavor-Based Configuration)

Aplikasi menggunakan **konfigurasi otomatis berbasis flavor**. URL backend dipilih secara otomatis sesuai flavor yang dijalankan:

### Konfigurasi Default (Built-in)

| Flavor | API URL | Link Base | App Name |
|--------|---------|-----------|----------|
| **prod** | `https://aplikasi.syathiby.id/geten/` | `https://aplikasi.syathiby.id` | Syathiby |
| **local** | `http://192.168.50.100/aplikasi/geten/` | `http://192.168.50.100/aplikasi` | Syathiby LOCAL |

### ⚡ Cara Menggunakan

**Untuk Production:**
```bash
fvm flutter run --flavor prod --dart-define=FLAVOR=prod
```
✅ Otomatis menggunakan URL: `https://aplikasi.syathiby.id`

**Untuk Local Development:**
```bash
fvm flutter run --flavor local --dart-define=FLAVOR=local
```
✅ Otomatis menggunakan URL: `http://192.168.50.100/aplikasi`

> **Catatan:** `--dart-define=FLAVOR=xxx` memberitahu aplikasi flavor mana yang sedang berjalan, sehingga URL otomatis dipilih sesuai konfigurasi.

### 🔧 Mengubah URL Default

Jika IP server lokal Anda **bukan** `192.168.50.100`, edit file:

📄 **`lib/res/flavor_config.dart`**

```dart
static const Map<String, Map<String, String>> _configs = {
  'prod': {
    'API_URL': 'https://aplikasi.syathiby.id/geten/',
    'LINK_BASE': 'https://aplikasi.syathiby.id',
  },
  'local': {
    'API_URL': 'http://192.168.1.100/aplikasi/geten/',  // ← Ubah IP di sini
    'LINK_BASE': 'http://192.168.1.100/aplikasi',       // ← dan di sini
  },
};
```

Setelah edit, rebuild:
```bash
fvm flutter clean
fvm flutter pub get
fvm flutter run --flavor local --dart-define=FLAVOR=local
```

### 🎛️ Override URL via Aplikasi (Runtime)

Anda tetap bisa **override URL sementara** tanpa rebuild:

**Step 1:** Jalankan aplikasi (flavor apa saja)

**Step 2:** Di halaman Login, **long-press logo Syathiby**

**Step 3:** Dialog muncul dengan URL aktif

**Step 4:** Masukkan URL custom:
```
API URL: http://192.168.1.200/aplikasi/geten/
Link Base: http://192.168.1.200/aplikasi
```

**Step 5:** Tekan **"Simpan & Restart"**

> Override ini **tersimpan di SharedPreferences** dan akan terus dipakai sampai di-reset.

### 🔄 Reset ke Default Flavor

**Via Aplikasi:**
1. Long-press logo di halaman Login
2. **Kosongkan semua field**
3. Tekan "Simpan & Restart"

Aplikasi akan kembali pakai URL default sesuai flavor.

### 💡 Tips Development

**Check IP Komputer Server:**

Windows:
```bash
ipconfig
```

macOS/Linux:
```bash
ifconfig
# atau
ip addr show
```

Cari IP yang dimulai dengan `192.168.x.x` atau `10.x.x.x`

**Environment Detection:**

Aplikasi otomatis detect environment berdasarkan URL aktif:
- IP lokal (`192.168.x.x`, `10.x.x.x`, `172.16-31.x.x`, `localhost`) → **LOCAL** (banner merah)
- Domain publik lainnya → **PROD** (banner hijau)

### 📁 File Structure

```
flutter_syathiby/
└── lib/res/
    ├── flavor_config.dart          # ← Konfigurasi URL per flavor
    ├── environment_config.dart     # Runtime config + override
    └── env.dart                    # Legacy (optional, untuk MAPS_API_KEY)
```

### 🐛 Troubleshooting

**Issue: URL masih salah setelah ganti flavor**

```bash
# Pastikan pakai --dart-define=FLAVOR
fvm flutter run --flavor local --dart-define=FLAVOR=local
# ⚠️ BUKAN: fvm flutter run --flavor local  (tanpa --dart-define)
```

**Issue: Cannot connect to local server**

1. ✅ Check backend server running
2. ✅ Device & server dalam satu network (WiFi sama)
3. ✅ Test URL di browser: `http://192.168.x.x/aplikasi/geten/`
4. ✅ Check firewall tidak block
5. ✅ Jangan pakai `localhost`, pakai IP address

**Issue: Environment label tetap PROD**

- Long-press logo untuk verify URL yang sebenarnya dipakai
- Pastikan format URL benar: `http://` (bukan `https://`) untuk lokal
- Check IP sesuai pattern: `192.168.x.x`

---

## 💻 Development

### Run App (Development Mode)

```bash
# PROD flavor (otomatis pakai https://aplikasi.syathiby.id)
fvm flutter run --flavor prod --dart-define=FLAVOR=prod

# LOCAL flavor (otomatis pakai http://192.168.50.100/aplikasi)
fvm flutter run --flavor local --dart-define=FLAVOR=local

# Specify device
fvm flutter run -d <device-id> --flavor prod --dart-define=FLAVOR=prod
fvm flutter run -d 127.0.0.1:5555 --flavor local --dart-define=FLAVOR=local
```

### Hot Reload & Restart

- **Hot Reload**: `r` (di terminal saat app running)
- **Hot Restart**: `R`
- **Quit**: `q`

### Code Generation

Setiap kali mengubah model atau environment config:

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

Watch mode (auto-generate saat file berubah):

```bash
fvm flutter pub run build_runner watch --delete-conflicting-outputs
```

### Clean Build

Jika ada masalah dengan cache atau dependency:

```bash
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🔨 Building & Deployment

### Android APK (Debug)

```bash
# PROD flavor
fvm flutter build apk --debug --flavor prod --dart-define=FLAVOR=prod

# LOCAL flavor
fvm flutter build apk --debug --flavor local --dart-define=FLAVOR=local
```

Output: `build/app/outputs/flutter-apk/`

### Android APK (Release)

```bash
# PROD flavor
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter build apk --release --flavor prod --dart-define=FLAVOR=prod

# LOCAL flavor
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter build apk --release --flavor local --dart-define=FLAVOR=local
```

### Android App Bundle (AAB) - untuk Play Store

```bash
# PROD
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter build appbundle --release --flavor prod --dart-define=FLAVOR=prod

# LOCAL
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter build appbundle --release --flavor local --dart-define=FLAVOR=local
```

Output: `build/app/outputs/bundle/`

### Install Kedua APK Sekaligus (Side-by-Side)

Gunakan skrip PowerShell untuk install PROD dan LOCAL secara otomatis:

```powershell
.\install-both-apks.ps1
```

**Prasyarat:**
- Device Android terhubung via USB/WiFi
- ADB terinstall dan tersedia di PATH
- Kedua APK sudah di-build (lihat section di atas)

**Skrip akan:**
1. Validasi ketersediaan ADB
2. Cek koneksi device
3. Install `app-local-debug.apk` → `id.syathiby.app.local`
4. Install `app-prod-debug.apk` → `id.syathiby.app`
5. Tampilkan status dengan warna (hijau = sukses, merah = gagal)

### Web Build

```bash
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter build web --release --tree-shake-icons
```

Output: `build/web/`

**Setup .htaccess untuk deploy web:**

```apache
RewriteEngine On
# Jika file atau folder yang diminta tidak ada secara fisik
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
# Arahkan semua request ke index.html
RewriteRule ^ index.html [L]
```

**Run web locally:**

```bash
fvm flutter run -d chrome --web-hostname 192.168.50.100 --web-port 8082
```

---

## ✨ Features

### Attendance System

Aplikasi mendukung 2 metode absensi:

1. **Location (GPS)**: Validasi berdasarkan koordinat GPS dan radius lokasi
2. **Wi-Fi**: Validasi berdasarkan public IP (103.178.146.98)

**Detail teknis:**
- User memilih metode saat klik tombol absen
- Mode Wi-Fi mengirim koordinat `(0,0)` sebagai penanda
- Pre-validation di Flutter sebelum submit
- Final validation di backend PHP
- Error code `03` untuk error validasi Wi-Fi

**Lihat [CHANGELOG.md](CHANGELOG.md) untuk detail lengkap update terbaru.**

---

## 🎨 Environment Indicators

Aplikasi memiliki indikator visual untuk membedakan environment:

### Global Banner (Ribbon) - LOCAL Only

- **LOCAL**: **Red ribbon** dengan tulisan "LOCAL" (untuk development)
- **PROD**: **No banner** - clean UI (untuk production)

> Production builds memiliki UI yang lebih clean tanpa banner, lebih profesional untuk public users.

### Dynamic App Name
- Environment lokal: "Syathiby LOCAL"
- Environment prod: "Syathiby"

### Login Screen Badge
- Menampilkan ENV label dan API URL aktif
- Warna merah untuk LOCAL, hijau untuk PROD
- **Long-press logo** untuk mengubah API URL (override runtime)

### Android Flavors

**Flavor PROD:**
- Application ID: `id.syathiby.app`
- App Label: `Syathiby`
- Banner: ❌ Tidak ada (clean UI)

**Flavor LOCAL:**
- Application ID: `id.syathiby.app.local`
- App Label: `Syathiby LOCAL`
- Banner: 🔴 Ada (red ribbon untuk development indicator)

Kedua flavor bisa diinstall bersamaan di device yang sama.

---

## 🧪 Testing

### Manual Testing

Panduan testing untuk fitur Wi-Fi attendance tersedia di:

📄 **[ATTENDANCE_WIFI_TEST_CHECKLIST.md](ATTENDANCE_WIFI_TEST_CHECKLIST.md)**

### Run Flutter Analyzer

```bash
fvm flutter analyze
```

### Run Tests (jika ada)

```bash
fvm flutter test
```

---

## 🛠️ Troubleshooting

### Build Runner Issues

**Error: Conflicting outputs**

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### Gradle Issues (Android)

**Clear Gradle cache:**

```bash
# Windows
Remove-Item -Recurse -Force $env:USERPROFILE\.gradle\caches

# macOS/Linux
rm -rf ~/.gradle/caches
```

**Kemudian rebuild:**

```bash
fvm flutter clean
fvm flutter pub get
```

### ADB Device Not Found

```bash
# Check connected devices
adb devices

# Restart ADB server
adb kill-server
adb start-server

# Connect via WiFi (after USB pairing)
adb tcpip 5555
adb connect <device-ip>:5555
```

### FVM Not Found

Pastikan FVM sudah ditambahkan ke PATH:

```bash
# Check FVM installation
fvm --version

# Install FVM jika belum
dart pub global activate fvm

# Add to PATH (example for Windows)
# Add: %USERPROFILE%\AppData\Local\Pub\Cache\bin
```

---

## 🔐 Keystore

## 🔐 Keystore

### Debug Keystore

Generate debug keystore untuk development:

```bash
keytool -genkeypair -v `
  -keystore debug.keystore `
  -alias androiddebugkey `
  -keyalg RSA -keysize 2048 `
  -validity 10000 `
  -storetype pkcs12 `
  -storepass android `
  -keypass android `
  -dname "CN=https://github.com/CreatorB, O=Freelance Fullstack Developer, C=ID"
```

### Release Keystore

Untuk production build, gunakan keystore yang aman. Simpan di lokasi yang aman dan **jangan commit ke git**.

---

## 🛠️ Advanced Configuration

### Rename App and Package Name

```bash
dart run flutter_application_id:main -f flutter_application_id.yaml
```

### Change App Icon

```bash
# Setup
dart run flutter_launcher_icons:generate --override

# Generate
dart run flutter_launcher_icons
```

### Change Splash Screen

```bash
dart run flutter_native_splash:create
```

---

## 📦 Project Structure

```
flutter_syathiby/
├── android/                 # Android native code
├── ios/                     # iOS native code  
├── lib/
│   ├── app.dart            # Root MaterialApp with environment banner
│   ├── data/               # Models, repositories
│   ├── presentation/       # UI screens & widgets
│   │   ├── login/          # Login screen with ENV display
│   │   └── presence/       # Attendance screen with Wi-Fi option
│   ├── res/
│   │   ├── environment_config.dart  # Environment detection
│   │   └── strings.dart    # App constants, dynamic app name
│   └── utils/              # Helpers, utilities
├── test/                   # Unit & widget tests
├── build/                  # Build outputs (gitignored)
├── CHANGELOG.md           # Version history (tampilkan di webview)
├── ATTENDANCE_WIFI_TEST_CHECKLIST.md  # Testing guide
├── install-both-apks.ps1  # Dual APK installer script
├── pubspec.yaml           # Dependencies
└── README.md              # This file
```

---

## 🤝 Contributing

Untuk kontribusi:

1. Create branch baru dari `dev`
2. Implementasi fitur/fix dengan commit message yang jelas
3. Update CHANGELOG.md dengan entry baru
4. Test semua perubahan
5. Create Pull Request ke branch `dev`

### Commit Message Convention

```
feat: menambahkan fitur X
fix: memperbaiki bug Y
docs: update dokumentasi Z
chore: update dependencies
refactor: restructure code untuk A
```

---

## 🌿 Branches

### [main](https://github.com/creatorb/flutter_syathiby)
Original version of Syathiby App built by IT Sragen. Kami akan terus support branch ini dengan requirements terbaru dan menjaga fitur-fitur original, InshaAllah.

### [dev](https://github.com/creatorb/flutter_syathiby/tree/dev)
Development version built by IT Syathiby. Branch ini akan terus diupdate dengan requirements terbaru dan penambahan fitur baru, InshaAllah.

---

## 👥 Team & Contact

**Ma'had Tahfizh al-Qur'an al-Imam as-Syathiby**  
Cileungsi, Bogor, Indonesia

- Website: [syathiby.com](https://syathiby.com)
- Tags: #pondok #jabodetabek #ma'had #tahfizh #al-Qur'an #sunnah #manhaj #salaf #cileungsi #bogor #indonesia #syathiby

---

## 📄 License

Copyright IT Syathiby 2024

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.