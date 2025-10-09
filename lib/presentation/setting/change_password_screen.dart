import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/utils/extension/ui.dart';

import 'account_controller.dart';

class ChangePasswordScreen extends HookConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    ref.listen(accountControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final accountController = ref.watch(accountControllerProvider);
    final oldPassword = useTextEditingController();
    final newPassword = useTextEditingController();
    final confirmPassword = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final oldPasswordVisible = useState<bool>(false);
    final newPasswordVisible = useState<bool>(false);
    final confirmPasswordVisible = useState<bool>(false);

    Future<void> changePassword() async {
      if (!formKey.currentState!.validate() || currentUser == null) {
        return;
      }
      final result = await ref
          .read(
            accountControllerProvider.notifier,
          )
          .changePassword(
            key: '${currentUser.key}',
            oldPassword: oldPassword.text.trim(),
            newPassword: newPassword.text.trim(),
          );

      if (result == null || !context.mounted) return;
      context.showSuccessMessage(
        result.msg,
        onComplete: () => context.pop(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Password'),
      ),
      body: ListView(
        children: [
          Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: oldPassword,
                    obscureText: !oldPasswordVisible.value,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Password lama'.hardcoded,
                      prefixIcon: const Icon(Icons.password),
                      suffixIcon: IconButton(
                        padding: const EdgeInsets.all(16.0),
                        onPressed: () {
                          oldPasswordVisible.value = !oldPasswordVisible.value;
                        },
                        icon: Icon(
                          oldPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.min(6),
                        FormBuilderValidators.required(),
                      ],
                    ),
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: newPassword,
                    obscureText: !newPasswordVisible.value,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Password baru'.hardcoded,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        padding: const EdgeInsets.all(16.0),
                        onPressed: () {
                          newPasswordVisible.value = !newPasswordVisible.value;
                        },
                        icon: Icon(
                          newPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.min(6),
                        FormBuilderValidators.required(),
                      ],
                    ),
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: confirmPassword,
                    obscureText: !confirmPasswordVisible.value,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Konfirmasi Password'.hardcoded,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        padding: const EdgeInsets.all(16.0),
                        onPressed: () {
                          confirmPasswordVisible.value =
                              !confirmPasswordVisible.value;
                        },
                        icon: Icon(
                          confirmPasswordVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.min(6),
                        FormBuilderValidators.required(),
                      ],
                    ),
                  ),
                  const Gap(24),
                  FilledButton(
                    onPressed:
                        accountController.isLoading ? null : changePassword,
                    child: accountController.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Text(
                            'Simpan'.hardcoded,
                          ),
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
