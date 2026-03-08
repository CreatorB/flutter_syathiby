import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/hostel/hostel.dart';
import 'package:syathiby/presentation/presence/presence_controller.dart';
import 'package:syathiby/res/strings.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../home/fetch_presence_controller.dart';
import '../setting/account_controller.dart';
import '../setting/local_auth_controller.dart';
import '../setting/presence_type.dart';

enum AttendanceMethod {
  location,
  wifi,
}

class PresenceScreen extends HookConsumerWidget {
  final PresenceType type;
  static const String _requiredWifiPublicIp = '103.178.146.98';

  const PresenceScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(accountControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final locationSelected = useState<Asrama?>(null);
    final auth = ref.watch(localAuthProvider);
    final isBiometricsFaceId = ref.watch(isBiometricsFaceIdProvider);
    final biometricsTitle =
        isBiometricsFaceId.valueOrNull == true ? 'Face Id' : 'Sidik Jari';
    final title =
        'Absensi ${type == PresenceType.biometric ? biometricsTitle : ''}';

    Future<void> showChooseLocationDialog() async {
      final locations = await ref.watch(
        fetchListHostelProvider(key: key).future,
      );
      if (!context.mounted) return;
      final message = type == PresenceType.biometric ? _getMessageInfo() : null;
      final selected = await showConfirmationDialog<Asrama>(
        context: context,
        title: 'Lokasi Presensi',
        message: message,
        actions: locations
            .map(
              (e) => AlertDialogAction(key: e, label: '${e.namaAsrama}'),
            )
            .toList(),
      );
      if (selected == null || !context.mounted) return;
      locationSelected.value = selected;

      final method = await showConfirmationDialog<AttendanceMethod>(
        context: context,
        title: 'Metode Absensi',
        message: 'Silakan pilih metode absensi',
        actions: const [
          AlertDialogAction(
            key: AttendanceMethod.location,
            label: 'Lokasi / GPS',
          ),
          AlertDialogAction(
            key: AttendanceMethod.wifi,
            label: 'Wi-Fi',
          ),
        ],
      );
      if (method == null || !context.mounted) return;

      final isWifiMethod = method == AttendanceMethod.wifi;
      if (isWifiMethod) {
        final isWifiIpValid = await _validateWifiPublicIp(context, ref);
        if (!isWifiIpValid || !context.mounted) return;
      }

      if (type == PresenceType.biometric) {
        await presenceBiometric(
          context: context,
          ref: ref,
          auth: auth,
          key: key,
          biometricsTitle: biometricsTitle,
          locationPresenceId: '${selected.idAsrama}',
          useWifiMethod: isWifiMethod,
        );
        return;
      }
      await presenceNormal(
        context: context,
        ref: ref,
        key: key,
        locationPresenceId: '${selected.idAsrama}',
        useWifiMethod: isWifiMethod,
      );
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) async {
          await showChooseLocationDialog();
        },
      );
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text(title.hardcoded),
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
                Text(
                  'Tempat Absen',
                  style: context.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Visibility(
                  visible: locationSelected.value?.namaAsrama != null,
                  child: Text(
                    '${locationSelected.value?.namaAsrama}',
                    style: context.titleLargeBold,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () async {
                    await showChooseLocationDialog();
                  },
                  icon: Icon(
                    type == PresenceType.normal
                        ? Icons.person
                        : isBiometricsFaceId.valueOrNull == true
                            ? Icons.face_unlock_outlined
                            : Icons.fingerprint,
                    size: 120,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Klik icon diatas untuk mengulangi absensi'.hardcoded,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMessageInfo() {
    return """Pastikan Hanphone Anda memiliki Fitur Biometrik (Sidik jari / Face ID) dan 
    pastikan juga sidik jari Anda sudah terdaftar di server.
""";
  }

  Future<void> presenceNormal({
    required BuildContext context,
    required WidgetRef ref,
    required String key,
    required String locationPresenceId,
    required bool useWifiMethod,
  }) async {
    try {
      final position =
        useWifiMethod ? null : await ref.read(getCurrentLocationProvider.future);
      final latitude = useWifiMethod ? 0.0 : position!.latitude;
      final longitude = useWifiMethod ? 0.0 : position!.longitude;
      final mock = useWifiMethod ? false : position!.isMocked;
      final result = await ref.read(accountControllerProvider.notifier).presence(
            key: key,
            presenceType: type,
            latitude: latitude,
            longitude: longitude,
            locationPresenceName: locationPresenceId,
            mock: mock,
          );

      if (result == null || !context.mounted) return;

      // Check if response is an error (has errCode that's not '01')
      if (result.errCode != null && result.errCode != '01') {
        // Error response from server
        if (!context.mounted) return;
        context.showErrorMessage(
          result.msg ?? 'Terjadi kesalahan saat absen',
        );
        return;
      }

      if (result.status == 'late') {
        showReasonLate(context, ref, key, '${result.status}');
      } else {
        final message =
            'Success Anda ${result.status} Luar biasa, terus pertahankan';
        context.showSuccessMessage(
          message,
          onComplete: () {
            context.pop();
          },
        );
      }
    } catch (error) {
      if (!context.mounted) return;
      final errorMessage = error.toString();
      final isLocationError = errorMessage.toLowerCase().contains('lokasi') ||
          errorMessage.toLowerCase().contains('permission') ||
          errorMessage.toLowerCase().contains('izin') ||
          errorMessage.toLowerCase().contains('denied') ||
          errorMessage.toLowerCase().contains('browser');

      if (isLocationError) {
        await showOkAlertDialog(
          context: context,
          title: 'Gagal Mendapatkan Lokasi',
          message: errorMessage,
          okLabel: kIsWeb ? 'Mengerti' : 'Buka Pengaturan',
        ).then((value) async {
          if (!kIsWeb) {
            await Geolocator.openAppSettings();
          }
        });
        return;
      }
      context.showErrorMessage(errorMessage);
    }
  }

  Future<void> presenceBiometric({
    required BuildContext context,
    required WidgetRef ref,
    required LocalAuthentication auth,
    required String key,
    required String biometricsTitle,
    required String locationPresenceId,
    required bool useWifiMethod,
  }) async {
    try {
      final position =
        useWifiMethod ? null : await ref.read(getCurrentLocationProvider.future);
      final latitude = useWifiMethod ? 0.0 : position!.latitude;
      final longitude = useWifiMethod ? 0.0 : position!.longitude;
      final mock = useWifiMethod ? false : position!.isMocked;
      final bool didAuthenticate = await auth.authenticate(
        localizedReason:
            'Gunakan $biometricsTitle Anda untuk absensi'.hardcoded,
        options: const AuthenticationOptions(useErrorDialogs: false),
      );
      if (!context.mounted || !didAuthenticate) return;

      final token = ref
          .read(sharedPreferencesHelperProvider)
          .getString(AppConstant.keyDeviceToken);

      final result =
          await ref.read(accountControllerProvider.notifier).presence(
                key: key,
                presenceType: type,
                token: token,
                latitude: latitude,
                longitude: longitude,
                locationPresenceName: locationPresenceId,
                mock: mock,
              );

      if (result == null || !context.mounted) return;

      if (result.status == 'late') {
        showReasonLate(context, ref, key, '${result.status}');
      } else {
        final message =
            'Success Anda ${result.status} Luar biasa, terus pertahankan';
        context.showSuccessMessage(
          message,
          onComplete: () {
            context.pop();
            ref.invalidate(fetchPresenceProvider(key: key));
          },
        );
      }
    } on PlatformException catch (e) {
      if (!context.mounted) return;
      if (e.code == auth_error.notAvailable) {
        context.showErrorMessage('Biometrik tidak tersedia di perangkat ini');
      } else if (e.code == auth_error.notEnrolled) {
        context.showErrorMessage(
            'Sidik jari/Face ID belum terdaftar di perangkat');
      } else {
        context.showErrorMessage(e.message);
      }
    } catch (error) {
      if (!context.mounted) return;
      final errorMessage = error.toString();
      final isLocationError = errorMessage.toLowerCase().contains('lokasi') ||
          errorMessage.toLowerCase().contains('permission') ||
          errorMessage.toLowerCase().contains('izin') ||
          errorMessage.toLowerCase().contains('denied') ||
          errorMessage.toLowerCase().contains('browser');

      if (isLocationError) {
        await showOkAlertDialog(
          context: context,
          title: 'Gagal Mendapatkan Lokasi',
          message: errorMessage,
          okLabel: kIsWeb ? 'Mengerti' : 'Buka Pengaturan',
        ).then((value) async {
          if (!kIsWeb) {
            await Geolocator.openAppSettings();
          }
        });
        return;
      }
      context.showErrorMessage(errorMessage);
    }
  }

  Future<bool> _validateWifiPublicIp(BuildContext context, WidgetRef ref) async {
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        'https://api.ipify.org?format=json',
        options: Options(responseType: ResponseType.json),
      );
      if (!context.mounted) return false;
      final data = response.data;
      final ip = data is Map<String, dynamic> ? '${data['ip'] ?? ''}' : '';
      if (ip == _requiredWifiPublicIp) {
        return true;
      }

      context.showErrorMessage(
        'Pastikan menggunakan Wi-Fi ma\'had. IP publik saat ini: ${ip.isEmpty ? '-' : ip}',
      );
      return false;
    } catch (_) {
      if (!context.mounted) return false;
      context.showErrorMessage(
        'Gagal mengecek IP publik. Pastikan menggunakan Wi-Fi ma\'had dan internet aktif.',
      );
      return false;
    }
  }

  Future<void> showReasonLate(
    BuildContext context,
    WidgetRef ref,
    String key,
    String status,
  ) async {
    final message =
        '“Setiap muslim harus menyesuaikan diri dengan kesepakatan yang dia setujui. Kecuali kesepakatan yang mengharamkan yang halal atau menghalalkan yang haram.” (HR. at-Thabrani dalam al-Mu’jam al-Kabir).\n\n\n" Anda $status Silahkan isi Alasan Anda';
    final reasonLate = await showTextInputDialog(
      context: context,
      title: 'Info',
      message: message,
      textFields: [
        DialogTextField(
          hintText: 'Alasan terlambat',
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null) return 'tidak boleh kosong';
            return null;
          },
          autocorrect: true,
        ),
      ],
    );

    final value = reasonLate?.firstOrNull;
    final result = await ref
        .read(accountControllerProvider.notifier)
        .reasonLate(key: key, reason: value ?? '', isClockIn: true);
    if (result == null || !context.mounted) return;

    context.showSuccessMessage(
      'Terimakasih, semoga besok lebih baik lagi',
      onComplete: () {
        context.pop();
        ref.invalidate(fetchPresenceProvider(key: key));
      },
    );
  }
}
