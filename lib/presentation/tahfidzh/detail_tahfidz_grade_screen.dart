import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/presentation/tahfidzh/tahfidz_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class DetailTahfidzGradeScreen extends HookConsumerWidget {
  final String? tahfidzId;

  const DetailTahfidzGradeScreen({super.key, this.tahfidzId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchDetailTahfidzGrade = ref.watch(fetchDetailTahfidzGradeProvider(
      key: key,
      tahfidzId: '$tahfidzId',
    ));
    final tahfidzGrade = fetchDetailTahfidzGrade.valueOrNull?.firstOrNull;
    final dateFormat = ref.watch(formatDateProvider(
      '${tahfidzGrade?.date}',
      format: 'EEEE, dd MMMM yyyy',
    ));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Hafalan'),
      ),
      body: Skeletonizer(
        enabled: fetchDetailTahfidzGrade.isLoading,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(
            fetchDetailTahfidzProvider(key: key, tahfidzId: '$tahfidzId')
                .future,
          ),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                '${tahfidzGrade?.nama_siswa}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildDetailItem(
                'Tanggal Penilaian',
                '$dateFormat - ${tahfidzGrade?.hour}',
              ),
              _buildDetailItem(
                'Kelas',
                '${tahfidzGrade?.kelas}',
              ),
              _buildDetailItem(
                'Pengampu',
                '${tahfidzGrade?.staff}',
              ),
              _buildDetailItem(
                'Jenis Penilaian',
                '${tahfidzGrade?.jenis_tahfidz}',
              ),
              _buildDetailItem('Nilai', '${tahfidzGrade?.nilai}'),
              _buildDetailItem(
                'Catatan',
                '${tahfidzGrade?.detail}',
              ),
              // Provide your image path here
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value, {
    VoidCallback? onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
