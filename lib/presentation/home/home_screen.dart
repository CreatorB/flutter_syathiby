import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' hide Store;
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/hostel/hostel.dart';
import 'package:syathiby/models/user/request_logout.dart';
import 'package:syathiby/presentation/home/fetch_presence_controller.dart';
import 'package:syathiby/presentation/report/bottomsheet_staff_month_picker.dart';
import 'package:syathiby/presentation/setting/account_controller.dart';
import 'package:syathiby/res/strings.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../presence/presence_controller.dart';
import '../setting/local_auth_controller.dart';
import '../setting/presence_type.dart';
import 'menu_home.dart';

class HomeScreen extends HookConsumerWidget {
  HomeScreen({super.key});

  final refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(fetchProfileProvider(key: key), (previous, next) {
      next.showToastOnError(context);
    });
    final token = ref
        .watch(sharedPreferencesHelperProvider)
        .getString(AppConstant.keyDeviceToken);
    final saveTokenToServer = useMemoized(
      () => ref.watch(
        saveTokenToServerProvider(key: key, token: '$token').future,
      ),
    );
    useFuture(saveTokenToServer);
    final fetchUserProfile = ref.watch(fetchProfileProvider(key: key));
    final fetchPresence = ref.watch(fetchPresenceProvider(key: key));
    final currentDateFormat = ref.watch(
      formatDateProvider(
        '${fetchUserProfile.valueOrNull?.date}',
        format: 'EEEE, dd MMM yyyy',
      ),
    );
    final timeAttandFormat = ref.watch(
      formatTimeProvider('${fetchPresence.valueOrNull?.timeattand}'),
    );
    final isClockIn = fetchPresence.valueOrNull?.absen == "1";
    final isHoliday = fetchPresence.valueOrNull?.holiday == "YES";

