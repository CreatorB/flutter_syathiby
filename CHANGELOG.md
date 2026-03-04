# Changelog

All notable changes to Syathiby App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.5] - 2026-03-04

### Added
- **Flavor-Based URL Configuration**: Automatic URL selection based on build flavor
  - Created `lib/res/flavor_config.dart` with built-in configuration per flavor
  - Flavor `prod`: Automatically uses `https://aplikasi.syathiby.id`
  - Flavor `local`: Automatically uses `http://192.168.50.100/aplikasi`
  - Requires `--dart-define=FLAVOR=xxx` in build commands
  - Eliminates need for manual .env configuration per build
  - Backward compatible with runtime URL override (long-press logo)

### Changed
- `EnvironmentConfig` now uses `FlavorConfig` as default fallback instead of `Env`
- Updated all build and run commands to include `--dart-define=FLAVOR=xxx`
- Simplified setup documentation with flavor-first approach
- **Banner behavior**: Now only shows for LOCAL environment (development)
  - PROD builds have clean UI without environment banner
  - Makes production app more professional and polished

### Removed
- **Legacy `env.dart` and `env.g.dart`** - Replaced by flavor-based config
- **`.env.example`** - No longer needed, configuration is in `lib/res/flavor_config.dart`
- Envied dependency can be removed from pubspec.yaml if not needed for other purposes

## [1.0.4] - 2026-03-04

### Added
- **Wi-Fi Based Attendance**: New attendance method using public IP validation (103.178.146.98)
  - User can choose between Location (GPS) or Wi-Fi method when marking attendance
  - Pre-validation in Flutter app before submitting
  - Backend validation using public IP detection from HTTP headers
  - Error code 03 for Wi-Fi validation failures
- **Environment Indicators**: Visual differentiation between LOCAL and PROD environments
  - Global banner ribbon showing "LOCAL" (red) or "PROD" (green)
  - Dynamic app name: "Syathiby LOCAL" when using local API
  - Environment label and API URL display on login screen
  - Long-press logo on login to change API URL
- **Android Product Flavors**: Side-by-side installation support
  - Flavor `prod`: id.syathiby.app (App name: Syathiby)
  - Flavor `local`: id.syathiby.app.local (App name: Syathiby LOCAL)
  - Both flavors can be installed simultaneously on same device
- **Dual APK Installer Script**: PowerShell script (`install-both-apks.ps1`) for one-click installation
  - Automatic ADB and device validation
  - Sequential installation of both local and prod APKs
  - Colored status output with clear error messages
- **Test Documentation**: Created `ATTENDANCE_WIFI_TEST_CHECKLIST.md` for testing scenarios
- **FVM Standardization**: All Flutter commands now use `fvm` prefix for version consistency

### Changed
- Attendance submission now accepts coordinates (0,0) to indicate Wi-Fi mode
- Backend skips GPS radius validation when Wi-Fi mode is detected with valid IP
- Updated all build and run commands in documentation to use FVM

### Technical Details
- **Wi-Fi Mode Detection**: Coordinates (0,0) indicate Wi-Fi-based attendance
- **IP Detection Order**: HTTP_X_FORWARDED_FOR → HTTP_CLIENT_IP → REMOTE_ADDR
- **Local Environment Detection**: Matches private IP ranges (192.168.x.x, 10.x.x.x, 172.16-31.x.x, localhost)
- **Backend Endpoints Modified**: presence.php, presencenormal.php, presencefinger.php

### Backend Changes
- Added `get_client_public_ip()` function to detect real public IP
- Wi-Fi validation in attendance endpoints
- Error code 03 for better error handling in app

### Flutter Changes
- `lib/presentation/presence/presence_screen.dart`: Method selection dialog, IP validation
- `lib/res/environment_config.dart`: Environment detection and label helpers
- `lib/res/strings.dart`: Dynamic app name based on environment
- `lib/presentation/login/login_screen.dart`: Environment badge display
- `lib/app.dart`: Global banner widget for environment indication
- `android/app/build.gradle.kts`: Product flavors configuration
- `android/app/src/main/AndroidManifest.xml`: Dynamic label placeholder

## [1.0.0] - 2024-12-XX

### Added
- Initial enhanced version of Syathiby Staff App
- Attendance system with GPS and radius validation
- Profile management
- Leave request system
- Timeline and activity tracking
- Multi-language support (Indonesian/English)

### Technical
- Flutter SDK with FVM management
- GetX for state management
- Dio for HTTP client
- Geolocator for location services

---

## Panduan Format Changelog

Gunakan kategori berikut untuk setiap perubahan:
- **Added**: Fitur baru
- **Changed**: Perubahan pada fitur yang sudah ada
- **Deprecated**: Fitur yang akan dihapus di versi mendatang
- **Removed**: Fitur yang dihapus
- **Fixed**: Bug fixes
- **Security**: Perbaikan terkait keamanan

### Contoh Entry Baru

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- Fitur A: deskripsi singkat
- Fitur B: deskripsi singkat

### Fixed
- Bug pada halaman X
- Crash saat melakukan Y
```
