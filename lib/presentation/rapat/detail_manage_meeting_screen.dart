import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';
import 'meeting_controller.dart';

class DetailManageMeetingScreen extends HookConsumerWidget {
  final String? meetingId;

  const DetailManageMeetingScreen({super.key, this.meetingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchDetailMeeting = ref.watch(fetchDetailMeetingProvider(
      key: key,
      meetingId: '$meetingId',
    ));
    final meeting = fetchDetailMeeting.valueOrNull?.firstOrNull;
    final dateFormat = ref.watch(formatDateProvider(
      '${meeting?.date}',
      format: 'EEEE, dd MMMM yyyy',
    ));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pertemuan'),
      ),
      body: Skeletonizer(
        enabled: fetchDetailMeeting.isLoading,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(fetchDetailMeetingProvider(
            key: key,
            meetingId: '$meetingId',
          ).future),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${meeting?.nameMeeting}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildDetailItem(
                    'Tanggal Pertemuan',
                    '$dateFormat',
                  ),
                  _buildDetailItem(
                    'Jam Pertemuan',
                    '${meeting?.hourStart}',
                  ),
                  _buildDetailItem(
                    'Jenis Pertemuan',
                    '${meeting?.meetingFor}',
                  ),
                  _buildDetailItem(
                    'Status Pertemuan',
                    '${meeting?.statusMeeting}',
                  ),
                  _buildDetailItem('Detail Pertemuan', '${meeting?.deskripsi}'),
                  _buildDetailItem(
                    'Dibuat Oleh',
                    '${meeting?.operator}',
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