    void buildJobAlertMessage() {
      final presence = fetchPresence.valueOrNull;
      final notif = presence?.notif ?? 0;
      final violation = presence?.notifpelanggaran ?? 0;
      final permit = presence?.notifizin ?? 0;
      final studentPermit = presence?.notifizinsantri ?? 0;
      final finance = presence?.notifkeuangan ?? 0;
      final logistic = presence?.notiflogistik ?? 0;
      final manager = presence?.notifmanager ?? 0;
      final director = presence?.notifmudir ?? 0;
      final requestMedicine = presence?.notifpermintaanobatmanager ?? 0;
      final ukp = presence?.notifukp ?? 0;

      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (notif > 0) {
          context.showSnackBar(
            'Anda memiliki $notif Tugas kerja!',
            actionLabel: 'Lihat',
            onAction: () {
              context.goNamed(AppRoute.jobs.name);
            },
          );
        }
        if (violation > 0) {
          context.showSnackBar(
            'Anda memiliki $violation Laporan Pelanggaran!',
            actionLabel: 'Lihat',
            onAction: () {
              context.goNamed(
                AppRoute.jobs.name,
                queryParameters: {"type": "umum"},
              );
            },
          );
        }
        if (permit > 0) {
          context.showSnackBar(
            'Anda memiliki $permit Permintaan Izin Staff!',
            actionLabel: 'Lihat',
            onAction: () {
              context.goNamed(AppRoute.permit.name);
            },
          );
        }
        if (studentPermit > 0) {
          context.showSnackBar(
            'Anda memiliki $studentPermit Permintaan Izin Santri!',
            actionLabel: 'Lihat',
            onAction: () {
              context.goNamed(AppRoute.studentPermit.name);
            },
          );
        }
        if (manager > 0) {
          context.showSnackBar(
            'Anda memiliki $manager Permohonan untuk di proses!',
            actionLabel: 'Lihat',
            onAction: () {
              context.goNamed(AppRoute.historyTransaction.name);
            },
          );
        }
        if (requestMedicine > 0) {
          context.showSnackBar(
            'Anda memiliki $requestMedicine Permintaan Obat untuk di proses!',
            actionLabel: 'Lihat',
            onAction: () {
              context.goNamed(AppRoute.medicineRequest.name);
            },
          );
        }
        if (finance > 0) {
          context.showSnackBar(
            'Anda memiliki $finance Permohonan untuk di proses!',
            actionLabel: 'Lihat',
            onAction: () {
              context.goNamed(AppRoute.historyTransaction.name);
            },
          );
        }
        if (logistic > 0) {
          context.showSnackBar(
            'Anda memiliki $logistic Permohonan untuk di proses!',
            actionLabel: 'Lihat',
            onAction: () {
              context.goNamed(AppRoute.historyTransaction.name);
            },
          );
        }
        if (ukp > 0) {
          context.showSnackBar(
            'Anda memiliki $ukp Permintaan Obat untuk di proses!',
            actionLabel: 'Lihat',
            onAction: () {
              context.goNamed(AppRoute.medicineRequest.name);
            },
          );
        }
        if (director > 0) {
          context.showSnackBar(
            'Anda memiliki $director Permohonan untuk di proses!',
            actionLabel: 'Lihat',
            onAction: () {
              context.goNamed(AppRoute.historyTransaction.name);
            },
          );
        }
      });
    }

    buildJobAlertMessage();

    Widget buildHeader() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorPrimary,
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assalamu\'alaikum',
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colorOnPrimary,
                        ),
                      ),
                      Text(
                        '${fetchUserProfile.valueOrNull?.fullName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.colorOnPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${fetchUserProfile.valueOrNull?.position}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colorOnPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8.0),
                  child: CustomAvatar(
                    size: 50,
                    imageUrl: '${fetchUserProfile.valueOrNull?.img}',
                    name: '${fetchUserProfile.valueOrNull?.fullName}',
                    color: context.colorInversePrimary,
                  ),
                ),
              ],
            ),
            Card(
              margin: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 0,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tempat Absen',
                          style: context.bodyMediumBold,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${fetchUserProfile.valueOrNull?.nameStore}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.bodyMedium,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hari',
                          style: context.bodyMediumBold,
                        ),
                        Text(
                          currentDateFormat ?? '-',
                          style: context.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jam Kerja',
                          style: context.bodyMediumBold,
                        ),
                        Text(
                          '${fetchUserProfile.valueOrNull?.absensi}',
                          style: context.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jam Masuk',
                          style: context.bodyMediumBold,
                        ),
                        Text(
                          timeAttandFormat ?? '--:--',
                          style: context.bodyMedium,
                        ),
                      ],
                    ),
                    Visibility(
                      visible: fetchPresence.valueOrNull?.late !=
                          "-", // Not Attendance
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Keterlambatan',
                                style: context.bodyMediumBold,
                              ),
                              Text(
                                fetchPresence.valueOrNull?.late ?? '-',
                                style: context.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: fetchPresence.valueOrNull?.timeattand !=
                          ":00", // Not Attendance
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Bekerja Selama',
                                style: context.bodyMediumBold,
                              ),
                              Text(
                                fetchPresence.valueOrNull?.during ?? '-',
                                style: context.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Visibility(
                        visible: !isHoliday,
                        child: FilledButton(
                          onPressed: () async {
                            if (isClockIn) {
                              _showPresenceIn(context, ref, key);
                              return;
                            }
                            _showPresenceOut(
                              context,
                              ref,
                              key,
                              '${currentUser?.device}',
                            );
                          },
                          child: Text(
                            isClockIn ? 'Absen Masuk' : 'Absen Pulang',
                          ),
                        ),
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

    Widget buildPresenceAndJob() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Card.outlined(
          margin: const EdgeInsets.all(8),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    onTap: () {
                      final monthSelected = DateTime.now().copyWith(day: 1);
                      final startDate =
                          DateFormat('yyyy-MM-dd').format(monthSelected);
                      final endDayOfMonth = monthSelected.copyWith(
                        month: monthSelected.month + 1,
                        day: 0,
                      );
                      final endDate =
                          DateFormat('yyyy-MM-dd').format(endDayOfMonth);
                      context.goNamed(
                        AppRoute.attendanceRecap.name,
                        queryParameters: {
                          "startDate": startDate,
                          "endDate": endDate
                        },
                      );
                    },
                    leading: const Icon(Icons.today),
                    title: Text(
                      'Kehadiran\n(bulan ini)',
                      style: context.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      '${fetchPresence.valueOrNull?.attandence}',
                      style: context.bodyMediumBold,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: ListTile(
                    onTap: () {
                      context.goNamed(AppRoute.jobs.name);
                    },
                    leading: const Icon(Icons.work_history),
                    title: Text(
                      'Penugasan\n(bulan ini)',
                      style: context.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    subtitle: Text(
                      '${fetchPresence.valueOrNull?.job}',
                      style: context.bodyMediumBold,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildListMenu({
      required List<MenuGrid> menus,
      String? title,
      bool enabled = false,
    }) {
      if (!enabled) return Container();
      final menuGrid = ResponsiveGridRow(
        children: menus
            .map(
              (menu) => ResponsiveGridCol(
                lg: 2,
                md: 3,
                sm: 3,
                xs: 4,
                child: InkWell(
                  onTap: menu.onClicked ??
                      () {
                        context.goNamed(
                          menu.goToRouteName,
                          extra: menu.extra,
                          queryParameters: menu.queryParameters ?? {},
                        );
                      },
                  child: Column(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Card(
                          elevation: 4,
                          color: context.colorPrimaryContainer,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: context.colorPrimary,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            menu.iconData,
                            color: context.colorPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        menu.title,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      );
      if (title == null) return menuGrid;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(title, style: context.titleMediumBold),
          ),
          const SizedBox(height: 12),
          menuGrid,
          const SizedBox(height: 8),
        ],
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: () => Future.wait(
          [
            ref.refresh(fetchPresenceProvider(key: key).future),
            ref.refresh(fetchProfileProvider(key: key).future)
          ],
        ),
        child: Skeletonizer(
          enabled: fetchUserProfile.isLoading,
          child: ListView(
            children: [
              buildHeader(),
              const SizedBox(height: 8),
              buildPresenceAndJob(),
              const SizedBox(height: 16),
              buildListMenu(
                enabled: true,
                menus: [
                  MenuGrid(
                    title: 'Izin',
                    iconData: Icons.info,
                    goToRouteName: AppRoute.permit.name,
                  ),
                  MenuGrid(
                    title: 'Penugasan',
                    iconData: Icons.work,
                    goToRouteName: AppRoute.jobs.name,
                  ),
                  MenuGrid(
                    title: 'Jadwal Mengajar',
                    iconData: Icons.school,
                    goToRouteName: AppRoute.teachingSchedule.name,
                  ),
                  MenuGrid(
                    title: 'Kunjungan',
                    iconData: Icons.car_rental,
                    goToRouteName: AppRoute.visitingPresence.name,
                  ),
                  MenuGrid(
                    title: 'Absensi',
                    iconData: Icons.insert_chart,
                    goToRouteName: AppRoute.presenceReport.name,
                  ),
                  MenuGrid(
                    title: 'Pelanggaran',
                    iconData: Icons.warning,
                    goToRouteName: AppRoute.violation.name,
                    queryParameters: {"type": "umum"},
                  ),
                ],
              ),
              const SizedBox(height: 8),
              buildListMenu(
                title: 'Menu Pendidikan',
                enabled: fetchPresence.valueOrNull?.kependidikan == 1 ||
                    fetchPresence.valueOrNull?.guru == "YES",
                menus: [
                  MenuGrid(
                    title: 'Penilaian',
                    iconData: Icons.credit_score,
                    goToRouteName: AppRoute.scoreType.name,
                  ),
                  MenuGrid(
                    title: 'Absensi Kelas',
                    iconData: Icons.history_edu,
                    goToRouteName: AppRoute.classAttendance.name,
                  ),
                  MenuGrid(
                    title: 'Laporan Kerja',
                    iconData: Icons.report,
                    goToRouteName: AppRoute.activityReport.name,
                    queryParameters: {
                      'type': 'kependidikan',
                    },
                  ),
                  MenuGrid(
                    title: 'RPP',
                    iconData: Icons.note_alt,
                    goToRouteName: AppRoute.teachingPlanner.name,
                  ),
                  MenuGrid(
                    title: 'Reward Siswa',
                    iconData: Icons.person_add,
                    goToRouteName: AppRoute.studentReward.name,
                    queryParameters: {'title': 'Murid'},
                  ),
                  MenuGrid(
                    title: 'Wali Kelas',
                    iconData: Icons.local_library,
                    goToRouteName: AppRoute.homeroomTeacher.name,
                  ),
                ],
              ),
              buildListMenu(
                title: 'Menu Kesantrian/Kepengasuhan',
                enabled: fetchPresence.valueOrNull?.kepengasuhan == 1,
                menus: [
                  MenuGrid(
                    title: 'Tugas Harian',
                    iconData: Icons.fact_check,
                    goToRouteName: AppRoute.activityReport.name,
                    queryParameters: {
                      'type': 'kepengasuhan',
                    },
                  ),
                  MenuGrid(
                    title: 'Penilaian',
                    iconData: Icons.credit_score,
                    goToRouteName: AppRoute.parentingScore.name,
                  ),
                  MenuGrid(
                    title: 'Absensi Asrama',
                    iconData: Icons.room_preferences,
                    goToRouteName: AppRoute.hostelAttendance.name,
                  ),
                  MenuGrid(
                    title: 'Izin Santri',
                    iconData: Icons.edit_calendar,
                    goToRouteName: AppRoute.studentPermit.name,
                  ),
                  MenuGrid(
                    title: 'Laporan Puasa',
                    iconData: Icons.no_food,
                    goToRouteName: AppRoute.fastingReport.name,
                  ),
                  MenuGrid(
                    title: 'Absensi Makan',
                    iconData: Icons.food_bank,
                    goToRouteName: AppRoute.eatingAttendance.name,
                  ),
                  MenuGrid(
                    title: 'Reward Santri',
                    iconData: Icons.person_add,
                    goToRouteName: AppRoute.studentReward.name,
                    queryParameters: {'title': 'Santri'},
                  ),
                  MenuGrid(
                    title: 'Kepulangan',
                    iconData: Icons.emoji_transportation,
                    goToRouteName: AppRoute.homecoming.name,
                  ),
                ],
              ),
              buildListMenu(
                title: 'Menu Kesehatan',
                enabled: fetchPresence.valueOrNull?.kesehatan == 1,
                menus: [
                  MenuGrid(
                    title: 'Kesehatan Santri',
                    iconData: Icons.health_and_safety,
                    goToRouteName: AppRoute.studentHealth.name,
                  ),
                  MenuGrid(
                    title: 'Permintaan Obat',
                    iconData: Icons.medical_information,
                    goToRouteName: AppRoute.medicineRequest.name,
                  ),
                  MenuGrid(
                    title: 'Laporan Kerja',
                    iconData: Icons.report,
                    goToRouteName: AppRoute.activityReport.name,
                    queryParameters: {
                      'type': 'ukp',
                    },
                  ),
                  MenuGrid(
                    title: 'Database Obat',
                    iconData: Icons.dataset,
                    goToRouteName: AppRoute.medicineDatabase.name,
                  ),
                  MenuGrid(
                    title: 'Inventaris UKP',
                    iconData: Icons.inventory,
                    goToRouteName: AppRoute.places.name,
                  ),
                ],
              ),
              buildListMenu(
                title: 'Menu Sarpras dan Dapur',
                enabled: fetchPresence.valueOrNull?.kerumahtanggaan == 1,
                menus: [
                  MenuGrid(
                    title: 'Laporan Makan',
                    iconData: Icons.table_restaurant,
                    goToRouteName: AppRoute.eatingReport.name,
                  ),
                  MenuGrid(
                    title: 'Laporan Kerja Dapur',
                    iconData: Icons.report,
                    goToRouteName: AppRoute.activityReport.name,
                    queryParameters: {
                      'type': 'dapur',
                    },
                  ),
                  MenuGrid(
                    title: 'Laporan Kerja Sarpras',
                    iconData: Icons.report_gmailerrorred,
                    goToRouteName: AppRoute.activityReport.name,
                    queryParameters: {
                      'type': 'kerumahtanggaan',
                    },
                  ),
                  MenuGrid(
                    title: 'Pengeluaran',
                    iconData: Icons.outbox,
                    goToRouteName: AppRoute.spending.name,
                  ),
                  MenuGrid(
                    title: 'Rekap Puasa',
                    iconData: Icons.no_food,
                    goToRouteName: AppRoute.studentFasting.name,
                  ),
                  MenuGrid(
                    title: 'Inventaris Barang',
                    iconData: Icons.inventory,
                    goToRouteName: AppRoute.places.name,
                  ),
                  MenuGrid(
                    title: 'Kelola Dapur',
                    iconData: Icons.soup_kitchen,
                    goToRouteName: AppRoute.manageKitchen.name,
                  ),
                ],
              ),
              buildListMenu(
                title: 'Menu Tahfidz',
                enabled: fetchPresence.valueOrNull?.tahfidz == 1,
                menus: [
                  MenuGrid(
                    title: 'Absensi Tahfidz',
                    iconData: Icons.local_library,
                    goToRouteName: AppRoute.tahfidzPresence.name,
                    queryParameters: {
                      'type': 'student',
                    },
                  ),
                  MenuGrid(
                    title: 'Absensi Pengampu',
                    iconData: Icons.edit_document,
                    goToRouteName: AppRoute.tahfidzPresence.name,
                    queryParameters: {
                      'type': 'teacher',
                    },
                  ),
                  MenuGrid(
                    title: 'Setoran Santri',
                    iconData: Icons.menu_book,
                    goToRouteName: AppRoute.tahfidz.name,
                  ),
                  MenuGrid(
                    title: 'Penilaian',
                    iconData: Icons.credit_score,
                    goToRouteName: AppRoute.tahfidzGrade.name,
                  ),
                  MenuGrid(
                    title: 'Laporan Kerja',
                    iconData: Icons.report,
                    goToRouteName: AppRoute.activityReport.name,
                    queryParameters: {
                      'type': 'tahfidz',
                    },
                  ),
                  MenuGrid(
                    title: 'Pelanggaran',
                    iconData: Icons.warning,
                    goToRouteName: AppRoute.violation.name,
                    queryParameters: {'type': 'tahfidz'},
                  ),
                ],
              ),
              buildListMenu(
                title: 'Menu Keuangan',
                enabled: fetchPresence.valueOrNull?.keuangan == 1,
                menus: [
                  MenuGrid(
                    title: 'Laporan Kerja',
                    iconData: Icons.report,
                    goToRouteName: AppRoute.activityReport.name,
                    queryParameters: {
                      'type': 'keuangan',
                    },
                  ),
                  // MenuGrid(
                  //   title: 'Tabungan',
                  //   iconData: Icons.monetization_on,
                  //   goToRouteName: AppRoute.studentTransaction.name,
                  //   queryParameters: {'type': 'Tabungan'},
                  // ),
                ],
              ),
              buildListMenu(
                title: 'Menu Unit Usaha',
                enabled: fetchPresence.valueOrNull?.unitusaha == 1,
                menus: [
                  MenuGrid(
                      title: 'Laporan Kerja',
                      iconData: Icons.report,
                      goToRouteName: AppRoute.activityReport.name,
                      queryParameters: {
                        'type': 'unit_usaha',
                      }),
                  // MenuGrid(
                  //   title: 'Loundry',
                  //   iconData: Icons.water_drop,
                  //   goToRouteName: AppRoute.studentTransaction.name,
                  //   queryParameters: {'type': 'Loundry'},
                  // ),
                  // MenuGrid(
                  //   title: 'Mini Market',
                  //   iconData: Icons.store,
                  //   goToRouteName: AppRoute.studentTransaction.name,
                  //   queryParameters: {'type': 'Mart'},
                  // ),
                  // MenuGrid(
                  //   title: 'Kantin',
                  //   iconData: Icons.shopping_cart,
                  //   goToRouteName: AppRoute.studentTransaction.name,
                  //   queryParameters: {'type': 'Kantin'},
                  // ),
                ],
              ),
              buildListMenu(
                title: 'Menu Lainnya',
                enabled: true,
                menus: [
                  MenuGrid(
                    title: 'Tukar Shift',
                    iconData: Icons.swap_horizontal_circle,
                    goToRouteName: AppRoute.changeShift.name,
                    queryParameters: {
                      'level': fetchPresence.valueOrNull?.level
                    },
                  ),
                  MenuGrid(
                    title: 'Pertemuan',
                    iconData: Icons.meeting_room,
                    goToRouteName: AppRoute.meetings.name,
                  ),
                  MenuGrid(
                    title: 'Absensi Kegiatan',
                    iconData: Icons.history_edu,
                    goToRouteName: AppRoute.activityPresence.name,
                  ),
                ],
              ),
              buildListMenu(
                title: 'Permohonan Barang/Dana',
                enabled: (fetchPresence.valueOrNull?.permohonan == 1 &&
                        fetchPresence.valueOrNull?.level == 'admin') ||
                    (fetchPresence.valueOrNull?.level != 'staff' &&
                        fetchPresence.valueOrNull?.level != 'pengabdian'),
                menus: [
                  MenuGrid(
                    title: 'Permohonan',
                    iconData: Icons.monetization_on,
                    goToRouteName: AppRoute.historyTransaction.name,
                    queryParameters: {
                      'level': fetchPresence.valueOrNull?.level
                    },
                  ),
                ],
              ),
              buildListMenu(
                title: 'Menu Kepala Bagian',
                enabled: fetchPresence.valueOrNull?.level == 'master' ||
                    fetchPresence.valueOrNull?.level == 'admin' ||
                    fetchPresence.valueOrNull?.level == 'manager',
                menus: [
                  MenuGrid(
                    title: 'Tambah Pekerjaan',
                    iconData: Icons.add_task,
                    goToRouteName: AppRoute.manageJob.name,
                  ),
                  MenuGrid(
                    title: 'Kelola Rapat',
                    iconData: Icons.groups_3,
                    goToRouteName: AppRoute.manageMeetings.name,
                  ),
                  MenuGrid(
                    title: 'Data Presensi',
                    iconData: Icons.edit_calendar,
                    goToRouteName: AppRoute.dataPresence.name,
                  ),
                  MenuGrid(
                    title: 'Absensi Manual',
                    iconData: Icons.edit_document,
                    goToRouteName: AppRoute.manualAttendance.name,
                  ),
                  MenuGrid(
                    title: 'Rekap Absensi',
                    iconData: Icons.library_books,
                    goToRouteName: AppRoute.recapPresence.name,
                  ),
                  MenuGrid(
                    title: 'Daftar Kehadiran',
                    iconData: Icons.co_present,
                    goToRouteName: AppRoute.attendanceRecapMonth.name,
                  ),
                  MenuGrid(
                    title: 'Laporan Absensi',
                    iconData: Icons.insert_chart,
                    goToRouteName: AppRoute.recapAttendance.name,
                    onClicked: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        builder: (context) => BottomSheetStaffMonthPicker(
                          title: 'Laporan Absensi',
                          routeName: AppRoute.reportAttendance.name,
                        ),
                      );
                    },
                  ),
                  MenuGrid(
                    title: 'Manajemen',
                    iconData: Icons.manage_accounts,
                    goToRouteName: AppRoute.management.name,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _showMethodPresence(BuildContext context, bool isFaceId) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (context) => Padding(
  //       padding: const EdgeInsets.only(bottom: 16.0),
  //       child: Wrap(
  //         children: [
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: ListTile(
  //               title: Text(
  //                 'Metode Presensi',
  //                 style: context.titleLarge,
  //               ),
  //               trailing: Transform.translate(
  //                 offset: const Offset(16, 0),
  //                 child: IconButton(
  //                   onPressed: () => context.pop(),
  //                   icon: const Icon(Icons.close),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         context.goNamed(
  //                           AppRoute.presence.name,
  //                           extra: PresenceType.biometric,
  //                         );
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         shape: const CircleBorder(),
  //                         padding: const EdgeInsets.all(20),
  //                         backgroundColor: context.colorPrimaryContainer,
  //                       ),
  //                       child: Icon(
  //                         isFaceId ? Icons.face : Icons.fingerprint,
  //                         color: context.colorPrimary,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       isFaceId ? 'Face ID' : 'Fingerpint',
  //                       style: context.titleMedium,
  //                       textAlign: TextAlign.center,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         context.goNamed(
  //                           AppRoute.presence.name,
  //                           extra: PresenceType.normal,
  //                         );
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         shape: const CircleBorder(),
  //                         padding: const EdgeInsets.all(20),
  //                         backgroundColor: context.colorErrorContainer,
  //                       ),
  //                       child: Icon(
  //                         Icons.download,
  //                         color: context.colorError,
  //                       ),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       'Tombol',
  //                       style: context.titleMedium,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Future<void> _showPresenceIn(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) async {
    try {
      final locations = await ref.watch(
        fetchListHostelProvider(key: key).future,
      );
      if (!context.mounted) return;
      final selected = await showConfirmationDialog<Asrama>(
        context: context,
        title: 'Lokasi Presensi',
        actions: locations
            .map(
              (e) => AlertDialogAction(key: e, label: '${e.namaAsrama}'),
        )
            .toList(),
      );
      if(selected == null) {
        return;
      }

      final position = await ref.read(getCurrentLocationProvider.future);
      final result = await ref.read(accountControllerProvider.notifier).presence(
        key: key,
        presenceType: PresenceType.normal,
        latitude: position.latitude,
        longitude: position.longitude,
        locationPresenceName: '${selected.idAsrama}',
        mock: position.isMocked,
      );

      if (result == null || !context.mounted) return;
      final status = result.status;

      if (result.status == 'late') {
        String message =
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

        ref.invalidate(fetchPresenceProvider);
        ref.invalidate(fetchProfileProvider);

        if (result == null || !context.mounted) return;

        context.showSuccessMessage('Terimakasih, semoga besok lebih baik lagi');
      } else {
        final message =
            'Success Anda ${result.status} Luar biasa, terus pertahankan';
        context.showSuccessMessage(
          message,
        );
        ref.invalidate(fetchPresenceProvider(key: key));
        ref.invalidate(fetchProfileProvider(key: key));
      }
    }catch (error) {
      context.showErrorMessage(error.toString());
    }
  }

  Future<void> _showPresenceOut(
    BuildContext context,
    WidgetRef ref,
    String key,
    String device,
  ) async {
    try {
      final presenceLocation =
          await showChooseLocationDialog(context, ref, key);
      if (presenceLocation == null) return;

      final position = await ref.read(getCurrentLocationProvider.future);

      final token = ref
          .watch(sharedPreferencesHelperProvider)
          .getString(AppConstant.keyDeviceToken);

      final requestLogout = RequestLogout(
        mock: position.isMocked,
        longitude: position.longitude,
        latitude: position.latitude,
        key: key,
        lokasi: '${presenceLocation.idAsrama}',
        token: token,
        device: device,
      );
      final result = await ref
          .read(accountControllerProvider.notifier)
          .presenceOut(requestLogout);

      if (!context.mounted) return;
      final status = result?.status;
      String title, message;
      if (status == 'before the time') {
        await showReasonLate(context, ref, key);
        return;
      } else if (status == 'ontime') {
        title = 'Absensi Sukses';
        message =
            'Anda selesai bekerja tepat waktu Luar biasa, terus pertahankan';
      } else if (status == 'nodistance') {
        message =
            'Lokasi Anda terlalu jauh dari kantor, Anda harus melakukan Absensi di lokasi yang sudah ditentukan';
        title = 'Absensi Gagal';
      } else {
        title = 'Absensi Gagal';
        message = 'Hari ini Anda Sudah Melakukan Absen Selesai bekerja';
      }
      await showOkAlertDialog(
        context: context,
        title: title,
        message: message,
      );
      ref.invalidate(fetchPresenceProvider(key: key));
      ref.invalidate(fetchProfileProvider(key: key));
      refreshKey.currentState?.show();
    } catch (error) {
      context.showErrorMessage(error.toString());
    }
  }

  Future<Asrama?> showChooseLocationDialog(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) async {
    final locations = await ref.watch(
      fetchListHostelProvider(key: key).future,
    );
    if (!context.mounted) return null;
    final selected = await showConfirmationDialog<Asrama>(
      context: context,
      title: 'Absen Pulang',
      message: 'Silahkan pilih lokasi absen',
      actions: locations
          .map(
            (e) => AlertDialogAction(key: e, label: '${e.namaAsrama}'),
          )
          .toList(),
    );
    return selected;
  }

  Future<void> showReasonLate(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) async {
    const message =
        '“Rasulullah melarang seseorang tidak melaksakan kewajiban yang ada padanya atau menuntut apa yang bukan menjadi haknya.” (Syarh An-Nawawi ‘ala Muslim)\n\nAnda selesai bekerja sebelum waktunya, Silahkan isi Alasan Anda';
    final reasonLate = await showTextInputDialog(
      context: context,
      title: 'Info',
      message: message,
      textFields: [
        DialogTextField(
          hintText: 'Alasan Anda',
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
        .reasonLate(key: key, reason: value ?? '', isClockIn: false);
    if (result == null || !context.mounted) return;

    ref.invalidate(fetchPresenceProvider(key: key));
    ref.invalidate(fetchProfileProvider(key: key));
    refreshKey.currentState?.show();

    context.showSuccessMessage(
      'Terimakasih, semoga besok lebih baik lagi',
    );
  }
}