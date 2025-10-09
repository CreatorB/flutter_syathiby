import 'package:dio/dio.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/cart/cart_service.dart';
import 'package:syathiby/models/change_schedule/change_schedule_service.dart';
import 'package:syathiby/models/days/days_service.dart';
import 'package:syathiby/models/event/event_service.dart';
import 'package:syathiby/models/fasting/fasting_service.dart';
import 'package:syathiby/models/health/health_service.dart';
import 'package:syathiby/models/hostel/hostel_service.dart';
import 'package:syathiby/models/job/job_service.dart';
import 'package:syathiby/models/meeting/meeting_service.dart';
import 'package:syathiby/models/news/news_service.dart';
import 'package:syathiby/models/permit/permit_service.dart';
import 'package:syathiby/models/pickup/pickup_service.dart';
import 'package:syathiby/models/place/place_service.dart';
import 'package:syathiby/models/prayer/dhikr_service.dart';
import 'package:syathiby/models/prayer/hadith_service.dart';
import 'package:syathiby/models/prayer/murottal_service.dart';
import 'package:syathiby/models/prayer/prayer_time_service.dart';
import 'package:syathiby/models/prayer/quran_service.dart';
import 'package:syathiby/models/product/product_service.dart';
import 'package:syathiby/models/raw_material/raw_material_service.dart';
import 'package:syathiby/models/recap/recap_service.dart';
import 'package:syathiby/models/recipe/recipe_service.dart';
import 'package:syathiby/models/report_card/report_card_service.dart';
import 'package:syathiby/models/rpp/rpp_service.dart';
import 'package:syathiby/models/schedule/schedule_service.dart';
import 'package:syathiby/models/score/score_service.dart';
import 'package:syathiby/models/slip/slip_service.dart';
import 'package:syathiby/models/staff/staff_service.dart';
import 'package:syathiby/models/store/store_service.dart';
import 'package:syathiby/models/student/student_service.dart';
import 'package:syathiby/models/tahfidz/tahfidz_service.dart';
import 'package:syathiby/models/transaction/transaction_service.dart';
import 'package:syathiby/models/unit/unit_service.dart';
import 'package:syathiby/models/user/user_service.dart';
import 'package:syathiby/models/violation/violation_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'allocation/allocation_service.dart';
import 'category_expense/category_expense_service.dart';
import 'medicine/medicine_service.dart';

part 'service_injection.g.dart';

@Riverpod(keepAlive: true)
UserService userService(UserServiceRef ref) {
  return UserService(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
AsramaRestInterface hostelService(HostelServiceRef ref) {
  return AsramaRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
NewsRestInterface newsService(NewsServiceRef ref) {
  return NewsRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
StaffRestInterface staffService(StaffServiceRef ref) {
  return StaffRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
StoreRestInterface storeService(StoreServiceRef ref) {
  return StoreRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
PermitRestInterface permitService(PermitServiceRef ref) {
  return PermitRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
JobRestInterface jobService(JobServiceRef ref) {
  return JobRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
JadwalRestInterface teachingScheduleService(TeachingScheduleServiceRef ref) {
  return JadwalRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
SiswaRestInterface studentService(StudentServiceRef ref) {
  return SiswaRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
SlipRestInterface slipService(SlipServiceRef ref) {
  return SlipRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
PelanggaranRestInterface violationService(ViolationServiceRef ref) {
  return PelanggaranRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
KesehatanRestInterface healthService(HealthServiceRef ref) {
  return KesehatanRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
TahfidzRestInterface tahfidzService(TahfidzServiceRef ref) {
  return TahfidzRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
RapatRestInterface meetingService(MeetingServiceRef ref) {
  return RapatRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
NilaiRestInterface scoreService(ScoreServiceRef ref) {
  return NilaiRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
RppRestInterface teachingPlannerService(TeachingPlannerServiceRef ref) {
  return RppRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
EventRestInterface eventService(EventServiceRef ref) {
  return EventRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
ReportCardRestInterface reportCardService(ReportCardServiceRef ref) {
  return ReportCardRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
PuasaService fastingService(FastingServiceRef ref) {
  return PuasaService(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
RecipeRestInterface recipeService(RecipeServiceRef ref) {
  return RecipeRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
RawMaterialRestInterface rawMaterialService(RawMaterialServiceRef ref) {
  return RawMaterialRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
PenjemputanRestInterface pickupService(PickupServiceRef ref) {
  return PenjemputanRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
TransactionService transactionService(TransactionServiceRef ref) {
  return TransactionService(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
ProductRestInterface productService(ProductServiceRef ref) {
  return ProductRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
DataObatRestInterface medicineService(MedicineServiceRef ref) {
  return DataObatRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
UnitService unitService(UnitServiceRef ref) {
  return UnitService(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
TempatRestInterface placeService(PlaceServiceRef ref) {
  return TempatRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
CategoryExpenseRestInterface expanseService(ExpanseServiceRef ref) {
  return CategoryExpenseRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
AlokasiRestInterface allocationService(AllocationServiceRef ref) {
  return AlokasiRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
ChangeScheduleService changeScheduleService(ChangeScheduleServiceRef ref) {
  return ChangeScheduleService(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
RecapRestInterface recapService(RecapServiceRef ref) {
  return RecapRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
DaysRestInterface scheduleService(ScheduleServiceRef ref) {
  return DaysRestInterface(ref.watch(dioProvider));
}

@Riverpod(keepAlive: true)
CartRestInterface cartService(CartServiceRef ref) {
  return CartRestInterface(ref.watch(dioProvider));
}

// API from 3rd
@Riverpod(keepAlive: true)
QuranService quranService(QuranServiceRef ref) {
  return QuranService(Dio());
}

@Riverpod(keepAlive: true)
HadithService hadithService(HadithServiceRef ref) {
  return HadithService(Dio());
}

@Riverpod(keepAlive: true)
PrayerTimeService prayerTimeService(PrayerTimeServiceRef ref) {
  return PrayerTimeService(Dio());
}

@Riverpod(keepAlive: true)
DhikrService dhikrService(DhikrServiceRef ref) {
  return DhikrService(Dio());
}

@Riverpod(keepAlive: true)
MurottalService murottalService(MurottalServiceRef ref) {
  return MurottalService(Dio());
}
