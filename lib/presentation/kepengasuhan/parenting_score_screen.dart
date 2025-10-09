import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/presentation/kepengasuhan/parenting_score_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';
import '../../utils/custom_avatar_widget.dart';

class ParentingScoreScreen extends HookConsumerWidget {
  const ParentingScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(parentingScoreControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final dateSelected = useState<DateTime>(DateTime.now());
    final dateStart = dateSelected.value.copyWith(day: 1);
    final dateFormatSelected =
        DateFormat('yyyy-MM-dd').format(dateSelected.value);
    final dateStartFormat = DateFormat('yyyy-MM-dd').format(dateStart);
    final customDateFormatSelected =
        DateFormat('d MMMM yyyy').format(dateSelected.value);

    final fetchAllScoreParenting = ref.watch(
      fetchAllScoreParentingProvider(
        key: key,
        dateStart: dateStartFormat,
        dateEnd: dateFormatSelected,
      ),
    );
    ref.listen(
      fetchAllScoreParentingProvider(
        key: key,
        dateStart: dateStartFormat,
        dateEnd: dateFormatSelected,
      ),
      (previous, next) => next.showToastOnError(context),
    );

    final itemCount = fetchAllScoreParenting.isLoading
        ? 10
        : fetchAllScoreParenting.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Penilaian'.hardcoded,
              style: context.titleMedium,
            ),
            Text(
              '${dateStart.day} - $customDateFormatSelected',
              style: context.titleSmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: dateSelected.value,
                lastDate: DateTime.now(),
                firstDate: DateTime(2000),
              );
              if (selected == null) return;
              dateSelected.value = selected;
            },
            icon: const Icon(Icons.today),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAllScoreParentingProvider(
            key: key,
            dateStart: dateStartFormat,
            dateEnd: dateFormatSelected,
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllScoreParenting.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final parentingScore =
                  fetchAllScoreParenting.valueOrNull?.elementAtOrNull(index);
              final dateFormat = ref.watch(formatDateProvider(
                '${parentingScore?.date}',
                format: 'EEE, dd MMMM yyyy',
              ));
              return ListTile(
                onTap: () {
                  context.goNamed(
                    AppRoute.detailParentingScore.name,
                    queryParameters: {
                      'tahfidzId': '${parentingScore?.id_tahfidz}'
                    },
                  );
                },
                title: Text(
                  '${parentingScore?.nama_siswa}',
                  style: context.bodyMediumBold,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${parentingScore?.jenis_tahfidz}',
                      style: context.bodyMedium,
                    ),
                    Text(
                      '$dateFormat',
                      style: context.bodySmall,
                    ),
                  ],
                ),
                leading: CustomAvatar(
                  imageUrl: '${parentingScore?.img}',
                  name: '${parentingScore?.nama_siswa}',
                ),
                trailing: Transform.translate(
                  offset: const Offset(16, 0),
                  child: IntrinsicWidth(
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            context.goNamed(
                              AppRoute.upsertParentingScore.name,
                              extra: parentingScore,
                            );
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () {
                            _removeParentingScore(
                                context,
                                ref,
                                key,
                                dateStartFormat,
                                dateFormatSelected,
                                '${parentingScore?.nama_siswa}',
                                parentingScore?.id_tahfidz,
                                dateSelected);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(
            AppRoute.upsertParentingScore.name,
          );
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _removeParentingScore(
    BuildContext context,
    WidgetRef ref,
    String key,
    String dateStartFormat,
    String dateFormatSelected,
    String studentName,
    String? tahfidzId,
    ValueNotifier<DateTime> dateSelected,
  ) async {
    final dialogResult = await showOkCancelAlertDialog(
      context: context,
      title: 'Hapus Data Ini?',
      message: studentName,
    );
    if (dialogResult == OkCancelResult.cancel) return;

    final result = await ref
        .read(parentingScoreControllerProvider.notifier)
        .deleteScoreParenting(
          key: key,
          dateStart: dateStartFormat,
          dateEnd: dateFormatSelected,
          tahfidzId: '$tahfidzId',
        );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage('Berhasil menghapus data');
    ref.invalidate(fetchAllScoreParentingProvider);
  }
}
