import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/generated/assets.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/res/strings.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/ui.dart';

import 'package:restart_app/restart_app.dart';
import 'package:syathiby/res/environment_config.dart';
import 'login_controller.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(loginControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final state = ref.watch(loginControllerProvider);
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final passwordVisible = useState(false);
    final phoneNumberController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLocalEnv = EnvironmentConfig.isLocalEnvironment;
    final envLabel = EnvironmentConfig.environmentLabel;
    final baseUrl = EnvironmentConfig.baseUrl;

    return Scaffold(
      body: Form(
        key: formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 40.0,
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onLongPress: () {
                      final baseUrlController = TextEditingController(
                        text: EnvironmentConfig.baseUrl,
                      );
                      final linkBaseController = TextEditingController(
                        text: EnvironmentConfig.linkBase,
                      );
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Debug Mode: Ganti API URL'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: baseUrlController,
                                  decoration: const InputDecoration(
                                    labelText: 'API_URL',
                                    hintText: 'https://...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const Gap(16),
                                TextField(
                                  controller: linkBaseController,
                                  decoration: const InputDecoration(
                                    labelText: 'LINK_BASE',
                                    hintText: 'https://...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  await EnvironmentConfig.reset();
                                  if (context.mounted) Navigator.pop(context);
                                  Restart.restartApp();
                                },
                                child: const Text(
                                  'Reset',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Batal'),
                              ),
                              FilledButton(
                                onPressed: () async {
                                  await EnvironmentConfig.updateConfig(
                                    baseUrl: baseUrlController.text,
                                    linkBase: linkBaseController.text,
                                  );
                                  if (context.mounted) Navigator.pop(context);
                                  Restart.restartApp();
                                },
                                child: const Text('Simpan & Restart'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Image.asset(
                      Assets.imagesLogo,
                      width: 175,
                      height: 175,
                    ),
                  ),
                  const Gap(16),
                  Text(
                    AppConstant.appName,
                    style: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isLocalEnv
                          ? Colors.red.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isLocalEnv ? Colors.red : Colors.green,
                      ),
                    ),
                    child: Text(
                      'ENV: $envLabel • API: $baseUrl',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isLocalEnv ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                  const Gap(32),
                  TextFormField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomer Telepon'.hardcoded,
                      prefixIcon: const Icon(Icons.phone),
                      border: const OutlineInputBorder(),
                    ),
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                      ],
                    ),
                  ),
                  const Gap(20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: !passwordVisible.value,
                    decoration: InputDecoration(
                      labelText: 'Password'.hardcoded,
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
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
                    validator: FormBuilderValidators.compose(
                      [
                        FormBuilderValidators.required(),
                        FormBuilderValidators.minLength(6),
                      ],
                    ),
                  ),
                  const Gap(20),
                  FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      // final loginResult = await ref
                      //     .read(loginControllerProvider.notifier)
                      //     .login(
                      //       phoneNumber: phoneNumberController.text,
                      //       password: passwordController.text,
                      //     );
                      // if (loginResult == null || !context.mounted) return;
                      // context.goNamed(AppRoute.home.name);
                      ref.read(loginControllerProvider.notifier).login(
                            phoneNumber: phoneNumberController.text,
                            password: passwordController.text,
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                      ),
                      minimumSize: const Size(
                        double.infinity,
                        50.0,
                      ),
                    ),
                    child: state.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                context.colorOnPrimary,
                              ),
                            ),
                          )
                        : const Text('Masuk'),
                  ),
                  const Gap(4),
                  TextButton(
                    onPressed: () {
                      context.showErrorMessage(
                        'Silahkan menguhubungi atasan untuk mendapatkan reset password',
                      );
                    },
                    child: Text(
                      'Lupa Password?',
                      style: TextStyle(
                        color: context.colorPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
