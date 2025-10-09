import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/presentation/kepengasuhan/parenting_score_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class DetailParentingScoreScreen extends HookConsumerWidget {
  final String? tahfidzId;

  const DetailParentingScoreScreen({super.key, this.tahfidzId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchDetailParenting = ref.watch(fetchDetailScoreParentingProvider(
      key: key,
      tahfidzId: '$tahfidzId',
    ));
    final parentingScore = fetchDetailParenting.valueOrNull?.firstOrNull;
    final dateFormat = ref.watch(formatDateProvider(
      '${parentingScore?.date}',
      format: 'EEEE, dd MMMM yyyy',
    ));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Penilaian'),
      ),
      body: Skeletonizer(
        enabled: fetchDetailParenting.isLoading,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(
            fetchDetailScoreParentingProvider(key: key, tahfidzId: '$tahfidzId')
                .future,
          ),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                '${parentingScore?.nama_siswa} - ${parentingScore?.nis}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                ),
              ),
              const SizedBox(height: 16.0),
              _buildDetailItem(
                'Tanggal Penilaian',
                '$dateFormat',
              ),
              _buildDetailItem(
                'Kelas',
                '${parentingScore?.kelas}',
              ),
              _buildDetailItem(
                'Pengampu',
                '${parentingScore?.staff}',
              ),
              _buildDetailItem(
                'Jenis Penilaian',
                '${parentingScore?.jenis_tahfidz}',
              ),
              _buildDetailItem('Nilai', '${parentingScore?.nilai}'),
              _buildDetailItem(
                'Catatan',
                '${parentingScore?.detail}',
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
