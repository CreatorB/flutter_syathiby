import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/presentation/manage_job/manage_job_controller.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';
import '../../models/job/job.dart';
import '../../routing/app_router.dart';

class ManageJobScreen extends HookConsumerWidget {
  const ManageJobScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(manageJobControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });

    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchJobs = ref.watch(fetchAllJobProvider(key: key));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pekerjaan'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.search),
        //     onPressed: () {},
        //   )
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(fetchAllJobProvider(key: key).future),
        child: fetchJobs.when(
          data: (jobs) => ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final formatDate = ref.watch(
                formatDateProvider(job.date, format: 'EEE, dd MMMM yyyy'),
              );
              return ListTile(
                title: Text(
                  '${job.operator}',
                  style: context.bodyLargeBold,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${job.note}',
                      style: context.bodyMedium,
                    ),
                    Text(
                      '$formatDate',
                      style: context.bodySmall,
                    ),
                  ],
                ),
                leading: CustomAvatar(
                  name: '${job.operator}',
                  imageUrl: '${job.img}',
                  size: 40,
                ),
                trailing: Transform.translate(
                  offset: const Offset(16, 0),
                  child: IconButton(
                    onPressed: () {
                      _removeJob(context, ref, key, job);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ),
                onTap: () {
                  context.goNamed(
                    AppRoute.upsertManageJob.name,
                    extra: job,
                  );
                },
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(
            AppRoute.upsertManageJob.name,
          );
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _removeJob(
    BuildContext context,
    WidgetRef ref,
    String key,
    Job? job,
  ) async {
    final dialogResult = await showOkCancelAlertDialog(
      context: context,
      title: 'Hapus Data Ini?',
      message: '${job?.note}',
    );
    if (dialogResult == OkCancelResult.cancel) return;

    final result =
        await ref.read(manageJobControllerProvider.notifier).removeJob(
              key: key,
              jobId: '${job?.id_history_job}',
            );
    if (result == null || !context.mounted) return;
    ref.invalidate(fetchAllJobProvider(key: key));
    context.showSuccessMessage(result.msg);
  }
}
