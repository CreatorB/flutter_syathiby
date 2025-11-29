import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/res/strings.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

import 'account_controller.dart';
import 'local_auth_controller.dart';

class SettingScreen extends HookConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchUserProfile = ref.watch(fetchProfileProvider(key: key));
    final isDarkMode = AdaptiveTheme.of(context).mode.isDark;
    final isBiometricsFaceId = ref.watch(isBiometricsFaceIdProvider);
    final biometricsTitle =
        isBiometricsFaceId.valueOrNull == true ? 'Face Id' : 'Sidik Jari';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Akun'.hardcoded,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  context.goNamed(AppRoute.account.name);
                },
                child: Card(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CustomAvatar(
                          name: '${fetchUserProfile.valueOrNull?.fullName}',
                          imageUrl: '${fetchUserProfile.valueOrNull?.img}',
                          size: 60,
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${fetchUserProfile.valueOrNull?.fullName}',
                                style: context.titleMediumBold,
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                '${fetchUserProfile.valueOrNull?.phoneNumber}',
                                style: context.titleSmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.edit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Akun'.hardcoded,
                style: context.titleMediumBold,
              ),
              const SizedBox(height: 8.0),
              Column(
                children: [
                  buildListItem(
                    'Ubah Profil',
                    onTap: () {
                      context.goNamed(AppRoute.account.name);
                    },
                  ),
                  const Divider(),
                  buildListItem(
                    'Pendaftaran Absen $biometricsTitle',
                    onTap: () {
                      context.goNamed(AppRoute.fingerprint.name);
                    },
                  ),
                  // const Divider(),
                  // buildListItem(
                  //   'Pendaftaran Absen Wajah',
                  //   onTap: () {
                  //     context.goNamed(AppRoute.faceUnlock.name);
                  //   },
                  // ),
                  const Divider(),
                  buildListItem(
                    'Ubah Password',
                    onTap: () {
                      context.goNamed(AppRoute.changePassword.name);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                'Lainnya'.hardcoded,
                style: context.titleMediumBold,
              ),
              const SizedBox(height: 8.0),
              Column(
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.only(left: 16),
                    value: isDarkMode,
                    onChanged: (value) {
                      AdaptiveTheme.of(context).toggleThemeMode(
                        useSystem: false,
                      );
                    },
                    title: const Text('Mode Gelap'),
                  ),
                  const Divider(),
                  buildListItem(
                    'Kebijakan Privasi',
                    onTap: () {
                      context.goNamed(
                        AppRoute.privacyPolicy.name,
                        queryParameters: {
                          'title': 'Kebijakan Privasi',
                          'url': AppConstant.privacyUrl,
                        },
                      );
                    },
                  ),
                  const Divider(),
                  buildListItem(
                    'Syarat & Ketentuan',
                    onTap: () {
                      context.goNamed(
                        AppRoute.privacyPolicy.name,
                        queryParameters: {
                          'title': 'Syarat & Ketentuan',
                          'url': AppConstant.termUrl,
                        },
                      );
                    },
                  ),
                  const Divider(),
                  buildListItem(
                    'Tentang Kami',
                    onTap: () {
                      context.goNamed(
                        AppRoute.aboutUs.name,
                        queryParameters: {
                          'title': 'Tentang kami',
                          'url': AppConstant.aboutUrl,
                        },
                      );
                    },
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () async {
                    await ref
                        .watch(sharedPreferencesHelperProvider)
                        .remove(AppConstant.keyLoginSession);
                    context.goNamed(AppRoute.login.name);
                  },
                  icon: Icon(
                    Icons.exit_to_app,
                    color: context.colorError,
                  ),
                  label: Text(
                    'Keluar',
                    style: context.titleMediumBold?.copyWith(
                      color: context.colorError,
                    ),
                  ),
                ),
              ),
              Center(
                child: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        'Versi ${snapshot.data!.version}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colorPrimary.withOpacity(0.8),
                        ),
                      );
                    }
                    return const SizedBox(); // Jangan tampilkan apa-apa saat loading
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListItem(String title, {IconData? icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            if (icon != null) Icon(icon),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
