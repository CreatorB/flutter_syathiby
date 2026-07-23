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

class StudentPermitScreen extends HookConsumerWidget {
  const StudentPermitScreen({super.key});

  static const int pagedSize = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final pagingController = useMemoized(
      () => PagingController<int, Permit>(
        firstPageKey: 1,
      ),
    );

    Future<void> fetchData(int pageKey) async {
      try {
        // Use ref.invalidate + ref.read to bypass Riverpod cache
        // so each refresh fetches fresh data from the backend.
        final provider = fetchStudentPermitListProvider(
          key: key,
          page: pageKey,
        );
        ref.invalidate(provider);
        final result = await ref.read(provider.future);
        final nextPageKey = pageKey + 1;
        if (result.isEmpty) {
          pagingController.appendLastPage(result);
        } else {
          pagingController.appendPage(result, nextPageKey);
        }
      } catch (error) {
        pagingController.error = error;
      }
    }

    useEffect(() {
      pagingController.addPageRequestListener((pageKey) {
        fetchData(pageKey);
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Izin Santri'),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
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
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton.extended(
              heroTag: 'student-permit',
              onPressed: () async {
                final added = await context.pushNamed<bool>(
                  AppRoute.addStudentPermit.name,
                );
                if (added == true) {
                  pagingController.refresh();
                }
              },
              label: const Text('Ajukan Izin'),
              icon: const Icon(
                Icons.add,
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton.extended(
              heroTag: 'tap-izin',
              onPressed: () async {
                final added = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const TapIzinBottomSheet(),
                );
                if (added == true) {
                  pagingController.refresh();
                }
              },
              label: const Text('Tap Izin'),
              icon: const Icon(
                Icons.badge,
              ),
              backgroundColor: Colors.orange,
            ),
          ),
        ],
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
          pagingController.refresh();
        }
      },
      onLongPress: () => _showItemActions(
        context,
        ref,
        permit,
        pagingController,
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

  Future<void> _showItemActions(
    BuildContext context,
    WidgetRef ref,
    Permit permit,
    PagingController<int, Permit> pagingController,
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
                    pagingController.refresh();
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
                        pagingController.refresh();
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
