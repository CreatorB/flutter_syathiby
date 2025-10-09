import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/pickup/pickup.dart';
import 'package:syathiby/presentation/penjemputan/event_controller.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class DetailEventStudentScreen extends HookConsumerWidget {
  final String? eventId, id;

  const DetailEventStudentScreen({
    super.key,
    this.eventId,
    this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final eventController = ref.watch(eventControllerProvider);
    ref.listen(eventControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });

    ref.listen(
      fetchDetailEventStudentProvider(
        key: key,
        id: '$id',
        eventId: '$eventId',
      ),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchDetailEventStudent = ref.watch(
      fetchDetailEventStudentProvider(
        key: key,
        id: '$id',
        eventId: '$eventId',
      ),
    );
    final student = fetchDetailEventStudent.valueOrNull?.firstOrNull;
    final isNotPickedUp = student?.status == 'Belum Dijemput';
    final isPickedUp = student?.status == 'Sudah Dijemput';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Siswa'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchDetailEventStudentProvider(
            key: key,
            id: '$id',
            eventId: '$eventId',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchDetailEventStudent.isLoading,
          child: ListView(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 32,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${student?.sekolah} - ${student?.tingkat}'
                            .toUpperCase(),
                        style: context.titleMediumBold,
                      ),
                      const SizedBox(height: 24),
                      CustomAvatar(
                        imageUrl: '${student?.img}',
                        name: '${student?.namaLengkap}',
                        size: 150,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '${student?.namaLengkap?.toUpperCase()}',
                        style: context.titleLargeBold,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'NIS: ${student?.nis}',
                        style: context.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kelas: '),
                          Text(student?.kelas ?? ''),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Asrama: '),
                          Text(student?.asrama ?? ''),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Nama Kegiatan: '),
                          Text(student?.namaEvent ?? ''),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Status: '),
                          Text(student?.status ?? ''),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          Visibility(
            visible: isNotPickedUp,
            child: Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FilledButton(
                  onPressed: eventController.isLoading
                      ? null
                      : () async {
                          _addStudentPickedUp(context, ref, key, student);
                        },
                  child: eventController.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Sudah Dijemput'),
                ),
              ),
            ),
          ),
          Visibility(
            visible: isPickedUp,
            child: Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FilledButton(
                  onPressed: eventController.isLoading
                      ? null
                      : () {
                          _addStudentReturned(context, ref, key, student);
                        },
                  child: eventController.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : const Text('Sudah Dikembalikan'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addStudentPickedUp(
    BuildContext context,
    WidgetRef ref,
    String key,
    Penjemputan? student,
  ) async {
    final input = await showTextInputDialog(
      context: context,
      title: 'Info',
      message:
          'Masukkan nama penjemput dan Tekan OK Jika Santri sudah di jemput kerumah',
      textFields: [
        DialogTextField(
          hintText: 'Nama Penjemput',
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null) return 'Anda Tidak memasukkan Nama Penjemput...';
            return null;
          },
          autocorrect: true,
        ),
      ],
    );
    final value = input?.firstOrNull;
    if (value == null) return;
    final result =
        await ref.refresh(eventControllerProvider.notifier).addPickupStudent(
              key: key,
              studentId: '${student?.nis}',
              eventId: '${student?.idEvent}',
              classId: '${student?.idKelas}',
              data: value,
            );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(
      fetchDetailEventStudentProvider(
        key: key,
        id: '$id',
        eventId: '$eventId',
      ),
    );
  }

  Future<void> _addStudentReturned(
    BuildContext context,
    WidgetRef ref,
    String key,
    Penjemputan? student,
  ) async {
    final input = await showTextInputDialog(
      context: context,
      title: 'Info',
      message:
          'Masukkan nama Pengantar dan Tekan OK Jika Santri sudah di Antar kepondok',
      textFields: [
        DialogTextField(
          hintText: 'Nama Pengantar',
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null) return 'Anda Tidak memasukkan Nama Pengantar...';
            return null;
          },
          autocorrect: true,
        ),
      ],
    );
    final value = input?.firstOrNull;
    if (value == null) return;
    final result =
        await ref.refresh(eventControllerProvider.notifier).addReturnStudent(
              key: key,
              studentId: '${student?.nis}',
              eventId: '${student?.idEvent}',
              classId: '${student?.idKelas}',
              data: value,
            );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(
      fetchDetailEventStudentProvider(
        key: key,
        id: '$id',
        eventId: '$eventId',
      ),
    );
  }
}
