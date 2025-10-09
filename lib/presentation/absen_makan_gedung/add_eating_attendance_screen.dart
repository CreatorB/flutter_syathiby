import 'package:dropdown_search/dropdown_search.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/presentation/absen_makan_gedung/eating_controller.dart';
import 'package:syathiby/presentation/pelanggaran/violation_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../di/providers.dart';
import '../../models/student/siswa.dart';
import '../../utils/custom_avatar_widget.dart';
import '../qr/scan_barcode_screen.dart';

class AddEatingAttendanceScreen extends HookConsumerWidget {
  final String? date, time;

  const AddEatingAttendanceScreen({
    super.key,
    this.date,
    this.time,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(eatingControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchAllStudentEatingProvider(key: key, date: '$date', time: '$time'),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchStudentEating = ref.watch(
      fetchAllStudentEatingProvider(key: key, date: '$date', time: '$time'),
    );
    final studentEating = fetchStudentEating.valueOrNull?.firstOrNull;
    final itemCount = fetchStudentEating.isLoading
        ? 10
        : fetchStudentEating.valueOrNull?.length ?? 0;
    final formatDate = ref.watch(
      formatDateProvider('${studentEating?.date}',
          format: 'EEEE, dd MMMM yyyy'),
    );
    final speechToText = useMemoized(() => SpeechToText());
    final speechText = useState<String?>(null);
    final isListening = useState<bool>(speechToText.isListening);

    useEffect(() {
      return () {
        if (isListening.value) {
          speechToText.stop();
        }
      };
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Makan ${time?.capitalize ?? ''}',
        ),
        actions: [
          IconButton(
            onPressed: () async {
              _openSpeechToText(
                context,
                ref,
                speechToText,
                isListening,
                onResult: (speechText) async {
                  final result = await ref
                      .read(eatingControllerProvider.notifier)
                      .addStudentEatingSearch(
                        key: key,
                        search: speechText,
                        type: '$time',
                      );
                  if (result == null || !context.mounted) return;
                  context.showSuccessMessage(result.msg);
                  ref.invalidate(
                    fetchAllStudentEatingProvider(
                      key: key,
                      date: '$date',
                      time: '$time',
                    ),
                  );
                },
              );
            },
            icon: Icon(
              isListening.value ? Icons.pause : Icons.spatial_audio_off,
            ),
          ),
          IconButton(
            onPressed: () async {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => ScanBarcodeScreen(
                  isSingleCapture: false,
                  onCapture: (scanTextId) {
                    _addAttendance(
                      context,
                      ref,
                      key,
                      scanTextId,
                      '$time',
                    );
                  },
                ),
              );
            },
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAllStudentEatingProvider(
            key: key,
            date: '$date',
            time: '$time',
          ).future,
        ),
        child: ListView(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      studentEating?.staff ?? 'Kegiatan Santri',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      formatDate ?? '$date',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      'Waktu Makan: ${time?.capitalize ?? ''}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                  ],
                ),
              ),
            ),
            Skeletonizer(
              enabled: fetchStudentEating.isLoading,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount, // Replace with your item count
                itemBuilder: (context, index) {
                  final student =
                      fetchStudentEating.valueOrNull?.elementAtOrNull(index);

                  return ListTile(
                    leading: CustomAvatar(
                      name: '${student?.namaLengkap}',
                      imageUrl: '${student?.img}',
                      size: 40,
                    ),
                    title: Text(
                      '${index + 1}. ${student?.namaLengkap}',
                      style: context.bodyMediumBold,
                    ),
                    subtitle: Text('Kelas: ${student?.kelas}'),
                    trailing: Transform.translate(
                      offset: const Offset(12, 0),
                      child: IntrinsicWidth(
                        child: TextFormField(
                          initialValue: student?.statusAbsen != "Belum Absen"
                              ? student?.statusAbsen
                              : null,
                          readOnly: true,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildAddStudentToClass(context, ref, key),
    );
  }

  Widget _buildAddStudentToClass(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: DropdownSearch<Siswa>(
        asyncItems: (String filter) {
          return ref.watch(
            fetchSearchStudentProvider(
              key: key,
              query: filter,
            ).future,
          );
        },
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
        itemAsString: (item) => '${item.namaLengkap}',
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: 'Tambah Murid',
            labelText: 'Tambah Murid',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            isDense: true,
            prefixIcon: const Icon(Icons.add),
          ),
        ),
        validator: FormBuilderValidators.required(),
        onChanged: (student) async {
          if (student == null) {
            return;
          }
          _addAttendance(context, ref, key, '${student.nis}', '$time');
        },
      ),
    );
  }

  Future<void> _addAttendance(
    BuildContext context,
    WidgetRef ref,
    String key,
    String studentId,
    String type,
  ) async {
    final result =
        await ref.read(eatingControllerProvider.notifier).addStudentEating(
              key: key,
              studentId: studentId,
              type: type,
            );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(
      fetchAllStudentEatingProvider(
        key: key,
        date: '$date',
        time: '$time',
      ),
    );
  }

  Future<void> _openSpeechToText(
    BuildContext context,
    WidgetRef ref,
    SpeechToText speechToText,
    ValueNotifier<bool> isListening, {
    required Function(String speechText) onResult,
  }) async {
    final speechAvailable = await speechToText.initialize();
    if (!context.mounted) return;
    if (!speechAvailable) {
      context.showErrorMessage('Speech not available');
      isListening.value = false;
      return;
    }
    if (isListening.value) {
      speechToText.stop();
      isListening.value = false;
      return;
    }
    isListening.value = true;
    context.showSnackBar('Silahkan ucapkan NIS siswa');
    await speechToText.listen(
      localeId: 'id',
      listenMode: ListenMode.search,
      listenFor: const Duration(seconds: 10),
      onResult: (result) {
        final isFinal = result.finalResult;
        final finalWords = result.recognizedWords.replaceAll(' ', '');
        final digit = finalWords.replaceAll(RegExp(r'[^0-9]'), '');
        context.showSnackBar('NIS: $digit');
        if (isFinal) {
          context.showSuccessMessage('NIS: $digit');
          onResult(digit);
          isListening.value = false;
        }
      },
    );
  }
}
