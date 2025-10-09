import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/penjemputan/event_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EventClassroomScreen extends HookConsumerWidget {
  final String? eventId;
  final String? hostelId;
  final String? eventName;

  const EventClassroomScreen({
    super.key,
    this.eventId,
    this.eventName,
    this.hostelId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchAllEventClassroomProvider(
        key: key,
        id: '$eventId',
        hostelId: '$hostelId',
      ),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllClassroom = ref.watch(
      fetchAllEventClassroomProvider(
        key: key,
        id: '$eventId',
        hostelId: '$hostelId',
      ),
    );
    final itemCount = fetchAllClassroom.isLoading
        ? 10
        : fetchAllClassroom.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('$eventName'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAllEventClassroomProvider(
            key: key,
            id: '$eventId',
            hostelId: '$hostelId',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllClassroom.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final classroom =
                  fetchAllClassroom.valueOrNull?.elementAtOrNull(index);

              return Card.outlined(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                  child: ListTile(
                    title: Center(
                      child: Text(
                        '${classroom?.namaAsrama}',
                        style: context.titleMediumBold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Jumlah Murid: '),
                              Text('${classroom?.jumlahSantri} murid'),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (classroom == null) return;
                            context.goNamed(
                              AppRoute.homecomingStudent.name,
                              queryParameters: {
                                'hostelId': hostelId,
                                'eventName': eventName,
                                'eventId': eventId,
                                'classId': '${classroom.idAsrama}',
                                'type': 'pulang',
                                'typeName': 'Sudah Pulang',
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Sudah Pulang: '),
                                Text('${classroom?.dijemput} murid'),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (classroom == null) return;
                            context.goNamed(
                              AppRoute.homecomingStudent.name,
                              queryParameters: {
                                'hostelId': hostelId,
                                'eventName': eventName,
                                'eventId': eventId,
                                'classId': '${classroom.idAsrama}',
                                'type': 'belum_pulang',
                                'typeName': 'Belum Pulang',
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Belum Pulang: '),
                                Text('${classroom?.belumpulang} murid'),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (classroom == null) return;
                            context.goNamed(
                              AppRoute.homecomingStudent.name,
                              queryParameters: {
                                'hostelId': hostelId,
                                'eventName': eventName,
                                'eventId': eventId,
                                'classId': '${classroom.idAsrama}',
                                'type': 'kembali',
                                'typeName': 'Murid Kembali'
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Murid Kembali: '),
                                Text('${classroom?.dikembalikan} murid'),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (classroom == null) return;
                            context.goNamed(
                              AppRoute.homecomingStudent.name,
                              queryParameters: {
                                'eventName': eventName,
                                'eventId': eventId,
                                'hostelId': hostelId,
                                'classId': '${classroom.idAsrama}',
                                'type': 'belum_kembali',
                                'typeName': 'Belum Kembali',
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Belum Kembali: '),
                                Text('${classroom?.belumkembali} murid'),
                              ],
                            ),
                          ),
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
