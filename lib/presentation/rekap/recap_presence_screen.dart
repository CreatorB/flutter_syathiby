import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' hide Store;
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/presentation/rekap/recap_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';
import '../../models/store/store.dart';
import 'package:path_provider/path_provider.dart';

class RecapPresenceScreen extends HookConsumerWidget {
  const RecapPresenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenshotController = useMemoized(() => ScreenshotController());
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchAllGroup = ref.watch(fetchAllGroupProvider(key: key));
    final group = fetchAllGroup.valueOrNull?.firstOrNull;
    final groupSelected = useState<Store?>(group);
    final dateSelected = useState<DateTime>(DateTime.now());
    final dateFormatSelected =
        DateFormat('yyyy-MM-dd').format(dateSelected.value);
    final fetchAttendanceRecap = ref.watch(
      fetchAllRecapPresenceProvider(
        key: key,
        startDate: dateFormatSelected,
        endDate: dateFormatSelected,
        groupId: groupSelected.value?.idStore ?? '',
      ),
    );
    final attendance = fetchAttendanceRecap.valueOrNull?.firstOrNull;
    final startDateFormat = ref.watch(
      formatDateProvider('${attendance?.date}', format: 'EEEE, dd MMMM yyyy'),
    );

    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rekap Absensi'),
          actions: [
            IconButton(
              onPressed: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: dateSelected.value,
                  lastDate: DateTime.now(),
                  firstDate: DateTime(2000),
                );
                if (selected == null) return;
                dateSelected.value = selected;
              },
              icon: const Icon(Icons.today),
            ),
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
            ),
          ],
        ),
        body: Skeletonizer(
          enabled: fetchAttendanceRecap.isLoading || fetchAllGroup.isLoading,
          child: RefreshIndicator(
            onRefresh: () => Future.wait(
              [
                ref.refresh(
                  fetchAllRecapPresenceProvider(
                    key: key,
                    startDate: dateFormatSelected,
                    endDate: dateFormatSelected,
                    groupId: groupSelected.value?.idStore ?? '',
                  ).future,
                ),
                ref.refresh(
                  fetchAllGroupProvider(key: key).future,
                ),
              ],
            ),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16,
                  ),
                  child: DropdownSearch<Store>(
                    selectedItem: groupSelected.value,
                    items: fetchAllGroup.valueOrNull ?? [],
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          isDense: true,
                          hintText: 'Pencarian...',
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                    itemAsString: (item) => '${item.nameStore}',
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'Grup Divisi',
                        labelText: 'Grup Divisi',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.group),
                      ),
                    ),
                    onChanged: (item) async {
                      groupSelected.value = item;
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Card.outlined(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '$startDateFormat',
                        style: context.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                _buildTextRow('Jumlah Pegawai', '${attendance?.jumlah}'),
                _buildTextRow('Tepat Waktu', '${attendance?.ontime}'),
                _buildTextRow(
                  'Terlambat',
                  '${attendance?.late}',
                  onTap: () {
                    context.goNamed(
                      AppRoute.filterRecapPresence.name,
                      queryParameters: {
                        'groupId': '${groupSelected.value?.idStore}',
                        'status': 'late',
                        'startDate': dateFormatSelected,
                        'endDate': dateFormatSelected,
                        'title': 'Terlambat',
                      },
                    );
                  },
                ),
                _buildTextRow('Pegawai Hadir', '${attendance?.hadir}'),
                _buildTextRow(
                  'Tidak Hadir atau Tidak Absen',
                  '${attendance?.alfa}',
                  onTap: () {
                    context.goNamed(
                      AppRoute.filterRecapPresence.name,
                      queryParameters: {
                        'groupId': '${groupSelected.value?.idStore}',
                        'status': 'login',
                        'startDate': dateFormatSelected,
                        'endDate': dateFormatSelected,
                        'title': 'Tidak Absen',
                      },
                    );
                  },
                ),
                _buildTextRow(
                  'Pegawai Izin',
                  '${attendance?.izin}',
                  onTap: () {
                    context.goNamed(
                      AppRoute.filterRecapPresence.name,
                      queryParameters: {
                        'groupId': '${groupSelected.value?.idStore}',
                        'status': 'permit',
                        'startDate': dateFormatSelected,
                        'endDate': dateFormatSelected,
                        'title': 'Pegawai Izin',
                      },
                    );
                  },
                ),
                const Divider(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: const Text(
                    'KEPULANGAN',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildTextRow('Tepat Waktu', '${attendance?.ontime2}'),
                _buildTextRow(
                  'Pulang Sebelum Waktunya',
                  '${attendance?.beforeTime}',
                  onTap: () {
                    context.goNamed(
                      AppRoute.filterRecapPresence.name,
                      queryParameters: {
                        'groupId': '${groupSelected.value?.idStore}',
                        'status': 'before the time',
                        'startDate': dateFormatSelected,
                        'endDate': dateFormatSelected,
                        'title': 'Pulang Sebelum Waktunya',
                      },
                    );
                  },
                ),
                _buildTextRow(
                  'Tidak Absen Pulang',
                  '${attendance?.notpresent2}',
                  onTap: () {
                    context.goNamed(
                      AppRoute.filterRecapPresence.name,
                      queryParameters: {
                        'groupId': '${groupSelected.value?.idStore}',
                        'status': 'logout',
                        'startDate': dateFormatSelected,
                        'endDate': dateFormatSelected,
                        'title': 'Tidak Absen Pulang',
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextRow(
    String title,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 6.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.0,
              ),
            ),
            Text(
              onTap != null ? '$value ➤' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
