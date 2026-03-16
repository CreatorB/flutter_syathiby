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
- [Color Palette & Theme](#-color-palette--theme)
- [Development](#-development) → **[Web Dev Cheatsheet](WEB_DEV_CHEATSHEET.md)**
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

## 📚 Quick Documentation Links

- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - One-page quick reference (print-friendly!)
- **[WEB_DEV_CHEATSHEET.md](WEB_DEV_CHEATSHEET.md)** - Quick reference for web development commands
- **[WEB_DEPLOYMENT_GUIDE.md](WEB_DEPLOYMENT_GUIDE.md)** - Detailed deployment troubleshooting & checklist
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and feature changes

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

## 🎨 Color Palette & Theme

The app uses a custom green color palette with a modern 3D gradient design.

### Base Colors

| Role | Hex Code | Color Preview |
|------|----------|---------------|
| **Primary** | `#26774e` | ![#26774e](https://via.placeholder.com/80x20/26774e/000000?text=+) |
| **Dark** | `#19633f` | ![#19633f](https://via.placeholder.com/80x20/19633f/000000?text=+) |
| **Light** | `#82aa68` | ![#82aa68](https://via.placeholder.com/80x20/82aa68/000000?text=+) |

### Theme Features

✨ **Modern 3D Gradient Design:**
- **Strong gradient colors** using base color palette (Dark → Primary → Light)
- **3D elevation effects** with deep shadows (elevation 8-16)
- **Bold visual depth** with multi-layer shadows
- Material 3 design system with enhanced depth perception
- Gradient accents on AppBar, buttons, cards, and navigation
- Support for dark and light modes with adaptive gradients
- Rounded corners (16-28px) and generous padding
- High-contrast color scheme for better visibility

**Key Design Elements:**
- 🎨 **AppBar**: Gradient background with 8px elevation
- 💳 **Cards**: Strong 3D shadow with 8-10px elevation
- 🔘 **Buttons**: Bold gradient colors with 8-12px elevation
- 📱 **Navigation Bar**: Gradient indicators with 12px elevation
- 🎯 **Inputs**: Gradient focus borders (2.5px)
- ✨ **Dialogs & Sheets**: Deep shadows with 16px elevation

### 3D Icon Grid Design

🎯 **Elegant 3D Menu Icons:**
All grid menu icons throughout the app feature an elegant 3D design:
- **Multi-layer shadows**: 3 shadow layers for realistic depth perception
  - Top-left highlight (simulated light source)
  - Main shadow (bottom-right)
  - Additional depth shadow (deeper)
- **Gradient backgrounds**: Smooth color transitions from light to dark
- **Icon shadows**: Individual icon elements have subtle shadows
- **Text shadows**: Labels feature depth shadows
- **Rounded corners**: 20px border radius for smooth, modern look
- **Border highlights**: Semi-transparent borders for edge definition
- **Compact size**: 58x58px menu icon containers for cleaner layout density

Applied in:
- Home screen menu grids (all menu categories)
- Prayer/Ibadah screen icons
- Book selection grid
- All other menu navigation elements

### Attendance Button Motion (Premium + Fast)

The main attendance CTA (`Absen Masuk` / `Absen Pulang`) now uses a compact, premium interaction model:
- **Compact geometry**: 44px rendered height on Home for a tighter, modern look
- **Fast premium tap animation**: quick bounce timing tuned for responsiveness
- **Fetch-aware loading state**: inline spinner + dynamic label (`Absen masuk...` / `Absen pulang...`)
- **Tap lock during processing**: prevents accidental double-submit while status is updating
- **Smooth state handoff**: waits for refreshed presence/profile data before returning to idle

### Reusable 3D Widgets

📦 **Custom 3D Components:**
The app includes reusable widgets for consistent 3D styling:

**Elegant3DIcon** - Beautiful 3D icon container
- Multi-layer shadows with adjustable depth
- Gradient backgrounds
- Customizable size and colors
- Icon shadow effects

**Elegant3DCard** - 3D elevated card widget
- Multi-layer shadow system
- Optional gradient backgrounds
- Customizable borders and corners
- Adjustable depth intensity (0.0 to 1.0)

**Elegant3DButton** - compact premium action button
- Fast bounce animation on press
- Built-in loading mode (`isLoading`) with inline progress indicator
- Dynamic loading label support (`loadingLabel`)
- Designed for primary CTAs like attendance check-in/check-out

**Usage Example:**
```dart
// Simple 3D icon
Elegant3DIcon(
  iconData: Icons.home,
  size: 58,
  iconSize: 24,
)

// Interactive 3D icon button
Elegant3DIconButton(
  iconData: Icons.settings,
  onTap: () { /* action */ },
  depth: 0.72,
)

// Compact attendance button with loading state
Elegant3DButton(
  label: 'Absen Masuk',
  icon: Icons.check_circle,
  height: 44,
  depth: 0.62,
  isLoading: false,
  loadingLabel: 'Absen masuk...',
  onPressed: () { /* action */ },
)

// 3D card with gradient
Elegant3DCard(
  borderRadius: 20,
  useGradient: true,
  child: YourContent(),
)
```

📄 **Theme Configuration Files:**
- [`lib/app.dart`](lib/app.dart) - Main theme setup with 3D gradient styling
- [`lib/res/colors.dart`](lib/res/colors.dart) - Color scheme definitions
- [`lib/utils/extension/color.dart`](lib/utils/extension/color.dart) - Color extensions
- [`lib/presentation/home/home_screen.dart`](lib/presentation/home/home_screen.dart) - 3D icon grid implementation
- [`lib/presentation/widgets/elegant_3d_icon.dart`](lib/presentation/widgets/elegant_3d_icon.dart) - Reusable 3D icon widget
- [`lib/presentation/widgets/elegant_3d_button.dart`](lib/presentation/widgets/elegant_3d_button.dart) - Reusable compact 3D action button
- [`lib/presentation/widgets/elegant_3d_card.dart`](lib/presentation/widgets/elegant_3d_card.dart) - Reusable 3D card widget

**To modify the theme:**
1. Edit the color values in `lib/res/colors.dart`
2. Update theme configuration in `lib/app.dart`
3. Adjust 3D icon effects in `buildListMenu()` method or use reusable widgets
4. Customize `Elegant3DIcon` and `Elegant3DCard` depth parameter (0.0 - 1.0)
5. Rebuild the app with `fvm flutter run`

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

### Web Development

Run Flutter web version locally for development and debugging:

#### Production Mode
```bash
# Simulates production environment (uses production API)
fvm flutter run -d chrome
```
- URL: `http://localhost:8080`
- API: `https://aplikasi.syathiby.id` (production)
- Best for: Final testing before deployment

#### Local/Development Mode
```bash
# Development environment (uses local backend API)
fvm flutter run -d chrome --web-hostname 192.168.50.100 --web-port 8082
```
- URL: `http://192.168.50.100:8082`
- API: `http://192.168.50.100/aplikasi` (local)
- Hot reload: Enabled (press `r` for instant reload)
- Best for: Debugging with local backend

#### Run Both Simultaneously
```powershell
# Starts PROD and LOCAL servers in separate browser windows
.\run-web-both.ps1

# PROD: http://localhost:8080
# LOCAL: http://192.168.50.100:8082
```

**See [WEB_DEV_CHEATSHEET.md](WEB_DEV_CHEATSHEET.md) for more web development tips & tricks!**

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

**Production build (deployed to `aplikasi.syathiby.id/web/`):**

```bash
# Manual build (step by step)
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter build web --release --base-href /web/ --tree-shake-icons
```

> **⚠️ IMPORTANT:** Flag `--base-href` is **REQUIRED** because Flutter web is deployed as a subfolder.

**OR use automated deployment script (recommended):**

```bash
# PROD (default): base-href /web/ — untuk aplikasi.test & server production
bash ./deploy_web.sh

# DEV: base-href /aplikasi/web/ — untuk akses via IP (HP/device lain)
bash ./deploy_web.sh --dev

# Build + sync + auto commit & push
bash ./deploy_web.sh --commit ":rocket: update flutter web"

# Sync saja tanpa build ulang
bash ./deploy_web.sh --skip-build
```

```powershell
# PowerShell (full pipeline: clean, pub get, build_runner, build, verify, copy):
.\deploy-web.ps1                # PROD mode
.\deploy-web.ps1 -Dev           # DEV mode (akses via IP)
.\deploy-web.ps1 -SkipClean     # Skip clean step (faster)
.\deploy-web.ps1 -Dev -SkipClean
```

| Mode | Base-href | Akses |
|------|-----------|-------|
| **PROD** | `/web/` | `aplikasi.test/web/` dan `aplikasi.syathiby.id/web/` |
| **DEV** | `/aplikasi/web/` | `192.168.50.100/aplikasi/web/` (HP/device lain via IP) |

**`deploy_web.sh`** (bash) will:
1. Auto-detect FVM path (Git Bash compatible)
2. Build web with base-href sesuai mode (PROD/DEV)
3. Sync `build/web/` → `../aplikasi/web/` (hapus file lama, copy baru)
4. (Optional) Git commit & push ke repo `aplikasi`

**`deploy-web.ps1`** (PowerShell) will:
1. Clean, get dependencies, generate code
2. Build web with base-href sesuai mode (PROD/DEV)
3. Verify critical files (`flutter_bootstrap.js`, `main.dart.js`, `version.json`)
4. **Prompt to auto-copy** build output to `../aplikasi/web/` (with auto-rename `htaccess` → `.htaccess`)

Output: `build/web/`

> **⚠️ CRITICAL: Web Deployment**
>
> 1. Upload contents of `build/web/` to `web/` folder on server `aplikasi.syathiby.id`
> 2. **DELETE old files** in `web/` folder before uploading
> 3. **Clear server cache** (Cloudflare/cPanel/Nginx)
> 4. **Verify**: `https://aplikasi.syathiby.id/web/version.json`
>
> **See comprehensive guide:** [WEB_DEPLOYMENT_GUIDE.md](WEB_DEPLOYMENT_GUIDE.md)

#### Local Testing Before Deployment (Laragon)

Test the built web app locally before uploading to production.

**Recommended: Laragon Virtual Host**

Laragon auto-creates a virtual host for every folder in `C:/laragon/www/`. The `aplikasi` folder becomes `aplikasi.test`:

```
http://aplikasi.test/web/    ← same path as production, works with --base-href /web/
```

No extra configuration needed — just run the deploy script with auto-copy, then open `http://aplikasi.test/web/`.

**Alternative: localhost/aplikasi/web/ via `.htaccess` Rewrite**

If you prefer `localhost/aplikasi/web/`, create `C:/laragon/www/.htaccess`:

```apache
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteCond %{REQUEST_URI} ^/web/
  RewriteCond %{REQUEST_URI} !^/aplikasi/
  RewriteRule ^web/(.*)$ /aplikasi/web/$1 [L]
</IfModule>
```

This rewrites `localhost/web/*` → `localhost/aplikasi/web/*` so Flutter can find its assets.

> A pre-made template is available at `aplikasi/web/htaccess_xampp_root` — copy and rename to `.htaccess` in your Laragon/XAMPP www root.

**Local testing workflow:**

```
# Via Laragon virtual host (PROD mode):
1. .\deploy-web.ps1           → build PROD + auto-copy to aplikasi/web/
2. Open http://aplikasi.test/web/  → test
3. Confirmed OK → git push aplikasi/web/ ke server

# Via IP dari HP/device lain (DEV mode):
1. .\deploy-web.ps1 -Dev      → build DEV + auto-copy
2. Open http://192.168.50.100/aplikasi/web/  → test dari HP
3. Setelah OK, rebuild PROD untuk deploy: .\deploy-web.ps1
```

> **Note**: Web version includes **Guest Mode** with full access to all **Ibadah** features (Al-Quran, Hadith, Prayer Schedule, Dhikr, etc.) accessible without login. The app automatically starts in guest mode at `/guest-news` when no session exists.

**Web Architecture (Same-Origin, No CORS):**

```
aplikasi.syathiby.id/           -> redirect to /web/
aplikasi.syathiby.id/web/       -> Flutter web app (subfolder)
aplikasi.syathiby.id/geten/     -> Backend API
aplikasi.syathiby.id/wordpress_images.php -> Image proxy
```

Flutter web and backend run on the **same origin** (`aplikasi.syathiby.id`), so there are **no CORS issues**.

#### Web Changelog Notification

**Problem**: Unlike native apps that show update dialogs from Play Store, web users don't know when new features are deployed because files are replaced instantly.

**Solution**: Web-specific changelog notification system using localStorage version tracking:

- **Automatic detection**: App checks current version vs last seen version on home screen load
- **First-time visitors**: See changelog modal for current version on first visit
- **After updates**: When deployment replaces files with new version, modal appears automatically
- **Content**: Changelog fetched from GitHub CHANGELOG.md (same as native)
- **User control**: "Understood" action closes the modal and marks the version as seen
- **Storage**: Uses browser localStorage to persist last seen version

**Implementation**:
- `UpdateChecker.checkForWeb()`: Check if changelog should be shown (web only)
- `UpdateChecker.markChangelogAsSeen()`: Save current version to localStorage
- Modal shows "What's New" instead of "Update Available"
- No Play Store button on web (replaced with an "Understood" acknowledgment)

**Benefits**:
- Web users always informed about new features after deployment
- Consistent changelog experience across native and web platforms
- No manual user action required (automatic detection)
- Non-intrusive (appears once per version, can be dismissed)

**After deployment:**
1. Open incognito/private window (Ctrl+Shift+N) — old service worker won't interfere
2. Test guest mode: Should land on News page automatically
3. Test login: Click "Pengguna" tab → "Masuk" button
4. Verify icons and UI match the native APK — if different, the `.htaccess` cache headers may not be active

**Why icons/UI may appear outdated after rebuild:**

Flutter web uses a service worker (`flutter_service_worker.js`) to cache assets. If this file is cached by the browser, the old service worker keeps serving old assets even after you rebuild and upload.

The `.htaccess` in `web/` includes `Cache-Control: no-store` for critical files:
- `flutter_service_worker.js` — **most important**: must always be fresh
- `flutter_bootstrap.js`, `index.html`, `version.json`, `manifest.json`

Static assets (`.js`, `.wasm`, fonts, images) use long-term caching — the service worker handles invalidation via content hash manifests.

### Run Web Locally for Development & Debugging

**⚠️ Important**: Web requires Chrome browser and active internet connection to backend server.

#### 1. Production Mode (Simulates Production Server)
```bash
# Run production build on Chrome (default: localhost:8080)
fvm flutter run -d chrome

# Or specify production server URL
fvm flutter run -d chrome --web-hostname localhost --web-port 8080
```

**Features:**
- Uses production API URL: `https://aplikasi.syathiby.id`
- No banner (clean production UI)
- Resembles deployed version
- Best for final testing before deployment

#### 2. Local Development Mode (For Debugging)
```bash
# Run local build on Chrome with custom hostname/port
fvm flutter run -d chrome --web-hostname 192.168.50.100 --web-port 8082

# Or if using localhost (same machine)
fvm flutter run -d chrome --web-hostname localhost --web-port 8082
```

**Configuration:**
- Change `192.168.50.100` to your machine's IP address
- Change `8082` to any available port
- Requires local backend server running at `http://192.168.50.100/aplikasi`

**Features:**
- Uses local/development API URL
- Shows RED banner with "LOCAL" indicator
- Hot reload enabled (press `r` in terminal)
- Perfect for debugging and development
- Preserves app state on refresh

#### 3. Debug Mode with Hot Reload
```bash
# Start development server with full debugging
fvm flutter run -d chrome --web-hostname 192.168.50.100 --web-port 8082 -v

# After app loads, press 'r' for hot reload
# Press 'q' to quit
```

**Development Workflow:**
1. Run command above
2. Browser opens automatically at `http://192.168.50.100:8082`
3. Edit Dart code in IDE
4. Press `r` in terminal → app reloads instantly
5. See changes immediately
6. Check DevTools for logs (`http://localhost:9222` in new browser tab)

#### 4. Chrome DevTools for Debugging
```bash
# Run with debugging support
fvm flutter run -d chrome --web-hostname 192.168.50.100 --web-port 8082 -v

# Open new Chrome tab and go to:
chrome://inspect/#devices

# Click "inspect" on the Flutter app
```

**Available in DevTools:**
- Widget tree explorer
- Performance profiler
- Network requests
- Console logs
- Breakpoints & step debugging

#### 5. Quick Test Both Variants
```powershell
# Run PROD environment
Write-Host "Starting PROD server..." -ForegroundColor Green
Start-Process -NoNewWindow pwsh -ArgumentList @"-NoExit", "-Command", "fvm flutter run -d chrome --web-hostname localhost --web-port 8080"

# Wait a moment for server to start
Start-Sleep -Seconds 3

# Run LOCAL environment in another terminal
Write-Host "Starting LOCAL server..." -ForegroundColor Yellow
Start-Process -NoNewWindow pwsh -ArgumentList @"-NoExit", "-Command", "fvm flutter run -d chrome --web-hostname 192.168.50.100 --web-port 8082"

Write-Host ""
Write-Host "✓ PROD: http://localhost:8080" -ForegroundColor Green
Write-Host "✓ LOCAL: http://192.168.50.100:8082" -ForegroundColor Yellow
```

Save as `run-web-both.ps1` and run: `.\run-web-both.ps1`

---

**Troubleshooting web routing:**
- If landing on login instead of guest mode: Clear browser localStorage
- Open DevTools → Application → Local Storage → Delete all entries
- Refresh page → Should redirect to guest news
- Use incognito/private mode to avoid cached assets

---

## 📱 Platform Differences: APK vs Web

⚠️ **Important**: While APK and Web versions share the same version number, certain features have different capabilities due to platform constraints.

### Quick Comparison Table

| Feature | APK (Mobile) | Web (Browser) |
|---------|-------------|---------------|
| **Push Notifications** | ✅ Full FCM support | ❌ Disabled |
| **GPS Location** | ✅ Native GPS | ⚠️ Browser geolocation (limited) |
| **Biometric Auth** | ✅ Fingerprint/Face | ❌ Not available |
| **Camera/QR Scanner** | ✅ Native camera | ⚠️ Browser camera (limited) |
| **Offline Mode** | ✅ Local caching | ❌ Requires internet |
| **Background Services** | ✅ Supported | ❌ Not available |
| **File System** | ✅ Full access | ⚠️ Downloads only |
| **Guest Mode** | ✅ Full support | ✅ Full support |
| **WordPress News** | ✅ Full support | ✅ Full support |
| **Attendance** | ✅ GPS + Wi-Fi | ⚠️ Browser location + Wi-Fi |
| **Login/Auth** | ✅ Full support | ✅ Full support |
| **Reports & Analytics** | ✅ Full support | ✅ Full support |

### Detailed Feature Comparison

#### 🔔 Push Notifications
- **APK**: Firebase Cloud Messaging with background notifications, notification channels, and message handling
- **Web**: Completely disabled. Firebase initialization is skipped on web for Safari compatibility
- **Impact**: Web users won't receive real-time notifications about attendance, announcements, or updates

#### 📍 Location & Permissions
- **APK**: 
  - Native Android location services with high accuracy
  - Permission dialogs with "Open Settings" direct link
  - Wi-Fi attendance with IP validation
  - GPS-based attendance with radius validation
- **Web**: 
  - Browser Geolocation API (accuracy varies by device/browser)
  - Permission dialogs show an acknowledgment-only action ("Mengerti")
  - Users must grant location manually via browser settings
  - Wi-Fi attendance works via IP detection from server headers
- **Impact**: Web attendance may have lower GPS accuracy; users need to manually enable browser location

#### 🔐 Biometric Authentication
- **APK**: Local Auth plugin supports fingerprint and face unlock
- **Web**: Not implemented (no Web Authentication API integration)
- **Impact**: Web users can only use password authentication

#### 📱 Native Device Features
- **APK**:
  - Barcode/QR scanner for attendance, meetings, inventory
  - Full camera access for photo capture
  - Local file system read/write
  - Background service for location tracking
- **Web**:
  - Browser camera API (may require HTTPS)
  - File downloads only, no direct filesystem
  - No background services
  - QR scanner works but limited by browser camera quality
- **Impact**: QR scanning and photo features work better on APK

#### 🌐 Connectivity & Offline Mode
- **APK**: Local database caching allows viewing previously loaded data offline
- **Web**: Requires active internet connection for all operations
- **Impact**: APK more reliable in areas with poor connectivity

#### 🎨 User Experience
- **APK**: Native UI with smooth animations, system integration, navigation gestures
- **Web**: Responsive design that adapts to screen size, works on any device with browser
- **Impact**: APK feels more native, Web more accessible cross-platform

### ✅ Features That Work Identically

Both platforms support:
- ✅ **Guest Mode**: News, Prayer Times, Quran, Qibla
- ✅ **Authentication**: Login, password change, session management
- ✅ **WordPress News**: Full news feed with images and rich content
- ✅ **Attendance**: Check-in/out (with platform-specific location handling)
- ✅ **Staff Management**: View and manage staff data
- ✅ **Reports**: Attendance reports, performance tracking, analytics
- ✅ **Dark/Light Theme**: Adaptive theme switching

### 📰 WordPress Detail Rendering Strategy

- **Web**: `WpPostDetailScreen` loads the article URL directly from WordPress response (`post.link`) via WebView URL request.
- **Android/iOS (APK)**: `WpPostDetailScreen` keeps the previous rich HTML rendering flow (`initialData`) for stable native behavior.
- **Fallback**: If `post.link` is missing/invalid on web, the screen falls back to HTML rendering.

This split approach keeps native behavior unchanged while avoiding black/blank embed rendering issues on web.

### 💡 Usage Recommendations

**Use APK when:**
- Staff needs daily attendance check-in/out
- Push notifications are required
- Working in areas with intermittent internet
- Need QR scanner for meetings/events
- Prefer native app experience

**Use Web when:**
- Occasional access to view information
- No access to Play Store (restricted devices)
- Need quick access from any device/computer
- Only need to view reports and data
- Don't need push notifications

**Hybrid Approach:**
- Give field staff APK for daily use
- Use Web for management/admin dashboard access
- Both platforms share same backend API and data

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

Splash screen dikonfigurasi di `pubspec.yaml` pada bagian `flutter_native_splash:`.

**Konfigurasi saat ini:**
- Background: hitam (`#000000`) untuk light & dark mode
- Gambar: `assets/images/syathiby_splash_1152.png` (logo hijau di atas background putih rounded corners)
- Web splash: aktif (`web: true`)

```bash
# Regenerate splash setelah mengubah konfigurasi atau gambar
fvm dart run flutter_native_splash:create
```

> **Catatan:** Setelah regenerate splash, jangan lupa rebuild web jika ingin perubahan terlihat di Flutter web.

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
├── web/
│   ├── htaccess                    # Apache config: SPA routing + Cache-Control headers
│   ├── index.html                  # Flutter web entry point
│   └── ...
├── CHANGELOG.md                    # Version history
├── ATTENDANCE_WIFI_TEST_CHECKLIST.md  # Wi-Fi attendance test guide
├── WEB_DEPLOYMENT_GUIDE.md         # Web deployment checklist & troubleshooting
├── install-both-apks.ps1           # Dual APK installer script
├── deploy_web.sh                   # Web deploy: bash (dev/prod mode, auto-detect FVM)
├── deploy-web.ps1                  # Web deploy: PowerShell (dev/prod, full pipeline)
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