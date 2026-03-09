# Web Development Cheat Sheet

Quick reference untuk command-command web development.

## 🚀 Quick Commands

### Run Web (Production Mode)
```bash
fvm flutter run -d chrome
```
- URL: `http://localhost:8080`
- Uses: Production API (`https://aplikasi.syathiby.id`)
- WordPress proxy: `http://localhost/aplikasi/geten/wordpress_proxy.php`
- Environment: GREEN banner or no banner
- Hot reload: ✅ Enabled

### Run Web (Local/Development Mode)
```bash
fvm flutter run -d chrome --web-hostname 192.168.50.100 --web-port 8082
```
- URL: `http://192.168.50.100:8082`
- Uses: Local API (`http://192.168.50.100/aplikasi`)
- WordPress proxy: `http://localhost/aplikasi/geten/wordpress_proxy.php`
- Environment: RED banner with "LOCAL"
- Hot reload: ✅ Enabled
- Best for: Debugging against local backend

### Run Web (Custom Port)
```bash
fvm flutter run -d chrome --web-hostname localhost --web-port 3000
```
- Change `localhost` to your IP
- Change `3000` to your desired port

### Run Both PROD and LOCAL
```powershell
.\run-web-both.ps1
```
- Starts both servers in separate jobs
- PROD: `http://localhost:8080`
- LOCAL: `http://192.168.50.100:8082`
- Perfect for comparing both environments

---

## 🔄 Hot Reload Workflow

1. Start development server:
   ```bash
   fvm flutter run -d chrome --web-hostname 192.168.50.100 --web-port 8082
   ```

2. App opens in Chrome automatically

3. Edit Dart code in your IDE

4. Press **`r`** in terminal → instant reload (state preserved!)

5. See changes immediately in browser

6. Press **`q`** to quit

---

## 🐞 Debugging

### Open DevTools
```bash
# While server is running, open new Chrome tab
chrome://inspect/#devices

# Then click "inspect" on Flutter app
```

### Chrome DevTools Features
- Widget tree explorer
- Performance profiler
- Network requests
- Console logs
- Breakpoints & step-through debugging

### View Logs
```bash
# Logs appear in terminal where you ran flutter run
# Look for: [INFO], [WARN], [ERROR], [SEVERE]
```

### Verbose Output
```bash
fvm flutter run -d chrome -v
# Shows detailed build and network logs
```

---

## 🧹 Build & Clean

### Clean Build
```bash
fvm flutter clean
```

### Clean Build + Full Rebuild (Production)
```bash
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter build web --release --base-href /web/ --tree-shake-icons
```

> **⚠️ PENTING:** Flag `--base-href /web/` WAJIB karena Flutter web di-deploy di subfolder `/web/` pada `aplikasi.syathiby.id`.

---

## 🔍 Verify Web Build Output

### Check version.json
```bash
# After build, check version file
Get-Content build\web\version.json

# Expected output:
# {
#   "version": "1.0.7",
#   "buildNumber": "7"
# }
```

### List all build output
```bash
Get-ChildItem build\web\ -Recurse | Select-Object FullName, Length
```

---

## 🌐 Architecture & Environment

### Web Architecture (Production)

```
aplikasi.syathiby.id/           → redirect ke /web/
aplikasi.syathiby.id/web/       → Flutter web app
aplikasi.syathiby.id/geten/     → Backend API (same origin!)
aplikasi.syathiby.id/wordpress_images.php → Image proxy (same origin!)
syathiby.id                     → WordPress (diakses via server-side proxy)
```

**Same-origin = Tidak ada CORS** antara Flutter web dan backend.

### Local Development Architecture

```
localhost:PORT                   → Flutter web (dev server)
localhost/aplikasi/geten/        → Backend API (XAMPP/Apache)
localhost/aplikasi/wordpress_images.php → Image proxy
localhost/aplikasi/geten/wordpress_proxy.php → WordPress API proxy
```

> Di localhost, Flutter web dan backend beda port (CORS), tapi proxy PHP sudah punya header `Access-Control-Allow-Origin: *`.

### How Environment is Detected

Web app automatically detects environment from hostname:

| Hostname | Environment | WordPress Proxy |
|----------|-------------|-----------------|
| `localhost` | LOCAL | `http://localhost/aplikasi/geten/wordpress_proxy.php` |
| `127.0.0.1` | LOCAL | `http://localhost/aplikasi/geten/wordpress_proxy.php` |
| `192.168.50.100` | LOCAL | `http://localhost/aplikasi/geten/wordpress_proxy.php` |
| Other (production) | PROD | `https://aplikasi.syathiby.id/geten/wordpress_proxy.php` |

