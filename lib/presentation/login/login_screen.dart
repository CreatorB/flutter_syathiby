import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/generated/assets.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/res/env.dart';
import 'package:syathiby/res/flavor_config.dart';
import 'package:syathiby/res/strings.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/ui.dart';

import 'login_controller.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(loginControllerProvider, (previous, next) {
      next.showToastOnError(context);

      // Router redirect will move user after session is saved.
      if (previous?.isLoading == true && next.hasValue && context.mounted) {
        // Navigation handled by router redirect
      }
    });
    final state = ref.watch(loginControllerProvider);
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final passwordVisible = useState(false);
    final phoneNumberController = useTextEditingController();
    final passwordController = useTextEditingController();

    final savedPhone = useMemoized(() {
      final pref = ref.read(sharedPreferencesHelperProvider);
      return pref.getString(AppConstant.keySavedPhone);
    }, []);

    final savedPassword = useMemoized(() {
      final pref = ref.read(sharedPreferencesHelperProvider);
      return pref.getString(AppConstant.keySavedPassword);
    }, []);

    final savedRememberMe = useMemoized(() {
      final pref = ref.read(sharedPreferencesHelperProvider);
      return pref.getString(AppConstant.keyRememberMe) == 'true';
    }, []);

    final rememberMe = useState(savedRememberMe);

    useEffect(() {
      if (savedRememberMe == true) {
        if (savedPhone != null) phoneNumberController.text = savedPhone;
        if (savedPassword != null) passwordController.text = savedPassword;
      } else if (FlavorConfig.isLocal) {
        if (LocalEnv.testPhone.isNotEmpty) {
          phoneNumberController.text = LocalEnv.testPhone;
        }
        if (LocalEnv.testPassword.isNotEmpty) {
          passwordController.text = LocalEnv.testPassword;
        }
      }
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/guest-user');
          },
        ),
      ),
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
                  Image.asset(
                    Assets.imagesLogo,
                    width: 175,
                    height: 175,
                  ),
                  const Gap(16),
                  Text(
                    AppConstant.appName,
                    style: const TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
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
                  const Gap(12),
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe.value,
                        onChanged: (value) {
                          rememberMe.value = value ?? false;
                        },
                      ),
                      const Text('Ingat Saya'),
                    ],
                  ),
                  const Gap(8),
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
                            rememberMe: rememberMe.value,
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
