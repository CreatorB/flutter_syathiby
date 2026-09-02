import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart' hide Store;
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/hostel/hostel.dart';
import 'package:syathiby/res/environment_config.dart';
import 'package:syathiby/utils/update_checker.dart';
import 'package:syathiby/models/slip/absent.dart';
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
import 'package:syathiby/presentation/widgets/elegant_3d_icon.dart';
import 'package:syathiby/presentation/widgets/elegant_3d_button.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../presence/presence_controller.dart';
import '../setting/presence_type.dart';
import 'menu_home.dart';

enum AttendanceMethod {
  location,
  wifi,
}

class HomeScreen extends HookConsumerWidget {
  HomeScreen({super.key});

  final refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMenuKey = useState<String?>(null);
    final isAttendanceLoading = useState(false);
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    // Token save is now handled lazily on login success, not on every home build
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
    final timeAttandOutFormat = ref.watch(
      formatTimeProvider('${fetchPresence.valueOrNull?.timeattandOut}'),
    );
    final displayTimeAttand = timeAttandFormat ?? '--:--';
    final rawWorkHour = fetchPresence.valueOrNull?.workhour?.trim();
    final jamMasukDate = fetchPresence.valueOrNull?.timeattandDate;
    final jamPulangDate = fetchPresence.valueOrNull?.timeattandOutDate;
    final userToday = '${fetchUserProfile.valueOrNull?.date}';
    final hariMasukSource = (jamMasukDate != null && jamMasukDate.isNotEmpty)
        ? jamMasukDate
        : userToday;
    final hariPulangSource = (jamPulangDate != null && jamPulangDate.isNotEmpty)
        ? jamPulangDate
        : userToday;
    final hariMasuk = ref.watch(
      formatDateProvider(hariMasukSource, format: 'EEEE'),
    );
    final hariPulang = ref.watch(
      formatDateProvider(hariPulangSource, format: 'EEEE'),
    );
    final jamMasukWithHari = (timeAttandFormat != null && hariMasuk != null)
        ? '$hariMasuk ${timeAttandFormat}'
        : '--:--';
    final jamPulangWithHari = (timeAttandOutFormat != null && hariPulang != null)
        ? '$hariPulang ${timeAttandOutFormat}'
        : '--:--';
    final isWorking = displayTimeAttand != '--:--';
    final isClockIn = fetchPresence.valueOrNull?.absen == "1";
    final isHoliday = fetchPresence.valueOrNull?.holiday == "YES";
    final isAnyLoading = fetchUserProfile.isLoading || fetchPresence.isLoading;

    final profileData = fetchUserProfile.valueOrNull;
    final presenceData = fetchPresence.valueOrNull;

    final safeUserName = profileData?.fullName?.isNotEmpty == true ? profileData!.fullName! : 'User';
    final safePosition = profileData?.position?.isNotEmpty == true ? profileData!.position! : '-';
    final safeNameStore = profileData?.nameStore?.isNotEmpty == true ? profileData!.nameStore! : '-';
    final safeUserImage = profileData?.img?.isNotEmpty == true ? profileData!.img! : '';
    final safeWorkHour = (rawWorkHour != null && rawWorkHour.isNotEmpty)
        ? rawWorkHour
        : (profileData?.absensi?.isNotEmpty == true ? profileData!.absensi! : '-');
    final safeAttendance = presenceData?.attandence?.toString() ?? '0';
    final safeJob = presenceData?.job?.toString() ?? '0';
    final safeLate = presenceData?.late ?? '-';
    final safeDuring = presenceData?.during ?? '--:--';

    final isKependidikan = presenceData?.kependidikan == 1 || presenceData?.guru == "YES";
    final isKepengasuhan = presenceData?.kepengasuhan == 1;
    final isKesehatan = presenceData?.kesehatan == 1;
    final isKerumahtanggaan = presenceData?.kerumahtanggaan == 1;
    final isTahfidz = presenceData?.tahfidz == 1;
    final isKeuangan = presenceData?.keuangan == 1;
    final isUnitUsaha = presenceData?.unitusaha == 1;
    final isPermohonan = presenceData?.permohonan == 1;
    final safeLevel = presenceData?.level ?? '';

// Cek update sekali saja saat home pertama kali tampil
    useEffect(() {
      Future.microtask(() async {
        final info = await PackageInfo.fromPlatform();

        // Web: cek changelog dari localStorage version tracking
        // Native: cek update dari Play Store
        final updateInfo = kIsWeb
            ? await UpdateChecker.checkForWeb(info.version)
            : await UpdateChecker.check(info.version);

        if (updateInfo != null && context.mounted) {
          _showUpdateDialog(context, info.version, updateInfo);
        }
      });
      return null;
    }, const []);

