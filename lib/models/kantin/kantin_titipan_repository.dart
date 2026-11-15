import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/kantin/kantin_models.dart';
import 'package:syathiby/models/kantin/kantin_titipan_models.dart';

Map<String, dynamic> _data(dynamic body) {
  if (body is Map<String, dynamic>) {
    return body.containsKey('data') && body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;
  }
  return <String, dynamic>{};
}

/// POST form generik ke endpoint kantin. Selain errCode 01 interceptor melempar
/// RestException berisi pesan server (mis. "Anda tidak berwenang ...").
Future<Map<String, dynamic>> kantinAksi(WidgetRef ref, String path, Map<String, dynamic> data) async {
  final res = await ref.read(dioProvider).post<dynamic>(
    path,
    data: data,
    options: Options(contentType: Headers.formUrlEncodedContentType),
  );
  return _data(res.data);
}

/// Pratinjau konfirmasi pembelian. TIDAK menulis apa pun di server.
Future<KantinPreview> kantinPreview(
  WidgetRef ref, {
  required String key,
  required String idCard,
  required Keranjang keranjang,
  required String metode,
}) async {
  final d = await kantinAksi(ref, 'kantin/transaksi.php', {
    'key': key,
    'act': 'preview',
    'id_card': idCard,
    'items': jsonEncode(keranjang.itemsServer),
    'metode': metode,
  });
  return KantinPreview.fromJson(d);
}

/// Tambah/ubah produk. [id] null = tambah.
Future<void> kantinProdukSimpan(WidgetRef ref, String key, Map<String, dynamic> f, {int? id}) async {
  await kantinAksi(ref, 'kantin/produk.php', {
    'key': key,
    'act': id == null ? 'tambah' : 'ubah',
    if (id != null) 'id_produk': id,
    ...f,
  });
}

final kantinPenitipProvider = FutureProvider.autoDispose.family<List<KantinPenitip>, String>((ref, key) async {
  final res = await ref.watch(dioProvider).get<dynamic>(
    'kantin/penitip.php',
    queryParameters: {'key': key, 'act': 'list'},
  );
  return KantinPenitip.daftarDari(_data(res.data));
});

/// Daftar pengajuan pencairan hasil titipan. [status]: menunggu|disetujui|ditolak|semua.
final kantinPencairanProvider =
    FutureProvider.autoDispose.family<DaftarPencairan, ({String key, int idPenitip, String status})>((ref, p) async {
  final res = await ref.watch(dioProvider).get<dynamic>(
    'kantin/penitip.php',
    queryParameters: {
      'key': p.key,
      'act': 'daftar_cair',
      'status': p.status,
      if (p.idPenitip > 0) 'id_penitip': p.idPenitip,
    },
  );
  return DaftarPencairan.fromJson(_data(res.data));
});

/// Daftar santri berhutang di kantin. [cari]: nama/NIS (boleh kosong).
final kantinHutangProvider = FutureProvider.autoDispose.family<KantinHutangDaftar, ({String key, String cari})>((ref, p) async {
  final res = await ref.watch(dioProvider).get<dynamic>(
    'kantin/hutang.php',
    queryParameters: {'key': p.key, 'act': 'list', if (p.cari.isNotEmpty) 'cari': p.cari},
  );
  return KantinHutangDaftar.fromJson(_data(res.data));
});

final kantinPenitipLaporanProvider =
    FutureProvider.autoDispose.family<PenitipLaporan, ({String key, int id, String dari, String sampai})>((ref, p) async {
  final res = await ref.watch(dioProvider).get<dynamic>(
    'kantin/penitip.php',
    queryParameters: {'key': p.key, 'act': 'laporan', 'id_penitip': p.id, 'dari': p.dari, 'sampai': p.sampai},
  );
  return PenitipLaporan.fromJson(_data(res.data));
});
