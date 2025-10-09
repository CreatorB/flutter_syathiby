import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/transaction/transaction_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../routing/app_router.dart';

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
    final fetchHistoryTransaction = ref.watch(
      fetchRequestItemsProvider(key: key),
    );

    final itemCount = fetchHistoryTransaction.isLoading
        ? 10
        : fetchHistoryTransaction.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengadaan'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchRequestItemsProvider(key: key).future,
        ),
        child: Skeletonizer(
          enabled: fetchHistoryTransaction.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final history =
                  fetchHistoryTransaction.valueOrNull?.elementAtOrNull(index);
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
        ),
      ),
    );
  }
}
