import 'package:flutter_test/flutter_test.dart';
import 'package:syathiby/models/transaction/history_transaction.dart';
import 'package:syathiby/models/transaction/transaction.dart';

void main() {
  test('totalprice diterima sebagai angka maupun teks', () {
    final angka = Transaction.fromJson(const {
      'no_invoice': 'URA-0001',
      'status': 'disetujui mudir',
      'jeniskegiatan': 'Pengadaan Barang',
      'totalprice': 30000,
    });
    expect(angka.totalPrice, 30000);

    final teks = Transaction.fromJson(const {
      'no_invoice': 'URA-0002',
      'status': 'disetujui mudir',
      'jeniskegiatan': 'Perbaikan',
      'totalprice': '0.00',
    });
    expect(teks.totalPrice, 0);
  });

  test('riwayat pengajuan terbaca dengan detail', () {
    final riwayat = HistoryTransaction.fromJson(const {
      'date': '2026-11-16',
      'totalorderall': '30000.00',
      'detail': [
        {
          'no_invoice': 'URA-0001',
          'status': 'disetujui mudir',
          'jeniskegiatan': 'Pengadaan Barang',
          'pemohon': 'Uji Riwayat Alur',
          'totalprice': '30000.00',
          'tujuan': 'Kebutuhan kelas',
          'id_tim': 42,
          'nama_tim': 'Keuangan',
        },
      ],
    });
    expect(riwayat.detail?.length, 1);
    final item = riwayat.detail!.first;
    expect(item.namaTim, 'Keuangan');
    expect(item.tujuan, 'Kebutuhan kelas');
    expect(item.totalPrice, 30000);
    expect(item.idTim, 42);
  });

  test('totalpay diterima sebagai angka maupun teks kosong', () {
    final angka = Transaction.fromJson(const {
      'no_invoice': 'UP-0001',
      'status': 'pengajuan',
      'totalpay': 0,
    });
    expect(angka.totalPay, 0);

    // Server lama mengirim "" (teks kosong) -> harus tetap terparse.
    final teks = Transaction.fromJson(const {
      'no_invoice': 'UP-0002',
      'status': 'pengajuan',
      'totalpay': '',
    });
    expect(teks.totalPay, isNull);
  });
}
