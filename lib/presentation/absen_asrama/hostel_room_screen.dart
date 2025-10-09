import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/absen_asrama/hostel_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HostelRoomScreen extends HookConsumerWidget {
  final String? hostelId;
  final String? hostelName;

  const HostelRoomScreen({
    super.key,
    this.hostelId,
    this.hostelName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchAllHostelRoomProvider(
        key: key,
        hostelId: '$hostelId',
      ),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllHostelRoom = ref.watch(fetchAllHostelRoomProvider(
      key: key,
      hostelId: '$hostelId',
    ));
    final itemCount = fetchAllHostelRoom.isLoading
        ? 10
        : fetchAllHostelRoom.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('$hostelName'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAllHostelRoomProvider(
            key: key,
            hostelId: '$hostelId',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllHostelRoom.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final room =
                  fetchAllHostelRoom.valueOrNull?.elementAtOrNull(index);
              final isNotAbsence = room?.status == "0";
              final isAlreadyAbsence = room?.status == "1";

              final textColor = isNotAbsence
                  ? context.colorOnError
                  : isAlreadyAbsence
                      ? context.colorOnPrimary
                      : context.colorOnSurface;

              final backgroundColor = isNotAbsence
                  ? context.colorError
                  : isAlreadyAbsence
                      ? context.colorPrimary
                      : context.colorSurface;

              return Card.outlined(
                color: backgroundColor,
                margin: const EdgeInsets.all(8),
                child: InkWell(
                  onTap: () {
                    context.goNamed(
                      AppRoute.addHostelAttendance.name,
                      extra: room,
                      queryParameters: {
                        'hostelId': hostelId,
                        'hostelName': hostelName,
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 4),
                    child: ListTile(
                      title: Text(
                        '${room?.namaAsrama}',
                        style: context.titleMediumBold?.copyWith(
                          color: textColor,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            'Jumlah Santri: ${room?.jumlahSantri}',
                            style: context.bodyMedium?.copyWith(
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Musyrif: ${room?.musrif}',
                            style: context.bodyMedium?.copyWith(
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      trailing: Transform.translate(
                        offset: const Offset(8, 0),
                        child: Chip(
                          backgroundColor: textColor,
                          padding: const EdgeInsets.all(0),
                          label: Text(
                            isNotAbsence
                                ? 'Belum diperiksa'
                                : 'Sudah diperiksa',
                            style: context.labelMedium?.copyWith(
                              color: backgroundColor,
                            ),
                          ),
                        ),
                      ),
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
