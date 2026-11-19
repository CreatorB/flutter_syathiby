import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/notifikasi/notifikasi.dart';
import 'package:syathiby/presentation/notifikasi/notifikasi_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

/// Kotak masuk notifikasi staff.
///
/// Isinya dibaca dari tabel `notifikasi` (server), jadi notifikasi tetap ada
/// walau push FCM tidak sampai. Notifikasi ditandai sudah dibaca begitu
/// layar ini dibuka.
class NotifikasiScreen extends HookConsumerWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final notifikasi = ref.watch(fetchNotifikasiProvider(key: key));
    final list = notifikasi.valueOrNull ?? const <Notifikasi>[];

    // Sudah dibaca begitu dibuka.
    useEffect(() {
      if (key.isEmpty || key == 'null') return null;
      Future.microtask(
        () => ref.read(notifikasiReadProvider.notifier).tandaiDibaca(key: key),
      );
      return null;
    }, [key]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(fetchNotifikasiProvider);
          ref.invalidate(fetchNotifikasiUnreadProvider);
          await ref.read(fetchNotifikasiProvider(key: key).future);
        },
        child: notifikasi.isLoading && list.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : list.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 160),
                      Icon(
                        Icons.notifications_none,
                        size: 56,
                        color: context.colorOutline,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Belum ada notifikasi',
                          style: context.bodyMedium,
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final n = list[index];
                      final belum = (n.status ?? 'baru') == 'baru';
                      return ListTile(
                        leading: Icon(
                          belum
                              ? Icons.notifications_active
                              : Icons.notifications_none,
                          color: belum ? context.colorPrimary : context.colorOutline,
                        ),
                        title: Text(
                          '${n.judul ?? '-'}',
                          style: context.bodyMediumBold,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((n.pesan ?? '').isNotEmpty)
                              Text('${n.pesan}', style: context.bodySmall),
                            const SizedBox(height: 2),
                            Text(
                              _waktu(n.createdAt),
                              style: context.bodySmall?.copyWith(
                                color: context.colorOutline,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: (n.pesan ?? '').isNotEmpty,
                      );
                    },
                  ),
      ),
    );
  }

  /// Ubah 'Y-m-d H:i:s' jadi 'd MMM yyyy, HH:mm'; kalau gagal, tampilkan
  /// apa adanya.
  String _waktu(String? mentah) {
    final teks = (mentah ?? '').trim();
    if (teks.isEmpty) return '-';
    try {
      final dt = DateTime.parse(teks);
      return DateFormat('d MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return teks;
    }
  }
}
