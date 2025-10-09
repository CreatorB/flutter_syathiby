import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/presentation/setting/presence_type.dart';
import 'package:syathiby/res/strings.dart';
import 'package:syathiby/utils/extension/ui.dart';

import 'account_controller.dart';
import 'local_auth_controller.dart';

class FingerprintScreen extends HookConsumerWidget {
  const FingerprintScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(accountControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final auth = ref.watch(localAuthProvider);
    final isBiometricsFaceId = ref.watch(isBiometricsFaceIdProvider);
    final biometricsTitle =
        isBiometricsFaceId.valueOrNull == true ? 'Face Id' : 'Sidik Jari';
    final registerPresenceFuture = useMemoized(
      () => registerPresence(context, ref, auth, key, biometricsTitle),
    );
    useFuture(registerPresenceFuture);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pendaftaran $biometricsTitle'.hardcoded),
        actions: [
          IconButton(
            onPressed: () async {
              showOkAlertDialog(
                context: context,
                title: 'Panduan'.hardcoded,
                message:
                    'Halaman ini digunakan untuk proses pendaftaran fingerprint di sisi server, Pastikan Handphone Anda support Fingerprint'
                        .hardcoded,
              );
            },
            icon: const Icon(Icons.info),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () async {
                    registerPresence(context, ref, auth, key, biometricsTitle);
                  },
                  icon: Icon(
                    isBiometricsFaceId.valueOrNull == true
                        ? Icons.face_unlock_outlined
                        : Icons.fingerprint,
                    size: 120,
                  ),
                ),
                const Gap(16),
                Text(
                  'Klik icon diatas untuk mengulangi\npendaftaran $biometricsTitle'
                      .hardcoded,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> registerPresence(
    BuildContext context,
    WidgetRef ref,
    LocalAuthentication auth,
    String key,
    String biometricsTitle,
  ) async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason:
            'Gunakan $biometricsTitle Anda untuk pendaftaran'.hardcoded,
        options: const AuthenticationOptions(useErrorDialogs: false),
      );
      final token = ref
          .read(sharedPreferencesHelperProvider)
          .getString(AppConstant.keyDeviceToken);
      if (!didAuthenticate) return;
      final result =
          await ref.read(accountControllerProvider.notifier).registerPresence(
                key: key,
                presenceType: PresenceType.biometric,
                token: token,
              );
      if (result == null || !context.mounted) return;
      showOkAlertDialog(
        context: context,
        message:
            '$biometricsTitle Anda berhasil disimpan dalam server'.hardcoded,
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // Add handling of no hardware here.
      } else if (e.code == auth_error.notEnrolled) {
        // ...
      } else {
        // ...
      }
    }
  }
}
