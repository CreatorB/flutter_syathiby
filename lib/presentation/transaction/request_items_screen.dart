import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/transaction/pengajuan_card.dart';
import 'package:syathiby/presentation/transaction/transaction_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../routing/app_router.dart';

/// Antrean tugas: pengajuan yang perlu tindakan staff ini (ACC atasan, ACC
/// Mudir, ACC & cairkan dana Tim Admin Keuangan, kerjakan Tim Maintenance,
/// atau mengesahkan sebagai pemohon).
class RequestItemsScreen extends HookConsumerWidget {
  const RequestItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchRequestItemsProvider(key: key),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchRequestItems = ref.watch(
      fetchRequestItemsProvider(key: key),
    );

    final itemCount = fetchRequestItems.isLoading
        ? 10
        : fetchRequestItems.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Antrean Tugas Pengajuan'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchRequestItemsProvider(key: key).future,
        ),
        child: (!fetchRequestItems.isLoading &&
                (fetchRequestItems.hasError ||
                    fetchRequestItems.valueOrNull?.isEmpty != false))
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    fetchRequestItems.hasError
                        ? Icons.error_outline
                        : Icons.task_alt,
                    size: 56,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      fetchRequestItems.hasError
                          ? 'Gagal memuat antrean. Tarik ke bawah untuk mencoba lagi.'
                          : 'Tidak ada pengajuan yang perlu tindakan Anda saat ini.',
                      textAlign: TextAlign.center,
                      style: context.bodyMedium,
                    ),
                  ),
                ],
              )
            : Skeletonizer(
          enabled: fetchRequestItems.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final history =
                  fetchRequestItems.valueOrNull?.elementAtOrNull(index);
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
        ),
      ),
    );
  }
}
