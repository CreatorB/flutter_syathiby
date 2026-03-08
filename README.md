# Syathiby App

Attendance and staff management application for Ma'had Tahfizh al-Qur'an al-Imam as-Syathiby.

Enhanced and customized version of Syathiby Vendor App — [https://github.com/creatorb/flutter-syathiby-vendor](https://github.com/creatorb/flutter-syathiby-vendor)

> 📋 **Changelog**: See [CHANGELOG.md](CHANGELOG.md) for full version history.

---

## 📑 Table of Contents

- [Quick Start](#-quick-start)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [URL Environment Setup](#-url-environment-setup-flavor-based)
- [Development](#-development)
- [Building & Deployment](#-building--deployment)
- [Features](#-features)
- [Environment Indicators](#-environment-indicators)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)
- [Keystore](#-keystore)
- [Advanced Configuration](#-advanced-configuration)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [Branches](#-branches)
- [Team & Contact](#-team--contact)
- [License](#-license)

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

# 4. Run app (PROD flavor — automatically uses production URL)
fvm flutter run --flavor prod --dart-define=FLAVOR=prod

# 5. Run app (LOCAL flavor — automatically uses local URL)
fvm flutter run --flavor local --dart-define=FLAVOR=local
```

---

## 📋 Prerequisites

- **Flutter SDK**: Managed via [FVM](https://fvm.app/)
- **Android Studio** / **Xcode** (for Android/iOS builds)
- **ADB** (Android Debug Bridge) for device deployment
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

### 1. Set Up FVM and Flutter SDK

```bash
# Install the Flutter version used by this project
fvm install

# Activate FVM version
fvm use
```

### 2. Install Dependencies

```bash
fvm flutter pub get
```

### 3. Generate Models & Code

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. (Optional) Set Up Keystore for Release Build

See the [Keystore](#-keystore) section below.

---

## 🌐 URL Environment Setup (Flavor-Based)

The app uses **automatic flavor-based URL configuration**. The backend URL is selected automatically based on the active flavor:

### Default Configuration (Built-in)

| Flavor | API URL | Link Base | App Name |
|--------|---------|-----------|----------|
| **prod** | `https://aplikasi.syathiby.id/geten/` | `https://aplikasi.syathiby.id` | Syathiby |
| **local** | `http://192.168.50.100/aplikasi/geten/` | `http://192.168.50.100/aplikasi` | Syathiby LOCAL |

### ⚡ Usage

**Production:**
```bash
fvm flutter run --flavor prod --dart-define=FLAVOR=prod
```
✅ Automatically uses: `https://aplikasi.syathiby.id`

**Local Development:**
```bash
fvm flutter run --flavor local --dart-define=FLAVOR=local
```
✅ Automatically uses: `http://192.168.50.100/aplikasi`

> **Note:** `--dart-define=FLAVOR=xxx` tells the app which flavor is active so the correct URL is selected automatically.

### 🔧 Changing the Default URL

If your local server IP is **not** `192.168.50.100`, edit:

📄 **`lib/res/flavor_config.dart`**

```dart
static const Map<String, Map<String, String>> _configs = {
  'prod': {
    'API_URL': 'https://aplikasi.syathiby.id/geten/',
    'LINK_BASE': 'https://aplikasi.syathiby.id',
  },
  'local': {
    'API_URL': 'http://192.168.1.100/aplikasi/geten/',  // ← Change IP here
    'LINK_BASE': 'http://192.168.1.100/aplikasi',       // ← and here
  },
};
```

After editing, rebuild:
```bash
fvm flutter clean
fvm flutter pub get
fvm flutter run --flavor local --dart-define=FLAVOR=local
```

### 🎛️ Runtime URL Override (Without Rebuild)

You can also **temporarily override the URL** at runtime without rebuilding:

1. Launch the app (any flavor)
2. On the Login screen, **long-press the Syathiby logo**
3. A dialog appears showing the active URL
4. Enter your custom URL:
   ```
   API URL:   http://192.168.1.200/aplikasi/geten/
   Link Base: http://192.168.1.200/aplikasi
   ```
5. Tap **"Save & Restart"**

> The override is **stored in SharedPreferences** and persists until manually reset.

### 🔄 Reset to Flavor Default

1. Long-press the logo on the Login screen
2. **Clear all fields**
3. Tap "Save & Restart"

The app will revert to the default URL for the active flavor.

### 💡 Development Tips

**Find your server's local IP:**

Windows:
```bash
ipconfig
```

macOS / Linux:
```bash
ifconfig
# or
ip addr show
```

Look for an IP starting with `192.168.x.x` or `10.x.x.x`.

**Environment detection:**

The app automatically detects the environment based on the active URL:
- Local IP (`192.168.x.x`, `10.x.x.x`, `172.16–31.x.x`, `localhost`) → **LOCAL** (red banner)
- Other public domain → **PROD** (green banner, hidden in release)

### 📁 Relevant File Structure

```
flutter_syathiby/
└── lib/res/
    ├── flavor_config.dart          # URL configuration per flavor
    ├── environment_config.dart     # Runtime config + URL override logic
    └── env.dart                    # Legacy (optional, for MAPS_API_KEY)
```

### 🐛 URL Environment Troubleshooting

**Issue: URL still wrong after changing flavor**

```bash
# Make sure to pass --dart-define=FLAVOR
fvm flutter run --flavor local --dart-define=FLAVOR=local
# ⚠️ NOT: fvm flutter run --flavor local  (missing --dart-define)
```

**Issue: Cannot connect to local server**

1. ✅ Verify the backend server is running
2. ✅ Device and server are on the same network (same Wi-Fi)
3. ✅ Test the URL in a browser: `http://192.168.x.x/aplikasi/geten/`
4. ✅ Check firewall is not blocking the connection
5. ✅ Use the device's IP address, not `localhost`

**Issue: Environment label shows PROD instead of LOCAL**

- Long-press the logo to verify the actual URL in use
- Ensure the URL uses `http://` (not `https://`) for local
- Confirm the IP matches the local pattern: `192.168.x.x`

---

## 💻 Development

### Run App (Development Mode)

```bash
# PROD flavor (automatically uses https://aplikasi.syathiby.id)
fvm flutter run --flavor prod --dart-define=FLAVOR=prod

# LOCAL flavor (automatically uses http://192.168.50.100/aplikasi)
fvm flutter run --flavor local --dart-define=FLAVOR=local

# Specify device
fvm flutter run -d <device-id> --flavor prod --dart-define=FLAVOR=prod
fvm flutter run -d 127.0.0.1:5555 --flavor local --dart-define=FLAVOR=local
```

### Hot Reload & Restart

- **Hot Reload**: `r` (in terminal while app is running)
- **Hot Restart**: `R`
- **Quit**: `q`

### Code Generation

Run whenever you modify models or environment config:

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

Watch mode (auto-generates on file changes):

```bash
fvm flutter pub run build_runner watch --delete-conflicting-outputs
```

### Clean Build

If you encounter cache or dependency issues:

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

### Android App Bundle (AAB) — Play Store

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

### Install Both APKs Side-by-Side

Use the PowerShell script to install PROD and LOCAL simultaneously:

```powershell
.\install-both-apks.ps1
```

**Requirements:**
- Android device connected via USB or Wi-Fi
- ADB installed and available in PATH
- Both APKs already built (see above)

**The script will:**
1. Validate ADB availability
2. Check device connection
3. Install `app-local-debug.apk` → `id.syathiby.app.local`
4. Install `app-prod-debug.apk` → `id.syathiby.app`
5. Display colored status output (green = success, red = failed)

### Web Build

```bash
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter build web --release --tree-shake-icons
```

Output: `build/web/`

**`.htaccess` for web deployment:**

```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^ index.html [L]
```

**Run web locally:**

```bash
fvm flutter run -d chrome --web-hostname 192.168.50.100 --web-port 8082
```

---

## ✨ Features

### WordPress News Integration

The app displays news and announcements from the Ma'had Syathiby WordPress site:

- **WordPress REST API**: Pull latest posts from `https://syathiby.id/wp-json/wp/v2/posts`
- **SEO-Optimized Images**: Uses Yoast SEO og_image for fast-loading, optimized thumbnails
- **Rich Content Display**: Full HTML rendering with InAppWebView
- **Embedded Media Support**: YouTube videos, Instagram posts, Twitter embeds automatically rendered
- **Skeleton Loading**: Smooth loading animations while fetching content
- **WebP Image Support**: Native support for modern WebP format images
- **Available in**: Guest News screen and Member News screen

**How it works:**
- News content is managed through WordPress CMS at syathiby.id
- App fetches posts via REST API with embedded featured media
- Images prioritize Yoast SEO optimized thumbnails from `yoast_head_json`
- Detail screen uses WebView for rich content including videos and embeds
- HTML entities automatically decoded for proper text display

### Attendance System

The app supports two attendance methods:

1. **Location (GPS)**: Validates attendance based on GPS coordinates and location radius
2. **Network (Wi-Fi / LAN)**: Validates attendance using the device's public IP address

**How Wi-Fi attendance works:**
- User selects the attendance method when tapping the check-in/out button
- Wi-Fi mode sends coordinates `(0, 0)` as a mode indicator to the backend
- The app fetches the allowed public IP from the server endpoint (`settings/wificonfig.php`)
- The app validates the device's current public IP against the allowed IP via an external IP API
- If validation passes, the attendance request is submitted — backend skips GPS radius check for `(0, 0)` coordinates
- Error code `03` is used for Wi-Fi validation failures

### Update Checker

- Automatically checks for a new version on app startup (Home screen)
- Compares current app version with the latest version in [CHANGELOG.md](CHANGELOG.md) on GitHub
- **Dynamic Branch Selection**: Selects the appropriate GitHub branch based on current flavor:
  - **LOCAL flavor** (`--flavor local`): Fetches CHANGELOG from **`test`** branch for development updates
  - **PROD flavor** (`--flavor prod`): Fetches CHANGELOG from **`dev`** branch for stable releases
- Displays a bottom sheet modal with the changelog content when an update is available
- Provides a direct link to the Play Store for the update
- Non-blocking: users can dismiss and continue using the current version

### Profile Management

View and manage staff profile information.

### Leave Request System

Submit and track leave/permit requests.

### Timeline & Activity Tracking

View attendance history and activity timeline.

---

## 🎨 Environment Indicators

The app provides visual indicators to distinguish between environments:

### Global Banner (Ribbon) — LOCAL Only

- **LOCAL**: Red ribbon with "LOCAL" label (development indicator)
- **PROD**: No banner — clean UI for end users

> Production builds have a clean UI without any environment banner.

### Dynamic App Name
- Local environment: "Syathiby LOCAL"
- Production environment: "Syathiby"

### Login Screen Badge
- Displays the active ENV label and API URL
- Red for LOCAL, green for PROD
- **Long-press logo** to override the API URL at runtime

### Android Flavors

| | Flavor `prod` | Flavor `local` |
|---|---|---|
| **Application ID** | `id.syathiby.app` | `id.syathiby.app.local` |
| **App Label** | Syathiby | Syathiby LOCAL |
| **Banner** | ❌ None (clean UI) | 🔴 Red ribbon |

Both flavors can be installed simultaneously on the same device.

---

## 🧪 Testing

### Wi-Fi Attendance Test Guide

A detailed test checklist for Wi-Fi attendance is available at:

📄 **[ATTENDANCE_WIFI_TEST_CHECKLIST.md](ATTENDANCE_WIFI_TEST_CHECKLIST.md)**

### Flutter Analyzer

```bash
fvm flutter analyze
```

### Unit Tests

```bash
fvm flutter test
```

---

## 📰 WordPress API Configuration

### WordPress REST API Endpoint

The app fetches news from the WordPress site using the REST API:

```
Base URL: https://syathiby.id/wp-json/wp/v2
Posts Endpoint: /posts?_embed=true
```

**Query Parameters:**
- `_embed=true`: Includes embedded resources (featured media, author, etc.)
- `page=1`: Page number for pagination
- `per_page=10`: Number of posts per page (default: 10, max: 100)
- `orderby=date`: Sort by date, relevance, id, etc.
- `order=desc`: Descending order (newest first)

### WordPress Models

The app uses Freezed models for WordPress data:

**`WpPost`** - Main post model
- `id`, `date`, `slug`, `link`
- `title`, `content`, `excerpt` (rendered HTML)
- `featured_media` (media ID)
- `_embedded` (embedded resources)
- `yoast_head_json` (Yoast SEO metadata)

**`YoastHeadJson`** - SEO metadata from Yoast plugin
- `og_image[]` - Open Graph images (optimized thumbnails)

**`OgImage`** - SEO-optimized image
- `url`: Direct image URL (WebP format)
- `width`, `height`: Image dimensions
- `type`: MIME type (image/webp)

**`WpEmbedded`** - Embedded resources
- `wp:featuredmedia[]` - Featured media with source_url

### Image Loading Strategy

The app uses a prioritized fallback strategy for images:

1. **Primary**: Yoast SEO og_image
   ```dart
   yoast_head_json.og_image[0].url
   ```
   ✅ SEO-optimized, pre-resized WebP thumbnails

2. **Fallback**: Featured media from embedded data
   ```dart
   _embedded['wp:featuredmedia'][0].source_url
   ```
   ⚠️ Full-resolution original image

### WordPress Service Configuration

**Location**: `lib/models/wordpress/wp_api_service.dart`

```dart
@RestApi(baseUrl: 'https://syathiby.id/wp-json/wp/v2')
abstract class WpApiService {
  factory WpApiService(Dio dio, {String baseUrl}) = _WpApiService;

  @GET('/posts')
  Future<List<WpPost>> getPosts({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('_embed') bool? embed,
  });

  @GET('/posts/{id}')
  Future<WpPost> getPost(@Path('id') int id);
}
```

**Dependency Injection**: `lib/di/providers.dart`

```dart
final wpApiServiceProvider = Provider<WpApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return WpApiService(dio);
});
```

### WordPress Content Display

**List View** (`wp_post_list_item.dart`):
- Featured image (200px height)
- Title (HTML decoded)
- Excerpt (HTML stripped and decoded)
- Skeleton loading animation

**Detail View** (`wp_post_detail_screen.dart`):
- Featured image at top
- Full HTML content rendering with InAppWebView
- Embedded media support (YouTube, Instagram, etc.)
- Custom CSS for responsive layout

### Yoast SEO Plugin

The WordPress site uses Yoast SEO plugin which provides:
- Optimized og_image thumbnails (WebP format)
- SEO metadata in `yoast_head_json` field
- Better performance with pre-resized images

To check if Yoast is installed:
```bash
curl https://syathiby.id/wp-json/wp/v2/posts?per_page=1 | jq '.[0].yoast_head_json'
```

---

## 🛠️ Troubleshooting

### Build Runner — Conflicting Outputs

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

**Then rebuild:**

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

# Connect via Wi-Fi (after USB pairing)
adb tcpip 5555
adb connect <device-ip>:5555
```

### FVM Not Found

Make sure FVM is added to PATH:

```bash
# Check FVM installation
fvm --version

# Install FVM if missing
dart pub global activate fvm

# Add to PATH (Windows example)
# Add: %USERPROFILE%\AppData\Local\Pub\Cache\bin
```

---

## 🔐 Keystore

### Debug Keystore

Generate a debug keystore for development:

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

For production builds, use a secure keystore. Store it in a safe location and **never commit it to git**.

---

## 🛠️ Advanced Configuration

### Rename App and Package Name

```bash
dart run flutter_application_id:main -f flutter_application_id.yaml
```

### Change App Icon

```bash
# Generate configuration
dart run flutter_launcher_icons:generate --override

# Generate icons
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
├── android/                        # Android native code & flavor config
├── ios/                            # iOS native code
├── lib/
│   ├── app.dart                    # Root MaterialApp with environment banner
│   ├── data/                       # Data layer (repositories, local storage)
│   ├── models/
│   │   ├── wordpress/               # WordPress REST API models
│   │   │   ├── wp_api_service.dart # Retrofit API service
│   │   │   └── wp_post.dart        # WpPost model (Freezed + JSON)
│   │   └── ...                     # Other models
│   ├── presentation/
│   │   ├── home/                   # Home screen with update checker
│   │   ├── login/                  # Login screen with environment badge
│   │   ├── presence/               # Attendance screen with Wi-Fi option
│   │   ├── wordpress/              # WordPress news screens
│   │   │   ├── wp_posts_controller.dart   # Riverpod controller
│   │   │   ├── wp_post_list_item.dart     # News list item widget
│   │   │   └── wp_post_detail_screen.dart # Article detail (WebView)
│   │   ├── guest/                  # Guest screens (uses WordPress API)
│   │   └── news/                   # Member news (uses WordPress API)
│   ├── di/
│   │   └── providers.dart          # Riverpod providers & DI
│   ├── res/
│   │   ├── flavor_config.dart      # Built-in URL configuration per flavor
│   │   ├── environment_config.dart # Runtime config + URL override
│   │   └── strings.dart            # App constants, dynamic app name
│   └── utils/
│       └── update_checker.dart     # GitHub CHANGELOG version check
├── test/                           # Unit & widget tests
├── build/                          # Build outputs (gitignored)
├── CHANGELOG.md                    # Version history
├── ATTENDANCE_WIFI_TEST_CHECKLIST.md  # Wi-Fi attendance test guide
├── install-both-apks.ps1           # Dual APK installer script
├── pubspec.yaml                    # Flutter dependencies
└── README.md                       # This file
```

---

## 🤝 Contributing

1. Create a new branch from `dev`
2. Implement features or fixes with clear commit messages
3. Update [CHANGELOG.md](CHANGELOG.md) with a new entry
4. Test all changes thoroughly
5. Open a Pull Request to the `dev` branch

### Commit Message Convention

```
feat: add feature X
fix: resolve bug Y
docs: update documentation for Z
chore: update dependencies
refactor: restructure code for A
```

---

## 🌿 Branches

### [dev](https://github.com/CreatorB/flutter_syathiby/tree/dev)
Active development branch — continuously updated with the latest features and requirements.

### [main](https://github.com/CreatorB/flutter_syathiby)
Stable branch. Maintained to support the latest production requirements with original features intact.

---

## 👥 Team & Contact

**Ma'had Tahfizh al-Qur'an al-Imam as-Syathiby**  
Cileungsi, Bogor, Indonesia

- Website: [syathiby.com](https://syathiby.com)
- Tags: `pondok` `jabodetabek` `ma'had` `tahfizh` `al-Qur'an` `sunnah` `manhaj` `salaf` `cileungsi` `bogor` `indonesia` `syathiby`

---

## 📄 License

Copyright IT Syathiby 2024

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at [http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.