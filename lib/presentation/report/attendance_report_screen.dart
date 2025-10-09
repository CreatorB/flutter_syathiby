import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/presentation/report/report_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';
import '../../utils/custom_avatar_widget.dart';

class AttendanceReportScreen extends HookConsumerWidget {
  final String? startDate;
  final String? endDate;
  final String? userKey;
  final String? name;

  const AttendanceReportScreen({
    super.key,
    this.startDate,
    this.endDate,
    this.userKey,
    this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
        fetchDetailPresenceReportProvider(
          key: userKey ?? key,
          startDate: '$startDate',
          endDate: '$endDate',
        ), (previous, next) {
      next.showToastOnError(context);
    });
    final fetchDetailPresenceReport = ref.watch(
      fetchDetailPresenceReportProvider(
        key: userKey ?? key,
        startDate: '$startDate',
        endDate: '$endDate',
      ),
    );
    final itemCount = fetchDetailPresenceReport.isLoading
        ? 10
        : fetchDetailPresenceReport.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Absensi Kehadiran',
              style: context.titleMedium,
            ),
            Visibility(
              visible: name != null,
              child: Text(
                '$name',
                style: context.titleSmall,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchDetailPresenceReportProvider(
            key: userKey ?? key,
            startDate: '$startDate',
            endDate: '$endDate',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchDetailPresenceReport.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final attendance =
                  fetchDetailPresenceReport.valueOrNull?.elementAtOrNull(index);
              final formatDate = ref.watch(formatDateProvider(
                '${attendance?.date}',
                format: 'EEEE, dd MMMM yyyy',
              ));

              return ListTile(
                onTap: () {
                  context.goNamed(
                    AppRoute.attendanceReportDetail.name,
                    extra: attendance,
                    queryParameters: {
                      "startDate": startDate,
                      "endDate": endDate
                    },
                  );
                },
                leading: CustomAvatar(
                  imageUrl: '${attendance?.img}',
                  name: '${attendance?.name_staff}',
                  size: 48,
                ),
                title: Text(
                  '$formatDate',
                  style: context.titleMediumBold,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jam Masuk: ',
                          style: context.bodySmall,
                        ),
                        Text(
                          '${attendance?.timeattand}',
                          style: context.bodySmallBold,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Selesai Bekerja: ',
                          style: context.bodySmall,
                        ),
                        Text(
                          '${attendance?.done}',
                          style: context.bodySmallBold,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bekerja Selama: ',
                          style: context.bodySmall,
                        ),
                        Text(
                          '${attendance?.during}',
                          style: context.bodySmallBold,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
