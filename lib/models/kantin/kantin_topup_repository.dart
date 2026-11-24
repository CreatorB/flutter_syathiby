import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/kantin/kantin_topup_models.dart';
import 'package:syathiby/res/flavor_config.dart';

/// Boleh verifikasi top-up atau tidak (hanya tim keuangan).
///
/// Dipakai supaya menu verifikasi disembunyikan dari kasir -- kasir menjaga
/// aktivitas keseharian di lapangan, bukan ACC uang. Server tetap yang
/// memutuskan; ini cuma supaya kasir tidak melihat menu yang tidak bisa dipakai.
final kantinTopupBolehProvider = FutureProvider<bool>((ref) async {
  final u = ref.watch(getCurrentUserProvider);
  final key = '${u?.key}';
  if (key.isEmpty || key == 'null') return false;
  try {
    final res = await ref.watch(dioProvider).get<dynamic>(
      'kantin/topup.php',
      queryParameters: {'key': key, 'act': 'boleh'},
    );
    final body = res.data is Map<String, dynamic>
        ? res.data as Map<String, dynamic>
        : <String, dynamic>{};
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final n = data['boleh'];
      return n is num ? n.toInt() == 1 : false;
    }
    return false;
  } catch (_) {
    return false;
  }
});

/// Daftar pengajuan top-up saldo (hanya tim keuangan yang boleh).
///
/// Server yang menentukan hak akses: kalau pemanggil bukan
/// `pengadaan_keuangan`/akses penuh, endpoint membalas errCode 03 dan
/// interceptor melempar RestException berisi pesan server.
final kantinTopupProvider =
    FutureProvider.autoDispose.family<TopupDaftar, ({String key, String status})>(
  (ref, p) async {
    final res = await ref.watch(dioProvider).get<dynamic>(
      'kantin/topup.php',
      queryParameters: {'key': p.key, 'act': 'list', 'status': p.status},
    );
    final body = res.data is Map<String, dynamic>
        ? res.data as Map<String, dynamic>
        : <String, dynamic>{};
    final data = body['data'];
    return TopupDaftar.fromJson(
      data is Map<String, dynamic> ? data : <String, dynamic>{},
    );
  },
);

/// Setujui satu pengajuan top-up saldo.
Future<void> kantinTopupSetuju(
  WidgetRef ref, {
  required String key,
  required int id,
}) async {
  await ref.read(dioProvider).get<dynamic>(
    'kantin/topup.php',
    queryParameters: {'key': key, 'act': 'setuju', 'id': '$id'},
  );
}

/// Tolak satu pengajuan top-up saldo (alasan wajib).
Future<void> kantinTopupTolak(
  WidgetRef ref, {
  required String key,
  required int id,
  required String alasan,
}) async {
  await ref.read(dioProvider).get<dynamic>(
    'kantin/topup.php',
    queryParameters: {
      'key': key,
      'act': 'tolak',
      'id': '$id',
      'alasan': alasan,
    },
  );
}

/// Alamat bukti transfer (bukti_tf). Berkasnya ada di luar docroot, jadi
/// hanya bisa diambil lewat endpoint yang memeriksa session.
String kantinTopupBuktiUrl(String key, int id) =>
    '${FlavorConfig.apiUrl}kantin/topup.php?key=$key&act=bukti&id=$id';
