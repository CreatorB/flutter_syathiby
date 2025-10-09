import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/laporan_absen_kelas/report_class_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HostelClassroomScreen extends HookConsumerWidget {
  final String? hostelId;
  final String? hostelName;

  const HostelClassroomScreen({super.key, this.hostelId, this.hostelName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchAllHostelClassroomProvider(key: key, hostelId: '$hostelId'),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllClassroom = ref.watch(
      fetchAllHostelClassroomProvider(key: key, hostelId: '$hostelId'),
    );
    final itemCount = fetchAllClassroom.isLoading
        ? 10
        : fetchAllClassroom.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('$hostelName'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAllHostelClassroomProvider(key: key, hostelId: '$hostelId')
              .future,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Wali Kelas: '),
                            Text('${classroom?.musrif}'),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Jumlah Murid: '),
                            Text('${classroom?.jumlahSantri} murid'),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      if (classroom == null) return;
                      context.goNamed(
                        AppRoute.classroomAttendance.name,
                        queryParameters: {
                          'date': classroom.date,
                          'classId': classroom.idAsrama,
                          'className': classroom.namaAsrama,
                          'hostelId': hostelId,
                          'hostelName': hostelName,
                        },
                      );
                    },
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
