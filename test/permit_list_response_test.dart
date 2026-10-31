// Uji parsing respons `permit/listsantri.php`.
//
// Backend mengirim objek `{status, errCode, msg, meta, data}`. Bagian `meta`
// dipakai layar Izin Santri untuk label tab (jumlah izin per status) dan
// untuk info lingkup sayap, jadi parsingnya harus benar.

import 'package:flutter_test/flutter_test.dart';
import 'package:syathiby/models/permit/permit.dart';

void main() {
  group('PermitListResponse', () {
    test('membaca daftar izin beserta meta jumlah per status', () {
      final json = <String, dynamic>{
        'status': 'true',
        'errCode': '01',
        'msg': 'Success',
        'meta': <String, dynamic>{
          'scope_gender': 'all',
          'sayap_terkunci': 0,
          'sayap': '',
          'jumlah': <String, dynamic>{
            'Menunggu Persetujuan': 7,
            'Disetujui': 2678,
            'Dibatalkan': 29,
          },
        },
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id_permit': '2716',
            'name_permit': 'Penjengukan',
            'nama_siswa': 'Uji Tapping Santri Akhwat Dua',
            'status': 'Disetujui',
            'gender': 'Perempuan',
            'sayap': 'Akhwat',
            'is_late': '0',
          },
        ],
      };

      final result = PermitListResponse.fromJson(json);

      expect(result.status, 'true');
      expect(result.errCode, '01');
      expect(result.msg, 'Success');
      expect(result.data, hasLength(1));
      expect(result.data.first.namaSiswa, 'Uji Tapping Santri Akhwat Dua');
      expect(result.data.first.namePermit, 'Penjengukan');
      expect(result.data.first.status, 'Disetujui');
      expect(result.data.first.sayap, 'Akhwat');
      expect(result.data.first.gender, 'Perempuan');

      final meta = result.meta;
      expect(meta, isNotNull);
      expect(meta!.scopeGender, 'all');
      expect(meta.sayapTerkunci, 0);
      expect(meta.sayap, '');
      expect(meta.jumlah?['Menunggu Persetujuan'], 7);
      expect(meta.jumlah?['Disetujui'], 2678);
      expect(meta.jumlah?['Dibatalkan'], 29);
    });

    test('respons tanpa data (tidak ada izin) tetap terbaca', () {
      final json = <String, dynamic>{
        'status': 'true',
        'errCode': '02',
        'msg': 'no data',
        'meta': <String, dynamic>{
          'scope_gender': 'laki-laki',
          'sayap_terkunci': 1,
          'sayap': 'ikhwan',
          'jumlah': <String, dynamic>{
            'Menunggu Persetujuan': 0,
            'Disetujui': 0,
            'Dibatalkan': 0,
          },
        },
      };

      final result = PermitListResponse.fromJson(json);

      expect(result.errCode, '02');
      expect(result.data, isEmpty);
      expect(result.meta?.sayapTerkunci, 1);
      expect(result.meta?.sayap, 'ikhwan');
      expect(result.meta?.scopeGender, 'laki-laki');
    });
  });
}
