# Changelog

All notable changes to Syathiby App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [1.0.5] - 2026-03-07

### Added
- **WordPress REST API Integration**: News feeds now pull from syathiby.id WordPress site
  - Implemented WordPress REST API v2 service with Retrofit
  - Created `WpPost` model with Freezed and JSON serialization
  - Added `YoastHeadJson` support for SEO-optimized og_image thumbnails
  - New presentation layer: `WpPostListItem` and `WpPostDetailScreen`
  - Integrated with both Guest News and Member News screens
- **Rich Content Display**: Enhanced news detail screen
  - Uses `InAppWebView` for rich content rendering
  - Supports embedded media (YouTube, Instagram, Twitter, etc.)
  - Custom HTML template with responsive design
  - Featured image display at top of article
- **Image Loading Optimization**: WebP image support
  - Prioritizes Yoast SEO og_image (optimized thumbnails from `yoast_head_json`)
  - Falls back to featured media from `_embedded` data
  - Uses native `Image.network` for WebP format compatibility
  - Loading progress indicator with smooth animations
- **UI/UX Enhancements**: Improved news reading experience
  - Skeleton loading animation using Skeletonizer package
  - Comprehensive HTML entity decoding (numeric and named entities)
  - Error handling with detailed diagnostic messages
  - Smooth navigation between list and detail views

### Changed
- **News Data Source**: Migrated from custom API to WordPress REST API
  - Guest News screen now uses WordPress posts endpoint
  - Member News screen updated to use WordPress API
  - Maintained consistent UI while improving content management
- **Dependencies**: Updated service injection and providers
  - Added `WpApiService` to dependency injection
  - Registered WordPress services in `ServiceInjection`
  - Updated routing configuration for WordPress screens
- **Update Checker Branch Configuration**: Implemented dynamic GitHub branch selection based on flavor
  - Feature: UpdateChecker now uses environment-specific branches for version checking
  - **Local flavor** (`--flavor local`): Checks `test` branch for development releases
  - **Production flavor** (`--flavor prod`): Checks `dev` branch for stable releases
  - Implementation: Added `FlavorConfig` dependency to `UpdateChecker` class
  - Benefit: Allows testing new versions on `test` branch before promoting to `dev` for production
  - File: `lib/utils/update_checker.dart` — Changed `changelogUrl` from static constant to dynamic getter

### Fixed
- **Kinerja Screen**: Performance list (Tab "List Penilaian") could not be scrolled down
  - Removed `NeverScrollableScrollPhysics` from `PagedListView` and `ListView.builder`
  - Infinite scroll pagination now works correctly to load next pages
- **Overnight Shift Attendance**: Fixed button logic for attendance spanning midnight
  - Issue: Security guards and night shift workers checking in at 23:00 and checking out at 07:00 saw incorrect button
  - Expected: "Absen Pulang" (Check Out) button at 07:00
  - Previous behavior: "Absen Masuk" (Check In) button appeared incorrectly
  - **Root cause**: Backend only checked attendance records for current date, missing shifts that started yesterday
  - **Solution**: Modified `detailstore.php` to search for login records within last 36 hours instead of current date only
  - Now correctly handles shifts that span across midnight (e.g., 23:00 Day 1 → 07:00 Day 2)
  - Also fixed work duration calculation for overnight shifts
- **Tahfidz Attendance Labels**: Fixed swapped dropdown labels for Sakit and Izin  
  - Issue: When selecting "Sakit" in app, dashboard showed it as "Izin" and vice versa
  - **Root cause**: Dropdown UI labels were reversed - value "sakit" had label "Izin", value "izin" had label "Sakit"
  - **Solution**: Corrected dropdown labels in both teacher and student tahfidz attendance screens
  - Now "Sakit" correctly saves as "sakit" and "Izin" correctly saves as "izin"
  - Dashboard properly displays counts in correct columns (SAKIT, IZIN, ALFA)
- **Notification Text Truncation**: Fixed success and error messages being cut off
  - Issue: Long notification messages like "Anda sudah melakukan absen masuk dan absen keluar hari ini. Absen berikutnya bisa dilakukan besok" were truncated
  - **Root cause**: Toast notification Text widget had no maxLines constraint, causing single-line truncation
  - **Solution**: Added `maxLines: 4` with `overflow: TextOverflow.visible` to show full message
  - Increased default auto-close duration from 2s to 3s for success messages, 3s to 4s for errors
  - Messages now wrap to multiple lines and display completely
