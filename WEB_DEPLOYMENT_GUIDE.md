# Web Deployment Checklist & Troubleshooting

## 🏗️ Arsitektur Deployment

```
aplikasi.syathiby.id/           → redirect ke /web/ (via .htaccess)
aplikasi.syathiby.id/web/       → Flutter web app
aplikasi.syathiby.id/geten/     → Backend API
aplikasi.syathiby.id/wordpress_images.php → Image proxy
syathiby.id                     → WordPress (beda hosting, diakses via proxy)
```

Flutter web dan backend berada di **satu origin** (`aplikasi.syathiby.id`), sehingga **tidak ada masalah CORS**.

---

## ✅ DEPLOYMENT CHECKLIST (WAJIB DIIKUTI!)

### 1️⃣ Build Web dengan Benar

```powershell
# Jalankan SEMUA command ini berurutan:
cd flutter_syathiby
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter build web --release --base-href /web/ --tree-shake-icons
```

> **⚠️ PENTING:** Flag `--base-href /web/` **WAJIB** karena Flutter web di-deploy di subfolder `/web/`.

**Cek build berhasil:**
- Folder `build/web/` harus ada
- File `build/web/version.json` harus berisi versi terbaru
- File `build/web/flutter.js` atau `flutter_bootstrap.js` ada
- Folder `build/web/assets/` ada isinya

---

### 2️⃣ Upload ke Server dengan BENAR

**Target folder di server:** `aplikasi/web/` (subfolder dari root `aplikasi.syathiby.id`)

**PENTING: DELETE folder lama di server DULU sebelum upload!**

#### Via FTP/SFTP:
1. **DELETE semua file di folder `web/`** pada server
2. Upload **SEMUA isi folder `build/web/`** ke folder `web/` di server
3. Pastikan file `.htaccess` ikut terupload (di dalam folder `web/`)
4. Verifikasi `version.json` terupload dengan benar

#### Via cPanel File Manager:
1. Buka File Manager → Masuk ke folder `web/`
2. **Select All → Delete** (hapus semua file lama)
3. Upload file ZIP dari `build/web/`
4. Extract di server
5. Cek file `.htaccess` ada

#### Via Command Line (SSH):
```bash
# Backup dulu (opsional)
cd /path/to/aplikasi/web
tar -czf backup-$(date +%Y%m%d).tar.gz *

# Delete semua file lama
rm -rf *

# Upload (gunakan scp, rsync, atau git)
rsync -avz --delete /local/path/build/web/ user@server:/path/to/aplikasi/web/
```

**CHECKLIST UPLOAD:**
- ✅ Semua file di `build/web/` terupload ke `aplikasi/web/`
- ✅ File `.htaccess` ada di folder `web/`
- ✅ File `version.json` terupload
- ✅ Folder `assets/`, `icons/`, dll ada
- ✅ Root `.htaccess` (`aplikasi/.htaccess`) sudah punya redirect ke `/web/`

---

### 3️⃣ Verifikasi Root .htaccess

Pastikan file `aplikasi/.htaccess` (root server) sudah punya rule redirect:

```apache
# REDIRECT ROOT KE /web/ (Flutter Web App - Production only)
RewriteCond %{HTTP_HOST} !=localhost
RewriteCond %{HTTP_HOST} !=127.0.0.1
RewriteCond %{HTTP_HOST} !=192.168.50.100
RewriteRule ^$ web/ [L,R=301]
```

Ini memastikan `https://aplikasi.syathiby.id/` otomatis redirect ke `https://aplikasi.syathiby.id/web/`.

---

### 4️⃣ Clear Server Cache (SANGAT PENTING!)

#### Jika pakai cPanel:
1. Masuk cPanel → **"Optimize Website"** atau **"Cache Manager"**
2. Klik **"Clear All Caches"**

#### Jika pakai Cloudflare:
1. Login Cloudflare Dashboard
2. Pilih domain → **Caching** → **Purge Everything**
3. Tunggu 3-5 menit

#### Jika pakai server sendiri (Nginx/Apache):
```bash
sudo systemctl restart nginx
# atau
sudo systemctl restart apache2

# Clear OPcache (jika ada)
sudo service php7.4-fpm restart
```

---

### 5️⃣ Test & Verify Upload Berhasil

**A. Test Version Endpoint:**
Buka browser: `https://aplikasi.syathiby.id/web/version.json`

**Expected output:**
```json
{
  "version": "1.0.7",
  "buildNumber": "7"
}
```

❌ **Jika masih versi lama atau 404:** Upload gagal!

**B. Test Root Redirect:**
Akses `https://aplikasi.syathiby.id/` → harus redirect ke `/web/`

**C. Test SPA Routing:**
Akses `https://aplikasi.syathiby.id/web/#/guest-news` → harus tampil halaman berita

**D. Test Backend API (Same Origin):**
Akses `https://aplikasi.syathiby.id/geten/` → harus ada response dari backend

---

### 6️⃣ Clear Browser Cache

#### Chrome/Edge/Brave:
1. Tekan `Ctrl + Shift + Delete`
2. Pilih "Cached images and files"
3. Klik "Clear data"

