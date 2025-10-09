import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:syathiby/presentation/report/report_controller.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';
import '../../models/slip/absent.dart';

class DetailAttendanceReportScreen extends HookConsumerWidget {
  final Absent absent;

  const DetailAttendanceReportScreen({
    super.key,
    required this.absent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(reportControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final reportController = ref.watch(reportControllerProvider);
    final formatDate = ref.watch(formatDateProvider(
      '${absent.date}',
      format: 'EEEE, dd MMMM yyyy',
    ));
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final isStaff = currentUser?.level == "staff";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Lainnya'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$formatDate',
                style: context.titleMediumBold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              CustomAvatar(
                imageUrl: '${absent.img}',
                name: '${absent.name_staff}',
                size: 150,
              ),
              const SizedBox(height: 20.0),
              Text(
                '${absent.name_staff}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              Card.outlined(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10.0),
                    const Center(
                      child: Text(
                        'Detail Absensi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Divider(),
                    _buildRowText('Jenis Absensi', '${absent.type}'),
                    _buildRowText('Waktu Absensi', '${absent.timeattand}'),
                    _buildRowText('Keterlambatan', '${absent.late}'),
                    _buildRowText('Bekerja Selama', '${absent.during}'),
                    _buildRowText('Lokasi Absensi', '${absent.distance}'),
                    _buildRowText('Selesai Bekerja', '${absent.done}'),
                    _buildRowText('Status', '${absent.status}'),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
              const SizedBox(height: 15.0),
              Card.outlined(
                child: Column(
                  children: [
                    const SizedBox(height: 10.0),
                    const Text(
                      'Cek Lokasi Kehadiran',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Column(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: context.colorPrimary,
                              ),
                              const SizedBox(height: 4),
                              const Text('Absen Masuk'),
                            ],
                          ),
                          onPressed: () async {
                            final location = absent.location?.split(', ');
                            final latitude =
                                double.tryParse('${location?.first}');
                            final longitude =
                                double.tryParse('${location?.last}');
                            if (latitude == null || longitude == null) return;
                            final isAvailable =
                                await MapLauncher.isMapAvailable(
                                    MapType.google);
                            if (isAvailable == true) {
                              await MapLauncher.showMarker(
                                mapType: MapType.google,
                                coords: Coords(latitude, longitude),
                                title: "Lokasi Absensi",
                                description: 'Lokasi Absensi',
                              );
                            } else {
                              final availableMaps =
                                  await MapLauncher.installedMaps;
                              await availableMaps.first.showMarker(
                                coords: Coords(latitude, longitude),
                                title: "Lokasi Absensi",
                                description: 'Lokasi Absensi',
                              );
                            }
                            // MapsLauncher.launchCoordinates(latitude, longitude);
                          },
                        ),
                        IconButton(
                          icon: Column(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: context.colorError,
                              ),
                              const SizedBox(height: 4),
                              const Text('Absen Pulang'),
                            ],
                          ),
                          onPressed: () async {
                            final location = absent.locationfinish?.split(', ');
                            final latitude =
                                double.tryParse('${location?.first}');
                            final longitude =
                                double.tryParse('${location?.last}');
                            if (latitude == null || longitude == null) return;

                            final isAvailable =
                                await MapLauncher.isMapAvailable(
                                    MapType.google);
                            if (isAvailable == true) {
                              await MapLauncher.showMarker(
                                mapType: MapType.google,
                                coords: Coords(latitude, longitude),
                                title: "Lokasi Absensi",
                                description: 'Lokasi Absensi',
                              );
                            } else {
                              final availableMaps =
                                  await MapLauncher.installedMaps;
                              await availableMaps.first.showMarker(
                                coords: Coords(latitude, longitude),
                                title: "Lokasi Absensi",
                                description: 'Lokasi Absensi',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              Visibility(
                visible: isStaff == false,
                child: FilledButton(
                  onPressed: reportController.isLoading
                      ? null
                      : () async {
                          final dialogResult = await showOkCancelAlertDialog(
                              context: context,
                              title: 'Info',
                              message: 'Pilih OK untuk menolak absensi');
                          if (dialogResult == OkCancelResult.cancel) return;
                          final result = await ref
                              .read(reportControllerProvider.notifier)
                              .rejectAttendance(
                                key: key,
                                attendanceId: '${absent.id_attendance}',
                              );
                          if (result == null || !context.mounted) return;
                          context.showSuccessMessage(result.msg);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorError,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: reportController.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : const Text(
                          'Tolak Absensi',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowText(
    String title,
    String value, {
    bool enableValueBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        enableValueBold ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
