import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/presentation/report/report_controller.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class AttendanceRecapScreen extends HookConsumerWidget {
  final String? startDate;
  final String? endDate;
  final String? userKey;

  const AttendanceRecapScreen({
    super.key,
    this.startDate,
    this.endDate,
    this.userKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenshotController = useMemoized(() => ScreenshotController());
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
        fetchAttendanceRecapProvider(
          key: userKey ?? key,
          startDate: '$startDate',
          endDate: '$endDate',
        ), (previous, next) {
      next.showToastOnError(context);
    });
    final fetchAttendanceRecap = ref.watch(
      fetchAttendanceRecapProvider(
        key: userKey ?? key,
        startDate: '$startDate',
        endDate: '$endDate',
      ),
    );
    final attendance = fetchAttendanceRecap.valueOrNull?.firstOrNull;
    final period = attendance?.period?.split(' s/d ');
    final startDateFormat =
        DateFormat('yyyy-MM-dd').tryParse('${period?.firstOrNull}');
    final endDateFormat = ref.watch(
        formatDateProvider('${period?.lastOrNull}', format: 'dd MMMM yyyy'));
    final dateFormat = '${startDateFormat?.day} - $endDateFormat';

    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rekap Absensi'),
          actions: [
            IconButton(
              onPressed: () async {
                try {
                  final result = await screenshotController.capture();
                  if (result == null) {
                    context.showErrorMessage('Gagal menyimpan screenshot');
                    return;
                  }
                  // Save the image temporarily in the device's temp directory
                  final tempDir = await getTemporaryDirectory();
                  final file =
                  await File('${tempDir.path}/screenshot.png').create();
                  await file.writeAsBytes(result);

                  await Share.shareXFiles(
                    [
                      XFile(
                        file.path,
                        name: 'screenshot.png',
                        mimeType: 'image/png',
                      ),
                    ],
                  );
                } catch (error) {
                  context.showErrorMessage('Gagal membagikan screenshot');
                }
              },
              icon: const Icon(Icons.share),
            )
          ],
        ),
        body: Skeletonizer(
          enabled: fetchAttendanceRecap.isLoading,
          child: RefreshIndicator(
            onRefresh: () => ref.refresh(
              fetchAttendanceRecapProvider(
                key: userKey ?? key,
                startDate: '$startDate',
                endDate: '$endDate',
              ).future,
            ),
            child: ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${attendance?.fullName}',
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Text(
                            'Jabatan',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${attendance?.part}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          const Text(
                            'Periode',
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              dateFormat,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: const Text(
                    'KEHADIRAN',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildTextRow('Jumlah Kehadiran', '${attendance?.presence}'),
                _buildTextRow('Tepat Waktu', '${attendance?.ontime}'),
                _buildTextRow('Keterlambatan', '${attendance?.late}'),
                _buildTextRow('Tidak Hadir', '${attendance?.notPresent}'),
                _buildTextRow('Izin', '${attendance?.permit}'),
                _buildTextRow('Lembur', '${attendance?.overtime}'),
                const Divider(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: const Text(
                    'PENUGASAN KERJA',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildTextRow('Jumlah Penugasan', '${attendance?.assign}'),
                _buildTextRow('Dalam Proses', '${attendance?.proses}'),
                _buildTextRow('Pekerjaan Selesai', '${attendance?.finish}'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 6.0,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
