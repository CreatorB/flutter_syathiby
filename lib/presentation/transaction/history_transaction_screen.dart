import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/transaction/history_transaction.dart';
import 'package:syathiby/models/transaction/transaction.dart';
import 'package:syathiby/presentation/transaction/transaction_controller.dart';
import 'package:syathiby/presentation/transaction/pengajuan_card.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../routing/app_router.dart';

/// Riwayat pengajuan (pengadaan + perbaikan) dengan status & progres alur.
class HistoryTransactionScreen extends HookConsumerWidget {
  const HistoryTransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final initialDate = DateTime.now();
    final startDate = useState<DateTime>(
      initialDate.subtract(const Duration(days: 30)),
    );
    final endDate = useState<DateTime>(initialDate);
    // Filter jenis: '' = semua, selain itu nama jenis kegiatannya.
    final filterJenis = useState<String>('');
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
    final semua =
        fetchHistoryTransaction.valueOrNull ?? const <HistoryTransaction>[];
    final filterHistoryTransaction = semua
        .where((element) => element.detail?.isNotEmpty == true)
        .toList()
        .reversed;
    final jenisTersedia = <String>{
      for (final harian in filterHistoryTransaction)
        for (final item in harian.detail ?? const <Transaction>[])
          if ((item.jenisKegiatan ?? '').trim().isNotEmpty)
            item.jenisKegiatan!.trim(),
    }.toList()
      ..sort();
    final daftarTersaring = filterHistoryTransaction
        .map(
          (harian) => harian.copyWith(
            detail: (harian.detail ?? const <Transaction>[])
                .where(
                  (item) => filterJenis.value.isEmpty ||
                      (item.jenisKegiatan ?? '').trim() ==
                          filterJenis.value,
                )
                .toList(),
          ),
        )
        .where((harian) => harian.detail?.isNotEmpty == true)
        .toList();

    final itemCount = fetchHistoryTransaction.isLoading
        ? 10
        : daftarTersaring.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Pengajuan'),
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
            tooltip: 'Antrean tugas saya',
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
        child: (!fetchHistoryTransaction.isLoading &&
                (fetchHistoryTransaction.hasError ||
                    daftarTersaring.isEmpty))
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    fetchHistoryTransaction.hasError
                        ? Icons.error_outline
                        : Icons.inbox_outlined,
                    size: 56,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      fetchHistoryTransaction.hasError
                          ? 'Gagal memuat pengajuan. Tarik ke bawah untuk mencoba lagi.'
                          : 'Belum ada pengajuan pada rentang tanggal ini.',
                      textAlign: TextAlign.center,
                      style: context.bodyMedium,
                    ),
                  ),
                ],
              )
            : Skeletonizer(
          enabled: fetchHistoryTransaction.isLoading,
          child: ListView.builder(
            itemCount: itemCount + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _FilterJenis(
                  jenisTersedia: jenisTersedia,
                  terpilih: filterJenis.value,
                  onPilih: (nilai) => filterJenis.value = nilai,
                );
              }
              final harian = daftarTersaring.elementAtOrNull(index - 1);
              final dateFormat = ref.watch(
                formatDateProvider('${harian?.date}',
                    format: 'EEE, dd MMMM yyyy'),
              );
              final items = harian?.detail?.reversed ?? [];
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
                        Text(
                          '${items.length} pengajuan',
                          style: context.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, itemIndex) {
                      final history = items.elementAtOrNull(itemIndex);
                      return PengajuanCard(
                        history: history,
                        onTap: () {
                          context.goNamed(
                            AppRoute.detailRequestTransaction.name,
                            queryParameters: {
                              'invoiceId': '${history?.noInvoice}',
                              'status': '${history?.status}',
                            },
                          );
                        },
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
          // Form pengajuan: perbaikan tanpa nominal, pengadaan dengan nominal.
          context.goNamed(AppRoute.addPengajuan.name);
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

/// Filter jenis pengajuan (Semua / Pengadaan / Perbaikan / Jasa).
class _FilterJenis extends StatelessWidget {
  const _FilterJenis({
    required this.jenisTersedia,
    required this.terpilih,
    required this.onPilih,
  });

  final List<String> jenisTersedia;
  final String terpilih;
  final ValueChanged<String> onPilih;

  @override
  Widget build(BuildContext context) {
    if (jenisTersedia.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Wrap(
        spacing: 8,
        children: [
          ChoiceChip(
            label: const Text('Semua'),
            selected: terpilih.isEmpty,
            onSelected: (_) => onPilih(''),
          ),
          for (final jenis in jenisTersedia)
            ChoiceChip(
              label: Text(jenis),
              selected: terpilih == jenis,
              onSelected: (_) => onPilih(jenis),
            ),
        ],
      ),
    );
  }
}

