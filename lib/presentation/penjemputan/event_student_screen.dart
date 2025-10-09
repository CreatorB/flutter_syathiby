import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/penjemputan/event_controller.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EventStudentScreen extends HookConsumerWidget {
  final String? type, classId, eventId, eventName, typeName;

  const EventStudentScreen({
    super.key,
    this.type,
    this.classId,
    this.eventId,
    this.eventName,
    this.typeName,
  });

  static const int pagedSize = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchAllEventStudentProvider(
        key: key,
        page: 1,
        id: '$eventId',
        type: '$type',
        classId: '$classId',
      ),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllStudent = ref.watch(fetchAllEventStudentProvider(
      key: key,
      page: 1,
      id: '$eventId',
      type: '$type',
      classId: '$classId',
    ));
    final itemCount = fetchAllStudent.isLoading
        ? 10
        : fetchAllStudent.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              '$typeName',
              style: context.titleMedium,
            ),
            Text(
              '$eventName',
              style: context.titleSmall,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAllEventStudentProvider(
            key: key,
            page: 1,
            id: '$eventId',
            type: '$type',
            classId: '$classId',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllStudent.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final student =
                  fetchAllStudent.valueOrNull?.elementAtOrNull(index);
              final status = student?.status;
              final isStatusRejected = status == "Belum Dijemput";
              final isStatusAccepted = status == "Sudah Dijemput";

              return ListTile(
                title: Text(
                  '${student?.namaLengkap}',
                  style: context.bodyMediumBold,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NIS: ${student?.nis}',
                      style: context.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Kelas: ${student?.kelas}',
                      style: context.bodySmall,
                    ),
                  ],
                ),
                leading: CustomAvatar(
                  name: '${student?.namaLengkap}',
                  imageUrl: '${student?.img}',
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
                  // TODO
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
