import 'dart:io';

import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/meeting/meeting.dart';
import '../../models/message.dart';
import '../../models/staff/staff.dart';

part 'meeting_controller.g.dart';

@riverpod
class MeetingController extends _$MeetingController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addNote({
    required String key,
    required String meetingId,
    required String text,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(meetingServiceProvider).notulen(key, meetingId, text),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> updateNote({
    required String key,
    required String meetingId,
    required String text,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () =>
          ref.read(meetingServiceProvider).updateNotulen(key, meetingId, text),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addComment({
    required String key,
    required String meetingId,
    required String text,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(meetingServiceProvider).komentar(key, meetingId, text),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> removeMeeting({
    required String key,
    required String meetingId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(meetingServiceProvider).delete(key, meetingId),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> removeNote({
    required String key,
    required String meetingId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(meetingServiceProvider).deleteNotulen(key, meetingId),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> removeParticipant({
    required String key,
    required String meetingId,
    required String phoneNumber,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(meetingServiceProvider).hapusPeserta(
            key,
            meetingId,
            phoneNumber,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addDocumentation({
    required String key,
    required String meetingId,
    required File image,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(meetingServiceProvider).uploadFoto(
            key,
            meetingId,
            img: image,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> meetingPresence({
    required String key,
    required String meetingId,
    required String location,
    required String meetingFor,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(meetingServiceProvider).presensi(
            key,
            meetingId,
            location,
            meetingFor,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addMeeting({
    required String key,
    required String meetingName,
    required String description,
    required String meetingFor,
    required String date,
    required String startTime,
    required String finish,
    required String location,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(meetingServiceProvider).add(
            key,
            meetingName,
            description,
            meetingFor,
            date,
            startTime,
            finish,
            location,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addMeetingPerson({
    required String key,
    required String meetingId,
    required String phoneNumber,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(meetingServiceProvider).addPeserta(
            key,
            meetingId,
            phoneNumber,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Rapat>> fetchAllMeeting(
  FetchAllMeetingRef ref, {
  required String key,
}) async {
  final result = await ref.watch(meetingServiceProvider).gets(key);
  return result;
}

@riverpod
Future<List<Rapat>> fetchDetailMeeting(
  FetchDetailMeetingRef ref, {
  required String key,
  required String meetingId,
}) async {
  final result = await ref.watch(meetingServiceProvider).detail(key, meetingId);
  return result;
}

@riverpod
Future<List<Rapat>> fetchMeetingParticipant(
  FetchMeetingParticipantRef ref, {
  required String key,
  required String meetingId,
}) async {
  final result =
      await ref.watch(meetingServiceProvider).peserta(key, meetingId);
  return result;
}

@riverpod
Future<List<Rapat>> fetchMeetingDocumentation(
  FetchMeetingDocumentationRef ref, {
  required String key,
  required String meetingId,
}) async {
  final result = await ref.watch(meetingServiceProvider).photo(key, meetingId);
  return result;
}

@riverpod
Future<List<Rapat>> fetchMeetingNotes(
  FetchMeetingNotesRef ref, {
  required String key,
  required String meetingId,
}) async {
  final result = await ref.watch(meetingServiceProvider).hasil(key, meetingId);
  return result.reversed.toList();
}

@riverpod
Future<List<Staff>> fetchAllStaff(
  FetchAllStaffRef ref, {
  required String key,
}) async {
  final result = await ref.watch(staffServiceProvider).getStaff(key);
  return result;
}
