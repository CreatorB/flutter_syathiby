import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/presentation/absen_asrama/hostel_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HostelAttendanceScreen extends HookConsumerWidget {
  const HostelAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchAllHostelAttendanceProvider(key: key),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllHostel =
        ref.watch(fetchAllHostelAttendanceProvider(key: key));
    final itemCount =
        fetchAllHostel.isLoading ? 10 : fetchAllHostel.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Absensi Asrama'.hardcoded),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.refresh(fetchAllHostelAttendanceProvider(key: key).future),
        child: Skeletonizer(
          enabled: fetchAllHostel.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final hostel = fetchAllHostel.valueOrNull?.elementAtOrNull(index);

              return Card.outlined(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                  child: ListTile(
                    title: Text(
                      '${hostel?.namaAsrama}',
                      style: context.titleMediumBold,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Jumlah Santri: '),
                            Text('${hostel?.jumlahSantri} santri'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Santri di kamar: '),
                            Text('${hostel?.dijemput}'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Santri tidak di kamar: '),
                            Text('${hostel?.dikembalikan}'),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      if (hostel == null) return;
                      context.goNamed(
                        AppRoute.hostelRoom.name,
                        queryParameters: {
                          'hostelId': hostel.idAsrama,
                          'hostelName': hostel.namaAsrama,
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
