import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/presentation/rekap/recap_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';
import '../../utils/custom_avatar_widget.dart';

class FilterRecapPresenceScreen extends HookConsumerWidget {
  final String? startDate;
  final String? endDate;
  final String? status;
  final String? groupId;
  final String? title;

  const FilterRecapPresenceScreen({
    super.key,
    this.startDate,
    this.endDate,
    this.groupId,
    this.status,
    this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final dateFormat = ref.watch(
      formatDateProvider('$startDate', format: 'EEEE, dd MMMM yyyy'),
    );

    final isPermit = status == 'permit';
    final isNotPresence = status == 'login' || status == 'logout';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title',
              style: context.titleMedium,
            ),
            Text(
              '$dateFormat',
              style: context.titleSmall,
            ),
          ],
        ),
      ),
      body: isPermit
          ? _buildRecapPermit(context, ref, key)
          : isNotPresence
              ? _buildRecapNotPresent(context, ref, key)
              : _buildRecapLate(context, ref, key),
    );
  }

  Widget _buildRecapLate(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) {
    ref.listen(
        fetchFilterRecapPresenceProvider(
          key: key,
          startDate: '$startDate',
          endDate: '$endDate',
          groupId: '$groupId',
          status: '$status',
        ), (previous, next) {
      next.showToastOnError(context);
    });
    final fetchFilterPresenceReport = ref.watch(
      fetchFilterRecapPresenceProvider(
        key: key,
        startDate: '$startDate',
        endDate: '$endDate',
        groupId: '$groupId',
        status: '$status',
      ),
    );
    final itemCount = fetchFilterPresenceReport.isLoading
        ? 10
        : fetchFilterPresenceReport.valueOrNull?.length ?? 0;
    return RefreshIndicator(
      onRefresh: () => ref.refresh(
        fetchFilterRecapPresenceProvider(
          key: key,
          startDate: '$startDate',
          endDate: '$endDate',
          groupId: '$groupId',
          status: '$status',
        ).future,
      ),
      child: Skeletonizer(
        enabled: fetchFilterPresenceReport.isLoading,
        child: ListView.builder(
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final attendance =
                fetchFilterPresenceReport.valueOrNull?.elementAtOrNull(index);
            final isLate = attendance?.status == 'late';
            final lateText = isLate
                ? 'Terlambat ${attendance?.late}'
                : '${attendance?.late} sebelum waktunya';
            final reason = attendance?.reason?.isEmpty == true
                ? 'Tanpa alasan'
                : '${attendance?.reason}';

            return ListTile(
              onTap: () {
                context.goNamed(
                  AppRoute.detailRecapPresence.name,
                  extra: attendance,
                  queryParameters: {
                    'groupId': groupId,
                    'status': status,
                    'startDate': startDate,
                    'endDate': endDate,
                    'title': title,
                  },
                );
              },
              leading: CustomAvatar(
                imageUrl: '${attendance?.img}',
                name: '${attendance?.name_staff}',
                size: 48,
              ),
              title: Text(
                '${attendance?.name_staff}',
                style: context.titleMediumBold,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Waktu absensi:',
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
                        'Status: ',
                        style: context.bodySmall,
                      ),
                      Text(
                        lateText,
                        style: context.bodySmallBold,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jumlah telat bulan ini: ',
                        style: context.bodySmall,
                      ),
                      Text(
                        '${attendance?.during} kali',
                        style: context.bodySmallBold,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Alasan: ',
                        style: context.bodySmall,
                      ),
                      Text(
                        reason,
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
    );
  }

  Widget _buildRecapNotPresent(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) {
    ref.listen(
        fetchFilterRecapPresenceProvider(
          key: key,
          startDate: '$startDate',
          endDate: '$endDate',
          groupId: '$groupId',
          status: '$status',
          isNotPresence: true,
        ), (previous, next) {
      next.showToastOnError(context);
    });
    final fetchFilterPresenceReport = ref.watch(
      fetchFilterRecapPresenceProvider(
        key: key,
        startDate: '$startDate',
        endDate: '$endDate',
        groupId: '$groupId',
        status: '$status',
        isNotPresence: true,
      ),
    );
    final itemCount = fetchFilterPresenceReport.isLoading
        ? 10
        : fetchFilterPresenceReport.valueOrNull?.length ?? 0;

    debugPrint('$fetchFilterPresenceReport');
    return RefreshIndicator(
      onRefresh: () => ref.refresh(
        fetchFilterRecapPresenceProvider(
          key: key,
          startDate: '$startDate',
          endDate: '$endDate',
          groupId: '$groupId',
          status: '$status',
          isNotPresence: true,
        ).future,
      ),
      child: Skeletonizer(
        enabled: fetchFilterPresenceReport.isLoading,
        child: ListView.builder(
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final attendance =
                fetchFilterPresenceReport.valueOrNull?.elementAtOrNull(index);

            return ListTile(
              leading: CustomAvatar(
                imageUrl: '${attendance?.img}',
                name: '${attendance?.name_staff}',
                size: 48,
              ),
              title: Text(
                '${attendance?.name_staff}',
                style: context.titleMediumBold,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jumlah absen bulan ini:',
                        style: context.bodySmall,
                      ),
                      Text(
                        '${attendance?.attandence} kali',
                        style: context.bodySmallBold,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jumlah telat bulan ini: ',
                        style: context.bodySmall,
                      ),
                      Text(
                        '${attendance?.during} kali',
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
    );
  }

  Widget _buildRecapPermit(BuildContext context, WidgetRef ref, String key) {
    ref.listen(
        fetchAllRecapPermitProvider(
          key: key,
          startDate: '$startDate',
          endDate: '$endDate',
          page: 1,
          groupId: '$groupId',
        ), (previous, next) {
      next.showToastOnError(context);
    });
    final fetchFilterPresenceReport = ref.watch(
      fetchAllRecapPermitProvider(
        key: key,
        startDate: '$startDate',
        endDate: '$endDate',
        page: 1,
        groupId: '$groupId',
      ),
    );
    final itemCount = fetchFilterPresenceReport.isLoading
        ? 10
        : fetchFilterPresenceReport.valueOrNull?.length ?? 0;
    return RefreshIndicator(
      onRefresh: () => ref.refresh(
        fetchAllRecapPermitProvider(
          key: key,
          startDate: '$startDate',
          endDate: '$endDate',
          page: 1,
          groupId: '$groupId',
        ).future,
      ),
      child: Skeletonizer(
        enabled: fetchFilterPresenceReport.isLoading,
        child: ListView.builder(
          itemCount: itemCount,
          itemBuilder: (context, index) {
            final permit =
                fetchFilterPresenceReport.valueOrNull?.elementAtOrNull(index);
            final dateFormat = ref.watch(formatDateProvider(
              '${permit?.date}',
              format: 'EEE, dd MMMM yyyy',
            ));
            final status = permit?.status;
            final isStatusRejected = status == "Ditolak";
            final isStatusAccepted = status == "Disetujui";

            return ListTile(
              title: Text(
                '${permit?.staff}',
                style: context.bodyMediumBold,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${permit?.namePermit}',
                    style: context.bodyMedium,
                  ),
                  Text(
                    '$dateFormat',
                    style: context.bodySmall,
                  ),
                ],
              ),
              leading: CustomAvatar(
                name: '${permit?.staff}',
                imageUrl: '${permit?.img}',
                size: 40,
              ),
              trailing: Transform.translate(
                offset: const Offset(12, 0),
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
              onTap: () {
                context.goNamed(
                  AppRoute.detailRecapPermit.name,
                  extra: permit?.idPermit,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
