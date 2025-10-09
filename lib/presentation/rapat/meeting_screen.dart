import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/rapat/meeting_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../routing/app_router.dart';

class MeetingScreen extends HookConsumerWidget {
  const MeetingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(meetingControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchAllMeetingProvider(key: key),
      (previous, next) => next.showToastOnError(context),
    );
    final fetchAllMeeting = ref.watch(fetchAllMeetingProvider(key: key));

    final itemCount = fetchAllMeeting.isLoading
        ? 10
        : fetchAllMeeting.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('List Pertemuan'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAllMeetingProvider(
            key: key,
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllMeeting.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final meeting =
                  fetchAllMeeting.valueOrNull?.elementAtOrNull(index);
              final dateFormat = ref.watch(formatDateProvider(
                '${meeting?.date}',
                format: 'EEEE, dd MMMM yyyy',
              ));
              return Card.outlined(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: ListTile(
                    onTap: () {
                      context.goNamed(
                        AppRoute.detailMeeting.name,
                        queryParameters: {'meetingId': '${meeting?.idMeeting}'},
                      );
                    },
                    title: Text(
                      '${meeting?.nameMeeting}',
                      style: context.bodyLargeBold,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${meeting?.meetingFor}',
                          style: context.bodyMedium,
                        ),
                        Text(
                          '$dateFormat',
                          style: context.bodyMedium,
                        ),
                      ],
                    ),
                    trailing: Transform.translate(
                      offset: const Offset(16, 0),
                      child: const Icon(Icons.arrow_forward_ios),
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