### Change URL at Runtime

1. On login screen, **long-press the Syathiby logo**
2. Dialog appears with current URL
3. Enter new URL (e.g., `http://other-server/aplikasi/`)
4. Tap "Save & Restart"
5. App restarts with new URL

---

## 🔗 Useful URLs

### During Development

| Type | URL |
|------|-----|
| App (PROD) | `http://localhost:8080` |
| App (LOCAL) | `http://192.168.50.100:8082` |
| Version Check | `http://<host>:<port>/version.json` |
| DevTools | `chrome://inspect/#devices` |
| WP Proxy Test | `http://localhost/aplikasi/geten/wordpress_proxy.php/posts?per_page=1` |

### After Deployment

| Type | URL |
|------|-----|
| App | `https://aplikasi.syathiby.id/web/` (atau root → redirect) |
| Version Check | `https://aplikasi.syathiby.id/web/version.json` |
| API Endpoint | `https://aplikasi.syathiby.id/geten/` |
| WP Proxy | `https://aplikasi.syathiby.id/geten/wordpress_proxy.php/posts?per_page=1` |

---

## 🚨 Troubleshooting

### Port Already in Use
```bash
# Use different port
fvm flutter run -d chrome --web-hostname localhost --web-port 3000
```

### Can't find Chrome
```bash
# Make sure Chrome is installed
# Or specify Chrome path
fvm flutter run -d edge  # Use Edge instead
```

### App Still Shows Old Version
```bash
# Clear browser cache
Ctrl + Shift + Delete  # Windows/Linux
Cmd + Shift + Delete   # macOS

# Or use Incognito mode
Ctrl + Shift + N       # Windows/Linux
Cmd + Shift + N        # macOS
```

### Localhost Doesn't Work
```bash
# Use your actual IP instead
fvm flutter run -d chrome --web-hostname 192.168.50.100 --web-port 8082

# Find your IP
ipconfig  # Windows
ifconfig  # macOS/Linux
```

### Cannot Connect to Backend
```bash
# Verify backend is running
curl http://192.168.50.100/aplikasi/geten/

# Check firewall allows connection
# Verify device and backend are on same network
# Try with IP instead of hostname
```

### WordPress Images Not Loading (CORS)
```
# Di local dev, pastikan XAMPP/Apache jalan
# Cek proxy langsung:
curl http://localhost/aplikasi/geten/wordpress_proxy.php/posts?per_page=1&_embed=true

# Cek image proxy:
curl http://localhost/aplikasi/wordpress_images.php?url=2025/08/test.webp
```

---

## 📦 Production Build

### Build for Deployment
```bash
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter build web --release --base-href /web/ --tree-shake-icons
```

Output: `build/web/`

### Deployment Steps
1. Upload isi `build/web/` ke folder `web/` di server `aplikasi.syathiby.id`
2. **DELETE file lama** di folder `web/` sebelum upload
3. Pastikan `.htaccess` ikut terupload (di folder `web/`)
4. Pastikan root `.htaccess` (`aplikasi/.htaccess`) sudah ada redirect ke `/web/`
5. Clear server cache (Cloudflare/cPanel)
6. Verify: `https://aplikasi.syathiby.id/web/version.json`
7. Test di incognito mode

---

## 💡 Pro Tips

### Faster Iteration
1. Use LOCAL mode with hot reload
2. Make code changes
3. Press `r` → instant reload
4. No need to rebuild entire app

### Test Production Before Deploying
1. Run PROD mode locally (`fvm flutter run -d chrome`)
2. Test guest mode, login, features
3. Compare with LOCAL mode
4. Verify no "ENV" text appears
5. Then deploy to server

### Debug Specific Feature
```bash
# 1. Start LOCAL server
fvm flutter run -d chrome --web-hostname 192.168.50.100 --web-port 8082

# 2. Open DevTools (Shift+F12 in Chrome)
# 3. Go to Console tab
# 4. Edit code in IDE
# 5. Press 'r' in terminal
# 6. Check console for logs and errors
```

### Use Both Simultaneously
```powershell
# Run PROD and LOCAL side-by-side
.\run-web-both.ps1

# Then:
# - PROD window: Test production behavior
# - LOCAL window: Test and debug development
# - Compare differences between environments
```

---

## 📚 Documentation

See main documentation files:
- `README.md` - Complete setup and deployment guide
- `WEB_DEPLOYMENT_GUIDE.md` - Detailed deployment troubleshooting
- `CHANGELOG.md` - Version history and changes

---

**Last Updated:** 2026-03-09 (v1.0.7)
