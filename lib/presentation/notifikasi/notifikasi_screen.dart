import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/notifikasi/notifikasi.dart';
import 'package:syathiby/presentation/notifikasi/notifikasi_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/waktu_notifikasi.dart';

/// Kotak masuk notifikasi staff.
///
/// Isinya dibaca dari tabel `notifikasi` (server), jadi notifikasi tetap ada
/// walau push FCM tidak sampai. Setiap staff hanya melihat notifikasinya
/// sendiri -- identitas diambil dari `key` sesi di server, bukan dari pilihan
/// di layar.
///
/// Daftar dimuat per MINGGU: minggu berjalan dulu, lalu minggu-minggu
/// sebelumnya saat layar di-scroll ke bawah. Judul minggu dikirim server
/// ("Pekan ini", "Pekan lalu"), jadi daftar di aplikasi dan di panel web
/// selalu menunjukkan batas minggu yang sama.
///
/// Notifikasi yang diklik ditandai terbaca lebih dulu, lalu dibuka halamannya.
/// Tombol di pojok kanan atas menandai semua notifikasi yang belum dibaca.
class NotifikasiScreen extends HookConsumerWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final list = ref.watch(notifikasiListProvider);
    // Notifier SELALU diambil lewat ref.read, tidak disimpan di useRef.
    // Provider-nya auto-dispose: kalau notifier disimpan di ref, saat
    // provider di-create ulang notifier yang disimpan bisa sudah dibuang --
    // hasil fetch-nya masuk ke provider yang tidak lagi dipakai, dan daftar
    // tampil kosong padahal server sudah mengirim data.
    final scroll = useMemoized(() => ScrollController(), []);
    // Muat minggu berikutnya. Kalau daftar masih tidak menutup layar (mis.
    // minggu ini cuma ada dua notifikasi), tidak ada yang bisa digulir --
    // jadi minggu berikutnya dimuat sendiri supaya pengguna tidak perlu
    // menggulir dulu untuk melihat notifikasi yang lebih lama.
    Future<void> muatMingguBerikutnya() async {
      await ref
          .read(notifikasiListProvider.notifier)
          .muatMingguBerikutnya(key);
      if (!scroll.hasClients) return;
      final terbaru = ref.read(notifikasiListProvider);
      if (terbaru.adaLagi && scroll.position.maxScrollExtent <= 0) {
        await Future.delayed(const Duration(milliseconds: 250));
        await muatMingguBerikutnya();
      }
    }

    Future<void> muatAwal() async {
      await ref.read(notifikasiListProvider.notifier).muatAwal(key);
      // Tunggu satu frame supaya ScrollController sudah punya client --
      // tanpa itu pengecekan "daftar cukup pendek" selalu gagal.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        muatMingguBerikutnya();
      });
    }
    void tandaiTerbaca(int id) =>
        ref.read(notifikasiListProvider.notifier).tandaiTerbacaDiDaftar(id);

    // Muat minggu pertama saat layar dibuka.
    useEffect(() {
      if (key.isEmpty || key == 'null') return null;
      Future.microtask(muatAwal);
      return null;
    }, [key]);

    // Muat minggu berikutnya saat nearing akhir daftar.
    useEffect(() {
      void onScroll() {
        if (!scroll.hasClients) return;
        if (scroll.position.pixels >= scroll.position.maxScrollExtent - 300) {
          muatMingguBerikutnya();
        }
      }

      scroll.addListener(onScroll);
      return () => scroll.removeListener(onScroll);
    }, [key, list.blok.length]);

    // Daftar yang diratakan jadi satu daftar datar: header minggu + item.
    final entries = <Object>[];
    for (final blok in list.blok) {
      entries.add(blok);
      entries.addAll(blok.items);
    }
    final items = list.jumlahItem;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (list.unread > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Text(
                  '${list.unread} baru',
                  style: context.bodySmall?.copyWith(
                    color: context.colorPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Tandai semua terbaca',
            onPressed: list.unread == 0
                ? null
                : () async {
                    ref
                        .read(notifikasiListProvider.notifier)
                        .tandaiSemuaTerbacaDiDaftar();
                    await ref
                        .read(notifikasiReadProvider.notifier)
                        .tandaiDibaca(key: key);
                  },
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(notifikasiListProvider.notifier).muatAwal(key);
          ref.invalidate(fetchNotifikasiUnreadProvider);
        },
        child: list.loading && items == 0
            ? const Center(child: CircularProgressIndicator())
            : items == 0
                ? _kosong(context)
                : ListView.builder(
                    controller: scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: entries.length + (list.adaLagi ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= entries.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final entri = entries[index];
                      if (entri is BlokMinggu) {
                        return _HeaderMinggu(label: entri.label);
                      }
                      final n = entri as Notifikasi;
                      return _BarisNotifikasi(
                        notifikasi: n,
                        onTap: () {
                          final id = n.id ?? 0;
                          if (id > 0) {
                            // Tandai terbaca dulu supaya badge turun
                            // seketika, baru buka halamannya.
                            tandaiTerbaca(id);
                            ref
                                .read(notifikasiReadProvider.notifier)
                                .tandaiDibaca(key: key, id: id);
                          }
                          // goNamed (bukan pushNamed): di web, pushNamed
                          // ke route anak tidak memperbarui URL browser,
                          // jadi halaman detail tidak bisa di-refresh atau
                          // di-share. Route detail memang anak dari
                          // 'notifikasi', jadi daftar tetap ada di bawah
                          // dan tombol kembali kembali ke daftar.
                          context.goNamed(
                            AppRoute.notifikasiDetail.name,
                            pathParameters: {'id': '$id'},
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }

  Widget _kosong(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 160),
        Icon(
          Icons.notifications_none,
          size: 56,
          color: context.colorOutline,
        ),
        const SizedBox(height: 12),
        Center(
          child: Text('Belum ada notifikasi', style: context.bodyMedium),
        ),
        const SizedBox(height: 6),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Notifikasi pengajuan, izin, dan tugas lain akan muncul di sini.',
              textAlign: TextAlign.center,
              style: context.bodySmall?.copyWith(color: context.colorOutline),
            ),
          ),
        ),
      ],
    );
  }
}

/// Judul kelompok minggu: 'Pekan ini', 'Pekan lalu', dst.
class _HeaderMinggu extends StatelessWidget {
  const _HeaderMinggu({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: context.bodySmall?.copyWith(
                color: context.colorOutline,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu baris notifikasi di daftar.
class _BarisNotifikasi extends StatelessWidget {
  const _BarisNotifikasi({required this.notifikasi, required this.onTap});

  final Notifikasi notifikasi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final belum = (notifikasi.status ?? 'baru') == 'baru';
    return InkWell(
      onTap: onTap,
      child: Container(
        color: belum
            ? context.colorPrimary.withOpacity(0.06)
            : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              belum
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: belum ? context.colorPrimary : context.colorOutline,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notifikasi.judul ?? '-',
                    style: context.bodyMediumBold?.copyWith(
                      fontWeight:
                          belum ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if ((notifikasi.pesan ?? '').isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${notifikasi.pesan}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    WaktuNotifikasi.relatif(notifikasi.createdAt),
                    style: context.bodySmall?.copyWith(
                      color: context.colorOutline,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (belum)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 6),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: context.colorError,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
