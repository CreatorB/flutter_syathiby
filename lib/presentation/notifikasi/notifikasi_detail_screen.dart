import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/notifikasi/notifikasi.dart';
import 'package:syathiby/presentation/notifikasi/notifikasi_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/waktu_notifikasi.dart';

/// Detail satu notifikasi.
///
/// Notifikasi diambil ulang dari server memakai `key` sesi + id, jadi staff
/// hanya bisa membuka notifikasinya sendiri. Membuka halaman ini menandai
/// notifikasi sebagai terbaca.
class NotifikasiDetailScreen extends HookConsumerWidget {
  const NotifikasiDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final detail = ref.watch(
      fetchNotifikasiDetailProvider(key: key, id: id),
    );
    // Id tidak valid (mis. URL '#/notifikasi/abc') -> perlakukan sama dengan
    // notifikasi yang tidak ada.
    final n = id > 0 ? detail.valueOrNull : null;

    // Tandai terbaca saat detail dibuka.
    //
    // Dipanggil SEKALI per screen (bukan lewat ref.listen yang bisa berulang):
    // menandai terbaca menyegarkan jumlah belum dibaca, dan kalau detail ikut
    // di-invalidate maka layarnya memuat ulang -> menandai lagi -> berulang.
    final sudahDitandai = useRef(false);
    ref.listen(fetchNotifikasiDetailProvider(key: key, id: id), (_, next) {
      if (next.hasValue && id > 0 && !sudahDitandai.value) {
        sudahDitandai.value = true;
        ref
            .read(notifikasiReadProvider.notifier)
            .tandaiDibaca(key: key, id: id);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Notifikasi')),
      body: detail.isLoading && n == null
          ? const Center(child: CircularProgressIndicator())
          : n == null
              ? _tidakDitemukan(context)
              : _isi(context, n, sudahDibaca: sudahDitandai.value),
    );
  }

  Widget _tidakDitemukan(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off, size: 48, color: context.colorOutline),
          const SizedBox(height: 12),
          Text('Notifikasi tidak ditemukan', style: context.bodyMedium),
          const SizedBox(height: 4),
          Text(
            'Notifikasi ini sudah dihapus atau bukan milik akun Anda.',
            style: context.bodySmall?.copyWith(color: context.colorOutline),
          ),
        ],
      ),
    );
  }

  Widget _isi(
    BuildContext context,
    Notifikasi n, {
    required bool sudahDibaca,
  }) {
    final refId = (n.refId ?? '').trim();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              (n.status ?? 'baru') == 'baru' && !sudahDibaca
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: context.colorPrimary,
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                n.judul ?? '-',
                style: context.titleMediumBold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          WaktuNotifikasi.lengkap(n.createdAt),
          style: context.bodySmall?.copyWith(color: context.colorOutline),
        ),
        if ((n.status ?? 'baru') == 'baru' && !sudahDibaca) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.colorPrimary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Baru',
              style: context.bodySmall?.copyWith(
                color: context.colorPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        if ((n.pesan ?? '').isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text('${n.pesan}', style: context.bodyMedium),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (refId.isNotEmpty) ...[
          _Baris(
            label: 'Nomor acuan',
            nilai: refId,
          ),
          const SizedBox(height: 8),
        ],
        _Baris(
          label: 'Sumber',
          nilai: _labelSumber(n.source),
        ),
        const SizedBox(height: 20),
        if (_tujuanUrl(n) != null)
          FilledButton.icon(
            onPressed: () => _bukaTujuan(context, n),
            icon: const Icon(Icons.open_in_new),
            label: Text(_labelTombol(n)),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
      ],
    );
  }

  /// Sumber notifikasi -> label yang dimengerti staff.
  String _labelSumber(String? source) {
    switch ((source ?? '').toLowerCase()) {
      case 'get_pengadaan':
        return 'Pengajuan barang / perbaikan';
      case 'get_permit':
        return 'Izin santri';
      case 'get_izin':
        return 'Izin santri';
      case 'kantin_topup_admin':
        return 'Top-up saldo';
      case 'kantin_pencairan':
        return 'Pencairan titipan';
      case 'kantin_stok':
        return 'Stok kantin menipis';
      case '':
        return '-';
      default:
        return source ?? '-';
    }
  }

  /// Halaman tujuan(notifikasi pengajuan) kalau notifikasi ini punya acuan.
  String? _tujuanUrl(Notifikasi n) {
    final source = (n.source ?? '').toLowerCase();
    final refId = (n.refId ?? '').trim();
    if (refId.isEmpty) return null;
    if (source == 'get_pengadaan') {
      return '${AppRoute.detailRequestTransaction.name}?invoiceId=$refId&status=pengajuan';
    }
    return null;
  }

  String _labelTombol(Notifikasi n) {
    final source = (n.source ?? '').toLowerCase();
    if (source == 'get_pengadaan') return 'Buka pengajuan';
    return 'Buka detail';
  }

  void _bukaTujuan(BuildContext context, Notifikasi n) {
    final source = (n.source ?? '').toLowerCase();
    final refId = (n.refId ?? '').trim();
    if (source == 'get_pengadaan' && refId.isNotEmpty) {
      context.goNamed(
        AppRoute.detailRequestTransaction.name,
        queryParameters: {'invoiceId': refId, 'status': 'pengajuan'},
      );
    }
  }
}

class _Baris extends StatelessWidget {
  const _Baris({required this.label, required this.nilai});

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: context.bodySmall?.copyWith(color: context.colorOutline),
          ),
        ),
        Expanded(
          child: Text(nilai, style: context.bodyMedium),
        ),
      ],
    );
  }
}
