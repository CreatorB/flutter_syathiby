import 'package:flutter_test/flutter_test.dart';
import 'package:syathiby/models/transaction/detail_transaction.dart';
import 'package:syathiby/models/transaction/petugas_pengajuan.dart';
import 'package:syathiby/models/transaction/request_transaction.dart';

void main() {
  test('PetugasPengajuan membaca atasan dan daftar tim perbaikan', () {
    final result = PetugasPengajuan.fromJson({
      'atasan': '0811',
      'atasan_nama': 'Muliadi',
      'atasan_otomatis': 0,
      'tim': [
        {
          'id': 3,
          'nama': 'Tim Maintenance',
          'anggota': [
            {'telp': '0822', 'nama': 'Budi'},
            {'telp': '0833', 'nama': 'Andi'},
          ],
        },
      ],
    });
    expect(result.atasanNama, 'Muliadi');
    expect(result.atasanOtomatis, 0);
    final tim = result.tim!.single;
    expect(tim.id, 3);
    expect(tim.nama, 'Tim Maintenance');
    expect(tim.anggota?.map((e) => e.nama), ['Budi', 'Andi']);
  });

  test('Tim tanpa anggota tetap terbaca', () {
    final result = PetugasPengajuan.fromJson({
      'atasan_otomatis': 1,
      'tim': [
        {'id': 1, 'nama': 'Tim Listrik', 'anggota': <dynamic>[]},
      ],
    });
    expect(result.atasanOtomatis, 1);
    expect(result.tim?.single.anggota, isEmpty);
  });

  test('Detail perbaikan tanpa barang dengan tim dan daftar aksi', () {
    final result = DetailTransaction.fromJson({
      'struk': {
        'jeniskegiatan': 'Perbaikan',
        'level': 'Maintenance',
        'atasan': '0811',
        'atasan_nama': 'Muliadi',
        'atasan_otomatis': 0,
        'tim': 'Tim Maintenance',
        'petugas': [
          {'telp': '0822', 'nama': 'Budi'},
        ],
        'aksi': ['confirm_maintenance'],
      },
      'data': <dynamic>[],
    });
    expect(result.data, isEmpty);
    expect(result.struk?.aksi, ['confirm_maintenance']);
    expect(result.struk?.tim, 'Tim Maintenance');
    expect(result.struk?.petugas?.single.nama, 'Budi');
  });

  test('Server lama tanpa field aksi dan tim menghasilkan null', () {
    final result = Struk.fromJson({'jeniskegiatan': 'Barang'});
    expect(result.aksi, isNull);
    expect(result.tim, isNull);
  });

  test('Field id_tim hanya dikirim bila diisi', () {
    const barang = RequestTransaction(key: 'k', jenisKegiatan: 'Barang');
    expect(barang.toJson().containsKey('id_tim'), isFalse);
    expect(barang.toJson().containsKey('petugas'), isFalse);

    const perbaikan = RequestTransaction(
      key: 'k',
      jenisKegiatan: 'Perbaikan',
      product: [],
      idTim: 3,
    );
    final json = perbaikan.toJson();
    expect(json['id_tim'], 3);
    expect(json.containsKey('petugas'), isFalse);
    expect(json['product'], isEmpty);
  });
}
