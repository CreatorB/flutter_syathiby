import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/presentation/keuangan/student_savings_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../di/providers.dart';
import '../../models/student/siswa.dart';
import '../../utils/custom_avatar_widget.dart';
import '../pelanggaran/violation_controller.dart';
import '../qr/scan_barcode_screen.dart';

class StudentTransactionScreen extends HookConsumerWidget {
  final String? type;

  const StudentTransactionScreen({
    super.key,
    this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(studentSavingsControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchStudentSavingsProvider(key: key, type: '$type'),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchStudentSavings = ref.watch(
      fetchStudentSavingsProvider(key: key, type: '$type'),
    );
    final studentSaving = fetchStudentSavings.valueOrNull?.firstOrNull;
    final itemCount = fetchStudentSavings.isLoading
        ? 10
        : fetchStudentSavings.valueOrNull?.length ?? 0;
    final formatDate = ref.watch(
          formatDateProvider(
            '${studentSaving?.date}',
            format: 'EEEE, dd MMMM yyyy',
          ),
        ) ??
        DateFormat('EEEE, dd MMMM yyyy').format(
          DateTime.now(),
        );

    final speechToText = useMemoized(() => SpeechToText());
    final isListening = useState<bool>(speechToText.isListening);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          type ?? '',
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
                  final result = await ref.read(
                    searchStudentTransactionProvider(
                      key: key,
                      query: speechText,
                      type: '$type',
                    ).future,
                  );
                  final student = result.firstOrNull;
                  if (student == null || !context.mounted) return;
                  _addTransaction(context, ref, key, student);
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
                  isSingleCapture: true,
                  onCapture: (scanTextId) async {
                    try {
                      final studentId = scanTextId.split('-').firstOrNull;
                      if (studentId == null) {
                        context.showErrorMessage('ID Siswa tidak ditemukan');
                        return;
                      }
                      final result = await ref.read(
                        searchStudentTransactionProvider(
                          key: key,
                          query: studentId,
                          type: '$type',
                        ).future,
                      );
                      final student = result.firstOrNull;
                      if (student == null || !context.mounted) return;
                      _addTransaction(context, ref, key, student);
                    } catch (error) {
                      context.showErrorMessage('Data tidak ditemukan');
                    }
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
          fetchStudentSavingsProvider(key: key, type: '$type').future,
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
                      studentSaving?.staff ?? 'Kegiatan Santri',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      formatDate,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      '$type'.toUpperCase(),
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
              enabled: fetchStudentSavings.isLoading,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount, // Replace with your item count
                itemBuilder: (context, index) {
                  final student =
                      fetchStudentSavings.valueOrNull?.elementAtOrNull(index);
                  final numberFormat =
                      NumberFormat.simpleCurrency(locale: 'id');
                  final balance = numberFormat.format(
                    num.tryParse('${student?.tabungan}') ?? 0,
                  );

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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NIS: ${student?.nis}'),
                        Text('Transaksi: ${student?.type}'),
                      ],
                    ),
                    trailing: Transform.translate(
                      offset: const Offset(12, 0),
                      child: IntrinsicWidth(
                        child: TextFormField(
                          initialValue: balance,
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
          _addTransaction(context, ref, key, student);
        },
      ),
    );
  }

  Future<void> _addTransaction(
    BuildContext context,
    WidgetRef ref,
    String key,
    Siswa student,
  ) async {
    final savings = ref.watch(formatCurrencyProvider('${student.tabungan}'));
    final message = '''
Nomor Induk Siswa (NIS): ${student.nis ?? ''}
Kelas: ${student.kelas ?? ''}
Sisa Tabungan: $savings
''';
    final inputResult = await showTextInputDialog(
      context: context,
      title: '${student.namaLengkap}',
      message: message,
      textFields: [
        DialogTextField(
          hintText: 'Nominal Transaksi',
          keyboardType: TextInputType.number,
          prefixText: '  Rp',
          validator: (value) {
            if (value == null || value.isEmpty == true) {
              return 'nominal tidak boleh kosong';
            }
            if (value == '0') return 'Nominal harus diatas angka 0';
            if (int.tryParse(value) == null) return 'Isikan berupa angka';
            return null;
          },
          autocorrect: true,
        ),
        DialogTextField(
          hintText: 'Keterangan',
          keyboardType: TextInputType.text,
          autocorrect: true,
          validator: (value) {
            if (value?.isEmpty == true) return 'Keterangan tidak boleh kosong';
            return null;
          },
        ),
      ],
    );
    if (inputResult == null) return;
    final nominal = inputResult[0];
    final description = inputResult[1];

    final result = await ref
        .read(studentSavingsControllerProvider.notifier)
        .addStudentTransaction(
          key: key,
          studentId: '${student.idSiswa}',
          type: '$type',
          notes: description,
          nominal: nominal,
        );

    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(
      fetchStudentSavingsProvider(key: key, type: '$type'),
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
