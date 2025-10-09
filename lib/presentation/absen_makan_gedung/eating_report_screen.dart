import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/hostel/food.dart';
import 'package:syathiby/presentation/absen_makan_gedung/eating_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class EatingReportScreen extends HookConsumerWidget {
  const EatingReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 3);
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final dateSelected = useState<DateTime>(DateTime.now());
    final dateFormatSelected = DateFormat('yyyy-MM-dd').format(
      dateSelected.value,
    );
    final fetchEatingReport = ref.watch(
      fetchEatingReportProvider(
        key: key,
        start: dateFormatSelected,
        end: dateFormatSelected,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Absensi Makan'),
        actions: [
          IconButton(
            onPressed: () async {
              final selected = await showDatePicker(
                context: context,
                initialDate: dateSelected.value,
                lastDate: DateTime.now(),
                firstDate: DateTime(2000),
              );
              if (selected == null) return;
              dateSelected.value = selected;
            },
            icon: const Icon(Icons.today),
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(text: 'Pagi'.hardcoded),
            Tab(text: 'Siang'.hardcoded),
            Tab(text: 'Malam'.hardcoded),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: List.generate(
          tabController.length,
          (index) => _buildItemTab(
            context,
            ref,
            index,
            key,
            dateFormatSelected,
            fetchEatingReport,
          ),
        ),
      ),
    );
  }

  Widget _buildItemTab(
    BuildContext context,
    WidgetRef ref,
    int index,
    String key,
    String dateFormatSelected,
    AsyncValue<List<Makan>> fetchEatingReport,
  ) {
    final report = fetchEatingReport.valueOrNull?.firstOrNull;
    final presentCount = _getPresentCount(index, report);
    final notPresentCount = _getNotPresentCount(index, report);
    final timePresent = _getTimePresent(index, report);
    final formatDate = ref.watch(
      formatDateProvider('${report?.tanggal}', format: 'EEEE, dd MMMM yyyy'),
    );
    return RefreshIndicator(
      onRefresh: () => ref.refresh(
        fetchEatingReportProvider(
          key: key,
          start: dateFormatSelected,
          end: dateFormatSelected,
        ).future,
      ),
      child: ListView(
        children: [
          Skeletonizer(
            enabled: fetchEatingReport.isLoading,
            child: Card.outlined(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Text(
                        '${report?.namaAsrama}',
                        style: context.titleMediumBold,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Center(
                      child: Text(
                        '$formatDate',
                        style: context.bodyMedium,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Jumlah Murid: '),
                        Text('${report?.jumlahSantri} murid'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Absen $timePresent: '),
                        Text('$presentCount murid'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tidak Absen $timePresent: '),
                        Text('$notPresentCount murid'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTimePresent(int index, Makan? report) {
    if (index == 0) {
      return 'Makan Pagi';
    }
    if (index == 1) {
      return 'Makan Siang';
    }
    return 'Makan Malam';
  }

  String _getPresentCount(int index, Makan? report) {
    if (index == 0) {
      return '${report?.absenPagi}';
    }
    if (index == 1) {
      return '${report?.absenSiang}';
    }
    return '${report?.absenMalam}';
  }

  String _getNotPresentCount(int index, Makan? report) {
    if (index == 0) {
      return '${report?.tidakAbsenPagi}';
    }
    if (index == 1) {
      return '${report?.tidakAbsenSiang}';
    }
    return '${report?.tidakAbsenMalam}';
  }
}
