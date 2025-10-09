import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/presentation/penilaian/score_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';
import '../../utils/custom_avatar_widget.dart';

class ScoreScreen extends HookConsumerWidget {
  final String? classId;
  final String? subjectId;
  final String? studentId;
  final String? scoreTypeId;

  const ScoreScreen({
    super.key,
    this.classId,
    this.subjectId,
    this.studentId,
    this.scoreTypeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(scoreControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
        fetchAllScoreProvider(
          key: key,
          subjectId: '$subjectId',
          classId: '$classId',
          typeId: '$scoreTypeId',
          studentId: '$studentId',
        ), (previous, next) {
      next.showToastOnError(context);
    });

    final fetchAllScore = ref.watch(
      fetchAllScoreProvider(
        key: key,
        subjectId: '$subjectId',
        classId: '$classId',
        typeId: '$scoreTypeId',
        studentId: '$studentId',
      ),
    );
    final itemCount =
        fetchAllScore.isLoading ? 10 : fetchAllScore.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Penilaian'),
        leading: Container(),
        actions: [
          IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAllScoreProvider(
            key: key,
            subjectId: '$subjectId',
            classId: '$classId',
            typeId: '$scoreTypeId',
            studentId: '$studentId',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllScore.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final score = fetchAllScore.valueOrNull?.elementAtOrNull(index);
              final dateFormat = ref.watch(
                formatDateProvider(
                  '${score?.date}',
                  format: 'EEEE, dd MMMM yyyy',
                ),
              );
              return InkWell(
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    context: context,
                    builder: (context) => FractionallySizedBox(
                      heightFactor: 0.75,
                      child: ScoreScreen(
                        scoreTypeId: score?.idJenisPenilaian,
                        subjectId: score?.idMapel,
                        classId: score?.idKelas,
                        studentId: score?.nis,
                      ),
                    ),
                  );
                },
                child: Card.outlined(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      ListTile(
                        leading: CustomAvatar(
                          name: '${score?.namaLengkap}',
                          imageUrl: '${score?.img}',
                          size: 40,
                        ),
                        title: Text(
                          '${index + 1}. ${score?.namaLengkap}',
                          style: context.bodyLargeBold,
                        ),
                        subtitle: Text('NIS: ${score?.nis}'),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Text('Nama Penilaian'),
                              Text(
                                '${score?.nameJenisPenilaian}',
                                style: context.bodyLargeBold,
                              ),
                              const SizedBox(height: 4),
                              const Text('Tanggal Penilaian'),
                              Text(
                                '$dateFormat',
                                style: context.bodyLargeBold,
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Nilai'),
                              Text(
                                '${score?.nilai}',
                                style: context.bodyLargeBold,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          showInputScoreDialog(context, ref, key);
        },
        label: const Text('Tambah Nilai'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void showInputScoreDialog(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final inputResult = await showTextInputDialog(
      title: 'Penilaian',
      context: context,
      textFields: [
        DialogTextField(
            hintText: 'Input Nilai',
            keyboardType: TextInputType.number,
            validator: FormBuilderValidators.compose(
              [
                FormBuilderValidators.required(
                  errorText: 'Nilai tidak boleh kosong',
                ),
                FormBuilderValidators.numeric(
                  errorText: 'Isikan dengan angka',
                ),
              ],
            )),
        DialogTextField(
          hintText: 'contoh: $today',
          initialText: today,
          prefixText: ' Tanggal',
          keyboardType: TextInputType.datetime,
          validator: (value) {
            if (DateTime.tryParse('$value') == null) {
              return 'Format tanggal salah';
            }
            return null;
          },
        ),
        const DialogTextField(
          hintText: 'Catatan',
          maxLines: 3,
          keyboardType: TextInputType.text,
        ),
      ],
    );
    if (inputResult == null) return;
    final score = inputResult[0];
    final date = inputResult[1];
    final note = inputResult[2];
    final result = await ref.read(scoreControllerProvider.notifier).addScore(
          key: key,
          classId: '$classId',
          subjectId: '$subjectId',
          studentId: '$studentId',
          scoreTypeId: '$scoreTypeId',
          score: score,
          date: date,
          note: note,
        );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
  }
}
