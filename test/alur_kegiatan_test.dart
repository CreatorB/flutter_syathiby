import 'package:flutter_test/flutter_test.dart';
import 'package:syathiby/utils/alur_kegiatan.dart';

void main() {
  group('jenis kegiatan', () {
    test('perbaikan dan jasa memakai alur tim maintenance', () {
      expect(isAlurTim('Perbaikan'), isTrue);
      expect(isAlurTim('Jasa'), isTrue);
      expect(isAlurTim('Pengadaan Barang'), isFalse);
      expect(isAlurPengadaan('Pengadaan Barang'), isTrue);
      expect(isAlurPengadaan('Perbaikan'), isFalse);
    });

    test('hanya Perbaikan yang tanpa nominal', () {
      expect(isJenisPerbaikan('Perbaikan'), isTrue);
      expect(isJenisPerbaikan('Jasa'), isFalse);
      expect(jenisTanpaNominal('Perbaikan'), isTrue);
      expect(jenisTanpaNominal('Jasa'), isTrue);
      expect(jenisTanpaNominal('Pengadaan Barang'), isFalse);
    });

    test('nama tim sesuai jenis', () {
      expect(namaTimUntukJenis('Perbaikan'), namaTimMaintenance);
      expect(namaTimUntukJenis('Jasa'), namaTimMaintenance);
      expect(namaTimUntukJenis('Pengadaan Barang'), namaTimKeuangan);
    });
  });

  group('label status', () {
    test('status alur tim punya label sendiri', () {
      expect(labelStatus('pengajuan'), 'Menunggu ACC Atasan');
      expect(labelStatus('dikerjakan maintenance'), 'Dikerjakan Tim Maintenance');
      expect(labelStatus('diselesaikan'), 'Selesai');
      expect(labelStatus('ditolak'), 'Ditolak');
    });

    test('status kosong tidak error', () {
      expect(labelStatus(null), 'Pengajuan');
      expect(labelStatus(''), 'Pengajuan');
    });
  });

  group('progress alur', () {
    test('alur perbaikan enam langkah', () {
      expect(langkahAlur('Perbaikan').length, 6);
      expect(langkahAlur('Perbaikan').first.status, 'pengajuan');
    });

    test('alur pengadaan lima langkah', () {
      expect(langkahAlur('Pengadaan Barang').length, 5);
      expect(langkahAlur('Pengadaan Barang').first.status, 'pengajuan');
    });

    test('posisi status menentukan langkah berjalan', () {
      final perbaikan = progressAlur('Perbaikan', 'disetujui mudir');
      expect(perbaikan.index, 2);
      expect(perbaikan.total, 6);
      expect(perbaikan.selesai, isFalse);
      expect(perbaikan.nilai, closeTo(3 / 6, 0.001));
    });

    test('status terakhir berarti selesai', () {
      final selesai = progressAlur('Pengadaan Barang', 'diselesaikan');
      expect(selesai.selesai, isTrue);
      expect(selesai.index, langkahAlur('Pengadaan Barang').length - 1);
    });

    test('status ditolak ditandai khusus', () {
      final ditolak = progressAlur('Perbaikan', 'ditolak');
      expect(ditolak.ditolak, isTrue);
      expect(ditolak.selesai, isFalse);
    });

    test('status di luar alur tidak error', () {
      final asing = progressAlur('Perbaikan', 'entah');
      expect(asing.index, 0);
      expect(asing.total, 6);
    });
  });
}