#### Mobile Browser:
- **Chrome Android:** Settings → Privacy → Clear browsing data
- **Safari iOS:** Settings → Safari → Clear History and Website Data

**ATAU gunakan INCOGNITO/PRIVATE MODE untuk test:**
- Chrome: `Ctrl + Shift + N`
- Firefox: `Ctrl + Shift + P`

---

## 🔍 TROUBLESHOOTING

### ❌ Problem: Web masih versi lama setelah upload

1. **Cek version.json:**
   ```
   https://aplikasi.syathiby.id/web/version.json
   ```
   Jika masih lama → Upload gagal, ulangi step 2

2. **Cek browser cache:**
   - DevTools (F12) → Tab Network → Reload → Cek timestamp file
   - Jika timestamp lama → Clear browser cache

3. **Cek server cache:**
   - Cloudflare → Purge cache
   - cPanel → Clear cache

### ❌ Problem: 404 Not Found

- File `.htaccess` tidak terupload atau tidak aktif
- Re-upload file `.htaccess` dari `build/web/.htaccess` ke folder `web/`
- Pastikan Apache `mod_rewrite` enabled di server

### ❌ Problem: Gambar WordPress tidak muncul

- Cek image proxy berjalan: `https://aplikasi.syathiby.id/wordpress_images.php?url=2025/08/test.webp`
- Cek WordPress proxy: `https://aplikasi.syathiby.id/geten/wordpress_proxy.php/posts?per_page=1&_embed=true`
- Pastikan `wordpress_images.php` dan `wordpress_proxy.php` terupload di server

### ❌ Problem: Root tidak redirect ke /web/

- Cek file `aplikasi/.htaccess` (root) punya rule redirect
- Pastikan `mod_rewrite` aktif
- Cek apakah ada rule lain yang konflik

### ❌ Problem: Guest mode tidak muncul, langsung ke login

1. Clear browser localStorage:
   - F12 → Application → Local Storage → Clear
   - Refresh page

2. Test di incognito/private mode

---

## 📋 DEPLOYMENT AUTOMATION SCRIPT

Simpan sebagai `deploy-web.ps1`:

```powershell
# Web Deployment Script untuk Syathiby
# Run: .\deploy-web.ps1

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Syathiby Web Deployment Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# 1. Clean build
Write-Host "[1/5] Cleaning previous build..." -ForegroundColor Yellow
fvm flutter clean
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# 2. Get dependencies
Write-Host "[2/5] Getting dependencies..." -ForegroundColor Yellow
fvm flutter pub get
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# 3. Generate code
Write-Host "[3/5] Generating code..." -ForegroundColor Yellow
fvm flutter pub run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# 4. Build web with --base-href /web/
Write-Host "[4/5] Building web (release mode, base-href=/web/)..." -ForegroundColor Yellow
fvm flutter build web --release --base-href /web/ --tree-shake-icons
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# 5. Verify build
Write-Host "[5/5] Verifying build..." -ForegroundColor Yellow

if (Test-Path "build\web\version.json") {
    $version = Get-Content "build\web\version.json" | ConvertFrom-Json
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host "  Version: $($version.version)" -ForegroundColor Green
} else {
    Write-Host "Build failed - version.json not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  BUILD COMPLETE!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. DELETE all files in server web/ folder" -ForegroundColor White
Write-Host "2. Upload ALL files from build\web\ to server web/ folder" -ForegroundColor White
Write-Host "3. Make sure .htaccess is uploaded (in web/ folder)" -ForegroundColor White
Write-Host "4. Verify root .htaccess has redirect to /web/" -ForegroundColor White
Write-Host "5. Clear server cache (Cloudflare/cPanel)" -ForegroundColor White
Write-Host "6. Test: https://aplikasi.syathiby.id/web/version.json" -ForegroundColor White
Write-Host "7. Clear browser cache and test app" -ForegroundColor White
Write-Host ""
Write-Host "Output location: build\web\" -ForegroundColor Cyan
```

---

## 📞 QUICK VERIFICATION COMMANDS

```bash
# Cek versi di server
curl https://aplikasi.syathiby.id/web/version.json

# Cek root redirect
curl -I https://aplikasi.syathiby.id/

# Cek .htaccess aktif (should redirect to index.html)
curl -I https://aplikasi.syathiby.id/web/test-invalid-url

# Cek WordPress proxy
curl https://aplikasi.syathiby.id/geten/wordpress_proxy.php/posts?per_page=1

# Cek image proxy
curl -I https://aplikasi.syathiby.id/wordpress_images.php?url=2025/08/test.webp
```

---

## ✅ FINAL CHECKLIST SEBELUM DEPLOY

- [ ] Flutter clean dilakukan
- [ ] Build web dengan `--base-href /web/` berhasil tanpa error
- [ ] File `build/web/version.json` ada dan berisi versi benar
- [ ] File `build/web/.htaccess` ada
- [ ] **DELETE semua file lama di folder `web/` server**
- [ ] Upload SEMUA file dari `build/web/` ke folder `web/` server
- [ ] Root `.htaccess` punya redirect ke `/web/`
- [ ] Test `https://aplikasi.syathiby.id/web/version.json` menampilkan versi baru
- [ ] Clear server cache
- [ ] Test di incognito/private browser
