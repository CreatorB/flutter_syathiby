import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/presentation/penilaian/score_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class ScoreTypeScreen extends HookConsumerWidget {
  const ScoreTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchScoreTypes = ref.watch(
      fetchAllScoreTypeProvider(key: key, type: 'Kependidikan'),
    );
    final itemCount = fetchScoreTypes.isLoading
        ? 10
        : fetchScoreTypes.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Jenis Penilaian'.hardcoded),
      ),
      body: RefreshIndicator(
        child: Skeletonizer(
          enabled: fetchScoreTypes.isLoading,
          child: ListView.separated(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final scoreType =
                  fetchScoreTypes.valueOrNull?.elementAtOrNull(index);
              return ListTile(
                title: Text(
                  '${scoreType?.nameJenisPenilaian}',
                  style: context.titleMediumBold,
                ),
                trailing: Transform.translate(
                  offset: const Offset(8, 0),
                  child: const Icon(Icons.chevron_right),
                ),
                onTap: () {
                  context.goNamed(
                    AppRoute.subjects.name,
                    queryParameters: {
                      'scoreTypeId': scoreType?.idJenisPenilaian
                    },
                  );
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
          ),
        ),
        onRefresh: () => ref.refresh(
          fetchAllScoreTypeProvider(key: key, type: 'Kependidikan').future,
        ),
      ),
    );
  }
}
