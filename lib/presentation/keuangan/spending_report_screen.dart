import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/keuangan/student_savings_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../routing/app_router.dart';

class SpendingReportScreen extends HookConsumerWidget {
  const SpendingReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
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
      fetchAllSpendingProvider(
        key: key,
        startDate: startDateFormat,
        endDate: endDateFormat,
      ),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllSpending = ref.watch(
      fetchAllSpendingProvider(
        key: key,
        startDate: startDateFormat,
        endDate: endDateFormat,
      ),
    );
    final filterSpending = fetchAllSpending.valueOrNull
        ?.where(
          (element) => element.detail?.isNotEmpty == true,
        )
        .toList()
        .reversed;

    final itemCount =
        fetchAllSpending.isLoading ? 10 : filterSpending?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Pengeluaran'),
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
          fetchAllSpendingProvider(
            key: key,
            startDate: startDateFormat,
            endDate: endDateFormat,
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllSpending.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final spending = filterSpending?.elementAtOrNull(index);
              final dateFormat = ref.watch(
                formatDateProvider('${spending?.date}',
                    format: 'EEE, dd MMMM yyyy'),
              );
              final items = spending?.detail?.reversed ?? [];
              final parseNominal =
                  double.tryParse('${spending?.totalNominal}') ?? 0;
              final nominal = currencyFormat.format(parseNominal);

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
                        Text(nominal),
                      ],
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final detail = items.elementAtOrNull(index);
                      final parseNominal =
                          double.tryParse('${detail?.nominal}') ?? 0;
                      final nominal = currencyFormat.format(parseNominal);

                      return ListTile(
                        onTap: () {
                          context.goNamed(
                            AppRoute.detailSpending.name,
                            queryParameters: {
                              'invoiceId': '${detail?.noInvoice}',
                            },
                          );
                        },
                        title: Text(
                          '${detail?.noInvoice}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.titleMediumBold,
                        ),
                        subtitle: Text(
                          '${detail?.oleh}',
                          style: context.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Transform.translate(
                          offset: const Offset(12, 0),
                          child: Chip(
                            label: Text(nominal),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                        ),
                        leading: FloatingActionButton(
                          onPressed: null,
                          elevation: 0,
                          shape: const CircleBorder(),
                          heroTag: '${detail?.noInvoice}',
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
          context.goNamed(AppRoute.addSpending.name);
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
