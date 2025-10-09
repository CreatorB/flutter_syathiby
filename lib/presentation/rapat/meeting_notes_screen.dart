import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/presentation/rapat/meeting_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';
import '../../models/meeting/meeting.dart';

class MeetingNotesScreen extends HookConsumerWidget {
  final Rapat? meeting;

  const MeetingNotesScreen({super.key, this.meeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(meetingControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';

    final fetchMeetingNotes = ref.watch(
      fetchMeetingNotesProvider(
        key: key,
        meetingId: '${meeting?.idMeeting}',
      ),
    );
    ref.listen(
      fetchMeetingNotesProvider(
        key: key,
        meetingId: '${meeting?.idMeeting}',
      ),
      (previous, next) => next.showToastOnError(context),
    );

    final itemCount = fetchMeetingNotes.isLoading
        ? 10
        : fetchMeetingNotes.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notulen',
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
          fetchMeetingNotesProvider(
            key: key,
            meetingId: '${meeting?.idMeeting}',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchMeetingNotes.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final note =
                  fetchMeetingNotes.valueOrNull?.elementAtOrNull(index);
              return Card.outlined(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    '${note?.deskripsi}',
                    style: context.bodyMediumBold,
                  ),
                  trailing: Transform.translate(
                    offset: const Offset(16, 0),
                    child: IconButton(
                      onPressed: () {
                        _removeNote(
                          context,
                          ref,
                          key,
                          note,
                        );
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showUpsertMeetingNotes(context, ref, key, meeting?.idMeeting);
        },
        label: const Text('Tambah Catatan'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _removeNote(
    BuildContext context,
    WidgetRef ref,
    String key,
    Rapat? note,
  ) async {
    final dialogResult = await showOkCancelAlertDialog(
      context: context,
      title: 'Hapus Data Ini?',
      message: '${note?.deskripsi}',
    );
    if (dialogResult == OkCancelResult.cancel) return;

    final result =
        await ref.read(meetingControllerProvider.notifier).removeNote(
              key: key,
              meetingId: '${note?.idMeeting}',
            );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(fetchMeetingNotesProvider);
  }

  Future<void> showUpsertMeetingNotes(
    BuildContext context,
    WidgetRef ref,
    String key,
    String? meetingId, {
    String? currentValue,
    bool isUpdate = false,
  }) async {
    final title = isUpdate ? 'Ubah Notulen' : 'Tambah Notulen';
    final message = isUpdate
        ? 'Anda Ingin Mengubah hasil pertemuan ini?'
        : 'Masukkan satu persatu hasil pertemuan ini, Anda bisa menambahkan sebanyak mungkin';

    final note = await showTextInputDialog(
      context: context,
      title: title,
      message: message,
      textFields: [
        DialogTextField(
          hintText: 'Catatan hasil pertemuan',
          initialText: currentValue,
          keyboardType: TextInputType.text,
          maxLines: 3,
          validator: (value) {
            if (value?.isEmpty == true) return 'tidak boleh kosong';
            return null;
          },
          autocorrect: true,
        ),
      ],
    );
    if (note == null) return;

    final result = isUpdate
        ? await ref.read(meetingControllerProvider.notifier).updateNote(
              key: key,
              meetingId: '$meetingId',
              text: '${note.firstOrNull}',
            )
        : await ref.read(meetingControllerProvider.notifier).addNote(
              key: key,
              meetingId: '$meetingId',
              text: '${note.firstOrNull}',
            );

    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(fetchMeetingNotesProvider(
      key: key,
      meetingId: '${meeting?.idMeeting}',
    ));
  }
}
