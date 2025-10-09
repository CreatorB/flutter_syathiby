import 'dart:io';

import 'package:syathiby/utils/extension/color.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/presentation/report/report_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../di/providers.dart';
import '../../models/staff/staff.dart';
import '../manage/manage_staff_controller.dart';
import 'package:path_provider/path_provider.dart';

import '../setting/account_controller.dart';

class AttendanceReportMonthScreen extends HookConsumerWidget {
  const AttendanceReportMonthScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final month = useTextEditingController();
    final currentMonth = DateFormat('MMMM', 'id').format(DateTime.now());
    final startDate = DateFormat('yyyy-MM-dd').format(
      DateTime.now().copyWith(day: 1),
    );
    final endDayOfMonth = DateTime.now().copyWith(
      month: DateTime.now().month + 1,
      day: 0,
    );
    final endDate = DateFormat('yyyy-MM-dd').format(endDayOfMonth);
    final staffSelected = useState<Staff?>(null);
    final dateStartSelected = useState<String?>(startDate);
    final dateEndSelected = useState<String?>(endDate);
    final screenshotController = useMemoized(() => ScreenshotController());

    ref.listen(
        fetchDetailPresenceReportProvider(
          key: '${staffSelected.value?.key}',
          startDate: '${dateStartSelected.value}',
          endDate: '${dateEndSelected.value}',
        ), (previous, next) {
      next.showToastOnError(context);
    });
    final fetchDetailPresenceReport = ref.watch(
      fetchDetailPresenceReportProvider(
        key: '${staffSelected.value?.key}',
        startDate: '${dateStartSelected.value}',
        endDate: '${dateEndSelected.value}',
      ),
    );
    final fetchAttendanceRecap = ref.watch(
      fetchAttendanceRecapProvider(
        key: '${staffSelected.value?.key}',
        startDate: '${dateStartSelected.value}',
        endDate: '${dateEndSelected.value}',
      ),
    );
    final attendance = fetchAttendanceRecap.valueOrNull?.firstOrNull;
    final fetchUserProfile = ref.watch(
      fetchProfileProvider(
        key: '${staffSelected.value?.key}',
      ),
    );
    final workHour = fetchUserProfile.valueOrNull?.absensi;

