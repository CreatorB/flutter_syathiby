import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/permit/permit.dart';
import 'package:syathiby/presentation/izin_santri/student_permit_controller.dart';
import 'package:syathiby/presentation/izin_santri/tap_izin_bottom_sheet.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';

/// Layar Izin Santri untuk petugas.
///
/// Susunan layar:
///   - Tab status (Menunggu Persetujuan / Disetujui / Dibatalkan), jumlah
///     izin per status diambil dari `meta` yang dikirim server.
///   - Chip sayap (Semua / Ikhwan / Akhwat). Kalau petugas punya
///     `gender_lock` tertentu, server mengunci lingkupnya dan chip tidak
///     dipakai - layar menampilkan pemberitahuan supaya petugas tahu
///     kenapa daftar yang tampil tidak berubah.
///
/// Setiap tab punya `PagingController` sendiri supaya pergantian tab tidak
/// pernah menampilkan data milik tab lain.
class StudentPermitScreen extends HookConsumerWidget {
  const StudentPermitScreen({super.key});

  static const int pagedSize = 10;

  static const List<String> statusTabs = <String>[
    'Menunggu Persetujuan',
    'Disetujui',
    'Dibatalkan',
  ];

  static const List<String> sayapChips = <String>['', 'ikhwan', 'akhwat'];

