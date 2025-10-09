import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/reward/reward_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RewardScreen extends HookConsumerWidget {
  final String? title;

  const RewardScreen({super.key, this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchAllRewardProvider(key: key),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllReward = ref.watch(fetchAllRewardProvider(key: key));
    final itemCount =
        fetchAllReward.isLoading ? 10 : fetchAllReward.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reward $title'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAllRewardProvider(
            key: key,
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllReward.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final reward = fetchAllReward.valueOrNull?.elementAtOrNull(index);
              final status = reward?.status;
              final isStatusRejected = status == "Laporan Ditolak";
              final isStatusAccepted = status == "Selesai";
              final dateFormat = ref.watch(formatDateProvider(
                '${reward?.date}',
                format: 'EEE, dd MMMM yyyy',
              ));

              return ListTile(
                title: Text(
                  '${reward?.namaSiswa}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyMediumBold,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${reward?.namaPelanggaran}',
                      style: context.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$dateFormat',
                      style: context.bodySmall?.copyWith(
                        color: context.colorOnSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
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
                leading: CustomAvatar(
                  name: '${reward?.namaSiswa}',
                  imageUrl: '${reward?.img}',
                  size: 40,
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(
            AppRoute.addStudentReward.name,
            queryParameters: {'title': '$title'},
          );
        },
        label: const Text('Tambah Reward'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
