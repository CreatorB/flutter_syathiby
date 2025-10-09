import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/presentation/rapat/meeting_controller.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';
import '../../models/meeting/meeting.dart';
import '../../models/staff/staff.dart';

class AddMeetingParticipantScreen extends HookConsumerWidget {
  final Rapat? meeting;

  const AddMeetingParticipantScreen({
    super.key,
    this.meeting,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(meetingControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';

    final fetchAllStaff = ref.watch(
      fetchAllStaffProvider(key: key),
    );

    final fetchMeetingParticipant = ref.watch(
      fetchMeetingParticipantProvider(
        key: key,
        meetingId: '${meeting?.idMeeting}',
      ),
    );
    ref.listen(
      fetchMeetingParticipantProvider(
        key: key,
        meetingId: '${meeting?.idMeeting}',
      ),
      (previous, next) => next.showToastOnError(context),
    );

    final meetingController = ref.watch(meetingControllerProvider);

    final itemCount = fetchMeetingParticipant.isLoading
        ? 10
        : fetchMeetingParticipant.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Peserta',
              style: context.titleMedium,
            ),
            Text(
              '${meeting?.nameMeeting}',
              style: context.titleSmall,
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchMeetingParticipantProvider(
            key: key,
            meetingId: '${meeting?.idMeeting}',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchMeetingParticipant.isLoading,
          child: Stack(
            children: [
              ListView.builder(
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  final participant = fetchMeetingParticipant.valueOrNull
                      ?.elementAtOrNull(index);
                  return Card.outlined(
                    child: ListTile(
                      leading: CustomAvatar(
                        imageUrl: '',
                        name: '${participant?.nameMeeting}',
                      ),
                      title: Text(
                        '${participant?.nameMeeting}',
                        style: context.bodyMediumBold,
                      ),
                      subtitle: Text(
                        '${participant?.meetingFor}',
                        style: context.bodyMedium,
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          _removeParticipant(
                            context,
                            ref,
                            key,
                            participant,
                          );
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                  );
                },
              ),
              meetingController.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _showSelectParticipant(
        context,
        ref,
        key,
        fetchAllStaff.valueOrNull,
      ),
    );
  }

  Future<void> _removeParticipant(
    BuildContext context,
    WidgetRef ref,
    String key,
    Rapat? meeting,
  ) async {
    final dialogResult = await showOkCancelAlertDialog(
      context: context,
      title: 'Hapus Data Ini?',
      message: '${meeting?.nameMeeting}',
    );
    if (dialogResult == OkCancelResult.cancel) return;

    final result = await ref
        .read(meetingControllerProvider.notifier)
        .removeParticipant(
            key: key,
            meetingId: '${meeting?.idMeeting}',
            phoneNumber: '${meeting?.meetingFor}');
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(fetchAllMeetingProvider(key: key));
  }

  Widget _showSelectParticipant(
    BuildContext context,
    WidgetRef ref,
    String key,
    List<Staff>? staffList,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownSearch<Staff>(
        items: staffList ?? [],
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
              hintText: 'Pencarian...',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        itemAsString: (item) => '${item.fullName}',
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: 'Tambah Peserta',
            labelText: 'Tambah Peserta',
            border: OutlineInputBorder(),
            isDense: true,
            prefixIcon: Icon(Icons.person),
          ),
        ),
        onChanged: (staff) async {
          final result = await ref
              .read(meetingControllerProvider.notifier)
              .addMeetingPerson(
                key: key,
                meetingId: '${meeting?.idMeeting}',
                phoneNumber: '${staff?.phoneNumber}',
              );
          if (result == null || !context.mounted) return;
          context.showSuccessMessage(result.msg);
          ref.invalidate(
            fetchMeetingParticipantProvider(
              key: key,
              meetingId: '${meeting?.idMeeting}',
            ),
          );
        },
      ),
    );
  }
}
