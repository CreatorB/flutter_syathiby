import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';

class ScaffoldNestedNavigation extends HookConsumerWidget {
  const ScaffoldNestedNavigation(this.navigationShell, {super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveScaffold(
      // An option to override the default breakpoints used for small, medium,
      // and large.
      // smallBreakpoint: const Breakpoints.small(end: 700),
      // mediumBreakpoint: const WidthPlatformBreakpoint(begin: 700, end: 1000),
      // largeBreakpoint: const WidthPlatformBreakpoint(begin: 1000),
      useDrawer: false,
      selectedIndex: navigationShell.currentIndex,
      onSelectedIndexChange: (int index) {
        _goBranch(index);
      },
      destinations: <NavigationDestination>[
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: 'Beranda'.hardcoded,
        ),
        NavigationDestination(
          icon: const Icon(Icons.article_outlined),
          selectedIcon: const Icon(Icons.article),
          label: 'Berita'.hardcoded,
        ),
        NavigationDestination(
          icon: const Icon(Icons.mosque_outlined),
          selectedIcon: const Icon(Icons.mosque),
          label: 'Ibadah'.hardcoded,
        ),
        NavigationDestination(
          icon: const Icon(Icons.insert_chart_outlined),
          selectedIcon: const Icon(Icons.insert_chart),
          label: 'Kinerja'.hardcoded,
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: 'Akun'.hardcoded,
        ),
      ],
      body: (_) => SafeArea(
        bottom: false,
        child: navigationShell,
      ),
      // smallBody: (_) => ListView.builder(
      //   itemCount: children.length,
      //   itemBuilder: (_, int idx) => children[idx],
      // ),
      // Define a default secondaryBody.
      // secondaryBody: (_) => Container(
      //   color: const Color.fromARGB(255, 234, 158, 192),
      // ),
      // Override the default secondaryBody during the smallBreakpoint to be
      // empty. Must use AdaptiveScaffold.emptyBuilder to ensure it is properly
      // overridden.
      smallSecondaryBody: AdaptiveScaffold.emptyBuilder,
    );
  }

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
