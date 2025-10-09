import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/presentation/tahfidzh/tahfidz_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class DetailTahfidzScreen extends HookConsumerWidget {
  final String? tahfidzId;

  const DetailTahfidzScreen({super.key, this.tahfidzId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchDetailTahfidz = ref.watch(fetchDetailTahfidzProvider(
      key: key,
      tahfidzId: '$tahfidzId',
    ));
    final tahfidz = fetchDetailTahfidz.valueOrNull?.firstOrNull;
    final dateFormat = ref.watch(formatDateProvider(
      '${tahfidz?.date}',
      format: 'EEEE, dd MMMM yyyy',
    ));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Hafalan'),
      ),
      body: Skeletonizer(
        enabled: fetchDetailTahfidz.isLoading,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(
            fetchDetailTahfidzProvider(key: key, tahfidzId: '$tahfidzId')
                .future,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${tahfidz?.nama_siswa}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildDetailItem(
                    'Tanggal Hafalan',
                    '$dateFormat - ${tahfidz?.hour}',
                  ),
                  _buildDetailItem(
                    'Kelas',
                    '${tahfidz?.kelas}',
                  ),
                  _buildDetailItem(
                    'Pengampu',
                    '${tahfidz?.staff}',
                  ),
                  _buildDetailItem('Halaman Awal', '${tahfidz?.halaman}'),
                  _buildDetailItem(
                    'Halaman Akhir',
                    '${tahfidz?.halaman_end}',
                  ),
                  _buildDetailItem(
                    'Jenis Hafalan',
                    '${tahfidz?.jenis_tahfidz}',
                  ),
                  _buildDetailItem('Jumlah Hafalan', '${tahfidz?.jumlah}'),
                  _buildDetailItem(
                    'Catatan',
                    '${tahfidz?.detail}',
                  ),
                  // Provide your image path here
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
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