- **Thumbnail Loading Issues**: Resolved image display problems
  - Fixed field mapping: og_image moved from root to `yoast_head_json.og_image`
  - Addressed SQLite cache database corruption (switched to Image.network)
  - WebP format now fully supported without cache issues
- **HTML Entity Display**: All HTML entities properly decoded
  - Numeric entities (&#8217;, &#038;, etc.)
  - Named entities (&amp;, &lt;, &gt;, &quot;, etc.)
  - Hellip and other special characters ([&hellip;], [...])

### Removed
- **Legacy News Models**: Replaced with WordPress models
  - Removed old news service and models
  - Kept backup files for reference (*.backup)

### Technical Details
- **WordPress Integration Files**:
  - **API Endpoint**: `https://syathiby.id/wp-json/wp/v2/posts?_embed=true`
  - **Image Priority Strategy**:
    1. Yoast SEO og_image: `yoast_head_json.og_image[0].url` (SEO-optimized WebP)
    2. Featured media: `_embedded['wp:featuredmedia'][0].source_url`
  - **Models Created**:
    - `WpPost`: Main post model with title, content, excerpt, featured_media
    - `WpEmbedded`: Embedded resources container
    - `WpFeaturedMedia`: Featured media with source_url and media_details
    - `YoastHeadJson`: Yoast SEO metadata container
    - `OgImage`: Open Graph image with width, height, url, type
  - **Presentation Layer**:
    - `WpPostsController`: Riverpod controller for fetching posts
    - `WpPostListItem`: List item widget with featured image and excerpt
    - `WpPostDetailScreen`: Full article view with WebView rendering
  - **Flutter Dependencies**:
    - `retrofit` + `dio`: REST API client
    - `freezed` + `json_serializable`: Model generation
    - `flutter_inappwebview`: Rich content display
    - `cached_network_image`: Image caching (replaced with Image.network for WebP support)
    - `skeletonizer`: Loading animations

- **Attendance System Updates**:
  - **Backend File Modified**: `aplikasi/geten/settings/detailstore.php`
  - **Changes**:
    - Attendance login query now uses `date >= '$yesterday'` instead of `date = '$tanggal'`
    - Added `ORDER BY date DESC, hour DESC LIMIT 1` to get most recent login
    - Both login and logout queries updated to support 36-hour lookback window
  - **Impact**: Affects all users with overnight shifts (security guards, night supervisors, etc.)
  - **Flutter Files Modified for Tahfidz**: 
    - `lib/presentation/presensi_tahfidz/tahfidz_teacher_presence_screen.dart`
    - `lib/presentation/presensi_tahfidz/tahfidz_presence_list_screen.dart`
  - **Changes**: Corrected DropdownMenuItem labels to match their values (Sakit ↔ sakit, Izin ↔ izin)
  - **Backend Files Modified for Status Normalization**:
    - `aplikasi/geten/siswa/absenpengamputahfidz.php` (teacher tahfidz attendance)
    - `aplikasi/geten/siswa/absentahfidz.php` (student tahfidz attendance)
  - **Changes**: Added `$status_key = strtolower(trim($status))` to normalize status before saving to database, ensuring consistent lowercase storage (hadir, sakit, izin, alfa) matching dashboard queries
  - **Flutter File Modified for Notification Display**:
    - `lib/utils/extension/ui.dart`
  - **Changes**: 
    - Added `maxLines: 4` and `overflow: TextOverflow.visible` to `showSuccessMessage` and `showErrorMessage`
    - Increased `autoCloseDuration` for success messages (2s → 3s) and error messages (3s → 4s)
    - Added explicit `fontSize: 14` for better readability

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
- **Flavor-Based URL Configuration**: Automatic URL selection based on build flavor
  - Created `lib/res/flavor_config.dart` with built-in configuration per flavor
  - Flavor `prod`: Automatically uses `https://aplikasi.syathiby.id`
  - Flavor `local`: Automatically uses `http://192.168.50.100/aplikasi`
  - Requires `--dart-define=FLAVOR=xxx` in build commands
  - Eliminates need for manual .env configuration per build
  - Backward compatible with runtime URL override (long-press logo)

### Changed
- Attendance submission now accepts coordinates (0,0) to indicate Wi-Fi mode
- Backend skips GPS radius validation when Wi-Fi mode is detected with valid IP
- Updated all build and run commands in documentation to use FVM
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

## Changelog Format Guide

Use the following categories for each change:
- **Added**: New features
- **Changed**: Changes to existing features
- **Deprecated**: Features to be removed in a future version
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security-related fixes

### New Entry Example

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- Feature A: brief description
- Feature B: brief description

### Fixed
- Bug on screen X
- Crash when doing Y
```
