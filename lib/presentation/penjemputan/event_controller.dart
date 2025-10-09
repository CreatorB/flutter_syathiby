import 'package:syathiby/models/hostel/hostel.dart';
import 'package:syathiby/models/pickup/pickup.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/event/event.dart';
import '../../models/message.dart';

part 'event_controller.g.dart';

@riverpod
class EventController extends _$EventController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addPickupStudent({
    required String key,
    required String studentId,
    required String eventId,
    required String classId,
    required String data,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(pickupServiceProvider).getJemput(
            key,
            studentId,
            eventId,
            classId,
            data,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addReturnStudent({
    required String key,
    required String studentId,
    required String eventId,
    required String classId,
    required String data,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(pickupServiceProvider).getPengembalian(
            key,
            studentId,
            eventId,
            classId,
            data,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Event>> fetchAllEvent(
  FetchAllEventRef ref, {
  required String key,
  required int page,
}) async {
  final result = ref.watch(eventServiceProvider).gets(key, page);
  return result;
}

@riverpod
Future<List<Asrama>> fetchAllEventHostel(
  FetchAllEventHostelRef ref, {
  required String key,
  required String id,
}) async {
  final result = ref.watch(hostelServiceProvider).getGedung(key, id);
  return result;
}

@riverpod
Future<List<Asrama>> fetchAllEventClassroom(
  FetchAllEventClassroomRef ref, {
  required String key,
  required String id,
  required String hostelId,
}) async {
  final result = ref.watch(hostelServiceProvider).getKelas(key, id, hostelId);
  return result;
}

@riverpod
Future<List<Penjemputan>> fetchAllEventStudent(
  FetchAllEventStudentRef ref, {
  required String key,
  required String id,
  required String classId,
  required String type,
  required int page,
}) async {
  final isStudentReturn = type == 'belum_kembali' || type == 'belum_pulang';
  final result = isStudentReturn
      ? ref
          .watch(pickupServiceProvider)
          .getsNegative(key, id, classId, type, page)
      : ref.watch(pickupServiceProvider).gets(key, id, classId, type, page);
  return result;
}

@riverpod
Future<List<Penjemputan>> fetchDetailEventStudent(
  FetchDetailEventStudentRef ref, {
  required String key,
  required String id,
  required String eventId,
}) async {
  final result = ref.watch(pickupServiceProvider).getsdata(key, id, eventId);
  return result;
}

@riverpod
Future<List<Penjemputan>> searchStudentHomecoming(
  SearchStudentHomecomingRef ref, {
  required String key,
  required String id,
  required String eventId,
}) async {
  final result = ref.watch(pickupServiceProvider).searchByBarcode(
        key,
        id,
        eventId,
      );
  return result;
}
