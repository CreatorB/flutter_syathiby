import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/presentation/rpp/teaching_planner_controller.dart';
import 'package:syathiby/res/strings.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';
import '../webview/chrome_safari_browser.dart';

class TeachingPlannerScreen extends HookConsumerWidget {
  const TeachingPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchTeachingPlanner = ref.watch(
      fetchAllTeachingPlannerProvider(key: key),
    );
    final itemCount = fetchTeachingPlanner.isLoading
        ? 10
        : fetchTeachingPlanner.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('RPP'.hardcoded),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAllTeachingPlannerProvider(key: key).future,
        ),
        child: Skeletonizer(
          enabled: fetchTeachingPlanner.isLoading,
          child: ListView.separated(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final teachingPlanner =
                  fetchTeachingPlanner.valueOrNull?.elementAtOrNull(index);
              return ListTile(
                leading: Text(
                  '${index + 1}',
                  style: context.titleMediumBold,
                ),
                title: Text(
                  '${teachingPlanner?.mapel}',
                  style: context.titleMediumBold,
                ),
                subtitle: Text(
                  'Kelas: ${teachingPlanner?.kelas}',
                  style: context.titleMedium,
                ),
                trailing: Transform.translate(
                  offset: const Offset(8, 0),
                  child: const Icon(Icons.chevron_right),
                ),
                onTap: () {
                  context.goNamed(
                    AppRoute.detailTeachingPlanner.name,
                    extra: teachingPlanner,
                  );
                },
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final browser = MyChromeSafariBrowser();
          await browser.open(
            url: WebUri(AppConstant.teachingPlannerUrl),
            settings: ChromeSafariBrowserSettings(
              shareState: CustomTabsShareState.SHARE_STATE_OFF,
              barCollapsingEnabled: true,
            ),
          );
        },
        label: const Text('Buat RPP'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