    // Auto-sync: refresh mengajar + tahfidz schedule when app resumes
    // (UKS officer may have updated student status)
    useEffect(() {
      void onResume() {
        ref.invalidate(fetchPresenceProvider(key: key));
      }
      final observer = AppLifecycleListener(onResume: onResume);
      return () {
        observer.dispose();
      };
    }, [key]);

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
                        safeUserName,
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
                        safePosition,
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
                    imageUrl: safeUserImage,
                    name: safeUserName,
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
                            safeNameStore,
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
                          'Jadwal Kerja',
                          style: context.bodyMediumBold,
                        ),
                        Text(
                          safeWorkHour,
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
                          jamMasukWithHari,
                          style: context.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jam Pulang',
                          style: context.bodyMediumBold,
                        ),
                        Text(
                          jamPulangWithHari,
                          style: context.bodyMedium,
                        ),
                      ],
                    ),
                    Visibility(
                      visible: safeLate != "-", // Not Attendance
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
                                safeLate,
                                style: context.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: isWorking,
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
                                safeDuring,
                                style: context.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Visibility(
                      visible: !isHoliday,
                      child: Elegant3DButton(
                        label: isClockIn ? 'Absen Masuk' : 'Absen Pulang',
                        loadingLabel:
                            isClockIn ? 'Absen masuk...' : 'Absen pulang...',
                        backgroundColor: isClockIn
                            ? context.colorPrimary // Hijau untuk masuk
                            : context.colorError, // Merah untuk pulang
                        icon:
                            isClockIn ? Icons.check_circle : Icons.exit_to_app,
                        isLoading: isAttendanceLoading.value,
                        height: 44,
                        depth: 0.62,
                        onPressed: () async {
                          if (isAttendanceLoading.value) return;
                          isAttendanceLoading.value = true;

                          try {
                            if (isClockIn) {
                              await _showPresenceIn(context, ref, key);
                            } else {
                              await _showPresenceOut(
                                context,
                                ref,
                                key,
                                '${currentUser?.device}',
                              );
                            }

                            if (!context.mounted) return;

                            await Future.wait([
                              ref.refresh(
                                  fetchPresenceProvider(key: key).future),
                              ref.refresh(
                                  fetchProfileProvider(key: key).future),
                            ]).timeout(
                              const Duration(seconds: 3),
                              onTimeout: () => <Object?>[],
                            );
                          } finally {
                            if (context.mounted) {
                              isAttendanceLoading.value = false;
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              'Versi ${snapshot.data!.version}',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.colorPrimary.withOpacity(0.8),
                              ),
                            );
                          }
                          return const SizedBox(); // Jangan tampilkan apa-apa saat loading
                        },
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
                      safeAttendance,
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
                      safeJob,
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
      Future<void> handleMenuTap(MenuGrid menu) async {
        const minBounceDuration = Duration(milliseconds: 520);
        const maxBackgroundWait = Duration(seconds: 2);
        final menuKey = '${menu.goToRouteName}|${menu.title}';

        if (activeMenuKey.value == menuKey) return;
        activeMenuKey.value = menuKey;

        try {
          final preloadTask = menu.preload == null
              ? Future<void>.value()
              : Future<void>.sync(menu.preload!).timeout(
                  maxBackgroundWait,
                  onTimeout: () {},
                );

          await Future.wait([
            Future.delayed(minBounceDuration),
            preloadTask,
          ]);

          if (!context.mounted) return;

          if (menu.onClicked != null) {
            await Future<void>.sync(menu.onClicked!);
            return;
          }

          context.goNamed(
            menu.goToRouteName,
            extra: menu.extra,
            queryParameters: menu.queryParameters ?? {},
          );
        } finally {
          if (context.mounted && activeMenuKey.value == menuKey) {
            activeMenuKey.value = null;
          }
        }
      }

      if (!enabled) return Container();
      final menuGrid = ResponsiveGridRow(
        children: menus
            .map(
              (menu) => ResponsiveGridCol(
                lg: 2,
                md: 3,
                sm: 3,
                xs: 4,
                child: Column(
                  children: [
                    // 3D Elegant Sphere Icon Button with Bounce Effect
                    Elegant3DIconButton(
                      iconData: menu.iconData,
                      primaryColor: context.colorPrimary,
                      size: 58,
                      iconSize: 24,
                      depth: 0.72,
                      isLoading: activeMenuKey.value ==
                          '${menu.goToRouteName}|${menu.title}',
                      onTap: () => handleMenuTap(menu),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      menu.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colorOnSurface,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
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
        onRefresh: () async {
          try {
            await Future.wait(
              [
                ref.refresh(fetchPresenceProvider(key: key).future),
                ref.refresh(fetchProfileProvider(key: key).future)
              ],
            );
          } catch (e) {
            if (context.mounted) {
              context.showErrorMessage(e);
            }
            rethrow;
          }
        },
        child: Stack(
          children: [
            Skeletonizer(
              enabled: isAnyLoading,
              child: ListView(
            children: [
              buildHeader(),
              const SizedBox(height: 8),
              buildPresenceAndJob(),
              const SizedBox(height: 8),
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
                enabled: isKependidikan,
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
                enabled: isKepengasuhan,
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
                enabled: isKesehatan,
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
                enabled: isKerumahtanggaan,
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
                enabled: isTahfidz,
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
                enabled: isKeuangan,
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
                enabled: isUnitUsaha,
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
                      'level': safeLevel
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
                enabled: (isPermohonan && safeLevel == 'admin') ||
                    (safeLevel != 'staff' && safeLevel != 'pengabdian'),
                menus: [
                  MenuGrid(
                    title: 'Permohonan',
                    iconData: Icons.monetization_on,
                    goToRouteName: AppRoute.historyTransaction.name,
                    queryParameters: {
                      'level': safeLevel
                    },
                  ),
                ],
              ),
              buildListMenu(
                title: 'Menu Kepala Bagian',
                enabled: safeLevel == 'master' ||
                    safeLevel == 'admin' ||
                    safeLevel == 'manager',
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
        if (!isAnyLoading && (fetchUserProfile.hasError || fetchPresence.hasError) && fetchUserProfile.valueOrNull == null)
          Container(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat data',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Terjadi kesalahan saat mengambil data dari server',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        ref.invalidate(fetchPresenceProvider(key: key));
                        ref.invalidate(fetchProfileProvider(key: key));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ],
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
            label: 'Jaringan (Wi-Fi / LAN)',
          ),
        ],
      );
      if (method == null || !context.mounted) return;

      final isWifiMethod = method == AttendanceMethod.wifi;
      if (isWifiMethod) {
        final isWifiIpValid = await _validateWifiPublicIp(context);
        if (!isWifiIpValid || !context.mounted) return;
      }

      final locations = await ref.watch(
        fetchListHostelProvider(key: key).future,
      );
      if (!context.mounted) return;

      final selected = isWifiMethod
          ? locations.isNotEmpty
              ? locations.first
              : null
          : await showConfirmationDialog<Asrama>(
              context: context,
              title: 'Lokasi Presensi',
              actions: locations
                  .map(
                    (e) => AlertDialogAction(key: e, label: '${e.namaAsrama}'),
                  )
                  .toList(),
            );

      if (selected == null || !context.mounted) {
        return;
      }

      // Show loading dialog while fetching GPS and calling API
      final dismissLoading = _startLoading(context);
      Absent? result;
      try {
        late double latitude;
        late double longitude;
        late bool isMocked;

        if (isWifiMethod) {
          latitude = 0.0;
          longitude = 0.0;
          isMocked = false;
        } else {
          final position = await ref.read(getCurrentLocationProvider.future);
          latitude = position.latitude;
          longitude = position.longitude;
          isMocked = position.isMocked;
        }

        result = await ref.read(accountControllerProvider.notifier).presence(
              key: key,
              presenceType: PresenceType.normal,
              latitude: latitude,
              longitude: longitude,
              locationPresenceName: '${selected.idAsrama}',
              mock: isMocked,
            );
      } finally {
        dismissLoading();
      }
      if (result == null || !context.mounted) return;

      // Check if response is an error (has errCode that's not '01')
      if (result.errCode != null && result.errCode != '01') {
        // Error response from server
        context.showErrorMessage(
          result.msg ?? 'Terjadi kesalahan saat absen',
        );
        return;
      }

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
    } catch (error) {
      final errorMessage = error.toString();
      // Cek apakah error terkait lokasi/permission
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
          // Hanya buka settings jika bukan web
          if (!kIsWeb) {
            await Geolocator.openAppSettings();
          }
        });
        return;
      }
      context.showErrorMessage(errorMessage);
    }
  }

  /// Validasi IP publik device dengan allowed IP dari server config.
  /// Server hanya menyimpan IP yang diizinkan di .env — tidak perlu rebuild app jika IP berubah.
  Future<bool> _validateWifiPublicIp(BuildContext context) async {
    try {
      final dioClient = Dio();

      // 1. Ambil allowed IP dari server config
      String allowedIp;
      try {
        final configRes = await dioClient
            .get(
              '${EnvironmentConfig.baseUrl}settings/wificonfig.php',
              options: Options(responseType: ResponseType.json),
            )
            .timeout(const Duration(seconds: 8));
        final configData = configRes.data;
        allowedIp = configData is Map<String, dynamic>
            ? '${configData['wifi_allowed_ip'] ?? ''}'
            : '';
      } catch (_) {
        if (!context.mounted) return false;
        context.showErrorMessage(
          'Tidak bisa mengambil konfigurasi jaringan. Coba lagi.',
        );
        return false;
      }

      if (allowedIp.isEmpty) {
        if (!context.mounted) return false;
        context
            .showErrorMessage('Konfigurasi IP Wi\'Fi ma\'had tidak ditemukan.');
        return false;
      }

      // 2. Deteksi IP publik device via external API
      String? detectedIp;
      try {
        final res = await dioClient
            .get(
              'https://api.ipify.org?format=json',
              options: Options(responseType: ResponseType.json),
            )
            .timeout(const Duration(seconds: 8));
        final data = res.data;
        detectedIp =
            data is Map<String, dynamic> ? '${data['ip'] ?? ''}' : null;
      } catch (_) {
        try {
          final res = await dioClient
              .get(
                'https://ipapi.co/json/',
                options: Options(responseType: ResponseType.json),
              )
              .timeout(const Duration(seconds: 8));
          final data = res.data;
          detectedIp =
              data is Map<String, dynamic> ? '${data['ip'] ?? ''}' : null;
        } catch (_) {
          try {
            final res = await dioClient
                .get(
                  'https://api.ip.sb/ip',
                  options: Options(responseType: ResponseType.plain),
                )
                .timeout(const Duration(seconds: 8));
            detectedIp = res.data?.toString().trim();
          } catch (_) {
            if (!context.mounted) return false;
            context.showErrorMessage(
              'Tidak bisa verifikasi IP. Pastikan koneksi jaringan aktif.',
            );
            return false;
          }
        }
      }

      if (!context.mounted) return false;

      if (detectedIp == allowedIp) return true;

      context.showErrorMessage(
        'Jaringan tidak diizinkan. Gunakan Wi-Fi / LAN ma\'had untuk absen.',
      );
      return false;
    } catch (e) {
      if (!context.mounted) return false;
      context.showErrorMessage('Gagal verifikasi jaringan.');
      return false;
    }
  }

  Future<void> _showPresenceOut(
    BuildContext context,
    WidgetRef ref,
    String key,
    String device,
  ) async {
    try {
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
            label: 'Jaringan (Wi-Fi / LAN)',
          ),
        ],
      );
      if (method == null || !context.mounted) return;

      final isWifiMethod = method == AttendanceMethod.wifi;
      if (isWifiMethod) {
        final isWifiIpValid = await _validateWifiPublicIp(context);
        if (!isWifiIpValid || !context.mounted) return;
      }

      final locations = await ref.watch(
        fetchListHostelProvider(key: key).future,
      );
      if (!context.mounted) return;

      final presenceLocation = isWifiMethod
          ? locations.isNotEmpty
              ? locations.first
              : null
          : await showChooseLocationDialog(context, ref, key);

      if (presenceLocation == null) return;

      // Show loading dialog while fetching GPS and calling API
      final dismissLoading = _startLoading(context);
      Absent? result;
      try {
        late double latitude;
        late double longitude;
        late bool isMocked;

        if (isWifiMethod) {
          latitude = 0.0;
          longitude = 0.0;
          isMocked = false;
        } else {
          final position = await ref.read(getCurrentLocationProvider.future);
          latitude = position.latitude;
          longitude = position.longitude;
          isMocked = position.isMocked;
        }

        final token = ref
            .watch(sharedPreferencesHelperProvider)
            .getString(AppConstant.keyDeviceToken);

        final requestLogout = RequestLogout(
          mock: isMocked,
          longitude: longitude,
          latitude: latitude,
          key: key,
          lokasi: '${presenceLocation.idAsrama}',
          token: token,
          device: device,
        );
        result = await ref
            .read(accountControllerProvider.notifier)
            .presenceOut(requestLogout);
      } finally {
        dismissLoading();
      }
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
      final errorMessage = error.toString();
      // Cek apakah error terkait lokasi/permission
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
          // Hanya buka settings jika bukan web
          if (!kIsWeb) {
            await Geolocator.openAppSettings();
          }
        });
        return;
      }
      context.showErrorMessage(errorMessage);
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

  void _showUpdateDialog(
    BuildContext context,
    String currentVersion,
    UpdateInfo updateInfo,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    kIsWeb ? Icons.new_releases : Icons.system_update,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kIsWeb ? 'Apa yang Baru' : 'Update Tersedia',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          kIsWeb
                              ? 'Versi ${updateInfo.latestVersion}${updateInfo.releaseDate.isNotEmpty ? '  •  ${updateInfo.releaseDate}' : ''}'
                              : 'v$currentVersion → v${updateInfo.latestVersion}${updateInfo.releaseDate.isNotEmpty ? '  •  ${updateInfo.releaseDate}' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 20),
            // Changelog content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: _buildChangelogWidgets(
                  ctx,
                  updateInfo.changelogContent,
                ),
              ),
            ),
            // Buttons
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(ctx).padding.bottom + 16,
              ),
              child: Column(
                children: [
                  // Web: show "Mengerti" button only
                  // Native: show "Update Sekarang" button with Play Store link
                  if (kIsWeb)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Mengerti'),
                        onPressed: () async {
                          await UpdateChecker.markChangelogAsSeen(
                            currentVersion,
                          );
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        },
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Update Sekarang'),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          await InAppBrowser.openWithSystemBrowser(
                            url: WebUri(UpdateChecker.playStoreUrl),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Native only: show "Nanti Saja" button
                  if (!kIsWeb)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Nanti Saja'),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Parse baris-baris markdown changelog menjadi widget sederhana.
  List<Widget> _buildChangelogWidgets(BuildContext context, String markdown) {
    final widgets = <Widget>[];
    for (final line in markdown.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 4));
      } else if (trimmed.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            trimmed.substring(4),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ));
      } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        final content = trimmed.substring(2);
        // Bold **text**
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 13)),
              Expanded(
                child: Text(
                  content.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'\1'),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ));
      } else if (!trimmed.startsWith('#')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(trimmed, style: const TextStyle(fontSize: 13)),
        ));
      }
    }
    return widgets;
  }

  /// Shows a dismissible loading dialog.
  /// Returns a [VoidCallback] that closes the dialog (safe to call even if
  /// the user already dismissed it by tapping outside).
  VoidCallback _startLoading(BuildContext context) {
    bool active = true;
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (_) => Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(strokeWidth: 3),
                SizedBox(width: 20),
                Text('Mohon tunggu...'),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() => active = false);

    return () {
      if (active && context.mounted) {
        active = false;
        Navigator.of(context).pop();
      }
    };
  }
}
