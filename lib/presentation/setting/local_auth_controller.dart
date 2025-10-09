import 'package:local_auth/local_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'local_auth_controller.g.dart';

@Riverpod(keepAlive: true)
LocalAuthentication localAuth(LocalAuthRef ref) {
  return LocalAuthentication();
}

@riverpod
Future<bool> isDeviceSupportBiometrics(IsDeviceSupportBiometricsRef ref) async {
  final auth = ref.watch(localAuthProvider);
  final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
  final bool canAuthenticate =
      canAuthenticateWithBiometrics || await auth.isDeviceSupported();
  return canAuthenticate;
}

@riverpod
Future<bool> isBiometricsFaceId(IsBiometricsFaceIdRef ref) async {
  final List<BiometricType> availableBiometrics = await ref
      .watch(
        localAuthProvider,
      )
      .getAvailableBiometrics();
  return availableBiometrics.contains(BiometricType.face);
}

@riverpod
Future<bool> isBiometricsFingerprint(IsBiometricsFingerprintRef ref) async {
  final List<BiometricType> availableBiometrics = await ref
      .watch(
        localAuthProvider,
      )
      .getAvailableBiometrics();
  return availableBiometrics.contains(BiometricType.face);
}
