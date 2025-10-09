import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/transaction/transaction_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../routing/app_router.dart';

class HistoryTransactionScreen extends HookConsumerWidget {
  const HistoryTransactionScreen({super.key});

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
      fetchHistoryTransactionProvider(
        key: key,
        startDate: startDateFormat,
        endDate: endDateFormat,
        status: '',
      ),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchHistoryTransaction = ref.watch(
      fetchHistoryTransactionProvider(
        key: key,
        startDate: startDateFormat,
        endDate: endDateFormat,
        status: '',
      ),
    );
    final filterHistoryTransaction = fetchHistoryTransaction.valueOrNull
        ?.where(
          (element) => element.detail?.isNotEmpty == true,
        )
        .toList()
        .reversed;

    final itemCount = fetchHistoryTransaction.isLoading
        ? 10
        : filterHistoryTransaction?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengadaan'),
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
          IconButton(
            onPressed: () {
              context.goNamed(AppRoute.requestItems.name);
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchHistoryTransactionProvider(
            key: key,
            startDate: startDateFormat,
            endDate: endDateFormat,
            status: '',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchHistoryTransaction.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final historyTransaction =
                  filterHistoryTransaction?.elementAtOrNull(index);
              final dateFormat = ref.watch(
                formatDateProvider('${historyTransaction?.date}',
                    format: 'EEE, dd MMMM yyyy'),
              );
              final items = historyTransaction?.detail?.reversed ?? [];
              final total = ref.watch(
                formatCurrencyProvider('${historyTransaction?.totalorderall}'),
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
                      final history = items.elementAtOrNull(index);
                      final status = history?.status;
                      final isStatusProcess = status == "pengajuan";
                      final isStatusRejected = status == "ditolak";
                      final isStatusAccepted = status == "diselesaikan";

                      return ListTile(
                        onTap: () {
                          context.goNamed(
                            AppRoute.detailRequestTransaction.name,
                            queryParameters: {
                              'invoiceId': '${history?.noInvoice}',
                              'status': '${history?.status}',
                            },
                          );
                        },
                        title: Text(
                          '${history?.noInvoice}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.titleMediumBold,
                        ),
                        subtitle: Text(
                          '${history?.nameTable}',
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
                          heroTag: '${history?.noInvoice}',
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
          context.goNamed(AppRoute.items.name);
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