  static const Map<String, String> sayapLabels = <String, String>{
    '': 'Semua',
    'ikhwan': 'Ikhwan',
    'akhwat': 'Akhwat',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';

    final tabController = useTabController(initialLength: statusTabs.length);
    final sayap = useState<String>('');
    final meta = useState<PermitMeta?>(null);
    final sayapSebelumnya = useRef<String>('');

    final pagingControllers = useMemoized(
      () => List<PagingController<int, Permit>>.generate(
        statusTabs.length,
        (_) => PagingController<int, Permit>(firstPageKey: 1),
      ),
      const [],
    );

    Future<void> fetchData(int tabIndex, int pageKey) async {
      try {
        // Use ref.invalidate + ref.read to bypass Riverpod cache
        // so each refresh fetches fresh data from the backend.
        final provider = fetchStudentPermitListProvider(
          key: key,
          page: pageKey,
          status: statusTabs[tabIndex],
          sayap: sayap.value.isEmpty ? null : sayap.value,
        );
        ref.invalidate(provider);
        final result = await ref.read(provider.future);
        if (result.meta != null) {
          meta.value = result.meta;
        }
        final list = result.data;
        final nextPageKey = pageKey + 1;
        if (list.isEmpty) {
          pagingControllers[tabIndex].appendLastPage(list);
        } else {
          pagingControllers[tabIndex].appendPage(list, nextPageKey);
        }
      } catch (error) {
        pagingControllers[tabIndex].error = error;
      }
    }

    useEffect(() {
      for (var i = 0; i < pagingControllers.length; i++) {
        final tabIndex = i;
        pagingControllers[tabIndex].addPageRequestListener((pageKey) {
          fetchData(tabIndex, pageKey);
        });
      }
      return null;
    }, const []);

    // Ganti chip sayap -> muat ulang semua tab dengan filter baru.
    useEffect(() {
      if (sayapSebelumnya.value != sayap.value) {
        sayapSebelumnya.value = sayap.value;
        for (final controller in pagingControllers) {
          controller.refresh();
        }
      }
      return null;
    }, [sayap.value]);

    void refreshAll() {
      for (final controller in pagingControllers) {
        controller.refresh();
      }
    }

    final metaSaatIni = meta.value;
    final terkunci = (metaSaatIni?.sayapTerkunci ?? 0) == 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Izin Santri'),
        bottom: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          controller: tabController,
          tabs: List.generate(statusTabs.length, (index) {
            final jumlah = metaSaatIni?.jumlah?[statusTabs[index]];
            final label = statusTabs[index];
            return Tab(
              text: jumlah == null ? label : '$label ($jumlah)',
            );
          }),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildSayapFilter(
                context,
                sayap.value,
                terkunci,
                metaSaatIni,
                (value) => sayap.value = value,
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: List.generate(
                    tabController.length,
                    (index) => _buildPermitList(
                      context,
                      ref,
                      index,
                      pagingControllers[index],
                      refreshAll,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Satu tombol saja sejak 7 Sep 2026.
          //
          // Dulu ada DUA: "Ajukan Izin" (permit/insertsantri.php) dan "Tap Izin"
          // (tap/insert_izin_tap.php). Keduanya terlihat setara tapi hasilnya
          // beda: staff berwenang yang menekan "Ajukan Izin" izinnya nyangkut
          // 'Menunggu Persetujuan', sedangkan lewat "Tap Izin" langsung
          // 'Disetujui'. Orang sama, maksud sama, hasil beda -- itu yang bikin
          // bingung di lapangan.
          //
          // Jalur tap yang dipertahankan karena praktis semua izin nyata lewat
          // sana (678 dari 686 izin di produksi berstatus Disetujui), dan hanya
          // jalur itu yang menyimpan jam keluar/kembali sehingga kiosk RFID dan
          // deteksi terlambat bisa bekerja. Kemampuan yang tadinya hanya ada di
          // "Ajukan Izin" sudah dipindahkan ke sini. Jenis izin diketik bebas
          // sejak 2 Okt 2026 (bukan lagi pilihan permit_type), jadi batas
          // max_hari per kategori tidak berlaku. Lampiran foto tidak diikutkan karena
          // 0 dari 686 izin pernah memakainya (backend tetap menerimanya).
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton.extended(
              heroTag: 'student-permit',
              onPressed: () async {
                final added = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const TapIzinBottomSheet(),
                );
                if (added == true) {
                  refreshAll();
                }
              },
              label: const Text('Buat Izin Santri'),
              icon: const Icon(
                Icons.add,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Baris chip filter sayap.
  ///
  /// Kalau lingkup sayap sudah dikunci server (`gender_lock` petugas),
  /// chip dinonaktifkan dan pantalla menampilkan alasannya.
  Widget _buildSayapFilter(
    BuildContext context,
    String sayapTerpilih,
    bool terkunci,
    PermitMeta? meta,
    void Function(String value) onChanged,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final lingkup = meta?.scopeGender ?? 'all';
    final scopeLabel = lingkup == 'laki-laki'
        ? 'Ikhwan'
        : lingkup == 'perempuan'
            ? 'Akhwat'
            : 'semua sayap';

    return Container(
      width: double.infinity,
      color: colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(sayapChips.length, (index) {
                final value = sayapChips[index];
                final selected = value == sayapTerpilih;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(sayapLabels[value] ?? value),
                    selected: selected,
                    onSelected: terkunci
                        ? null
                        : (_) => onChanged(selected ? '' : value),
                    selectedColor: colorScheme.primaryContainer,
                    labelStyle: context.bodySmall?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                );
              }),
            ),
          ),
          if (terkunci)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 14,
                    color: context.colorOnSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Lingkup otomatis: $scopeLabel. Filter sayap dikunci untuk akun ini.',
                      style: context.bodySmall?.copyWith(
                        color: context.colorOnSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPermitList(
    BuildContext context,
    WidgetRef ref,
    int tabIndex,
    PagingController<int, Permit> pagingController,
    void Function() refreshAll,
  ) {
    return RefreshIndicator(
      onRefresh: () => Future.sync(pagingController.refresh),
      child: PagedListView(
        pagingController: pagingController,
        builderDelegate: PagedChildBuilderDelegate<Permit>(
          itemBuilder: (context, permit, index) {
            final dateFormat = ref.watch(formatDateProvider(
              '${permit.date}',
              format: 'EEE, dd MMMM yyyy',
            ));
            final status = permit.status;
            final isStatusRejected = status == "Ditolak";
            final isStatusAccepted = status == "Disetujui";

            return _buildPermitTile(
              context,
              ref,
              permit,
              dateFormat,
              isStatusRejected,
              isStatusAccepted,
              pagingController,
              refreshAll,
            );
          },
        ),
      ),
    );
  }

  Widget _buildPermitTile(
    BuildContext context,
    WidgetRef ref,
    Permit permit,
    String? dateFormat,
    bool isStatusRejected,
    bool isStatusAccepted,
    PagingController<int, Permit> pagingController,
    void Function() refreshAll,
  ) {
    final status = permit.status;
    final isLate = permit.isLate == '1';

    final tile = ListTile(
      title: Text(
        '${permit.namaSiswa}',
        style: context.bodyMediumBold,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${permit.namePermit}',
            style: context.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$dateFormat',
            style: context.bodySmall,
          ),
          if (isLate)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 14,
                    color: context.colorError,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Terlambat masuk',
                    style: context.bodySmall?.copyWith(
                      color: context.colorError,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      leading: CustomAvatar(
        name: '${permit.namaSiswa}',
        imageUrl: '${permit.img}',
        size: 40,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((permit.sayap ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _buildSayapBadge(context, permit.sayap!),
            ),
          if (status != 'Dibatalkan' && status != 'Disetujui')
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: context.colorError,
              ),
              tooltip: 'Hapus Izin',
              onPressed: () => _confirmDeleteFromList(
                context,
                ref,
                permit,
                pagingController,
              ),
            ),
          Transform.translate(
            offset: const Offset(8, 0),
            child: Chip(
              label: Text(
                '$status',
                style: context.bodySmall?.copyWith(
                  color: isStatusAccepted
                      ? context.colorOnPrimary
                      : isStatusRejected
                          ? context.colorOnError
                          : context.colorOnSurfaceVariant,
                ),
              ),
              shape: const StadiumBorder(
                side: BorderSide(),
              ),
              backgroundColor: isStatusAccepted
                  ? context.colorPrimary
                  : isStatusRejected
                      ? context.colorError
                      : context.colorSurfaceVariant,
              side: BorderSide(
                color: isStatusAccepted
                    ? context.colorPrimary
                    : isStatusRejected
                        ? context.colorError
                        : context.colorOnSurfaceVariant,
              ),
              padding: const EdgeInsets.symmetric(vertical: 4),
            ),
          ),
        ],
      ),
      onTap: () async {
        final result = await context.pushNamed<bool>(
          AppRoute.detailStudentPermit.name,
          extra: permit.idPermit,
        );
        if (result == true) {
          refreshAll();
        }
      },
      onLongPress: () => _showItemActions(
        context,
        ref,
        permit,
        pagingController,
        refreshAll,
      ),
    );

    if (!isLate) return tile;

    final lateBg = context.colorError.withValues(alpha: 0.08);
    final lateBorder = context.colorError.withValues(alpha: 0.25);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: lateBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: lateBorder, width: 1),
      ),
      child: tile,
    );
  }

  /// Lencana kecil penanda sayap di baris daftar.
  Widget _buildSayapBadge(BuildContext context, String sayap) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIkhwan = sayap.toLowerCase() == 'ikhwan';
    final background =
        isIkhwan ? colorScheme.secondaryContainer : colorScheme.tertiaryContainer;
    final foreground =
        isIkhwan ? colorScheme.onSecondaryContainer : colorScheme.onTertiaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        sayap,
        style: context.bodySmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _showItemActions(
    BuildContext context,
    WidgetRef ref,
    Permit permit,
    PagingController<int, Permit> pagingController,
    void Function() refreshAll,
  ) async {
    final currentUser = ref.read(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final permitId = '${permit.idPermit}';
    final errorColor = context.colorError;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('Lihat Detail'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final result = await context.pushNamed<bool>(
                    AppRoute.detailStudentPermit.name,
                    extra: permit.idPermit,
                  );
                  if (result == true && context.mounted) {
                    refreshAll();
                  }
                },
              ),
              if (permit.status != 'Dibatalkan' &&
                  permit.status != 'Disetujui')
                ListTile(
                  leading: Icon(Icons.delete_outline, color: errorColor),
                  title: Text(
                    'Hapus Izin',
                    style: TextStyle(color: errorColor),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final confirm = await showOkCancelAlertDialog(
                      context: context,
                      title: 'Hapus Izin',
                      message:
                          'Yakin ingin membatalkan izin "${permit.namePermit}" untuk ${permit.namaSiswa}?',
                      okLabel: 'Hapus',
                      cancelLabel: 'Batal',
                      isDestructiveAction: true,
                    );
                    if (confirm != OkCancelResult.ok) return;
                    if (!context.mounted) return;
                    try {
                      final result = await ref
                          .read(studentPermitControllerProvider.notifier)
                          .deletePermit(key: key, permitId: permitId);
                      if (!context.mounted) return;
                      if (result != null &&
                          (result.status == true || result.status == 'true')) {
                        context.showSuccessMessage(result.msg);
                        refreshAll();
                      } else if (result != null) {
                        context.showErrorMessage(result.msg);
                      } else {
                        context.showErrorMessage(
                          'Gagal terhubung ke server',
                        );
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      context.showErrorMessage(e);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteFromList(
    BuildContext context,
    WidgetRef ref,
    Permit permit,
    PagingController<int, Permit> pagingController,
  ) async {
    final currentUser = ref.read(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final permitId = '${permit.idPermit}';
    final confirm = await showOkCancelAlertDialog(
      context: context,
      title: 'Hapus Izin',
      message:
          'Yakin ingin membatalkan izin "${permit.namePermit}" untuk ${permit.namaSiswa}?',
      okLabel: 'Hapus',
      cancelLabel: 'Batal',
      isDestructiveAction: true,
    );
    if (confirm != OkCancelResult.ok) return;
    if (!context.mounted) return;
    try {
      final result = await ref
          .read(studentPermitControllerProvider.notifier)
          .deletePermit(key: key, permitId: permitId);
      if (!context.mounted) return;
      if (result != null && (result.status == true || result.status == 'true')) {
        context.showSuccessMessage(result.msg);
        pagingController.refresh();
      } else if (result != null) {
        context.showErrorMessage(result.msg);
      } else {
        context.showErrorMessage('Gagal terhubung ke server');
      }
    } catch (e) {
      if (!context.mounted) return;
      context.showErrorMessage(e);
    }
  }
}
