import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/presentation/report/report_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentFastingScreen extends HookConsumerWidget {
  const StudentFastingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final dateNow = DateFormat('yyyy-MM-dd').format(DateTime.now());
    ref.listen(
      fetchReportStudentFastingProvider(
        key: key,
        startDate: dateNow,
        endDate: dateNow,
      ),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchReportFasting = ref.watch(
      fetchReportStudentFastingProvider(
        key: key,
        startDate: dateNow,
        endDate: dateNow,
      ),
    );
    final itemCount = fetchReportFasting.isLoading
        ? 10
        : fetchReportFasting.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Rekap Puasa'.hardcoded),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchReportStudentFastingProvider(
            key: key,
            startDate: dateNow,
            endDate: dateNow,
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchReportFasting.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final report =
                  fetchReportFasting.valueOrNull?.elementAtOrNull(index);
              final formatDate = ref.watch(
                formatDateProvider('${report?.date}',
                    format: 'EEEE, dd MMMM yyyy'),
              );

              return Card.outlined(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                  child: ListTile(
                    title: Text(
                      '$formatDate',
                      style: context.titleMediumBold,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Asrama Putra MA: '),
                            Text('${report?.totalma} murid'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Asrama Putra MSW: '),
                            Text('${report?.totalmsw} murid'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Asrama Putri: '),
                            Text('${report?.totalpi} murid'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Jumlah Murid Puasa: '),
                            Text('${report?.total} murid'),
                          ],
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
    );
  }
}
