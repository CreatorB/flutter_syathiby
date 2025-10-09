import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/typography.dart';

import 'job_controller.dart';

class JobScreen extends HookConsumerWidget {
  const JobScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 3);
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Penugasan'.hardcoded),
        bottom: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          controller: tabController,
          tabs: [
            Tab(text: 'Pekerjaan Baru'.hardcoded),
            Tab(text: 'Dalam Proses'.hardcoded),
            Tab(text: 'Pekerjaan Selesai'.hardcoded),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: List.generate(
          tabController.length,
          (index) => _buildJobList(context, ref, index, key),
        ),
      ),
    );
  }

  String _getStatusFromIndex(int index) {
    if (index == 0) {
      return "Pending";
    } else if (index == 1) {
      return "process";
    } else {
      return "finish";
    }
  }

  Widget _buildJobList(
    BuildContext context,
    WidgetRef ref,
    int tabIndex,
    String key,
  ) {
    final status = _getStatusFromIndex(tabIndex);
    final fetchJobs = ref.watch(fetchJobsProvider(key: key, status: status));

    return RefreshIndicator(
      onRefresh: () =>
          ref.refresh(fetchJobsProvider(key: key, status: status).future),
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
              onTap: () {
                context.goNamed(
                  AppRoute.detailJob.name,
                  extra: '${job.no_invoice}',
                );
              },
            );
          },
        ),
        error: (err, stack) => const Center(
          child: Text('Tidak ada data'),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