    final itemCount = fetchDetailPresenceReport.isLoading
        ? 10
        : fetchDetailPresenceReport.valueOrNull?.length ?? 0;

    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Absensi Kehadiran',
                style: context.titleMedium,
              ),
              Text(
                'Bulan ${month.text.isEmpty == true ? currentMonth : month.text}',
                style: context.titleMedium,
              ),
            ],
          ),
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
                    text: 'Rekap Absensi Bulanan',
                  );
                } catch (error) {
                  context.showErrorMessage('Gagal membagikan screenshot');
                }
              },
              icon: const Icon(Icons.share),
            ),
            IconButton(
              onPressed: () async {
                final monthSelected = await showMonthPicker(
                  context: context,
                  initialDate: DateTime.now(),
                  lastDate: DateTime.now(),
                );
                if (monthSelected == null || !context.mounted) return;
                month.text = DateFormat('MMMM').format(monthSelected);
                final startDate =
                    DateFormat('yyyy-MM-dd').format(monthSelected);
                final endDayOfMonth = monthSelected.copyWith(
                  month: monthSelected.month + 1,
                  day: 0,
                );
                final endDate = DateFormat('yyyy-MM-dd').format(endDayOfMonth);
                dateStartSelected.value = startDate;
                dateEndSelected.value = endDate;
              },
              icon: const Icon(Icons.today),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(140),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  DropdownSearch<Staff>(
                    asyncItems: (text) => ref.read(
                      searchStaffProvider(key: key, query: text).future,
                    ),
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
                    itemAsString: (item) => '${item.fullName}',
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'Nama Staff',
                        labelText: 'Nama Staff',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    onChanged: (staff) async {
                      staffSelected.value = staff;
                    },
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Skeletonizer(
                    enabled: fetchDetailPresenceReport.isLoading,
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      children: [
                        Card.outlined(
                          color: context.colorPrimary,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Hadir',
                                  style: context.bodyMediumBold?.copyWith(
                                    color: context.colorOnPrimary,
                                  ),
                                ),
                                Text(
                                  attendance?.presence ?? '-',
                                  style: context.bodyMedium?.copyWith(
                                    color: context.colorOnPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card.outlined(
                          color: context.colorError,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Terlambat',
                                  style: context.bodyMediumBold?.copyWith(
                                    color: context.colorOnError,
                                  ),
                                ),
                                Text(
                                  attendance?.late ?? '-',
                                  style: context.bodyMedium?.copyWith(
                                    color: context.colorOnError,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card.outlined(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Tidak Absen',
                                  style: context.bodyMediumBold?.copyWith(),
                                ),
                                Text(
                                  attendance?.notPresent ?? '-',
                                  style: context.bodyMedium?.copyWith(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card.outlined(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Izin',
                                  style: context.bodyMediumBold?.copyWith(),
                                ),
                                Text(
                                  attendance?.permit ?? '-',
                                  style: context.bodyMedium?.copyWith(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => ref.refresh(
            fetchDetailPresenceReportProvider(
              key: '${staffSelected.value?.key}',
              startDate: '${dateStartSelected.value}',
              endDate: '${dateEndSelected.value}',
            ).future,
          ),
          child: Skeletonizer(
            enabled: fetchDetailPresenceReport.isLoading,
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              columns: [
                DataColumn2(
                  label: Text(
                    'Tanggal',
                    style: context.bodyMediumBold,
                  ),
                  fixedWidth: 90,
                ),
                DataColumn2(
                  label: Text(
                    'Jam Kerja',
                    style: context.bodyMediumBold,
                  ),
                  fixedWidth: 100,
                ),
                DataColumn2(
                  label: Text(
                    'Masuk',
                    style: context.bodyMediumBold,
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'Pulang',
                    style: context.bodyMediumBold,
                  ),
                ),
                DataColumn2(
                  label: Text(
                    'Keterangan',
                    style: context.bodyMediumBold,
                  ),
                ),
              ],
              rows: List<DataRow>.generate(
                itemCount,
                (index) {
                  final attendance = fetchDetailPresenceReport.valueOrNull
                      ?.elementAtOrNull(index);
                  final dateFormat =
                      DateFormat('yyyy-MM-dd').tryParse(attendance?.date ?? '');
                  final formattedDate = DateFormat("dd/MM/yyyy")
                      .format(dateFormat ?? DateTime.now());
                  final parsedTimeClockIn = DateFormat("HH:mm:ss")
                      .tryParse('${attendance?.timeattand}' ?? '');
                  String formattedTimeClockIn = DateFormat("HH:mm")
                      .format(parsedTimeClockIn ?? DateTime.now());
                  final parsedTimeClockOut = DateFormat("HH:mm:ss")
                      .tryParse('${attendance?.done}' ?? '');
                  String formattedTimeClockOut = DateFormat("HH:mm")
                      .format(parsedTimeClockOut ?? DateTime.now());
                  final workTime = workHour?.replaceAll(' s/d ', '-') ?? '-';
                  final isLate = attendance?.overtime == 'late';
                  return DataRow(
                    color: isLate
                        ? WidgetStatePropertyAll(context.colorErrorContainer)
                        : null,
                    cells: [
                      DataCell(
                        Text(formattedDate),
                      ),
                      DataCell(
                        Text(workTime),
                      ),
                      DataCell(
                        Text(formattedTimeClockIn),
                      ),
                      DataCell(
                        Text(formattedTimeClockOut),
                      ),
                      DataCell(
                        Text('${attendance?.overtime}'),
                      )
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
