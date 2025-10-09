import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/presentation/puasa/fasting_student_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';
import '../../utils/custom_avatar_widget.dart';

class ReportFastingStudentScreen extends HookConsumerWidget {
  const ReportFastingStudentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(fastingStudentControllerProvider, (previous, next) {
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

    final fetchAllFastingStudent = ref.watch(
      fetchAllFastingStudentProvider(
        key: key,
        dateStart: dateStartFormat,
        dateEnd: dateFormatSelected,
      ),
    );
    ref.listen(
      fetchAllFastingStudentProvider(
        key: key,
        dateStart: dateStartFormat,
        dateEnd: dateFormatSelected,
      ),
      (previous, next) => next.showToastOnError(context),
    );

    final itemCount = fetchAllFastingStudent.isLoading
        ? 10
        : fetchAllFastingStudent.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Puasa Sunnah'.hardcoded,
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
          fetchAllFastingStudentProvider(
            key: key,
            dateStart: dateStartFormat,
            dateEnd: dateFormatSelected,
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllFastingStudent.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final fasting =
                  fetchAllFastingStudent.valueOrNull?.elementAtOrNull(index);
              final dateFormat = ref.watch(formatDateProvider(
                '${fasting?.date}',
                format: 'EEE, dd MMMM yyyy',
              ));
              return ListTile(
                title: Text(
                  '${fasting?.namaSiswa}',
                  style: context.bodyMediumBold,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${fasting?.jenisPuasa}',
                      style: context.bodyMedium,
                    ),
                    Text(
                      '$dateFormat',
                      style: context.bodySmall,
                    ),
                  ],
                ),
                leading: CustomAvatar(
                  imageUrl: '${fasting?.img}',
                  name: '${fasting?.namaSiswa}',
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(
            AppRoute.addFastingReport.name,
          );
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
