import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/job/job_detail.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'job_controller.dart';

class DetailJobScreen extends HookConsumerWidget {
  final String jobId;

  const DetailJobScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenshotController = useMemoized(() => ScreenshotController());
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchJobDetail = ref.watch(
      fetchJobDetailProvider(key: key, jobId: jobId),
    );
    final jobDetail = fetchJobDetail.valueOrNull;
    final jobInfo = jobDetail?.info;
    final jobData = jobDetail?.data;
    final formatDate = ref.watch(
      formatDateProvider('${jobInfo?.date}', format: 'EEE, dd MMMM yyyy'),
    );
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Penugasan'),
          actions: [
            IconButton(
              onPressed: () async {
                try {
                  final result = await screenshotController.capture();
                  if (result == null) {
                    context.showErrorMessage('Gagal menyimpan screenshot');
                    return;
                  }
                  // Save the image temporarily in the device's temp directory
                  final tempDir = await getTemporaryDirectory();
                  final file =
                  await File('${tempDir.path}/screenshot.png').create();
                  await file.writeAsBytes(result);

                  await Share.shareXFiles(
                    [
                      XFile(
                        file.path,
                        name: 'screenshot.png',
                        mimeType: 'image/png',
                      ),
                    ],
                  );
                } catch (error) {
                  context.showErrorMessage('Gagal membagikan screenshot');
                }
              },
              icon: const Icon(Icons.share),
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.refresh(
            fetchJobDetailProvider(key: key, jobId: jobId).future,
          ),
          child: Skeletonizer(
            enabled: fetchJobDetail.isLoading,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          '${jobInfo?.no_invoice}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tanggal',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '$formatDate',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Operator',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${jobInfo?.name_staff}',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${jobInfo?.status?.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'JUDUL: ${jobInfo?.note}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'RINCIAN: ${jobInfo?.detail}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                // const Divider(),
                _buildItemProgress(context, ref, key, jobData),
              ],
            ),
          ),
        ),
        floatingActionButton: _buildProcessOfFinishJob(
          ref: ref,
          context: context,
          key: key,
          status: '${jobInfo?.status}',
        ),
      ),
    );
  }

  Widget _buildItemProgress(
    BuildContext context,
    WidgetRef ref,
    String key,
    List<JobData>? jobData,
  ) {
    if (jobData == null) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: jobData.length, // Set number of progress items
          itemBuilder: (context, index) {
            final data = jobData[index];
            final formatDate = ref.watch(
              formatDateProvider('${data.date}', format: 'EEE, dd MMMM yyyy'),
            );
            return InkWell(
              onTap: () {
                _showJobComment(context, ref, key, data);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdvancedAvatar(
                      image: CachedNetworkImageProvider('${data.img}'),
                      size: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colorPrimary,
                      ),
                      child: Icon(
                        Icons.work,
                        color: context.colorOnPrimary,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${data.name_staff}',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: context.colorOnSurface.withOpacity(0.87),
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '${data.note}',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: context.colorOnSurface.withOpacity(0.78),
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '$formatDate',
                            style: context.bodySmall?.copyWith(
                              color: context.colorOnSurface.withOpacity(0.60),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        color: data.status == 'pending'
                            ? context.colorError
                            : data.status == "process"
                                ? context.colorPrimaryContainer
                                : context.colorPrimary,
                      ),
                      child: Text(
                        '${data.status}',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: data.status == 'pending'
                              ? context.colorOnError
                              : data.status == "process"
                                  ? context.colorPrimary
                                  : context.colorOnPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showJobComment(
    BuildContext context,
    WidgetRef ref,
    String key,
    JobData data,
  ) async {
    final formatDate = ref.watch(
      formatDateProvider(
        '${data.date}',
        format: 'EEEE, dd MMMM yyyy',
      ),
    );
    final commentController = TextEditingController(text: data.comment ?? '');

    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      context: context,
      builder: (context) {
        return FractionallySizedBox(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Komentar'),
              leading: Container(),
              actions: [
                IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(Icons.close),
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                children: [
                  const SizedBox(height: 16.0),
                  Text(
                    'Status: ${data.status}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Card.outlined(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$formatDate',
                            style: context.titleMedium?.copyWith(
                              color: context.colorOnSurface.withOpacity(0.60),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            '${data.note}',
                            style: context.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Update Comment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: commentController,
                    maxLines: null,
                    minLines: 6,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Isikan komentar disini...',
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 16.0),
                  FilledButton(
                    onPressed: () async {
                      final comment = commentController.text.toString();
                      if (comment.isEmpty) {
                        context.showErrorMessage('Komentar tidak boleh kosong');
                        return;
                      }
                      final result = await ref
                          .read(jobControllerProvider.notifier)
                          .comment(key: key, id: data.id!, data: comment);
                      if (result == null || !context.mounted) return;
                      context.pop();
                      context.showSuccessMessage('Berhasil menyimpan komentar');
                      ref.invalidate(
                        fetchJobDetailProvider(key: key, jobId: jobId),
                      );
                      commentController.dispose();
                    },
                    child: const Text('Simpan'),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget? _buildProcessOfFinishJob({
    required WidgetRef ref,
    required BuildContext context,
    required String key,
    required String? status,
  }) {
    final fabProcessJob = FloatingActionButton.extended(
      onPressed: () async {
        final isConfirm = await showOkCancelAlertDialog(
          title: 'Info',
          message: 'Tekan tombol OK untuk memproses penugasan ini',
          context: context,
        );
        if (isConfirm == OkCancelResult.cancel) return;
        final result = await ref
            .read(jobControllerProvider.notifier)
            .processDetailJob(key: key, id: jobId);
        if (result == null || !context.mounted) return;
        context.showSuccessMessage('Berhasil Memproses Tugas');
        ref.invalidate(
          fetchJobDetailProvider(key: key, jobId: jobId),
        );
      },
      label: const Text('Dalam Proses'),
      icon: const Icon(Icons.check),
    );

    final fabFinishJob = FloatingActionButton.extended(
      onPressed: () async {
        final isConfirm = await showOkCancelAlertDialog(
          title: 'Info',
          message:
              'Pastikan anda telah mengerjakan tugas ini. tekan tombol OK untuk menyelesaikan tugas',
          context: context,
        );
        if (isConfirm == OkCancelResult.cancel) return;
        final result = await ref
            .read(jobControllerProvider.notifier)
            .finishDetailJob(key: key, id: jobId);
        if (result == null || !context.mounted) return;
        context.showSuccessMessage('Berhasil Menyelesaikan Tugas');
        ref.invalidate(
          fetchJobDetailProvider(key: key, jobId: jobId),
        );
      },
      label: const Text('Pekerjaan Selesai'),
      icon: const Icon(Icons.done_all),
    );
    switch (status) {
      case 'cancel':
        return null;
      case 'billing':
        return fabFinishJob;
      case 'process':
        return fabFinishJob;
      case 'pending':
        return fabProcessJob;
      case 'finish':
        return null;
      default:
        return null;
    }
  }
}
