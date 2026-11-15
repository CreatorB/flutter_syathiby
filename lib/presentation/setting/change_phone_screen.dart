import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/res/strings.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/ui.dart';

import 'account_controller.dart';

/// Menormalkan nomor HP: buang spasi/strip, awalan +62/62 menjadi 0.
/// Mengembalikan null bila formatnya tidak valid.
String? normalizePhone(String input) {
  var value = input.replaceAll(RegExp(r'[\s\-()]'), '');
  if (value.startsWith('+62')) {
    value = '0${value.substring(3)}';
  } else if (value.startsWith('62')) {
    value = '0${value.substring(2)}';
  }
  return RegExp(r'^0\d{8,14}$').hasMatch(value) ? value : null;
}

class ChangePhoneScreen extends HookConsumerWidget {
  const ChangePhoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    ref.listen(accountControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final accountController = ref.watch(accountControllerProvider);
    final newPhone = useTextEditingController();
    final password = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final passwordVisible = useState<bool>(false);

    Future<void> changePhone() async {
      if (!formKey.currentState!.validate() || currentUser == null) {
        return;
      }
      final result = await ref.read(accountControllerProvider.notifier).changePhone(
            key: '${currentUser.key}',
            password: password.text,
            newPhone: normalizePhone(newPhone.text)!,
          );

      if (result == null || !context.mounted) return;
      context.showSuccessMessage(
        result.msg,
        onComplete: () async {
          final pref = ref.read(sharedPreferencesHelperProvider);
          await pref.remove(AppConstant.keyLoginSession);
          await pref.remove(AppConstant.keyRememberMe);
          await pref.remove(AppConstant.keySavedPhone);
          await pref.remove(AppConstant.keySavedPassword);
          if (context.mounted) {
            context.goNamed(AppRoute.login.name);
          }
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Nomor HP'),
      ),
      body: ListView(
        children: [
          Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Nomor HP dipakai untuk masuk ke aplikasi. Setelah berhasil, '
                    'Anda akan keluar dan harus masuk lagi dengan nomor yang baru.'
                        .hardcoded,
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: newPhone,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Nomor HP baru'.hardcoded,
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nomor HP wajib diisi'.hardcoded;
                      }
                      if (normalizePhone(value) == null) {
                        return 'Format nomor HP tidak valid'.hardcoded;
                      }
                      return null;
                    },
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: password,
                    obscureText: !passwordVisible.value,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Password saat ini'.hardcoded,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        padding: const EdgeInsets.all(16.0),
                        onPressed: () {
                          passwordVisible.value = !passwordVisible.value;
                        },
                        icon: Icon(
                          passwordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const Gap(24),
                  FilledButton(
                    onPressed: accountController.isLoading ? null : changePhone,
                    child: accountController.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Text('Simpan'.hardcoded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
