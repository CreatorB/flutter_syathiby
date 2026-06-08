# Syathiby Development Quick Reference

**Last Updated:** 2026-03-08 (v1.0.6+6)

---

## 🚀 START WEB DEVELOPMENT

### Option 1: Production Mode (Test Production)
```bash
fvm flutter run -d chrome
```
✓ Uses production API  
✓ Best for final testing

### Option 2: Local Development (Debug)
```bash
fvm flutter run -d chrome --web-hostname 192.168.50.100 --web-port 8082
```
✓ Uses local backend  
✓ Hot reload enabled  
✓ RED "LOCAL" banner  
✓ Best for debugging

### Option 3: Run Both Simultaneously
```powershell
.\run-web-both.ps1
```
✓ PROD at `http://localhost:8080`  
✓ LOCAL at `http://192.168.50.100:8082`  
✓ Test both at same time

---

## 📱 START MOBILE DEVELOPMENT

### APK (Mobile Phone Testing)
```bash
# Production
fvm flutter run --flavor prod --dart-define=FLAVOR=prod

# Local
fvm flutter run --flavor local --dart-define=FLAVOR=local
```

---

## 🔨 BUILD & DEPLOY

### Web Release Build
```bash
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter build web --release --tree-shake-icons
```

**Output:** `build\web\` → Upload to server

### Web Deployment
1. **DELETE** all old files on server
2. **UPLOAD** all files from `build\web\`
3. **CLEAR** server cache (Cloudflare/cPanel)
4. **VERIFY** `https://mobile.syathiby.id/version.json` shows v1.0.6
5. **CLEAR** browser cache
6. **TEST** in incognito mode

See [WEB_DEPLOYMENT_GUIDE.md](WEB_DEPLOYMENT_GUIDE.md) for details.

### APK Release Build
```bash
# Production
fvm flutter build apk --release --flavor prod --dart-define=FLAVOR=prod

# Local
fvm flutter build apk --release --flavor local --dart-define=FLAVOR=local
```

**Output:** `build\app\outputs\flutter-apk\app-prod-release.apk`

---

## 🔄 DEVELOPMENT WORKFLOW

### Hot Reload (Instant Changes)
```
1. Run app: fvm flutter run -d chrome --web-hostname 192.168.50.100 --web-port 8082
2. Edit code in IDE
3. Press 'r' in terminal → Instant reload (state preserved!)
4. See changes in browser
```

### DevTools Debugging
```
1. Chrome: Menu → More tools → Developer tools (F12)
2. Console tab → See logs
3. Network tab → Monitor API calls
4. Or: chrome://inspect/#devices →检查 Flutter app
```

---

## 🔧 UTILITY SCRIPTS

```powershell
# Run PROD + LOCAL simultaneously
.\run-web-both.ps1

# Automated web build
.\deploy-web.ps1

# Install both APKs
.\install-both-apks.ps1

# Simple web run
.\run.ps1
```

---

## 📋 VERSION INFO

| App | Version | Build # | Mode |
|-----|---------|---------|------|
| Android APK | 1.0.6 | 6 | Production Ready |
| Web (PROD) | 1.0.6 | 6 | Production Ready |
| Web (LOCAL) | 1.0.6 | 6 | Development Ready |

---

## 🌐 IMPORTANT LINKS

### During Development
| Type | URL |
|------|-----|
| Web (PROD) | http://localhost:8080 |
| Web (LOCAL) | http://192.168.50.100:8082 |
| DevTools | chrome://inspect/#devices |

### After Deployment
| Type | URL |
|------|-----|
| App | https://mobile.syathiby.id |
| Version | https://mobile.syathiby.id/version.json |
| API | https://aplikasi.syathiby.id |

---

## 🅰️ API ENDPOINTS

### Production
```
API Base: https://aplikasi.syathiby.id/geten/
File Base: https://aplikasi.syathiby.id/
```

### Local Development
```
API Base: http://192.168.50.100/aplikasi/geten/
File Base: http://192.168.50.100/aplikasi/
```

---

## 🎯 FEATURE STATUS

### Available on Web
✅ Guest Mode (News, Prayer, Quran)  
✅ Login & Authentication  
✅ WordPress News  
✅ Prayer Times  
✅ Attendance (limited location)  
✅ Reports & Data

### Mobile-Only (APK)
📱 Push Notifications  
📱 Biometric Auth (Fingerprint/Face)  
📱 Native Camera/QR Scanner  
📱 Background Services  
📱 Offline Caching  

---

## ⚠️ COMMON ISSUES

### Web shows old version
```
1. Check: https://mobile.syathiby.id/version.json
2. If old → server not updated
3. Solution: Follow deployment guide
```

### Can't connect to local backend
```
1. Verify: http://192.168.50.100/aplikasi/
2. Check firewall allows connection
3. Verify same network
4. Try local IP instead of hostname
```

### Hot reload not working
```
1. Check network connection
2. Try full restart: Ctrl+C then run again
3. Clear browser cache
4. Use dev tools: F12 → Console for errors
```

### Incognito mode needed?
```
✓ Always use incognito after deployment
✓ Or clear browser cache completely
Ctrl+Shift+Delete → Clear all
```

---

## 📚 DETAILED DOCUMENTATION

For more details, see:

- 📖 **[README.md](README.md)** - Complete setup guide
- 🚀 **[WEB_DEV_CHEATSHEET.md](WEB_DEV_CHEATSHEET.md)** - Web development tips
- 📦 **[WEB_DEPLOYMENT_GUIDE.md](WEB_DEPLOYMENT_GUIDE.md)** - Deployment troubleshooting
- 📋 **[CHANGELOG.md](CHANGELOG.md)** - Version history

---

## 💡 TIPS

1. **Use LOCAL mode for development** - faster iteration with hot reload
2. **Test PROD mode before deploying** - catch issues early
3. **Always delete old files when deploying** - prevents cache conflicts
4. **Clear browser cache after updates** - ensures latest version loads
5. **Use incognito mode for testing** - avoids cache issues
6. **Check version.json endpoint** - verify deployment successful
7. **Use both PROD + LOCAL simultaneously** - compare environments side-by-side

---

**Questions?** Check [CHANGELOG.md](CHANGELOG.md) for recent updates and fixes.
