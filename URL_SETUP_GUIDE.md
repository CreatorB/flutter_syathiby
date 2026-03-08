# Quick Guide: Setup URL Local & Production (Flavor-Based)

Panduan singkat untuk setup URL backend API dengan **konfigurasi otomatis per flavor**.

## 🎯 Konsep: Flavor = URL Otomatis

Aplikasi sekarang menggunakan **flavor-based configuration**:

| Flavor | URL Otomatis | Banner | Untuk |
|--------|--------------|--------|--------|
| **prod** | `https://aplikasi.syathiby.id` | ❌ Tidak ada (Clean UI) | Production / Public |
| **local** | `http://192.168.50.100/aplikasi` | 🔴 Red ribbon | Development / Testing |

**Cukup jalankan dengan flavor yang sesuai**, URL otomatis terpilih!

---

## ⚡ Quick Commands

### Production (URL: https://aplikasi.syathiby.id)

Clean UI tanpa banner untuk user experience yang profesional:

```bash
# Run
fvm flutter run --flavor prod --dart-define=FLAVOR=prod

# Build APK
fvm flutter build apk --release --flavor prod --dart-define=FLAVOR=prod
```

### Local Development (URL: http://192.168.50.100/aplikasi)

Dengan red ribbon banner untuk development indicator:

```bash
# Run
fvm flutter run --flavor local --dart-define=FLAVOR=local

# Build APK
fvm flutter build apk --debug --flavor local --dart-define=FLAVOR=local
```

> **⚠️ Penting:** Harus include `--dart-define=FLAVOR=xxx` agar URL otomatis dipilih!

---

## 🔧 Cara 1: Edit URL Default (Permanent)

**Cocok untuk:** Ganti IP server lokal default

**Step 1:** Edit file `lib/res/flavor_config.dart`

```dart
static const Map<String, Map<String, String>> _configs = {
  'prod': {
    'API_URL': 'https://aplikasi.syathiby.id/geten/',
    'LINK_BASE': 'https://aplikasi.syathiby.id',
  },
  'local': {
    // ⬇️ Ubah IP sesuai server Anda
    'API_URL': 'http://192.168.1.100/aplikasi/geten/',
    'LINK_BASE': 'http://192.168.1.100/aplikasi',
  },
};
```

**Step 2:** Rebuild & run

```bash
fvm flutter clean
fvm flutter pub get
fvm flutter run --flavor local --dart-define=FLAVOR=local
```

---

## 🎛️ Cara 2: Override via Aplikasi (Runtime)

**Cocok untuk:** Ganti URL sementara tanpa rebuild

1. Buka app → Halaman **Login**
2. **Long-press logo Syathiby** (tekan lama)
3. Dialog muncul, masukkan URL custom:
   ```
   API URL: http://192.168.1.200/aplikasi/geten/
   Link Base: http://192.168.1.200/aplikasi
   ```
4. Tekan **"Simpan & Restart"**

**Reset ke default:**
- Long-press logo → Kosongkan semua → Simpan & Restart

---

## 📱 Cara Cek URL Aktif

1. Lihat **banner** sudut kanan atas:
   - 🟢 **PROD** → Pakai production URL
   - 🔴 **LOCAL** → Pakai local IP
2. Di halaman **Login**, ada badge:
   - ENV: LOCAL / PROD
   - API URL lengkap

---

## 🔍 Check IP Komputer Server

### Windows:
```bash
ipconfig
```
→ Cari: `IPv4 Address . . . : 192.168.x.x`

### macOS / Linux:
```bash
ifconfig
```
→ Cari: `inet 192.168.x.x`

---

## ⚠️ Common Issues & Solutions

### ❌ "URL masih salah padahal sudah ganti flavor"

**Penyebab:** Lupa `--dart-define=FLAVOR`

**Solusi:**
```bash
# ✅ BENAR:
fvm flutter run --flavor local --dart-define=FLAVOR=local

# ❌ SALAH (tanpa --dart-define):
fvm flutter run --flavor local
```

### ❌ "Tidak bisa connect ke server local"

**Checklist:**
1. ✅ Backend server **running**
2. ✅ Device & server **satu WiFi**
3. ✅ Test URL di browser: `http://192.168.x.x/aplikasi/geten/`
4. ✅ **Jangan pakai `localhost`**, pakai IP address
5. ✅ Firewall tidak block port 80/443

### ❌ "Banner tetap PROD padahal pakai local"

**Cek:**
- Long-press logo → verify URL yang sebenarnya dipakai
- Pastikan format: `http://192.168.x.x` (bukan `https://`)
- IP harus range: `192.168.x.x`, `10.x.x.x`, `172.16-31.x.x`

---

## 💡 Best Practices

### Untuk Developer:
```bash
# Development: pakai flavor local
fvm flutter run --flavor local --dart-define=FLAVOR=local

# Production test: pakai flavor prod
fvm flutter run --flavor prod --dart-define=FLAVOR=prod
```

### Untuk Build Release:
```bash
# Production APK
fvm flutter build apk --release --flavor prod --dart-define=FLAVOR=prod

# Local APK (untuk testing internal)
fvm flutter build apk --release --flavor local --dart-define=FLAVOR=local
```

### Side-by-Side Install:
```bash
# Build kedua APK
fvm flutter build apk --debug --flavor prod --dart-define=FLAVOR=prod
fvm flutter build apk --debug --flavor local --dart-define=FLAVOR=local

# Install otomatis
.\install-both-apks.ps1
```

Kedua app akan terinstall dengan:
- **Syathiby** (prod) → hijau, pakai production URL
- **Syathiby LOCAL** (local) → merah, pakai local URL

---

## 📋 Cheat Sheet

| Task | Command |
|------|---------|
| **Run PROD** | `fvm flutter run --flavor prod --dart-define=FLAVOR=prod` |
| **Run LOCAL** | `fvm flutter run --flavor local --dart-define=FLAVOR=local` |
| **Build PROD APK** | `fvm flutter build apk --release --flavor prod --dart-define=FLAVOR=prod` |
| **Build LOCAL APK** | `fvm flutter build apk --release --flavor local --dart-define=FLAVOR=local` |
| **Check IP** | Windows: `ipconfig` / Mac: `ifconfig` |
| **Override URL** | Long-press logo di halaman Login |
| **Reset URL** | Long-press logo → kosongkan → Simpan |

---

## 🔗 File Penting

- **`lib/res/flavor_config.dart`** → Konfigurasi URL per flavor
- **`lib/res/environment_config.dart`** → Runtime override handler
- **`README.md`** → Dokumentasi lengkap

---

*Last updated: March 2026 | IT Syathiby*
