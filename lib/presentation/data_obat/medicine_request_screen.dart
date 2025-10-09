import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/data_obat/medicine_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../routing/app_router.dart';

class MedicineRequestScreen extends HookConsumerWidget {
  const MedicineRequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final initialDate = DateTime.now();
    final startDate = useState<DateTime>(
      initialDate.subtract(const Duration(days: 7)),
    );
    final endDate = useState<DateTime>(initialDate);
    final startDateFormat = DateFormat('yyyy-MM-dd').format(startDate.value);
    final endDateFormat = DateFormat('yyyy-MM-dd').format(endDate.value);
    ref.listen(
      historyMedicineRequestProvider(
        key: key,
        startDate: startDateFormat,
        endDate: endDateFormat,
        status: '',
      ),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchMedicineRequest = ref.watch(
      historyMedicineRequestProvider(
        key: key,
        startDate: startDateFormat,
        endDate: endDateFormat,
        status: '',
      ),
    );
    final filterMedicineRequest = fetchMedicineRequest.valueOrNull
        ?.where(
          (element) => element.detail?.isNotEmpty == true,
        )
        .toList()
        .reversed;

    final itemCount = fetchMedicineRequest.isLoading
        ? 10
        : filterMedicineRequest?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permohonan Obat'),
        actions: [
          IconButton(
            onPressed: () async {
              final dateResult = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                initialDateRange: DateTimeRange(
                  start: startDate.value,
                  end: endDate.value,
                ),
                lastDate: endDate.value,
              );
              if (dateResult == null) return;
              startDate.value = dateResult.start;
              endDate.value = dateResult.end;
            },
            icon: const Icon(Icons.date_range),
          ),
          // IconButton(
          //   onPressed: () {
          //     showSearch(
          //       context: context,
          //       delegate: SearchPage<Transaction>(
          //         items: [],
          //         searchLabel: 'Masukkan nomor permohonan',
          //         failure: const Center(
          //           child: Text('Nomor permohonan tidak ditemukan'),
          //         ),
          //         filter: (item) => [
          //           item.noInvoice,
          //         ],
          //         builder: (surah) => _buildItemSurah(
          //           context,
          //           surah,
          //           lastReadQuran.valueOrNull,
          //           bookmarkQuran.valueOrNull,
          //         ),
          //       ),
          //     );
          //   },
          //   icon: const Icon(Icons.search),
          // ), TODO
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          historyMedicineRequestProvider(
            key: key,
            startDate: startDateFormat,
            endDate: endDateFormat,
            status: '',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchMedicineRequest.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final medicineRequest =
                  filterMedicineRequest?.elementAtOrNull(index);
              final dateFormat = ref.watch(
                formatDateProvider('${medicineRequest?.date}',
                    format: 'EEE, dd MMMM yyyy'),
              );
              final items = medicineRequest?.detail?.reversed ?? [];
              final total = ref.watch(
                formatCurrencyProvider('${medicineRequest?.totalorderall}'),
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$dateFormat'),
                        Text(total),
                      ],
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final medicine = items.elementAtOrNull(index);
                      final status = medicine?.status;
                      final isStatusProcess = status == "pengajuan";
                      final isStatusRejected = status == "ditolak";
                      final isStatusAccepted = status == "diselesaikan";

                      return ListTile(
                        onTap: () {
                          context.goNamed(
                            AppRoute.detailMedicineRequest.name,
                            queryParameters: {
                              'invoiceId': '${medicine?.noInvoice}',
                              'status': '${medicine?.status}',
                            },
                          );
                        },
                        title: Text(
                          '${medicine?.noInvoice}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.titleMediumBold,
                        ),
                        subtitle: Text(
                          '${medicine?.nameTable}',
                          style: context.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Transform.translate(
                          offset: const Offset(12, 0),
                          child: Chip(
                            label: Text(
                              '$status',
                              style: context.bodySmall?.copyWith(
                                color: isStatusAccepted
                                    ? context.colorOnPrimary
                                    : isStatusRejected
                                        ? context.colorOnError
                                        : context.colorOnSurfaceVariant,
                              ),
                            ),
                            shape: const StadiumBorder(
                              side: BorderSide(),
                            ),
                            backgroundColor: isStatusAccepted
                                ? context.colorPrimary
                                : isStatusRejected
                                    ? context.colorError
                                    : context.colorSurfaceVariant,
                            side: BorderSide(
                              color: isStatusAccepted
                                  ? context.colorPrimary
                                  : isStatusRejected
                                      ? context.colorError
                                      : context.colorOnSurfaceVariant,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                        ),
                        leading: FloatingActionButton(
                          onPressed: null,
                          elevation: 0,
                          shape: const CircleBorder(),
                          heroTag: '${medicine?.noInvoice}',
                          child: Icon(
                            Icons.medical_information,
                            color: context.colorPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(AppRoute.medicines.name);
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
