import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/presentation/laporan_absen_kelas/report_class_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HostelScreen extends HookConsumerWidget {
  const HostelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchAllHostelProvider(key: key),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllHostel = ref.watch(fetchAllHostelProvider(key: key));
    final itemCount =
        fetchAllHostel.isLoading ? 10 : fetchAllHostel.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mata Pelajaran'.hardcoded),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(fetchAllHostelProvider(key: key).future),
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
                            const Text('Jumlah Santri/Murid: '),
                            Text('${hostel?.jumlahSantri} santri/murid'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Jumlah Kelas: '),
                            Text('${hostel?.dijemput} kelas'),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      if (hostel == null) return;
                      context.goNamed(
                        AppRoute.hostelClassroom.name,
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
