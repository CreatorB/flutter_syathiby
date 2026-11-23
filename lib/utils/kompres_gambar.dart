import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Sisi terpanjang maksimum (piksel) untuk gambar yang diunggah.
///
/// Foto HP modern 4000-6000 piksel tidak perlu dikirim penuh. Server menyimpan
/// maksimal 1600 piksel, jadi mengirim lebih besar hanya membuang kuota dan
/// waktu unggah -- dan membuat server menyimpan berkas yang lebih besar.
const int sisiMaksUnggah = 1600;

/// Mutu kompresi (0-100).
///
/// Angka 80 memberi berkas sekitar sepuluh kali lebih kecil dari foto HP
/// aslinya, sementara mutu gambarnya masih jelas untuk bukti dan
/// dokumentasi.
const int mutuUnggah = 80;

/// Kompres gambar sebelum dikirim ke server.
///
/// [bytes] adalah isi berkas hasil ambil dari galeri atau kamera. Hasilnya
/// sudah dikecilkan ke [sisiMaks] piksel terpanjang dan dikompresi dengan
/// [mutu]. Format PNG dipertahankan supaya area transparan (logo, tanda
/// tangan) tidak berubah jadi kotak hitam; selain itu hasilnya JPEG.
///
/// Kalau kompresi gagal, berkas asli dikembalikan -- lebih baik berkas besar
/// terkirim daripada unggahan gagal.
Future<Uint8List> kompresGambarUntukUnggah(
  Uint8List bytes, {
  int sisiMaks = sisiMaksUnggah,
  int mutu = mutuUnggah,
}) async {
  if (bytes.isEmpty) {
    return bytes;
  }

  final png = _adakahPng(bytes);
  try {
    final hasil = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: sisiMaks,
      minHeight: sisiMaks,
      quality: mutu,
      format: png ? CompressFormat.png : CompressFormat.jpeg,
      keepExif: false,
    );
    if (hasil.isEmpty) {
      return bytes;
    }
    return Uint8List.fromList(hasil);
  } catch (_) {
    return bytes;
  }
}

/// Deteksi PNG dari tanda tangan berkas (8 byte pertama).
bool _adakahPng(Uint8List bytes) {
  if (bytes.length < 8) {
    return false;
  }
  return bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47;
}
