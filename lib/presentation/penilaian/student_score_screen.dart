import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/penilaian/score_controller.dart';
import 'package:syathiby/presentation/penilaian/score_screen.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StudentScoreScreen extends HookConsumerWidget {
  final String? classId;
  final String? subjectId;
  final String? scoreTypeId;
  final String? className;
  final String? subjectName;
  final String? hour;
  final String? day;

  const StudentScoreScreen({
    super.key,
    this.classId,
    this.subjectId,
    this.scoreTypeId,
    this.className,
    this.subjectName,
    this.hour,
    this.day,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchStudentScore = ref.watch(
      fetchStudentScoreProvider(
        key: key,
        classId: '$classId',
        subjectId: '$subjectId',
        typeId: '$scoreTypeId',
      ),
    );
    final itemCount = fetchStudentScore.isLoading
        ? 10
        : fetchStudentScore.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('$className'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchStudentScoreProvider(
            key: key,
            classId: '$classId',
            subjectId: '$subjectId',
            typeId: '$scoreTypeId',
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
                      '$subjectName',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      '$hour',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      '$day',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Skeletonizer(
              enabled: fetchStudentScore.isLoading,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  final student =
                      fetchStudentScore.valueOrNull?.elementAtOrNull(index);
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
                            scoreTypeId: student?.idJenisPenilaian,
                            subjectId: student?.idMapel,
                            classId: student?.idKelas,
                            studentId: student?.nis,
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
                              name: '${student?.namaLengkap}',
                              imageUrl: '${student?.img}',
                              size: 40,
                            ),
                            title: Text(
                              '${index + 1}. ${student?.namaLengkap}',
                              style: context.bodyLargeBold,
                            ),
                            subtitle: Text('NIS: ${student?.nis}'),
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Text('Jumlah Penilaian'),
                                  Text(
                                    '${student?.rpr}',
                                    style: context.bodyLargeBold,
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text('Rata-rata Nilai'),
                                  Text(
                                    '${student?.rt}',
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
          ],
        ),
      ),
    );
  }
}
