import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/hostel/hostel.dart';
import 'package:syathiby/models/medicine/medicine.dart';
import 'package:syathiby/models/news/news.dart';
import 'package:syathiby/models/place/inventaris.dart';
import 'package:syathiby/models/prayer/hadith/book_response.dart';
import 'package:syathiby/models/prayer/surah/surah.dart';
import 'package:syathiby/models/product/product.dart';
import 'package:syathiby/models/rpp/rpp.dart';
import 'package:syathiby/models/slip/absent.dart';
import 'package:syathiby/models/staff/staff.dart';
import 'package:syathiby/models/student/siswa.dart';
import 'package:syathiby/presentation/absen_asrama/add_hostel_attendance_screen.dart';
import 'package:syathiby/presentation/absen_asrama/hostel_attendance_screen.dart';
import 'package:syathiby/presentation/absen_asrama/hostel_room_screen.dart';
import 'package:syathiby/presentation/absen_makan_gedung/add_eating_attendance_screen.dart';
import 'package:syathiby/presentation/absen_makan_gedung/eating_attendance_screen.dart';
import 'package:syathiby/presentation/absen_makan_gedung/eating_report_screen.dart';
import 'package:syathiby/presentation/activity/activity_presence_screen.dart';
import 'package:syathiby/presentation/dapur/add_cooking_report_screen.dart';
import 'package:syathiby/presentation/dapur/detail_cooking_report_screen.dart';
import 'package:syathiby/presentation/dapur/detail_food_menu_screen.dart';
import 'package:syathiby/presentation/dapur/detail_stock_tracking_screen.dart';
import 'package:syathiby/presentation/dapur/order_raw_material_screen.dart';
import 'package:syathiby/presentation/dapur/stock_opname_screen.dart';
import 'package:syathiby/presentation/dapur/upsert_food_menu_screen.dart';
import 'package:syathiby/presentation/dapur/upsert_raw_material_screen.dart';
import 'package:syathiby/presentation/data_obat/add_request_medicine_screen.dart';
import 'package:syathiby/presentation/data_obat/detail_medicine_request_screen.dart';
import 'package:syathiby/presentation/data_obat/medicine_request_screen.dart';
import 'package:syathiby/presentation/data_obat/medicine_screen.dart';
import 'package:syathiby/presentation/data_obat/upsert_medicine_screen.dart';
import 'package:syathiby/presentation/forgot/forgot_screen.dart';
import 'package:syathiby/presentation/home/home_screen.dart';
import 'package:syathiby/presentation/jadwal/class_journal_screen.dart';
import 'package:syathiby/presentation/jadwal/classroom_screen.dart';
import 'package:syathiby/presentation/jadwal/teaching_schedule_screen.dart';
import 'package:syathiby/presentation/job/detail_job_screen.dart';
import 'package:syathiby/presentation/job/job_screen.dart';
import 'package:syathiby/presentation/kepengasuhan/detail_parenting_score_screen.dart';
import 'package:syathiby/presentation/kepengasuhan/parenting_score_screen.dart';
import 'package:syathiby/presentation/kepengasuhan/upsert_parenting_score_screen.dart';
import 'package:syathiby/presentation/kesehatan/add_student_health_screen.dart';
import 'package:syathiby/presentation/kesehatan/detail_student_health_screen.dart';
import 'package:syathiby/presentation/kesehatan/student_health_list_screen.dart';
import 'package:syathiby/presentation/keuangan/add_spending_screen.dart';
import 'package:syathiby/presentation/keuangan/detail_spending_screen.dart';
import 'package:syathiby/presentation/keuangan/raw_material_screen.dart';
import 'package:syathiby/presentation/keuangan/spending_report_screen.dart';
import 'package:syathiby/presentation/keuangan/student_transaction_screen.dart';
import 'package:syathiby/presentation/kinerja/performance_screen.dart';
import 'package:syathiby/presentation/laporan_absen_kelas/classroom_attendance_screen.dart';
import 'package:syathiby/presentation/laporan_absen_kelas/hostel_classroom_screen.dart';
import 'package:syathiby/presentation/laporan_absen_kelas/hostel_screen.dart';
import 'package:syathiby/presentation/laporan_aktivitas/activity_report_screen.dart';
import 'package:syathiby/presentation/laporan_aktivitas/add_activity_report_screen.dart';
import 'package:syathiby/presentation/login/login_screen.dart';
import 'package:syathiby/presentation/manage/manage_staff_screen.dart';
import 'package:syathiby/presentation/manage/upsert_staff_screen.dart';
import 'package:syathiby/presentation/news/news_screen.dart';
import 'package:syathiby/presentation/pelanggaran/add_violation_screen.dart';
import 'package:syathiby/presentation/pelanggaran/detail_violation_screen.dart';
import 'package:syathiby/presentation/pelanggaran/violation_list_screen.dart';
import 'package:syathiby/presentation/penilaian/score_type_screen.dart';
import 'package:syathiby/presentation/penilaian/student_score_screen.dart';
import 'package:syathiby/presentation/penilaian/subjects_screen.dart';
import 'package:syathiby/presentation/penjemputan/detail_event_student_screen.dart';
import 'package:syathiby/presentation/penjemputan/event_classroom_screen.dart';
import 'package:syathiby/presentation/penjemputan/event_hostel_screen.dart';
import 'package:syathiby/presentation/penjemputan/event_screen.dart';
import 'package:syathiby/presentation/penjemputan/event_student_screen.dart';
import 'package:syathiby/presentation/permit/add_permit_screen.dart';
import 'package:syathiby/presentation/permit/detail_permit_screen.dart';
import 'package:syathiby/presentation/permit/permit_screen.dart';
import 'package:syathiby/presentation/prayer/ayah_screen.dart';
import 'package:syathiby/presentation/prayer/book_screen.dart';
import 'package:syathiby/presentation/prayer/dhikr_screen.dart';
import 'package:syathiby/presentation/prayer/hadith_screen.dart';
import 'package:syathiby/presentation/prayer/murottal_screen.dart';
import 'package:syathiby/presentation/prayer/pray_screen.dart';
import 'package:syathiby/presentation/prayer/prayer_screen.dart';
import 'package:syathiby/presentation/prayer/prayer_time_screen.dart';
import 'package:syathiby/presentation/prayer/surah_screen.dart';
import 'package:syathiby/presentation/presence/add_visiting_presence_screen.dart';
import 'package:syathiby/presentation/presence/presence_screen.dart';
import 'package:syathiby/presentation/presence/visiting_presence_screen.dart';
import 'package:syathiby/presentation/presensi_tahfidz/tahfidz_presence_list_screen.dart';
import 'package:syathiby/presentation/presensi_tahfidz/tahfidz_presence_screen.dart';
import 'package:syathiby/presentation/rapat/add_meeting_participant_screen.dart';
import 'package:syathiby/presentation/rapat/add_meeting_screen.dart';
import 'package:syathiby/presentation/rapat/detail_manage_meeting_screen.dart';
import 'package:syathiby/presentation/rapat/manage_meeting_screen.dart';
import 'package:syathiby/presentation/rapat/meeting_notes_screen.dart';
import 'package:syathiby/presentation/rapat/meeting_qr_code_screen.dart';
import 'package:syathiby/presentation/rapat/meeting_screen.dart';
import 'package:syathiby/presentation/rekap/filter_recap_presence_screen.dart';
import 'package:syathiby/presentation/rekap/manual_attendance_screen.dart';
import 'package:syathiby/presentation/rekap/recap_presence_screen.dart';
import 'package:syathiby/presentation/report/attendance_recap_screen.dart';
import 'package:syathiby/presentation/report/attendance_report_month_screen.dart';
import 'package:syathiby/presentation/report/detail_attendance_report_screen.dart';
import 'package:syathiby/presentation/report/report_presence_screen.dart';
import 'package:syathiby/presentation/reward/add_reward_screen.dart';
import 'package:syathiby/presentation/reward/reward_screen.dart';
import 'package:syathiby/presentation/rpp/detail_teaching_planner_screen.dart';
import 'package:syathiby/presentation/rpp/teaching_planner_screen.dart';
import 'package:syathiby/presentation/rumah_tangga/inventory_screen.dart';
import 'package:syathiby/presentation/rumah_tangga/places_screen.dart';
import 'package:syathiby/presentation/rumah_tangga/upsert_inventory_screen.dart';
import 'package:syathiby/presentation/setting/account_screen.dart';
import 'package:syathiby/presentation/setting/change_password_screen.dart';
import 'package:syathiby/presentation/setting/face_unclock_screen.dart';
import 'package:syathiby/presentation/setting/presence_type.dart';
import 'package:syathiby/presentation/setting/setting_screen.dart';
import 'package:syathiby/presentation/tahfidzh/detail_tahfidz_screen.dart';
import 'package:syathiby/presentation/tahfidzh/tahfidz_grade_screen.dart';
import 'package:syathiby/presentation/tahfidzh/tahfidz_screen.dart';
import 'package:syathiby/presentation/tahfidzh/upsert_tahfidz_screen.dart';
import 'package:syathiby/presentation/transaction/history_transaction_screen.dart';
import 'package:syathiby/presentation/tv/tv_screen.dart';
import 'package:syathiby/presentation/ubah_jadwal/add_change_shift_screen.dart';
import 'package:syathiby/presentation/ubah_jadwal/detail_change_shift_screen.dart';
import 'package:syathiby/presentation/wali_kelas/homeroom_teacher_screen.dart';
import 'package:syathiby/presentation/wali_kelas/report_card_screen.dart';
import 'package:syathiby/res/strings.dart';
import 'package:syathiby/utils/adaptive_scaffold.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/job/job.dart';
import '../models/meeting/meeting.dart';
import '../models/raw_material/raw_material.dart';
import '../models/schedule/schedule.dart';
import '../models/tahfidz/tahfidz.dart';
import '../presentation/activity/student_activity_screen.dart';
import '../presentation/dapur/cooking_report_screen.dart';
import '../presentation/dapur/food_menu_screen.dart';
import '../presentation/dapur/manage_kitchen_screen.dart';
import '../presentation/dapur/tracking_stock_screen.dart';
import '../presentation/data_obat/medicine_database_screen.dart';
import '../presentation/izin_santri/add_student_permit_screen.dart';
import '../presentation/izin_santri/detail_student_permit_screen.dart';
import '../presentation/izin_santri/student_permit_screen.dart';
import '../presentation/manage_job/manage_job_screen.dart';
import '../presentation/manage_job/upsert_manage_job.dart';
import '../presentation/news/detail_news_screen.dart';
import '../presentation/penilaian/score_screen.dart';
import '../presentation/prayer/qibla_compass_screen.dart';
import '../presentation/presensi_tahfidz/tahfidz_teacher_presence_screen.dart';
import '../presentation/puasa/add_report_fasting_student.dart';
import '../presentation/puasa/report_fasting_student_screen.dart';
import '../presentation/rapat/detail_meeting_screen.dart';
import '../presentation/rekap/add_manual_attendance_screen.dart';
import '../presentation/rekap/data_presence_screen.dart';
import '../presentation/report/attendance_report_screen.dart';
import '../presentation/report/student_fasting_screen.dart';
import '../presentation/setting/face_preview_screen.dart';
import '../presentation/setting/fingerprint_screen.dart';
import '../presentation/tahfidzh/detail_tahfidz_grade_screen.dart';
import '../presentation/tahfidzh/upsert_tahfidz_grade_screen.dart';
import '../presentation/transaction/add_item_screen.dart';
import '../presentation/transaction/add_request_transaction_screen.dart';
import '../presentation/transaction/detail_request_transaction_screen.dart';
import '../presentation/transaction/items_screen.dart';
import '../presentation/transaction/request_items_screen.dart';
import '../presentation/ubah_jadwal/change_shift_screen.dart';
import '../presentation/webview/webview_screen.dart';

