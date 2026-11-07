import 'package:flutter_test/flutter_test.dart';
import 'package:syathiby/models/transaction/detail_transaction.dart';
import 'package:syathiby/models/transaction/petugas_pengajuan.dart';
import 'package:syathiby/models/transaction/request_transaction.dart';

void main() {
  test('PetugasPengajuan membaca atasan dan daftar petugas', () {
    final result = PetugasPengajuan.fromJson({
      'atasan': '0811',
      'atasan_nama': 'Muliadi',
      'atasan_otomatis': 0,
      'petugas': [
        {'telp': '0822', 'nama': 'Budi'},
      ],
    });
    expect(result.atasanNama, 'Muliadi');
    expect(result.atasanOtomatis, 0);
    expect(result.petugas?.single.telp, '0822');
  });

  test('Detail perbaikan tanpa barang dengan daftar aksi', () {
    final result = DetailTransaction.fromJson({
      'struk': {
        'jeniskegiatan': 'Perbaikan',
        'level': 'Maintenance',
        'atasan': '0811',
        'atasan_nama': 'Muliadi',
        'atasan_otomatis': 1,
        'petugas': [
          {'telp': '0822', 'nama': 'Budi'},
        ],
        'aksi': ['confirm_maintenance'],
      },
      'data': <dynamic>[],
    });
    expect(result.data, isEmpty);
    expect(result.struk?.aksi, ['confirm_maintenance']);
    expect(result.struk?.petugas?.single.nama, 'Budi');
  });

  test('Server lama tanpa field aksi menghasilkan null', () {
    final result = Struk.fromJson({'jeniskegiatan': 'Barang'});
    expect(result.aksi, isNull);
  });

  test('Field petugas hanya dikirim bila diisi', () {
    const barang = RequestTransaction(key: 'k', jenisKegiatan: 'Barang');
    expect(barang.toJson().containsKey('petugas'), isFalse);

    const perbaikan = RequestTransaction(
      key: 'k',
      jenisKegiatan: 'Perbaikan',
      product: [],
      petugas: ['0822'],
    );
    final json = perbaikan.toJson();
    expect(json['petugas'], ['0822']);
    expect(json['product'], isEmpty);
  });
}
