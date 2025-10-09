import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';
import '../../models/meeting/meeting.dart';
import '../qr/scan_barcode_screen.dart';
import 'meeting_controller.dart';

class DetailMeetingScreen extends HookConsumerWidget {
  final String? meetingId;

  const DetailMeetingScreen({super.key, this.meetingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(meetingControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final tabController = useTabController(initialLength: 4);
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchDetailMeeting = ref.watch(fetchDetailMeetingProvider(
      key: key,
      meetingId: '$meetingId',
    ));
    final meeting = fetchDetailMeeting.valueOrNull?.firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pertemuan'),
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: const [
            Tab(text: 'Detail'),
            Tab(text: 'Peserta'),
            Tab(text: 'Dokumentasi'),
            Tab(text: 'Notulen'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await showAddMeetingSuggestion(context, ref, key, meetingId);
              tabController.animateTo(1);
            },
            icon: const Icon(Icons.note_add),
          ),
          IconButton(
            onPressed: () async {
              final file = await _showCameraPicker(context);
              if (file == null) return;
              final result = await ref
                  .read(meetingControllerProvider.notifier)
                  .addDocumentation(
                    key: key,
                    meetingId: '$meetingId',
                    image: file,
                  );
              if (result == null || !context.mounted) return;
              context.showSuccessMessage(result.msg);
              ref.invalidate(fetchMeetingDocumentationProvider(
                key: key,
                meetingId: '$meetingId',
              ));
            },
            icon: const Icon(Icons.camera_alt),
          ),
          IconButton(
            onPressed: () async {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => ScanBarcodeScreen(
                  isSingleCapture: true,
                  onCapture: (scanTextId) async {
                    try {
                      final position = await ref.read(
                        getCurrentLocationProvider.future,
                      );
                      if (!context.mounted) return;
                      final location =
                          '${position.latitude},${position.longitude}';
                      final result = await ref
                          .read(meetingControllerProvider.notifier)
                          .meetingPresence(
                        key: key,
                        meetingId: scanTextId,
                        location: location,
                        meetingFor: '${position.isMocked}',
                      );
                      if (result == null || !context.mounted) return;
                      context.showSuccessMessage(result.msg);
                      ref.invalidate(fetchMeetingParticipantProvider);
                    } catch (error) {
                      context.showErrorMessage(
                        'Lokasi diperlukan untuk absensi QR Code kehadiran',
                      );
                    }
                  },
                ),
              );
            },
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildTabDetail(
            context,
            ref,
            key,
            meeting,
            fetchDetailMeeting.isLoading,
          ),
          _buildTabParticipant(context, ref, key, meeting),
          _buildTabDocumentation(context, ref, key, meeting),
          _buildTabNotes(context, ref, key, meeting),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showUpsertMeetingNotes(context, ref, key, meeting?.idMeeting);
        },
        label: const Text('Tambah Notulen'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value, {
    VoidCallback? onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildTabDetail(
    BuildContext context,
    WidgetRef ref,
    String key,
    Rapat? meeting,
    bool isLoading,
  ) {
    final dateFormat = ref.watch(formatDateProvider(
      '${meeting?.date}',
      format: 'EEEE, dd MMMM yyyy',
    ));
    return RefreshIndicator(
      onRefresh: () => ref.refresh(
        fetchDetailMeetingProvider(
          key: key,
          meetingId: '$meetingId',
        ).future,
      ),
      child: Skeletonizer(
        enabled: isLoading,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              '${meeting?.nameMeeting}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildDetailItem(
              'Tanggal Pertemuan',
              '$dateFormat',
            ),
            _buildDetailItem(
              'Jam Pertemuan',
              '${meeting?.hourStart}',
            ),
            _buildDetailItem(
              'Jenis Pertemuan',
              '${meeting?.meetingFor}',
            ),
            _buildDetailItem(
              'Status Pertemuan',
              '${meeting?.statusMeeting}',
            ),
            _buildDetailItem('Detail Pertemuan', '${meeting?.deskripsi}'),
            _buildDetailItem(
              'Dibuat Oleh',
              '${meeting?.operator}',
            ),
            // Provide your image path here
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildTabParticipant(
    BuildContext context,
    WidgetRef ref,
    String key,
    Rapat? meeting,
  ) {
    final fetchMeetingParticipant = ref.watch(
      fetchMeetingParticipantProvider(
        key: key,
        meetingId: '${meeting?.idMeeting}',
      ),
    );
    final dateFormat = ref.watch(formatDateProvider(
      '${meeting?.date}',
      format: 'EEEE, dd MMM yyyy',
    ));
    return RefreshIndicator(
      onRefresh: () => ref.refresh(
        fetchMeetingParticipantProvider(
          key: key,
          meetingId: '${meeting?.idMeeting}',
        ).future,
      ),
      child: fetchMeetingParticipant.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (ctx, index) {
            final participant = data[index];
            return Card.outlined(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: CustomAvatar(
                  imageUrl: '',
                  name: '${participant.nameMeeting}',
                ),
                title: Text(
                  '${participant.nameMeeting}',
                  style: context.bodyMediumBold,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$dateFormat', style: context.bodySmall),
                    Visibility(
                      visible: participant.deskripsi?.isNotEmpty == true,
                      child: Text(
                        'Usulan: ${participant.deskripsi}',
                        style: context.bodySmall,
                      ),
                    ),
                  ],
                ),
                trailing: Chip(
                  label: Text(
                    '${participant.statusMeeting}',
                    style: context.bodySmall,
                  ),
                ),
              ),
            );
          },
        ),
        error: (err, stack) => ListView(
          children: const [
            Center(
              child: Text('Tidak ada data / Gagal memuat data'),
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildTabDocumentation(
    BuildContext context,
    WidgetRef ref,
    String key,
    Rapat? meeting,
  ) {
    final fetchMeetingDocumentation = ref.watch(
      fetchMeetingDocumentationProvider(
        key: key,
        meetingId: '${meeting?.idMeeting}',
      ),
    );
    return RefreshIndicator(
      onRefresh: () => ref.refresh(
        fetchMeetingDocumentationProvider(
          key: key,
          meetingId: '${meeting?.idMeeting}',
        ).future,
      ),
      child: fetchMeetingDocumentation.when(
        data: (data) => ListView(
          padding: const EdgeInsets.all(8),
          children: [
            ResponsiveGridRow(
              children: data
                  .map(
                    (documentation) => ResponsiveGridCol(
                      lg: 2,
                      md: 3,
                      sm: 3,
                      xs: 4,
                      child: InkWell(
                        onTap: () {
                          final imageProvider = CachedNetworkImageProvider(
                            '${documentation.deskripsi}',
                          );
                          showImageViewer(context, imageProvider);
                        },
                        child: Column(
                          children: [
                            CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: '${documentation.deskripsi}',
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.image),
                              height: 150,
                            ),
                            const SizedBox(height: 4),
                            Text('${documentation.nameMeeting}'),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        error: (err, stack) => ListView(
          children: const [
            Center(
              child: Text('Tidak ada data / Gagal memuat data'),
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildTabNotes(
    BuildContext context,
    WidgetRef ref,
    String key,
    Rapat? meeting,
  ) {
    final fetchMeetingNotes = ref.watch(
      fetchMeetingNotesProvider(
        key: key,
        meetingId: '${meeting?.idMeeting}',
      ),
    );

    return RefreshIndicator(
      onRefresh: () => ref.refresh(
        fetchMeetingNotesProvider(
          key: key,
          meetingId: '${meeting?.idMeeting}',
        ).future,
      ),
      child: fetchMeetingNotes.when(
        data: (data) => ListView.builder(
          itemCount: data.length,
          itemBuilder: (ctx, index) {
            final note = data[index];
            return Card.outlined(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(
                  '${note.deskripsi}',
                  style: context.bodyMediumBold,
                ),
                trailing: Transform.translate(
                  offset: const Offset(16, 0),
                  child: IconButton(
                    onPressed: () {
                      _removeNote(context, ref, key, note);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ),
              ),
            );
          },
        ),
        error: (err, stack) => ListView(
          children: const [
            Center(
              child: Text('Tidak ada data / Gagal memuat data'),
            ),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Future<void> _removeNote(
    BuildContext context,
    WidgetRef ref,
    String key,
    Rapat? meeting,
  ) async {
    final dialogResult = await showOkCancelAlertDialog(
      context: context,
      title: 'Hapus Data Ini?',
      message: '${meeting?.deskripsi}',
    );
    if (dialogResult == OkCancelResult.cancel) return;

    final result =
        await ref.read(meetingControllerProvider.notifier).removeNote(
              key: key,
              meetingId: '${meeting?.idMeeting}',
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
    ref.invalidate(fetchMeetingNotesProvider);
  }

  Future<void> showAddMeetingSuggestion(
    BuildContext context,
    WidgetRef ref,
    String key,
    String? meetingId,
  ) async {
    const title = 'Tambah Usulan';
    const message =
        'Anda bisa memberikan Usulan, Kritik dan Saran untuk Pertemuan ini. Komentar Anda akan muncul di List Peserta';
    final note = await showTextInputDialog(
      context: context,
      title: title,
      message: message,
      textFields: [
        DialogTextField(
          hintText: 'Komentar/Usulan Anda...',
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

    final result =
        await ref.read(meetingControllerProvider.notifier).addComment(
              key: key,
              meetingId: '$meetingId',
              text: '${note.firstOrNull}',
            );

    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(fetchMeetingParticipantProvider);
  }

  Future<File?> _showCameraPicker(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    final imageCompressed = await FlutterImageCompress.compressWithList(
      await image.readAsBytes(),
      quality: 10,
    );
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/${DateTime.timestamp()}').create();
    file.writeAsBytesSync(imageCompressed);
    return file;
  }
}