import 'package:syathiby/presentation/prayer/qibla_compass_screen.dart';

part 'app_router.g.dart';

enum AppRoute {
  home,
  login,
  forgot,
  news,
  detailNews,
  performance,
  account,
  setting,
  fingerprint,
  faceUnlock,
  facePreview,
  changePassword,
  privacyPolicy,
  agreement,
  aboutUs,
  prayer,
  quran,
  hadith,
  books,
  prayerTime,
  murottal,
  qibla,
  qiblaMaps,
  dhikr,
  pray,
  ayah,
  permit,
  assignment,
  teachingSchedule,
  visit,
  report,
  violation,
  studentScore,
  classAttendance,
  teachingPlanner,
  studentReward,
  homeroomTeacher,
  boardingStudentScore,
  studentPermit,
  fastingReport,
  homecoming,
  studentHealth,
  medicines,
  UkpInventory,
  mealPresence,
  goodsInventory,
  tahfidzPresence,
  memorizationDeposits,
  savings,
  loundry,
  minimarket,
  canteen,
  changeShift,
  meetings,
  activityReport,
  historyTransaction,
  addWork,
  recapPresence,
  manageMeetings,
  manualAttendance,
  presenceList,
  reportPresence,
  management,
  presence,
  addPermit,
  detailPermit,
  jobs,
  detailJob,
  classroom,
  journalClass,
  presenceReport,
  visitingPresence,
  addVisiting,
  attendanceReport,
  attendanceReportDetail,
  attendanceRecap,
  addViolation,
  detailViolation,
  detailStudentHealth,
  addStudentHealth,
  tahfidzPresenceList,
  upsertTahfidz,
  detailTahfidz,
  tahfidz,
  tahfidzGrade,
  upsertTahfidzGrade,
  detailTahfidzGrade,
  detailManageMeeting,
  addMeetingParticipant,
  meetingQrCode,
  meetingNotes,
  addMeeting,
  detailMeeting,
  meetingScanQr,
  editJob,
  upsertManageJob,
  manageJob,
  subjects,
  scoreType,
  score,
  classroomAttendance,
  hostelClassroom,
  detailTeachingPlanner,
  addActivityReport,
  addStudentReward,
  reportCard,
  parentingScore,
  upsertParentingScore,
  detailParentingScore,
  hostelAttendance,
  hostelRoom,
  addHostelAttendance,
  addStudentPermit,
  detailStudentPermit,
  eatingAttendance,
  addEatingAttendance,
  addFastingReport,
  homecomingHostel,
  homecomingClassroom,
  homecomingStudent,
  detailHomecoming,
  medicineRequest,
  detailMedicineRequest,
  addMedicineRequest,
  medicineDatabase,
  upsertMedicine,
  places,
  addInventory,
  inventories,
  upsertInventory,
  eatingReport,
  studentTransaction,
  addSpending,
  spending,
  detailSpending,
  studentFasting,
  manageKitchen,
  upsertFoodMenu,
  foodMenu,
  detailFoodMenu,
  upsertRawMaterial,
  rawMaterial,
  orderRawMaterial,
  cookingReport,
  detailCookingReport,
  addCookingReport,
  trackingStock,
  detailTrackingStock,
  stockOpname,
  tahfidzTeacherPresence,
  addChangeShift,
  detailChangeShift,
  changeShiftAdmin,
  activityPresence,
  studentActivity,
  filterRecapPresence,
  detailRecapPresence,
  detailRecapPermit,
  reportAttendance,
  recapAttendance,
  tv,
  detailJournalClass,
  upsertStaff,
  addManualAttendance,
  items,
  requestItems,
  detailRequestTransaction,
  orderItem,
  addItem,
  scanQr,
  dataPresence,
  attendanceRecapMonth,
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorAKey = GlobalKey<NavigatorState>();
final _shellNavigatorBKey = GlobalKey<NavigatorState>();
final _shellNavigatorCKey = GlobalKey<NavigatorState>();
final _shellNavigatorDKey = GlobalKey<NavigatorState>();
final _shellNavigatorEKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    // errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: (context, state) async {
      try {
        final session = ref
            .read(sharedPreferencesHelperProvider)
            .getObject<Map<String, dynamic>>(AppConstant.keyLoginSession);

        final goingToLogin = state.matchedLocation.contains('/login');
        if (session == null && !goingToLogin) {
          return '/login';
        }
        return null;
      }catch(e){
       return '/login';
      }
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldNestedNavigation(navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAKey,
            routes: [
              GoRoute(
                path: '/',
                name: AppRoute.home.name,
                builder: (context, state) => HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'presence',
                    name: AppRoute.presence.name,
                    builder: (context, state) => PresenceScreen(
                      type: state.extra as PresenceType,
                    ),
                  ),
                  GoRoute(
                    path: 'permit',
                    name: AppRoute.permit.name,
                    builder: (context, state) => const PermitScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: AppRoute.addPermit.name,
                        builder: (context, state) => const AddPermitScreen(),
                      ),
                      GoRoute(
                        path: 'detail',
                        name: AppRoute.detailPermit.name,
                        builder: (context, state) => DetailPermitScreen(
                          permitId: state.extra as String,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'jobs',
                    name: AppRoute.jobs.name,
                    builder: (context, state) => const JobScreen(),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        name: AppRoute.detailJob.name,
                        builder: (context, state) => DetailJobScreen(
                          jobId: state.extra as String,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'teaching-schedule',
                    name: AppRoute.teachingSchedule.name,
                    builder: (context, state) => const TeachingScheduleScreen(),
                    routes: [
                      GoRoute(
                        path: 'classroom',
                        name: AppRoute.classroom.name,
                        builder: (context, state) =>
                            ClassroomScreen(schedule: state.extra as Jadwal),
                        routes: [
                          GoRoute(
                            path: 'journal',
                            name: AppRoute.journalClass.name,
                            builder: (context, state) => JournalClassScreen(
                              schedule: state.extra as Jadwal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'visiting-presence',
                    name: AppRoute.visitingPresence.name,
                    builder: (context, state) => const VisitingPresenceScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: AppRoute.addVisiting.name,
                        builder: (context, state) =>
                            const AddVisitingPresenceScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'presence-report',
                    name: AppRoute.presenceReport.name,
                    builder: (context, state) => const PresenceReportScreen(),
                    routes: [
                      GoRoute(
                        path: 'attendance',
                        name: AppRoute.attendanceReport.name,
                        builder: (context, state) => AttendanceReportScreen(
                          startDate: state.uri.queryParameters['startDate'],
                          endDate: state.uri.queryParameters['endDate'],
                        ),
                        routes: [
                          GoRoute(
                            path: 'detail',
                            name: AppRoute.attendanceReportDetail.name,
                            builder: (context, state) =>
                                DetailAttendanceReportScreen(
                              absent: state.extra as Absent,
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'recap',
                        name: AppRoute.attendanceRecap.name,
                        builder: (context, state) => AttendanceRecapScreen(
                          startDate: state.uri.queryParameters['startDate'],
                          endDate: state.uri.queryParameters['endDate'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'violation',
                    name: AppRoute.violation.name,
                    builder: (context, state) => ViolationListScreen(
                      type: state.uri.queryParameters['type'],
                    ),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: AppRoute.addViolation.name,
                        builder: (context, state) => AddViolationScreen(
                          type: state.uri.queryParameters['type'],
                        ),
                      ),
                      GoRoute(
                        path: 'detail',
                        name: AppRoute.detailViolation.name,
                        builder: (context, state) => DetailViolationScreen(
                          violationId: state.extra as String,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'student-health',
                    name: AppRoute.studentHealth.name,
                    builder: (context, state) =>
                        const StudentHealthListScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: AppRoute.addStudentHealth.name,
                        builder: (context, state) =>
                            const AddStudentHealthScreen(),
                      ),
                      GoRoute(
                        path: 'detail',
                        name: AppRoute.detailStudentHealth.name,
                        builder: (context, state) => DetailStudentHealthScreen(
                          studentHealthId: state.extra as String,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'tahfidz-presence',
                    name: AppRoute.tahfidzPresence.name,
                    builder: (context, state) => TahfidzPresenceScreen(
                      type: state.uri.queryParameters['type'],
                    ),
                    routes: [
                      GoRoute(
                        path: 'list',
                        name: AppRoute.tahfidzPresenceList.name,
                        builder: (context, state) => TahfidzPresenceListScreen(
                          date: state.uri.queryParameters['date'],
                          time: state.uri.queryParameters['time'],
                        ),
                      ),
                      GoRoute(
                        path: 'teacher',
                        name: AppRoute.tahfidzTeacherPresence.name,
                        builder: (context, state) =>
                            TahfidzTeacherPresenceScreen(
                          date: state.uri.queryParameters['date'],
                          time: state.uri.queryParameters['time'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'tahfidz',
                    name: AppRoute.tahfidz.name,
                    builder: (context, state) => const TahfidzScreen(),
                    routes: [
                      GoRoute(
                        path: 'upsert',
                        name: AppRoute.upsertTahfidz.name,
                        builder: (context, state) => UpsertTahfidzScreen(
                          tahfidz: state.extra as Tahfidz?,
                        ),
                      ),
                      GoRoute(
                        path: 'detail',
                        name: AppRoute.detailTahfidz.name,
                        builder: (context, state) => DetailTahfidzScreen(
                          tahfidzId: state.uri.queryParameters['tahfidzId'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'tahfidz-grade',
                    name: AppRoute.tahfidzGrade.name,
                    builder: (context, state) => const TahfidzGradeScreen(),
                    routes: [
                      GoRoute(
                        path: 'upsert',
                        name: AppRoute.upsertTahfidzGrade.name,
                        builder: (context, state) => UpsertTahfidzGradeScreen(
                          tahfidz: state.extra as Tahfidz?,
                        ),
                      ),
                      GoRoute(
                        path: 'detail',
                        name: AppRoute.detailTahfidzGrade.name,
                        builder: (context, state) => DetailTahfidzGradeScreen(
                          tahfidzId: state.uri.queryParameters['tahfidzId'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'meeting',
                    name: AppRoute.meetings.name,
                    builder: (context, state) => const MeetingScreen(),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        name: AppRoute.detailMeeting.name,
                        builder: (context, state) => DetailMeetingScreen(
                          meetingId: state.uri.queryParameters['meetingId'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'manage-meeting',
                    name: AppRoute.manageMeetings.name,
                    builder: (context, state) => const ManageMeetingScreen(),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        name: AppRoute.detailManageMeeting.name,
                        builder: (context, state) => DetailManageMeetingScreen(
                          meetingId: state.uri.queryParameters['meetingId'],
                        ),
                      ),
                      GoRoute(
                        path: 'insert',
                        name: AppRoute.addMeeting.name,
                        builder: (context, state) => const AddMeetingScreen(),
                      ),
                      GoRoute(
                        path: 'insert-participant',
                        name: AppRoute.addMeetingParticipant.name,
                        builder: (context, state) =>
                            AddMeetingParticipantScreen(
                          meeting: state.extra as Rapat?,
                        ),
                      ),
                      GoRoute(
                        path: 'qrcode',
                        name: AppRoute.meetingQrCode.name,
                        builder: (context, state) => MeetingQrCodeScreen(
                          meeting: state.extra as Rapat?,
                        ),
                      ),
                      GoRoute(
                        path: 'notes',
                        name: AppRoute.meetingNotes.name,
                        builder: (context, state) => MeetingNotesScreen(
                          meeting: state.extra as Rapat?,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'manage-job',
                    name: AppRoute.manageJob.name,
                    builder: (context, state) => const ManageJobScreen(),
                    routes: [
                      GoRoute(
                        path: 'upsert',
                        name: AppRoute.upsertManageJob.name,
                        builder: (context, state) => UpsertManageJobScreen(
                          job: state.extra as Job?,
                        ),
                      ),
                    ],
                  ),
                  // Education Menu
                  GoRoute(
                    path: 'score-type',
                    name: AppRoute.scoreType.name,
                    builder: (context, state) => const ScoreTypeScreen(),
                    routes: [
                      GoRoute(
                        path: 'subject',
                        name: AppRoute.subjects.name,
                        builder: (context, state) => SubjectsScreen(
                          scoreTypeId: state.uri.queryParameters['scoreTypeId'],
                        ),
                        routes: [
                          GoRoute(
                            path: 'student',
                            name: AppRoute.studentScore.name,
                            builder: (context, state) => StudentScoreScreen(
                              classId: state.uri.queryParameters['classId'],
                              className: state.uri.queryParameters['className'],
                              subjectId: state.uri.queryParameters['subjectId'],
                              day: state.uri.queryParameters['day'],
                              hour: state.uri.queryParameters['hour'],
                              scoreTypeId:
                                  state.uri.queryParameters['scoreTypeId'],
                              subjectName:
                                  state.uri.queryParameters['subjectName'],
                            ),
                            routes: [
                              GoRoute(
                                path: 'score',
                                name: AppRoute.score.name,
                                builder: (context, state) => ScoreScreen(
                                  scoreTypeId:
                                      state.uri.queryParameters['scoreTypeId'],
                                  subjectId:
                                      state.uri.queryParameters['subjectId'],
                                  classId: state.uri.queryParameters['classId'],
                                  studentId:
                                      state.uri.queryParameters['studentId'],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'hostel',
                    name: AppRoute.classAttendance.name,
                    builder: (context, state) => const HostelScreen(),
                    routes: [
                      GoRoute(
                        path: 'classroom',
                        name: AppRoute.hostelClassroom.name,
                        builder: (context, state) => HostelClassroomScreen(
                          hostelId: state.uri.queryParameters['hostelId'],
                          hostelName: state.uri.queryParameters['hostelName'],
                        ),
                        routes: [
                          GoRoute(
                            path: 'attendance',
                            name: AppRoute.classroomAttendance.name,
                            builder: (context, state) =>
                                ClassroomAttendanceScreen(
                              classId: state.uri.queryParameters['classId'],
                              className: state.uri.queryParameters['className'],
                              date: state.uri.queryParameters['date'],
                              hostelId: state.uri.queryParameters['hostelId'],
                              hostelName:
                                  state.uri.queryParameters['hostelName'],
                            ),
                            routes: [
                              // TODO REQUEST FEATURE CHECK DETAIL JOURNAL CLASS
                              GoRoute(
                                path: 'journal',
                                name: AppRoute.detailJournalClass.name,
                                builder: (context, state) => JournalClassScreen(
                                  schedule: state.extra as Jadwal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  // RPP
                  GoRoute(
                    path: 'activity-report',
                    name: AppRoute.activityReport.name,
                    builder: (context, state) => ActivityReportScreen(
                      type: state.uri.queryParameters['type'],
                    ),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: AppRoute.addActivityReport.name,
                        builder: (context, state) => AddActivityReportScreen(
                          type: state.uri.queryParameters['type'],
                          date: state.uri.queryParameters['date'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'teaching-planner',
                    name: AppRoute.teachingPlanner.name,
                    builder: (context, state) => const TeachingPlannerScreen(),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        name: AppRoute.detailTeachingPlanner.name,
                        builder: (context, state) =>
                            DetailTeachingPlannerScreen(
                                teachingPlanner: state.extra as Rpp),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'student-reward',
                    name: AppRoute.studentReward.name,
                    builder: (context, state) => RewardScreen(
                      title: state.uri.queryParameters['title'],
                    ),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: AppRoute.addStudentReward.name,
                        builder: (context, state) => const AddRewardScreen(),
                      ),
                    ],
                  ),
                  // Homeroom teacher
                  GoRoute(
                    path: 'homeroom-teacher',
                    name: AppRoute.homeroomTeacher.name,
                    builder: (context, state) => const HomeroomTeacherScreen(),
                    routes: [
                      GoRoute(
                        path: 'report',
                        name: AppRoute.reportCard.name,
                        builder: (context, state) =>
                            ReportCardScreen(student: state.extra as Siswa),
                      ),
                    ],
                  ),
                  // Parenting
                  GoRoute(
                    path: 'parenting-score',
                    name: AppRoute.parentingScore.name,
                    builder: (context, state) => const ParentingScoreScreen(),
                    routes: [
                      GoRoute(
                        path: 'upsert',
                        name: AppRoute.upsertParentingScore.name,
                        builder: (context, state) => UpsertParentingScoreScreen(
                          tahfidz: state.extra as Tahfidz?,
                        ),
                      ),
                      GoRoute(
                        path: 'detail',
                        name: AppRoute.detailParentingScore.name,
                        builder: (context, state) => DetailParentingScoreScreen(
                          tahfidzId: state.uri.queryParameters['tahfidzId'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'hostel-attendance',
                    name: AppRoute.hostelAttendance.name,
                    builder: (context, state) => const HostelAttendanceScreen(),
                    routes: [
                      GoRoute(
                        path: 'room',
                        name: AppRoute.hostelRoom.name,
                        builder: (context, state) => HostelRoomScreen(
                          hostelId: state.uri.queryParameters['hostelId'],
                          hostelName: state.uri.queryParameters['hostelName'],
                        ),
                        routes: [
                          GoRoute(
                            path: 'room',
                            name: AppRoute.addHostelAttendance.name,
                            builder: (context, state) =>
                                AddHostelAttendanceScreen(
                              hostel: state.extra as Asrama,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Student Savings
                  GoRoute(
                    path: 'student-transaction',
                    name: AppRoute.studentTransaction.name,
                    builder: (context, state) => StudentTransactionScreen(
                      type: state.uri.queryParameters['type'],
                    ),
                  ),
                  // Student Permit
                  GoRoute(
                    path: 'student-permit',
                    name: AppRoute.studentPermit.name,
                    builder: (context, state) => const StudentPermitScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: AppRoute.addStudentPermit.name,
                        builder: (context, state) =>
                            const AddStudentPermitScreen(),
                      ),
                      GoRoute(
                        path: 'detail',
                        name: AppRoute.detailStudentPermit.name,
                        builder: (context, state) => DetailStudentPermitScreen(
                          permitId: state.extra as String,
                        ),
                      ),
                    ],
                  ),
                  // Fasting Report Student
                  GoRoute(
                    path: 'fasting-report',
                    name: AppRoute.fastingReport.name,
                    builder: (context, state) =>
                        const ReportFastingStudentScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: AppRoute.addFastingReport.name,
                        builder: (context, state) =>
                            const AddReportFastingStudentScreen(),
                      ),
                    ],
                  ),
                  // Eating Attendance
                  GoRoute(
                    path: 'eating-attendance',
                    name: AppRoute.eatingAttendance.name,
                    builder: (context, state) => const EatingAttendanceScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: AppRoute.addEatingAttendance.name,
                        builder: (context, state) => AddEatingAttendanceScreen(
                          date: state.uri.queryParameters['date'],
                          time: state.uri.queryParameters['time'],
                        ),
                      ),
                    ],
                  ),
                  // Homecoming Student
                  GoRoute(
                    path: 'homecoming',
                    name: AppRoute.homecoming.name,
                    builder: (context, state) => const EventScreen(),
                    routes: [
                      GoRoute(
                        path: 'hostel',
                        name: AppRoute.homecomingHostel.name,
                        builder: (context, state) => EventHostelScreen(
                          eventId: state.uri.queryParameters['eventId'],
                          eventName: state.uri.queryParameters['eventName'],
                        ),
                        routes: [
                          GoRoute(
                            path: 'classroom',
                            name: AppRoute.homecomingClassroom.name,
                            builder: (context, state) => EventClassroomScreen(
                              eventId: state.uri.queryParameters['eventId'],
                              hostelId: state.uri.queryParameters['hostelId'],
                              eventName: state.uri.queryParameters['eventName'],
                            ),
                            routes: [
                              GoRoute(
                                path: 'student',
                                name: AppRoute.homecomingStudent.name,
                                builder: (context, state) => EventStudentScreen(
                                  eventId: state.uri.queryParameters['eventId'],
                                  eventName:
                                      state.uri.queryParameters['eventName'],
                                  classId: state.uri.queryParameters['classId'],
                                  type: state.uri.queryParameters['type'],
                                  typeName:
                                      state.uri.queryParameters['typeName'],
                                ),
                              ),
                            ],
                          ),
                          GoRoute(
                            path: 'detail',
                            name: AppRoute.detailHomecoming.name,
                            builder: (context, state) =>
                                DetailEventStudentScreen(
                              eventId: state.uri.queryParameters['eventId'],
                              id: state.uri.queryParameters['id'],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Spending Report
                  GoRoute(
                    path: 'spending',
                    name: AppRoute.spending.name,
                    builder: (context, state) => const SpendingReportScreen(),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        name: AppRoute.detailSpending.name,
                        builder: (context, state) => DetailSpendingScreen(
                          invoiceId: state.uri.queryParameters['invoiceId'],
                        ),
                      ),
                      GoRoute(
                        path: 'add',
                        name: AppRoute.addSpending.name,
                        builder: (context, state) => const AddSpendingScreen(),
                      ),
                    ],
                  ),
                  // Fasting Report
                  GoRoute(
                    path: 'student-fasting',
                    name: AppRoute.studentFasting.name,
                    builder: (context, state) => const StudentFastingScreen(),
                  ),
                  // Menu Kepala Bagian Laporan Absensi
                  GoRoute(
                    path: 'report-attendance',
                    name: AppRoute.reportAttendance.name,
                    builder: (context, state) => AttendanceReportScreen(
                      startDate: state.uri.queryParameters['startDate'],
                      endDate: state.uri.queryParameters['endDate'],
                      userKey: state.uri.queryParameters['userKey'],
                      name: state.uri.queryParameters['name'],
                    ),
                  ),
                  GoRoute(
                    path: 'recap-attendance',
                    name: AppRoute.attendanceRecapMonth.name,
                    builder: (context, state) =>
                        const AttendanceReportMonthScreen(),
                  ),
                  // Manage Kitchen
                  GoRoute(
                    path: 'manage-kitchen',
                    name: AppRoute.manageKitchen.name,
                    builder: (context, state) => const ManageKitchenScreen(),
                    routes: [
                      GoRoute(
                        path: 'menu',
                        name: AppRoute.foodMenu.name,
                        builder: (context, state) => const FoodMenuScreen(),
                        routes: [
                          GoRoute(
                            path: 'upsert',
                            name: AppRoute.upsertFoodMenu.name,
                            builder: (context, state) => UpsertFoodMenuScreen(
                              product: state.extra as Product?,
                            ),
                          ),
                          GoRoute(
                            path: 'detail',
                            name: AppRoute.detailFoodMenu.name,
                            builder: (context, state) =>
                                const DetailFoodMenuScreen(),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'raw-material',
                        name: AppRoute.rawMaterial.name,
                        builder: (context, state) => const RawMaterialScreen(),
                        routes: [
                          GoRoute(
                            path: 'upsert',
                            name: AppRoute.upsertRawMaterial.name,
                            builder: (context, state) =>
                                UpsertRawMaterialScreen(
                              rawMaterial: state.extra as RawMaterial?,
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'order-raw-material',
                        name: AppRoute.orderRawMaterial.name,
                        builder: (context, state) =>
                            const OrderRawMaterialScreen(),
                      ),
                      GoRoute(
                        path: 'cooking-report',
                        name: AppRoute.cookingReport.name,
                        builder: (context, state) =>
                            const CookingReportScreen(),
                        routes: [
                          GoRoute(
                            path: 'detail',
                            name: AppRoute.detailCookingReport.name,
                            builder: (context, state) =>
                                DetailCookingReportScreen(
                              invoiceId: state.uri.queryParameters['invoiceId'],
                              status: state.uri.queryParameters['status'],
                            ),
                          ),
                          GoRoute(
                            path: 'add',
                            name: AppRoute.addCookingReport.name,
                            builder: (context, state) =>
                                const AddCokingReportScreen(),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'tracking-stock',
                        name: AppRoute.trackingStock.name,
                        builder: (context, state) =>
                            const TrackingStockScreen(),
                        routes: [
                          GoRoute(
                            path: 'detail',
                            name: AppRoute.detailTrackingStock.name,
                            builder: (context, state) =>
                                DetailTrackingStockScreen(
                              productId: state.uri.queryParameters['stockId'],
                            ),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'stock-opname',
                        name: AppRoute.stockOpname.name,
                        builder: (context, state) => const StockOpnameScreen(),
                      ),
                    ],
                  ),
                  // Medicine Request
                  GoRoute(
                    path: 'medicine-request',
                    name: AppRoute.medicineRequest.name,
                    builder: (context, state) => const MedicineRequestScreen(),
                    routes: [
                      GoRoute(
                        path: 'detail',
                        name: AppRoute.detailMedicineRequest.name,
                        builder: (context, state) =>
                            DetailMedicineRequestScreen(
                          invoiceId: state.uri.queryParameters['invoiceId'],
                          status: state.uri.queryParameters['status'],
                        ),
                      ),
                      GoRoute(
                        path: 'medicines',
                        name: AppRoute.medicines.name,
                        builder: (context, state) => const MedicineScreen(),
                        routes: [
                          GoRoute(
                            path: 'add',
                            name: AppRoute.addMedicineRequest.name,
                            builder: (context, state) =>
                                AddRequestMedicineScreen(
                              medicine: state.extra as Product,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Medicine Database
                  GoRoute(
                    path: 'medicine-database',
                    name: AppRoute.medicineDatabase.name,
                    builder: (context, state) => const MedicineDatabaseScreen(),
                    routes: [
                      GoRoute(
                        path: 'upsert',
                        name: AppRoute.upsertMedicine.name,
                        builder: (context, state) => UpsertMedicineScreen(
                          medicine: state.extra as DataObat?,
                        ),
                      ),
                    ],
                  ),
                  // Place Inventaris
                  GoRoute(
                    path: 'places',
                    name: AppRoute.places.name,
                    builder: (context, state) => const PlacesScreen(),
                    routes: [
                      GoRoute(
                        path: 'inventory',
                        name: AppRoute.inventories.name,
                        builder: (context, state) => InventoryScreen(
                          placeId: state.uri.queryParameters['placeId'],
                          placeName: state.uri.queryParameters['placeName'],
                        ),
                        routes: [
                          GoRoute(
                            path: 'upsert',
                            name: AppRoute.upsertInventory.name,
                            builder: (context, state) => UpsertInventoryScreen(
                              placeId: state.uri.queryParameters['placeId'],
                              inventory: state.extra as Inventaris?,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Eating Report
                  GoRoute(
                    path: 'eating-report',
                    name: AppRoute.eatingReport.name,
                    builder: (context, state) => const EatingReportScreen(),
                  ),
                  // Change Shift
                  GoRoute(
                    path: 'change-shift',
                    name: AppRoute.changeShift.name,
                    builder: (context, state) => ChangeShiftScreen(
                      level: state.uri.queryParameters['level'],
                    ),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: AppRoute.addChangeShift.name,
                        builder: (context, state) =>
                            const AddChangeShiftScreen(),
                      ),
                      GoRoute(
                        path: 'detail',
                        name: AppRoute.detailChangeShift.name,
                        builder: (context, state) => DetailChangeShiftScreen(
                          shiftId: state.uri.queryParameters['shiftId'],
                        ),
                      ),
                    ],
                  ),
                  // Student Activity
                  GoRoute(
                    path: 'activity-presence',
                    name: AppRoute.activityPresence.name,
                    builder: (context, state) => const ActivityPresenceScreen(),
                    routes: [
                      GoRoute(
                        path: 'student',
                        name: AppRoute.studentActivity.name,
                        builder: (context, state) => StudentActivityScreen(
                          date: state.uri.queryParameters['date'],
                          time: state.uri.queryParameters['time'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'data-presence',
                    name: AppRoute.dataPresence.name,
                    builder: (context, state) => const DataPresenceScreen(),
                  ),
                  // Recap Presence
                  GoRoute(
                    path: 'recap-presence',
                    name: AppRoute.recapPresence.name,
                    builder: (context, state) => const RecapPresenceScreen(),
                    routes: [
                      GoRoute(
                        path: 'filter',
                        name: AppRoute.filterRecapPresence.name,
                        builder: (context, state) => FilterRecapPresenceScreen(
                          startDate: state.uri.queryParameters['startDate'],
                          endDate: state.uri.queryParameters['endDate'],
                          status: state.uri.queryParameters['status'],
                          groupId: state.uri.queryParameters['groupId'],
                          title: state.uri.queryParameters['title'],
                        ),
                        routes: [
                          GoRoute(
                            path: 'detail',
                            name: AppRoute.detailRecapPresence.name,
                            builder: (context, state) =>
                                DetailAttendanceReportScreen(
                              absent: state.extra as Absent,
                            ),
                          ),
                          GoRoute(
                            path: 'detail',
                            name: AppRoute.detailRecapPermit.name,
                            builder: (context, state) => DetailPermitScreen(
                              permitId: state.extra as String,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Management
                  GoRoute(
                    path: 'management',
                    name: AppRoute.management.name,
                    builder: (context, state) => const ManageStaffScreen(),
                    routes: [
                      GoRoute(
                        path: 'upsert',
                        name: AppRoute.upsertStaff.name,
                        builder: (context, state) => UpsertStaffScreen(
                          staff: state.extra as Staff?,
                        ),
                      ),
                    ],
                  ),
                  // Manual Attendance
                  GoRoute(
                    path: 'manual-attendance',
                    name: AppRoute.manualAttendance.name,
                    builder: (context, state) => const ManualAttendanceScreen(),
                    routes: [
                      GoRoute(
                        path: 'add',
                        name: AppRoute.addManualAttendance.name,
                        builder: (context, state) =>
                            const AddManualAttendanceScreen(),
                      ),
                    ],
                  ),
                  // Request Items and History Transaction
                  // Management
                  GoRoute(
                    path: 'history-transaction',
                    name: AppRoute.historyTransaction.name,
                    builder: (context, state) =>
                        const HistoryTransactionScreen(),
                    routes: [
                      GoRoute(
                        path: 'items',
                        name: AppRoute.items.name,
                        builder: (context, state) => const ItemsScreen(),
                        routes: [
                          GoRoute(
                            path: 'order',
                            name: AppRoute.orderItem.name,
                            builder: (context, state) =>
                                AddRequestTransactionScreen(
                              item: state.extra as Product,
                            ),
                          ),
                          GoRoute(
                            path: 'add',
                            name: AppRoute.addItem.name,
                            builder: (context, state) => const AddItemScreen(),
                          ),
                        ],
                      ),
                      GoRoute(
                        path: 'request_items',
                        name: AppRoute.requestItems.name,
                        builder: (context, state) => const RequestItemsScreen(),
                      ),
                      GoRoute(
                        path: 'detail',
                        name: AppRoute.detailRequestTransaction.name,
                        builder: (context, state) =>
                            DetailRequestTransactionScreen(
                          invoiceId: state.uri.queryParameters['invoiceId'],
                          status: state.uri.queryParameters['status'],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorBKey,
            routes: [
              // Shopping Cart
              GoRoute(
                path: '/news',
                name: AppRoute.news.name,
                builder: (context, state) => const NewsScreen(),
                routes: [
                  GoRoute(
                    path: 'detail-news',
                    name: AppRoute.detailNews.name,
                    builder: (context, state) => DetailNewsScreen(
                      news: state.extra as News,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCKey,
            routes: [
              // Shopping Cart
              GoRoute(
                path: '/prayer',
                name: AppRoute.prayer.name,
                builder: (context, state) => const PrayerScreen(),
                routes: [
                  GoRoute(
                    path: 'time',
                    name: AppRoute.prayerTime.name,
                    builder: (context, state) => const PrayerTimeScreen(),
                  ),
                  GoRoute(
                    path: 'quran',
                    name: AppRoute.quran.name,
                    builder: (context, state) => const SurahScreen(),
                    routes: [
                      GoRoute(
                        path: 'ayah',
                        name: AppRoute.ayah.name,
                        builder: (context, state) => AyahScreen(
                          surah: state.extra as Surah,
                          jumpToAyahNumber: int.tryParse(
                            '${state.uri.queryParameters['jump_to_ayah_number']}',
                          ),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                      path: 'books',
                      name: AppRoute.books.name,
                      builder: (context, state) => const BooksScreen(),
                      routes: [
                        GoRoute(
                          path: 'hadith',
                          name: AppRoute.hadith.name,
                          builder: (context, state) =>
                              HadithScreen(book: state.extra as Book),
                        ),
                      ]),
                  GoRoute(
                    path: 'qibla',
                    name: AppRoute.qibla.name,
                    builder: (context, state) => const QiblaCompassScreen(),
                    routes: [
                      GoRoute(
                        path: 'qibla-maps',
                        name: AppRoute.qiblaMaps.name,
                        builder: (context, state) => WebViewScreen(
                          title: state.uri.queryParameters['title'],
                          url: state.uri.queryParameters['url'],
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'murottal',
                    name: AppRoute.murottal.name,
                    builder: (context, state) => const MurottalScreen(),
                  ),
                  GoRoute(
                    path: 'dhikr',
                    name: AppRoute.dhikr.name,
                    builder: (context, state) => DhikrScreen(
                      type: state.extra as DhikrType,
                    ),
                  ),
                  GoRoute(
                    path: 'pray',
                    name: AppRoute.pray.name,
                    builder: (context, state) => const PrayScreen(),
                  ),
                  GoRoute(
                    path: 'tv',
                    name: AppRoute.tv.name,
                    builder: (context, state) => const TvScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDKey,
            routes: [
              GoRoute(
                path: '/performance',
                name: AppRoute.performance.name,
                builder: (context, state) => const PerformanceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorEKey,
            routes: [
              GoRoute(
                path: '/setting',
                name: AppRoute.setting.name,
                builder: (context, state) => const SettingScreen(),
                routes: [
                  GoRoute(
                    path: 'account',
                    name: AppRoute.account.name,
                    builder: (context, state) => const AccountScreen(),
                  ),
                  GoRoute(
                    path: 'fingerprint',
                    name: AppRoute.fingerprint.name,
                    builder: (context, state) => const FingerprintScreen(),
                  ),
                  GoRoute(
                    path: 'face-unclock',
                    name: AppRoute.faceUnlock.name,
                    builder: (context, state) => const FaceUnlockScreen(),
                  ),
                  GoRoute(
                    path: 'face-preview',
                    name: AppRoute.facePreview.name,
                    builder: (context, state) => const FacePreviewScreen(),
                  ),
                  GoRoute(
                    path: 'change-password',
                    name: AppRoute.changePassword.name,
                    builder: (context, state) => const ChangePasswordScreen(),
                  ),
                  GoRoute(
                    path: 'privacy-policy',
                    name: AppRoute.privacyPolicy.name,
                    builder: (context, state) => WebViewScreen(
                      title: state.uri.queryParameters['title'],
                      url: state.uri.queryParameters['url'],
                    ),
                  ),
                  GoRoute(
                    path: 'agreement',
                    name: AppRoute.agreement.name,
                    builder: (context, state) => WebViewScreen(
                      title: state.uri.queryParameters['title'],
                      url: state.uri.queryParameters['url'],
                    ),
                  ),
                  GoRoute(
                    path: 'about-us',
                    name: AppRoute.aboutUs.name,
                    builder: (context, state) => WebViewScreen(
                      title: state.uri.queryParameters['title'],
                      url: state.uri.queryParameters['url'],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'forgot',
            name: AppRoute.forgot.name,
            builder: (context, state) => const ForgotScreen(),
          ),
        ],
      ),
    ],
  );
}
