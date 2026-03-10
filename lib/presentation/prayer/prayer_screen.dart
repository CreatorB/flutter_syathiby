import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/res/strings.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:syathiby/presentation/widgets/elegant_3d_icon.dart';

import '../home/menu_home.dart';
import '../webview/chrome_safari_browser.dart';
import 'dhikr_screen.dart';

class PrayerScreen extends HookConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menus = getMenus(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ibadah',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: ResponsiveGridRow(
        children: menus
            .map(
              (menu) => ResponsiveGridCol(
                lg: 2,
                md: 3,
                sm: 3,
                xs: 4,
                child: Column(
                  children: [
                    // 3D Elegant Sphere Icon Button with Bounce Effect
                    Elegant3DIconButton(
                      iconData: menu.iconData,
                      primaryColor: context.colorPrimary,
                      size: 68,
                      iconSize: 30,
                      onTap: menu.onClicked ??
                          () {
                            context.goNamed(
                              menu.goToRouteName,
                              extra: menu.extra,
                            );
                          },
                    ),
                    const SizedBox(height: 6),
                    Text(
                      menu.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colorOnSurface,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            )
            .toList(),
        ),
      ),
    );
  }

  List<MenuGrid> getMenus(BuildContext context) {
    final menus = [
      MenuGrid(
        title: 'Al-Quran',
        iconData: Icons.menu_book,
        goToRouteName: AppRoute.quran.name,
      ),
      MenuGrid(
        title: 'Hadits',
        iconData: Icons.book,
        goToRouteName: AppRoute.books.name,
      ),
      MenuGrid(
        title: 'Jadwal Shalat',
        iconData: Icons.access_time_rounded,
        goToRouteName: AppRoute.prayerTime.name,
      ),
      MenuGrid(
        title: 'Arah Kiblat',
        iconData: Icons.explore,
        goToRouteName: AppRoute.qibla.name,
      ),
      MenuGrid(
        title: 'Dzikir Pagi',
        iconData: Icons.sunny,
        goToRouteName: AppRoute.dhikr.name,
        extra: DhikrType.morning,
      ),
      MenuGrid(
        title: 'Dzikir Petang',
        iconData: Icons.brightness_6,
        goToRouteName: AppRoute.dhikr.name,
        extra: DhikrType.evening,
      ),
      MenuGrid(
        title: 'Murottal',
        iconData: Icons.spatial_audio_off,
        goToRouteName: AppRoute.murottal.name,
      ),
      MenuGrid(
        title: 'Masjid Terdekat',
        iconData: Icons.mosque,
        goToRouteName: '',
        onClicked: () async {
          openMaps();
        },
      ),
      MenuGrid(
        title: AppConstant.youtubeChannelName,
        iconData: Icons.live_tv,
        goToRouteName: AppRoute.tv.name,
      ),
    ];
    return menus;
  }

  void openMaps() async {
    final browser = MyChromeSafariBrowser();
    await browser.open(
      url: WebUri(
        'https://www.google.com/maps/search/?api=1&query=masjid+terdekat',
      ),
      settings: ChromeSafariBrowserSettings(
        shareState: CustomTabsShareState.SHARE_STATE_OFF,
        barCollapsingEnabled: true,
      ),
    );
  }
}
