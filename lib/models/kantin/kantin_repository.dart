import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/kantin/kantin_models.dart';
import 'package:syathiby/utils/rest_exception.dart';

/// Pesan yang aman ditampilkan dari error apa pun (termasuk penolakan server).
String kantinPesanError(Object e) {
  if (e is RestException) return e.message;
  if (e is DioException) {
    final dalam = e.error;
    if (dalam is RestException) return dalam.message;
    return 'Tidak bisa terhubung ke server. Periksa koneksi lalu tarik untuk memuat ulang.';
  }
  return 'Terjadi kesalahan. Coba lagi.';
}

Map<String, dynamic> _data(dynamic body) {
  if (body is Map<String, dynamic>) {
    return body.containsKey('data') && body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;
  }
  return <String, dynamic>{};
}

/// Hak akses ditentukan server: selain errCode 01 interceptor melempar
/// RestException berisi pesan server (mis. "Anda tidak berwenang ...").
final kantinKatalogProvider = FutureProvider.autoDispose.family<KantinKatalog, String>((ref, key) async {
  final res = await ref.watch(dioProvider).get<dynamic>(
    'kantin/produk.php',
    queryParameters: {'key': key, 'act': 'list'},
  );
  return KantinKatalog.fromJson(_data(res.data));
});

final kantinRiwayatProvider = FutureProvider.autoDispose.family<KantinRiwayat, ({String key, String tanggal})>((ref, p) async {
  final res = await ref.watch(dioProvider).get<dynamic>(
    'kantin/riwayat.php',
    queryParameters: {'key': p.key, 'act': 'transaksi', 'dari': p.tanggal, 'sampai': p.tanggal, 'batas': 200},
  );
  return KantinRiwayat.fromJson(_data(res.data));
});
