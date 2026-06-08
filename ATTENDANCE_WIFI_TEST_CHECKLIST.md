# Attendance Wi-Fi Test Checklist

Checklist ini untuk verifikasi fitur pilihan metode absen: **Location / Wi-Fi**.

## Prasyarat
- Build app terbaru sudah terpasang.
- Endpoint backend terbaru sudah deploy (folder `aplikasi/geten/attendance`).
- Public IP Wi-Fi ma'had: `103.178.146.98`.
- Akun user punya jadwal kerja aktif hari ini.

## Skenario 1 — Absen via Location (Sukses)
1. Buka menu Absen.
2. Pilih lokasi asrama.
3. Pilih metode **Location**.
4. Izinkan akses GPS jika diminta.
5. Lanjutkan proses absen sampai submit.

**Ekspektasi:**
- Absen berhasil (`ontime`/`late`) sesuai aturan jam.
- Tidak ada error terkait Wi-Fi/IP.

## Skenario 2 — Absen via Wi-Fi dengan IP SALAH (Harus Gagal)
1. Pindah ke jaringan non-ma'had (misalnya hotspot pribadi).
2. Buka menu Absen.
3. Pilih lokasi asrama.
4. Pilih metode **Wi-Fi**.
5. Submit absen.

**Ekspektasi:**
- Absen ditolak.
- Muncul pesan: pastikan menggunakan Wi-Fi ma'had (IP publik harus `103.178.146.98`).
- Data attendance **tidak** tersimpan.

## Skenario 3 — Absen via Wi-Fi dengan IP BENAR (Sukses)
1. Sambungkan perangkat ke Wi-Fi ma'had.
2. Buka menu Absen.
3. Pilih lokasi asrama.
4. Pilih metode **Wi-Fi**.
5. Submit absen.

**Ekspektasi:**
- Absen berhasil (`ontime`/`late`) walau GPS perangkat bermasalah.
- Validasi location radius di-skip khusus mode Wi-Fi valid.

## Verifikasi Data Backend
- Cek record baru pada tabel `attendance` untuk user dan tanggal hari ini.
- Untuk mode Wi-Fi, nilai `latitude` dan `longitude` tersimpan `0`/`0`.
- Untuk mode Location, nilai `latitude` dan `longitude` tersimpan koordinat real.

## Catatan Teknis
- Validasi IP dilakukan 2 lapis:
  - Flutter pre-check (public IP lookup).
  - Backend final-check (anti bypass).
- Jika server di belakang proxy/CDN, pastikan `HTTP_X_FORWARDED_FOR` mengandung IP client yang benar.
