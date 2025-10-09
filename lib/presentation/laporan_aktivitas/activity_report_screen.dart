import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/laporan_aktivitas/activity_report_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ActivityReportScreen extends HookConsumerWidget {
  final String? type;

  const ActivityReportScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final dateNow = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dateSelected = useState<String?>(dateNow);
    ref.listen(
      fetchAllActivityReportProvider(
        key: key,
        dateStart: '${dateSelected.value}',
        dateEnd: '${dateSelected.value}',
        type: '$type',
      ),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchActivityReport = ref.watch(
      fetchAllActivityReportProvider(
        key: key,
        dateStart: '${dateSelected.value}',
        dateEnd: '${dateSelected.value}',
        type: '$type',
      ),
    );
    final itemCount = fetchActivityReport.isLoading
        ? 10
        : fetchActivityReport.valueOrNull?.length ?? 0;

    final dateFormat = ref.watch(
      formatDateProvider(
        '${dateSelected.value}',
        format: 'EEEE, dd MMMM yyyy',
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Laporan Aktivitas',
              style: context.titleMedium,
            ),
            Text(
              '$dateFormat',
              style: context.titleSmall,
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () async {
                final initialDate = DateTime.tryParse('${dateSelected.value}');
                final selected = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  initialDate: initialDate ?? DateTime.now(),
                  lastDate: DateTime.now(),
                );
                if (selected == null) return;
                final dateFormat = DateFormat('yyyy-MM-dd').format(selected);
                dateSelected.value = dateFormat;
              },
              icon: const Icon(Icons.today)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAllActivityReportProvider(
            key: key,
            dateStart: '${dateSelected.value}',
            dateEnd: '${dateSelected.value}',
            type: '$type',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchActivityReport.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final activity =
                  fetchActivityReport.valueOrNull?.elementAtOrNull(index);

              return Card.outlined(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          final imageProvider = CachedNetworkImageProvider(
                            '${activity?.img}',
                          );
                          showImageViewer(context, imageProvider);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: '${activity?.img}',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Container(
                                width: 70,
                                height: 70,
                                color: context.colorOutline,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: Text(
                            '${activity?.hour} - ${activity?.name_event}',
                            style: context.bodyMediumBold,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(
                                'Keterangan: ${activity?.during}',
                                style: context.bodyMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${activity?.name_staff}',
                                style: context.labelLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
            AppRoute.addActivityReport.name,
            queryParameters: {'type': '$type', 'date': '${dateSelected.value}'},
          );
        },
        label: const Text('Tambah Laporan'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
