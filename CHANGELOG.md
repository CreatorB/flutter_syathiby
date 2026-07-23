# Catatan Perubahan

Semua perubahan penting pada Aplikasi Syathiby akan didokumentasikan dalam file ini.

Format berdasarkan [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
dan proyek ini mengikuti [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.8] - 2026-07-23 (rebuild tanpa version bump)

> Catatan: rebuild untuk Play Store dengan `versionName` tetap `1.0.8` dan `versionCode` tetap `+8`. Perubahan di bawah ini ditulis ulang ke CHANGELOG untuk dokumentasi what-changed dalam build ini, bukan rilis SemVer baru.

### Diubah
- **Presensi Tahfidz Guru (`tahfidz_teacher_presence_screen.dart`)**: Refaktor alur muat jadwal halaqoh berdasarkan parameter tanggal + waktu
  - Fetch hanya berjalan jika `date` **dan** `time` keduanya terisi — sebelumnya layar kadang melakukan fetch tanpa filter yang memicu error backend
  - Ditambahkan empty-state eksplisit saat tidak ada murid pada slot waktu tersebut (hadir/alpha/sakit/izin count tetap 0, tampil pesan kosong)
  - Tombol tarik-untuk-muat-ulang dijaga agar tidak memantik fetch saat filter belum lengkap
  - Error toast dari `fetchTeacherTahfidzScheduleProvider` sekarang ditampilkan via `showToastOnError` (sebelumnya silent)
- **Daftar Presensi Tahfidz (`tahfidz_presence_list_screen.dart`)**: Pola fetch-conditional + empty-state yang sama dengan layar di atas, sehingga sinkron antara layar guru dan layar admin/asrama

### Diperbaiki
- **Error Message Hilang di Endpoint Write/Single-Object**: Pesan kesalahan backend tidak pernah sampai ke user pada endpoint yang mengembalikan `Message` tunggal
  - **Gejala**: Misal `POST permit/insertsantri.php` mengembalikan `{"errCode":"02","msg":"Izin sudah pernah diinput"}` — sebelumnya UI diam-diam memaksa parse sebagai list kosong, tidak ada feedback
  - **Gejala 2**: `siswa/absentahfidz.php` mengembalikan validation error `{"errCode":"02","msg":"Siswa tidak ditemukan"}` — tidak ada toast, layar sunyi
  - **Penyebab**: `ResponseInterceptor` untuk semua endpoint yang kembali ke `Future<Message>` (write/single-object) melempar daftar kosong `[]` saat backend mengembalikan `errCode='02'` tanpa field `data`
  - **Solusi**:
    - Ditambahkan `static const _messageEndpoints` di `response_interceptor.dart` berisi 20 path endpoint yang kembalikan single `Message`
    - Metode `_isMessageEndpoint(path)` mendeteksi apakah response berasal dari endpoint Message
    - Pada `errCode='02'` + `data==null` di endpoint Message, interceptor sekarang melempar `RestException(message, errCode)` sehingga `showToastOnError` menampilkan pesan asli backend
    - Endpoint list (siswa data, jadwal list, dll.) tetap memakai fallback `[]` agar `PagedListView`/`DropdownSearch` tidak crash
  - **Daftar endpoint yang mencakup fix ini**:
    - Presensi & tahfidz: `absenpengampu`, `absenpengamputahfidz`, `absentahfidz`, `getsantritahfidz`, `siswa/absen`, `siswa/absenguru`, `siswa/absenpengampu`, `deletehalaqah`
    - Transaksi/kegiatan: `siswa/insertmakan`, `siswa/insertkegiatan`, `siswa/inserttransaksi`, `siswa/insertkegiatansearch`, `siswa/insertmakansearch`
    - Permit (izin): `permit/insert`, `permit/insertsantri`, `permit/confirm`, `permit/confirmsantri`, `permit/deletesantri`, `permit/waliinsertsantri`, `permit/walidecancelsantri`
- **Log Debug Interceptor**: Pesan `Failed to parse ResponseEntity` sekarang memuat path endpoint yang gagal agar lebih mudah di-trace di logcat
  - Tambahan `[$path]` prefix di seluruh print statement di `response_interceptor.dart`
  - Body string di-truncate ke 500 karakter agar tidak membanjiri logcat

### Detail Teknis
- **File yang Dimodifikasi**:
  - `lib/utils/response_interceptor.dart`: tambah `_messageEndpoints` + `_isMessageEndpoint()`, ganti silent `[]` dengan `RestException` pada path Message, tambah prefix `[$path]` di log debug
  - `lib/presentation/presensi_tahfidz/tahfidz_teacher_presence_screen.dart`: refaktor fetch-conditional berdasarkan date+time, tampilkan empty-state, attach `showToastOnError` listener
  - `lib/presentation/presensi_tahfidz/tahfidz_presence_list_screen.dart`: pola fetch-conditional + empty-state yang sama seperti layar guru
- **Penyebab Utama Fix Ini**: Root cause `errCode='02'` silent swallow adalah `ResponseInterceptor` lama yang menganggap semua response dengan `data==null` pasti sebagai list — kini endpoint Message dipisah pengangan errornya

## [1.0.8] - 2026-03-15

### Diubah
- **Splash Screen Redesign**: Tampilan splash screen diperbarui untuk semua platform (Android, iOS, Web)
  - Background splash diubah dari putih (#FFFFFF) ke hitam (#000000)
  - Gambar logo splash (`syathiby_splash_1152.png`) dimodifikasi: background hitam diinvert menjadi putih dengan rounded corners
  - Logo hijau gradient tetap dipertahankan di tengah
  - Konsistensi tampilan antara light mode dan dark mode (keduanya background hitam)
  - Tampilan lebih modern dan premium dengan kontras hitam-putih
- **Web Splash Screen Diaktifkan**: Konfigurasi `web: true` pada `flutter_native_splash`
  - Sebelumnya splash screen web dinonaktifkan (`web: false`)
  - Sekarang splash screen tampil di Flutter web dengan gambar dan warna yang sama seperti Android/iOS
  - File splash CSS dan gambar (light/dark 1x-4x) di-generate otomatis ke folder `web/splash/`
- **Dzikir Offline Migration**: Menu "Dzikir Pagi dan Petang" kini menggunakan data offline JSON
  - Implementasi warna baris selang-seling untuk pembacaan yang lebih nyaman
  - Fitur **Progress Step** (Tap-to-Increment) untuk melacak jumlah bacaan secara interaktif
  - Tampilan lengkap 6 komponen: Jumlah bacaan, Arab, Latin, Terjemah, Riwayat, dan Faidah
- **Ibadah Menu Synchronization**: Sinkronisasi menu Ibadah antara mode Guest dan Member
  - Guest kini memiliki akses ke semua 9 fitur Ibadah (sebelumnya hanya 4)
  - Tampilan menu Guest diperbarui menggunakan grid layout premium yang konsisten dengan mode Member
  - Penambahan route aman untuk Hadits, Dzikir, dan TV pada mode Guest

### Ditambahkan
- **Deploy Script Dev/Prod Mode**: Kedua script deploy (PowerShell & bash) mendukung mode DEV dan PROD
  - **PROD** (default): `--base-href /web/` — untuk `aplikasi.test/web/` dan `aplikasi.syathiby.id/web/`
  - **DEV**: `--base-href /aplikasi/web/` — untuk akses via IP `192.168.50.100/aplikasi/web/`
  - PowerShell: `.\deploy-web.ps1` (prod) / `.\deploy-web.ps1 -Dev` (dev)
  - Bash: `bash ./deploy_web.sh` (prod) / `bash ./deploy_web.sh --dev` (dev)
  - Banner menampilkan mode dan base-href yang digunakan
- **Script Deploy Web (`deploy_web.sh`)**: Script bash untuk otomasi build dan deploy Flutter web
  - `bash ./deploy_web.sh` — build PROD + sync ke `../aplikasi/web/`
  - `bash ./deploy_web.sh --dev` — build DEV untuk akses via IP
  - `bash ./deploy_web.sh --skip-build` — sync saja tanpa build ulang
  - `bash ./deploy_web.sh --commit "pesan"` — build + sync + git commit & push otomatis
  - Auto-detect path FVM di Windows (Git Bash compatible)

### Detail Teknis
- **File yang Dimodifikasi**:
  - `pubspec.yaml`: `color`/`color_dark` → `#000000`, `web: false` → `web: true`
  - `assets/images/syathiby_splash_1152.png`: Background diinvert hitam→putih, ditambah rounded corners
  - `web/index.html`: Ditambahkan splash screen markup oleh flutter_native_splash
  - `web/splash/`: Folder baru berisi CSS dan gambar splash untuk web
  - `deploy_web.sh`: Script deploy bash baru (dev/prod mode, auto-detect FVM)
  - `deploy-web.ps1`: v1.0.8→v1.1.0 — ditambah flag `-Dev` untuk mode DEV
- **Perintah Regenerasi Splash**: `fvm dart run flutter_native_splash:create`
- **Perintah Build Web**:
  - PROD: `fvm flutter build web --base-href /web/ --release`
  - DEV: `fvm flutter build web --base-href /aplikasi/web/ --release`

## [1.0.7] - 2026-03-10

### Ditambahkan
- **Mode Tamu Versi Web**: Mode tamu sekarang berfungsi penuh pada platform web
  - Halaman awal: `/guest-news` (Feed berita dapat diakses tanpa login)
  - Guest Shell dengan 3 tab: Berita, Ibadah, Pengguna (Login)
  - Integrasi berita WordPress berjalan lancar di web
  - Fitur jadwal shalat, Quran, dan Qibla dapat diakses di mode tamu
- **Penanganan Error Routing Web**: Peningkatan penanganan error untuk route yang tidak dikenal
  - Ditambahkan `errorBuilder` di GoRouter untuk redirect URL tidak valid ke mode tamu
  - Handler route lama: `/login` otomatis redirect ke `/auth/login`
  - Redirect di level server via `.htaccess` untuk URL lama yang di-cache/bookmark
- **Tools Deploy Web**: Tools otomasi dan verifikasi deployment baru
  - `deploy-web.ps1`: Script PowerShell untuk build otomatis dengan verifikasi
  - `version.json`: Endpoint untuk verifikasi versi setelah deployment
  - `WEB_DEPLOYMENT_GUIDE.md`: Panduan lengkap troubleshooting deployment
  - `build-info.json`: Metadata build yang di-generate otomatis dengan timestamp
- **Auto-Copy Build ke Folder Lokal**: `deploy-web.ps1` sekarang menawarkan copy otomatis hasil build
  - Setelah build selesai, script menanyakan apakah ingin langsung copy ke `../aplikasi/web/`
  - File `htaccess` otomatis di-rename menjadi `.htaccess` di folder tujuan
  - Menghilangkan langkah copy manual setiap kali build
- **Setup Testing Lokal Laragon**: Konfigurasi multi-environment untuk testing sebelum deploy ke production
  - File `C:/laragon/www/.htaccess` merewrite `/web/*` ke `/aplikasi/web/*` untuk akses lokal
  - Memungkinkan akses `localhost/aplikasi/web/` dengan base-href `/web/` yang sama seperti production
  - Rekomendasi: akses via `http://aplikasi.test/web/` (Laragon auto virtual host, tanpa perlu rewrite)
  - File template `aplikasi/web/htaccess_xampp_root` tersedia untuk referensi dan XAMPP users
- **Cache-Control Headers pada `.htaccess`**: Penambahan header cache untuk mencegah browser/service worker memuat aset lama
  - File kritis (`flutter_service_worker.js`, `flutter_bootstrap.js`, `index.html`, `version.json`) diberi `Cache-Control: no-store`
  - Aset statis (JS, WASM, gambar, font) diberi `Cache-Control: public, max-age=31536000`
  - Diterapkan di `flutter_syathiby/web/htaccess` (source) dan `aplikasi/web/htaccess` (destination)
- **Notifikasi Changelog untuk Web**: Sistem notifikasi "Apa yang Baru" khusus platform web
  - Platform web mendapat modal changelog otomatis setelah deployment versi baru
  - Tracking versi menggunakan localStorage (last seen version)
  - Modal tampil otomatis saat first visit atau version berubah
  - Konten changelog di-fetch dari GitHub CHANGELOG.md (sama seperti native app)
  - Button "Mengerti" untuk menutup modal dan menandai changelog sudah dibaca
  - Mengatasi masalah web users tidak tahu sudah ada update apa karena file langsung di-replace

### Diubah
- **Arsitektur Deployment Web**: Migrasi Flutter web dari `mobile.syathiby.id` ke `aplikasi.syathiby.id/web/`
  - Flutter web di-deploy sebagai subfolder `/web/` di bawah `aplikasi.syathiby.id`
  - Arsitektur same-origin menghilangkan semua masalah CORS antara Flutter web dan backend
  - Root `.htaccess` redirect `aplikasi.syathiby.id/` → `/web/`
  - Build command sekarang wajib pakai `--base-href /web/`
- **WordPress Proxy URL Rewriting**: Ganti regex yang rusak dengan `str_replace`
  - Regex sebelumnya gagal pada escaped slashes (`\/`) dan `\"` di field HTML content
  - Pendekatan baru pakai prefix replacement — aman untuk semua konteks JSON
- **Production URL Paths**: Perbaikan path proxy untuk production server
  - WordPress proxy: `/geten/wordpress_proxy.php` (hapus prefix `/aplikasi/`)
  - Image proxy: `/wordpress_images.php` (hapus prefix `/aplikasi/`)
  - Path localhost tidak berubah: `localhost/aplikasi/...`
- **Dokumentasi Build Web**: Update README dengan panduan lengkap deployment web
  - Ditambahkan instruksi membersihkan cache browser
  - Section troubleshooting untuk pembersihan localStorage
  - Konfigurasi `.htaccess` untuk routing SPA yang benar
- **Strategi Cache Web**: Peningkatan kontrol cache untuk deployment
  - File HTML dan JSON: Header no-cache (selalu fresh)
  - Asset statis (JS/CSS/gambar): Cache jangka panjang dengan versioning berbasis hash
  - Mencegah tampilan "versi lama" setelah deployment
  - Kontrol cache di level server via header `.htaccess`
- **Interaksi Tombol Absensi**: Tampilan tombol `Absen Masuk/Pulang` dibuat lebih compact, elegan, dan responsif
  - Ukuran tombol diperkecil agar proporsional di layar mobile
  - Transisi tap diperhalus dengan animasi premium yang tetap cepat
  - Label loading dinamis ditampilkan sesuai mode (`Absen masuk...` / `Absen pulang...`)
- **Feedback Saat Fetch Status Absensi**: Ditambahkan state loading di tombol saat menunggu pembaruan status masuk/pulang
  - Tombol terkunci sementara untuk mencegah double tap
  - Durasi minimum animasi dijaga singkat agar UX terasa halus namun cepat
  - Refresh data profil/presensi disinkronkan sebelum tombol kembali idle
- **Strategi Rendering Detail Berita per Platform**: Penyesuaian perilaku `WpPostDetailScreen` antara web dan mobile
  - **Web**: Memuat URL artikel WordPress langsung dari response (`post.link`) menggunakan request URL pada WebView
  - **Android/iOS (APK)**: Mengembalikan alur rendering HTML rich content seperti sebelumnya (`initialData`)
  - **Fallback Web**: Jika `post.link` kosong/tidak valid, otomatis fallback ke rendering HTML
  - Tujuan: menjaga stabilitas mobile sambil mengurangi kasus blank/hitam pada embed video di web

### Diperbaiki
- **Ikon Lama di Flutter Web Setelah Build Ulang**: Tampilan web tetap menampilkan ikon kotak (versi lama) meski sudah build ulang berkali-kali
  - **Masalah**: `flutter_service_worker.js` ter-cache oleh browser. Service worker lama tetap aktif dan menyajikan aset lama
  - **Penyebab**: Tidak ada `Cache-Control` header di `.htaccess` sehingga browser meng-cache `flutter_service_worker.js` tanpa batas waktu
  - **Solusi**: Tambahkan `Cache-Control: no-store` untuk semua file kritis di `.htaccess` (service worker, bootstrap, index.html, version.json)
  - **Cara verifikasi**: Buka tab incognito setelah deploy ulang — tampilan harus langsung menampilkan versi terbaru
- **Build Command Tanpa `--base-href`**: `deploy-web.ps1` sebelumnya build web tanpa flag `--base-href /web/`
  - **Masalah**: Flutter web berjalan di `aplikasi.syathiby.id/web/` (subfolder), tanpa `--base-href /web/` semua request aset gagal
  - **Solusi**: Flag `--base-href /web/` ditambahkan permanen di `deploy-web.ps1`
- **Flutter Web Blank Putih di Lokal (`localhost/aplikasi/web/`)**: Halaman Flutter web tidak tampil sama sekali saat diakses lewat XAMPP/Laragon
  - **Masalah**: Flutter dengan `<base href="/web/">` meminta aset dari `localhost/web/...` padahal folder ada di `localhost/aplikasi/web/...`
  - **Solusi**: Tambahkan `C:/laragon/www/.htaccess` yang merewrite `/web/*` ke `/aplikasi/web/*` untuk environment lokal
  - **Alternatif lebih bersih**: Akses via `http://aplikasi.test/web/` (Laragon auto virtual host, tidak butuh rewrite apapun)
- **Video Embed di Detail Berita Flutter Web**: Perbaikan video/iframe tidak bisa diputar di halaman detail berita
  - **Masalah**: Video embed (YouTube, iframe) tidak tampil normal dan area konten menjadi hitam pada web
  - **Penyebab**: Pendekatan render HTML mentah di WebView tidak stabil di browser untuk konten embed tertentu
  - **Solusi**: Ubah detail berita WordPress agar memuat URL artikel langsung dari response (`post.link`) ke WebView
  - **Benefit**:
    - Konten artikel dan embed mengikuti rendering native situs sumber
    - Mengurangi risiko blank/black area saat memuat iframe video
    - Implementasi lebih sederhana karena memanfaatkan URL final dari WordPress
  - **File yang Dimodifikasi**: `lib/presentation/wordpress/wp_post_detail_screen.dart`
- **CORS pada Flutter Web**: Gambar dari `syathiby.id` diblokir oleh browser CORS policy
  - **Masalah**: `Image.network` di Flutter Web (CanvasKit) pakai XMLHttpRequest yang enforce CORS
  - **Penyebab**: URL gambar WordPress tidak di-rewrite ke proxy
  - **Solusi**: Arsitektur same-origin + `str_replace` URL rewriting di PHP proxy + Dart-side fallback
- **JSON Parse Error di WordPress Proxy**: Perbaikan broken JSON response dari proxy
  - **Masalah**: `SyntaxError: Expected ',' or '}' after property value in JSON`
  - **Penyebab**: Regex menangkap `\` dari `\"` (escaped quotes di HTML content dalam JSON)
  - **Solusi**: Ganti regex dengan `str_replace` pada URL prefix saja
- **Masalah Cache Deployment Web**: Perbaikan web menampilkan versi lama setelah upload
  - **Masalah**: Versi web menampilkan 1.0.4 padahal sudah build dan upload 1.0.6
  - **Gejala**: 
    - Teks "ENV" masih terlihat di layar login (harusnya hanya muncul di LOCAL flavor)
    - Mode tamu tidak muncul (routing lama)
    - Nomor versi tidak update
  - **Penyebab**: Browser cache dan server cache masih menyajikan asset lama
  - **Solusi**: 
    - Ditambahkan header no-cache untuk index.html dan version.json
    - Dibuat endpoint verifikasi deployment (version.json)
    - Wajib hapus file lama sebelum upload yang baru
    - Disediakan script otomasi deployment dengan pengecekan
  - **Persyaratan Deployment**:
    1. Hapus semua file lama di server sebelum upload
    2. Upload semua file dari `build/web/` 
    3. Bersihkan server cache (Cloudflare/cPanel/Nginx)
    4. Verifikasi endpoint `version.json` menampilkan versi yang benar
    5. Bersihkan cache browser atau gunakan mode incognito
  - **File yang Dimodifikasi**:
    - `web/index.html`: Ditambahkan meta tag no-cache
    - `web/.htaccess`: Header Cache-Control untuk HTML/JSON vs asset
    - `deploy-web.ps1`: Script build dan verifikasi otomatis
    - `WEB_DEPLOYMENT_GUIDE.md`: Checklist deployment step-by-step
- **Crash Animasi Tombol Absensi**: Perbaikan error `SingleTickerProviderStateMixin` saat multiple ticker aktif
  - **Masalah**: `Elegant3DButtonState` membuat lebih dari satu `AnimationController`
  - **Penyebab**: Menggunakan `SingleTickerProviderStateMixin` untuk lebih dari satu ticker
  - **Solusi**: Mengganti ke `TickerProviderStateMixin` agar semua controller animasi valid

### Perbedaan Platform

**⚠️ Penting**: Meskipun APK dan Web berbagi nomor versi yang sama, beberapa fitur bekerja berbeda karena keterbatasan platform:

#### 🔔 **Notifikasi Push**
- **APK**: ✅ Dukungan penuh Firebase Cloud Messaging dengan notifikasi background
- **Web**: ❌ Dinonaktifkan (inisialisasi Firebase dilewati untuk kompatibilitas Safari)
  - Tidak ada notifikasi push pada versi web
  - Pesan background service worker tidak diimplementasikan

#### 📍 **Lokasi & Izin**
- **APK**: ✅ Permintaan izin native dengan opsi "Buka Pengaturan"
  - GPS penuh dan akurasi lokasi
  - Absensi berbasis Wi-Fi didukung
- **Web**: ⚠️ API geolokasi browser terbatas
  - Dialog izin menampilkan "Mengerti" bukan "Buka Pengaturan"
  - Browser harus memberikan izin lokasi secara manual
  - Mungkin memiliki akurasi GPS lebih rendah tergantung device/browser
  - Deteksi IP Wi-Fi bekerja tapi tergantung header IP server

#### 🔐 **Autentikasi Biometrik**
- **APK**: ✅ Sidik jari dan Face Unlock didukung
- **Web**: ❌ Tidak tersedia (tidak ada implementasi Web Authentication API browser)

#### 📱 **Fitur Native**
- **APK**: 
  - ✅ Scanner barcode/QR
  - ✅ Akses kamera untuk foto
  - ✅ Akses sistem file lokal
  - ✅ Layanan background
- **Web**:
  - ⚠️ Kamera berbasis browser (terbatas)
  - ⚠️ Download file saja (tidak ada akses sistem file langsung)
  - ❌ Tidak ada layanan background

#### 🌐 **Konektivitas**
- **APK**: ✅ Berfungsi offline dengan caching database lokal
- **Web**: ⚠️ Memerlukan koneksi internet (tidak ada mode offline)

#### 🎨 **Pengalaman Pengguna**
- **APK**: UI native yang bersih dengan integrasi sistem
- **Web**: Desain web responsif, bekerja di semua device dengan browser

#### ✅ **Fitur Tersedia di Kedua Platform**
- ✅ Mode Tamu (Berita, Shalat, Quran)
- ✅ Login & Autentikasi
- ✅ Feed Berita WordPress
- ✅ Waktu Shalat & Qibla
- ✅ Absensi (dengan keterbatasan di web)
- ✅ Manajemen Staff
- ✅ Laporan & Analitik
- ✅ Tema Gelap/Terang

**Rekomendasi**: 
- **Gunakan APK** untuk staff dengan kebutuhan absensi harian dan memerlukan notifikasi push
- **Gunakan Web** untuk akses sesekali, melihat laporan, atau device tanpa akses Play Store

### Detail Teknis
- **File yang Dimodifikasi**:
  - `aplikasi/.htaccess`: Redirect root → `/web/`, skip folder `web/` dari PHP rules
  - `aplikasi/geten/wordpress_proxy.php`: Perbaikan image URL rewriting dengan `str_replace`
  - `lib/models/service_injection.dart`: Update production WordPress proxy URL
  - `lib/models/wordpress/wp_post.dart`: Update production image proxy URL
  - `web/.htaccess`: Hapus legacy `/login` redirect, aturan URL rewrite di level server untuk routing SPA
  - `lib/routing/app_router.dart`: Ditambahkan error handler dan legacy route redirect
  - `README.md`: Dokumentasi deployment dan troubleshooting web
- **Perintah Build**: `fvm flutter build web --release --base-href /web/ --tree-shake-icons`
- **Arsitektur**: `aplikasi.syathiby.id/web/` (Flutter) + `aplikasi.syathiby.id/geten/` (API) = same origin, no CORS
- **Deteksi Platform**: Menggunakan konstanta `kIsWeb` untuk mengaktifkan fitur secara kondisional
- **File yang Dimodifikasi (update 2026-03-10)**:
  - `web/htaccess`: Tambah Cache-Control headers (no-store untuk file kritis, long-term untuk aset)
  - `aplikasi/web/htaccess`: Sinkron dengan `web/htaccess`
  - `deploy-web.ps1`: Tambah `--base-href /web/`, auto-copy ke `../aplikasi/web/`, rename htaccess ke .htaccess
  - `C:/laragon/www/.htaccess`: Rewrite `/web/*` ke `/aplikasi/web/*` untuk lokal
  - `aplikasi/web/htaccess_xampp_root`: Template rewrite untuk XAMPP/Laragon

## [1.0.5] - 2026-03-07

### Ditambahkan
- **Integrasi WordPress REST API**: Feed berita sekarang mengambil data dari situs WordPress syathiby.id
  - Implementasi WordPress REST API v2 service dengan Retrofit
  - Dibuat model `WpPost` dengan Freezed dan serialisasi JSON
  - Ditambahkan dukungan `YoastHeadJson` untuk thumbnail og_image yang dioptimasi SEO
  - Layer presentasi baru: `WpPostListItem` dan `WpPostDetailScreen`
  - Terintegrasi dengan layar Guest News dan Member News
- **Tampilan Konten Kaya**: Peningkatan layar detail berita
  - Menggunakan `InAppWebView` untuk rendering konten kaya
  - Mendukung media tertanam (YouTube, Instagram, Twitter, dll.)
  - Template HTML custom dengan desain responsif
  - Tampilan featured image di bagian atas artikel
- **Optimisasi Pemuatan Gambar**: Dukungan format WebP
  - Memprioritaskan Yoast SEO og_image (thumbnail yang dioptimasi dari `yoast_head_json`)
  - Fallback ke featured media dari data `_embedded`
  - Menggunakan `Image.network` native untuk kompatibilitas format WebP
  - Indikator loading progress dengan animasi halus
- **Peningkatan UI/UX**: Pengalaman membaca berita yang lebih baik
  - Animasi skeleton loading menggunakan paket Skeletonizer
  - Decoding HTML entity yang komprehensif (entitas numerik dan named)
  - Penanganan error dengan pesan diagnostik yang detail
  - Navigasi yang mulus antara list dan detail view

### Diubah
- **Sumber Data Berita**: Migrasi dari custom API ke WordPress REST API
  - Layar Guest News sekarang menggunakan endpoint posts WordPress
  - Layar Member News diupdate untuk menggunakan WordPress API
  - Mempertahankan UI yang konsisten sambil meningkatkan manajemen konten
- **Dependencies**: Update service injection dan provider
  - Ditambahkan `WpApiService` ke dependency injection
  - Registrasi WordPress services di `ServiceInjection`
  - Update konfigurasi routing untuk layar WordPress
- **Konfigurasi Branch Update Checker**: Implementasi pemilihan branch GitHub dinamis berdasarkan flavor
  - Fitur: UpdateChecker sekarang menggunakan branch spesifik environment untuk pengecekan versi
  - **Local flavor** (`--flavor local`): Mengecek branch `test` untuk rilis development
  - **Production flavor** (`--flavor prod`): Mengecek branch `dev` untuk rilis stable
  - Implementasi: Ditambahkan dependency `FlavorConfig` ke class `UpdateChecker`
  - Manfaat: Memungkinkan pengujian versi baru di branch `test` sebelum promosi ke `dev` untuk production
  - File: `lib/utils/update_checker.dart` — Mengubah `changelogUrl` dari konstanta statis ke dynamic getter

### Diperbaiki
- **Layar Kinerja**: Daftar performa (Tab "List Penilaian") tidak bisa di-scroll ke bawah
  - Dihapus `NeverScrollableScrollPhysics` dari `PagedListView` dan `ListView.builder`
  - Paginasi infinite scroll sekarang bekerja dengan benar untuk memuat halaman berikutnya
- **Absensi Shift Malam**: Perbaikan logika tombol untuk absensi yang melewati tengah malam
  - Masalah: Satpam dan pekerja shift malam yang absen masuk jam 23:00 dan absen pulang jam 07:00 melihat tombol yang salah
  - Yang diharapkan: Tombol "Absen Pulang" (Check Out) pada jam 07:00
  - Perilaku sebelumnya: Tombol "Absen Masuk" (Check In) muncul secara tidak benar
  - **Penyebab**: Backend hanya mengecek rekaman absensi untuk tanggal saat ini, melewatkan shift yang dimulai kemarin
  - **Solusi**: Modifikasi `detailstore.php` untuk mencari rekaman login dalam 36 jam terakhir bukan hanya tanggal saat ini
  - Sekarang menangani shift yang melewati tengah malam dengan benar (misal: 23:00 Hari 1 → 07:00 Hari 2)
  - Juga memperbaiki kalkulasi durasi kerja untuk shift malam
- **Label Absensi Tahfidz**: Perbaikan label dropdown yang tertukar antara Sakit dan Izin
  - Masalah: Ketika memilih "Sakit" di app, dashboard menampilkannya sebagai "Izin" dan sebaliknya
  - **Penyebab**: Label UI dropdown terbalik - value "sakit" memiliki label "Izin", value "izin" memiliki label "Sakit"
  - **Solusi**: Memperbaiki label dropdown di layar absensi tahfidz guru dan siswa
  - Sekarang "Sakit" tersimpan dengan benar sebagai "sakit" dan "Izin" tersimpan sebagai "izin"
  - Dashboard menampilkan hitungan dengan benar di kolom yang tepat (SAKIT, IZIN, ALFA)
- **Pemotongan Teks Notifikasi**: Perbaikan pesan sukses dan error yang terpotong
  - Masalah: Pesan notifikasi panjang seperti "Anda sudah melakukan absen masuk dan absen keluar hari ini. Absen berikutnya bisa dilakukan besok" terpotong
  - **Penyebab**: Widget Text notifikasi toast tidak memiliki constraint maxLines, menyebabkan pemotongan satu baris
  - **Solusi**: Ditambahkan `maxLines: 4` dengan `overflow: TextOverflow.visible` untuk menampilkan pesan lengkap
  - Meningkatkan durasi auto-close default dari 2 detik ke 3 detik untuk pesan sukses, 3 detik ke 4 detik untuk error
  - Pesan sekarang membungkus ke beberapa baris dan ditampilkan sepenuhnya
- **Masalah Pemuatan Thumbnail**: Mengatasi masalah tampilan gambar
  - Perbaikan mapping field: og_image dipindah dari root ke `yoast_head_json.og_image`
  - Mengatasi korupsi database cache SQLite (beralih ke Image.network)
  - Format WebP sekarang sepenuhnya didukung tanpa masalah cache
- **Tampilan HTML Entity**: Semua HTML entity didecode dengan benar
  - Entitas numerik (&#8217;, &#038;, dll.)
  - Entitas named (&amp;, &lt;, &gt;, &quot;, dll.)
  - Hellip dan karakter spesial lainnya ([&hellip;], [...])

### Dihapus
- **Model Berita Lama**: Diganti dengan model WordPress
  - Dihapus service dan model berita lama
  - File backup disimpan untuk referensi (*.backup)

### Detail Teknis
- **File Integrasi WordPress**:
  - **API Endpoint**: `https://syathiby.id/wp-json/wp/v2/posts?_embed=true`
  - **Strategi Prioritas Gambar**:
    1. Yoast SEO og_image: `yoast_head_json.og_image[0].url` (WebP dioptimasi SEO)
    2. Featured media: `_embedded['wp:featuredmedia'][0].source_url`
  - **Model yang Dibuat**:
    - `WpPost`: Model post utama dengan title, content, excerpt, featured_media
    - `WpEmbedded`: Container untuk embedded resources
    - `WpFeaturedMedia`: Featured media dengan source_url dan media_details
    - `YoastHeadJson`: Container metadata Yoast SEO
    - `OgImage`: Open Graph image dengan width, height, url, type
  - **Presentation Layer**:
    - `WpPostsController`: Riverpod controller untuk mengambil posts
    - `WpPostListItem`: Widget list item dengan featured image dan excerpt
    - `WpPostDetailScreen`: Tampilan artikel lengkap dengan rendering WebView
  - **Dependencies Flutter**:
    - `retrofit` + `dio`: REST API client
    - `freezed` + `json_serializable`: Generasi model
    - `flutter_inappwebview`: Tampilan konten kaya
    - `cached_network_image`: Caching gambar (diganti dengan Image.network untuk dukungan WebP)
    - `skeletonizer`: Animasi loading

- **Update Sistem Absensi**:
  - **File Backend yang Dimodifikasi**: `aplikasi/geten/settings/detailstore.php`
  - **Perubahan**:
    - Query login absensi sekarang menggunakan `date >= '$yesterday'` bukan `date = '$tanggal'`
    - Ditambahkan `ORDER BY date DESC, hour DESC LIMIT 1` untuk mendapat login terbaru
    - Query login dan logout keduanya diupdate untuk mendukung lookback window 36 jam
  - **Dampak**: Mempengaruhi semua pengguna dengan shift malam (satpam, supervisor malam, dll.)
  - **File Flutter yang Dimodifikasi untuk Tahfidz**: 
    - `lib/presentation/presensi_tahfidz/tahfidz_teacher_presence_screen.dart`
    - `lib/presentation/presensi_tahfidz/tahfidz_presence_list_screen.dart`
  - **Perubahan**: Memperbaiki label DropdownMenuItem agar sesuai dengan nilainya (Sakit ↔ sakit, Izin ↔ izin)
  - **File Backend yang Dimodifikasi untuk Normalisasi Status**:
    - `aplikasi/geten/siswa/absenpengamputahfidz.php` (absensi tahfidz guru)
    - `aplikasi/geten/siswa/absentahfidz.php` (absensi tahfidz siswa)
  - **Perubahan**: Ditambahkan `$status_key = strtolower(trim($status))` untuk normalisasi status sebelum disimpan ke database, memastikan penyimpanan lowercase yang konsisten (hadir, sakit, izin, alfa) sesuai query dashboard
  - **File Flutter yang Dimodifikasi untuk Tampilan Notifikasi**:
    - `lib/utils/extension/ui.dart`
  - **Perubahan**: 
    - Ditambahkan `maxLines: 4` dan `overflow: TextOverflow.visible` ke `showSuccessMessage` dan `showErrorMessage`
    - Meningkatkan `autoCloseDuration` untuk pesan sukses (2 detik → 3 detik) dan pesan error (3 detik → 4 detik)
    - Ditambahkan `fontSize: 14` eksplisit untuk keterbacaan yang lebih baik

## [1.0.4] - 2026-03-04

### Ditambahkan
- **Absensi Berbasis Wi-Fi**: Metode absensi baru menggunakan validasi IP publik (103.178.146.98)
  - Pengguna dapat memilih antara metode Lokasi (GPS) atau Wi-Fi saat melakukan absensi
  - Pre-validasi di aplikasi Flutter sebelum submit
  - Validasi backend menggunakan deteksi IP publik dari HTTP headers
  - Error code 03 untuk kegagalan validasi Wi-Fi
- **Indikator Environment**: Diferensiasi visual antara environment LOCAL dan PROD
  - Banner ribbon global menampilkan "LOCAL" (merah) atau "PROD" (hijau)
  - Nama aplikasi dinamis: "Syathiby LOCAL" saat menggunakan API lokal
  - Label environment dan tampilan URL API di layar login
  - Long-press logo di login untuk mengubah URL API
- **Android Product Flavors**: Dukungan instalasi side-by-side
  - Flavor `prod`: id.syathiby.app (Nama aplikasi: Syathiby)
  - Flavor `local`: id.syathiby.app.local (Nama aplikasi: Syathiby LOCAL)
  - Kedua flavor dapat diinstal bersamaan di device yang sama
- **Script Installer APK Ganda**: Script PowerShell (`install-both-apks.ps1`) untuk instalasi one-click
  - Validasi ADB dan device otomatis
  - Instalasi sekuensial APK local dan prod
  - Output status berwarna dengan pesan error yang jelas
- **Dokumentasi Tes**: Dibuat `ATTENDANCE_WIFI_TEST_CHECKLIST.md` untuk skenario testing
- **Standardisasi FVM**: Semua perintah Flutter sekarang menggunakan prefix `fvm` untuk konsistensi versi
- **Konfigurasi URL Berbasis Flavor**: Pemilihan URL otomatis berdasarkan build flavor
  - Dibuat `lib/res/flavor_config.dart` dengan konfigurasi built-in per flavor
  - Flavor `prod`: Otomatis menggunakan `https://aplikasi.syathiby.id`
  - Flavor `local`: Otomatis menggunakan `http://192.168.50.100/aplikasi`
  - Memerlukan `--dart-define=FLAVOR=xxx` di perintah build
  - Menghilangkan kebutuhan konfigurasi .env manual per build
  - Kompatibel mundur dengan penimpaan URL runtime (long-press logo)

### Diubah
- Pengiriman absensi sekarang menerima koordinat (0,0) untuk mengindikasikan mode Wi-Fi
- Backend melewati validasi radius GPS saat mode Wi-Fi terdeteksi dengan IP valid
- Update semua perintah build dan run di dokumentasi untuk menggunakan FVM
- `EnvironmentConfig` sekarang menggunakan `FlavorConfig` sebagai fallback default bukan `Env`
- Update semua perintah build dan run untuk menyertakan `--dart-define=FLAVOR=xxx`
- Dokumentasi setup yang disederhanakan dengan pendekatan flavor-first
- **Perilaku banner**: Sekarang hanya muncul untuk environment LOCAL (development)
  - Build PROD memiliki UI bersih tanpa banner environment
  - Membuat aplikasi production lebih profesional dan polished

### Dihapus
- **Legacy `env.dart` dan `env.g.dart`** - Diganti dengan konfigurasi berbasis flavor
- **`.env.example`** - Tidak lagi diperlukan, konfigurasi ada di `lib/res/flavor_config.dart`
- Dependency Envied dapat dihapus dari pubspec.yaml jika tidak diperlukan untuk keperluan lain

### Detail Teknis
- **Deteksi Mode Wi-Fi**: Koordinat (0,0) mengindikasikan absensi berbasis Wi-Fi
- **Urutan Deteksi IP**: HTTP_X_FORWARDED_FOR → HTTP_CLIENT_IP → REMOTE_ADDR
- **Deteksi Environment Lokal**: Mencocokkan rentang IP privat (192.168.x.x, 10.x.x.x, 172.16-31.x.x, localhost)
- **Endpoint Backend yang Dimodifikasi**: presence.php, presencenormal.php, presencefinger.php

### Perubahan Backend
- Ditambahkan fungsi `get_client_public_ip()` untuk mendeteksi IP publik sebenarnya
- Validasi Wi-Fi di endpoint absensi
- Error code 03 untuk penanganan error yang lebih baik di aplikasi

### Perubahan Flutter
- `lib/presentation/presence/presence_screen.dart`: Dialog pemilihan metode, validasi IP
- `lib/res/environment_config.dart`: Deteksi environment dan helper label
- `lib/res/strings.dart`: Nama aplikasi dinamis berdasarkan environment
- `lib/presentation/login/login_screen.dart`: Tampilan badge environment
- `lib/app.dart`: Widget banner global untuk indikasi environment
- `android/app/build.gradle.kts`: Konfigurasi product flavors
- `android/app/src/main/AndroidManifest.xml`: Placeholder label dinamis

## [1.0.0] - 2024-12-XX

### Ditambahkan
- Versi enhanced awal dari Syathiby Staff App
- Sistem absensi dengan validasi GPS dan radius
- Manajemen profil
- Sistem permintaan izin
- Tracking timeline dan aktivitas
- Dukungan multi-bahasa (Indonesia/Inggris)

### Teknis
- Flutter SDK dengan manajemen FVM
- GetX untuk state management
- Dio untuk HTTP client
- Geolocator untuk layanan lokasi

---

## Panduan Format Changelog

Gunakan kategori berikut untuk setiap perubahan:
- **Ditambahkan**: Fitur baru
- **Diubah**: Perubahan pada fitur yang sudah ada
- **Deprecated**: Fitur yang akan dihapus di versi mendatang
- **Dihapus**: Fitur yang dihapus
- **Diperbaiki**: Perbaikan bug
- **Keamanan**: Perbaikan terkait keamanan

### Contoh Entry Baru

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Ditambahkan
- Fitur A: deskripsi singkat
- Fitur B: deskripsi singkat

### Diperbaiki
- Bug pada layar X
- Crash saat melakukan Y
```
