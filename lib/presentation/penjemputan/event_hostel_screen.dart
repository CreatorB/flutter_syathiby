import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/presentation/penjemputan/event_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/student/siswa.dart';
import '../pelanggaran/violation_controller.dart';
import '../qr/scan_barcode_screen.dart';

class EventHostelScreen extends HookConsumerWidget {
  final String? eventId, eventName;

  const EventHostelScreen({super.key, this.eventId, this.eventName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchAllEventHostelProvider(key: key, id: '$eventId'),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllHostel = ref.watch(
      fetchAllEventHostelProvider(key: key, id: '$eventId'),
    );
    final itemCount =
        fetchAllHostel.isLoading ? 10 : fetchAllHostel.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('$eventName'.hardcoded),
        actions: [
          IconButton(
            onPressed: () async {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => ScanBarcodeScreen(
                  isSingleCapture: true,
                  onCapture: (scanTextId) async {
                    try {
                      final result = await ref.read(
                        searchStudentHomecomingProvider(
                          key: key,
                          id: scanTextId,
                          eventId: '$eventId',
                        ).future,
                      );
                      final selected = result.firstOrNull;
                      if (!context.mounted) return;
                      if (selected == null) {
                        context.showErrorMessage('Data tidak ditemukan');
                        return;
                      }
                      final code = '${selected.nis}-${selected.idKelas}';
                      context.goNamed(
                        AppRoute.detailHomecoming.name,
                        queryParameters: {
                          'id': code,
                          'eventId': '$eventId',
                          'eventName': '$eventName',
                        },
                      );
                    } catch (error) {
                      context.showErrorMessage('Data Tidak ditemukan');
                    }
                  },
                ),
              );
            },
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
            fetchAllEventHostelProvider(key: key, id: '$eventId').future),
        child: Skeletonizer(
          enabled: fetchAllHostel.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final hostel = fetchAllHostel.valueOrNull?.elementAtOrNull(index);

              return Card.outlined(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                  child: ListTile(
                    title: Text(
                      '${hostel?.namaAsrama}',
                      style: context.titleMediumBold,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Jumlah Murid: '),
                            Text('${hostel?.jumlahSantri} murid'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sudah Pulang: '),
                            Text('${hostel?.dijemput} murid'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Murid Kembali: '),
                            Text('${hostel?.dikembalikan} murid'),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      if (hostel == null) return;
                      context.goNamed(
                        AppRoute.homecomingClassroom.name,
                        queryParameters: {
                          'eventId': '$eventId',
                          'hostelId': hostel.idAsrama,
                          'eventName': '$eventName',
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _addStudentHomecoming(context, ref, key),
    );
  }

  Widget _addStudentHomecoming(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownSearch<Siswa>(
        asyncItems: (String filter) {
          return ref.watch(
            fetchSearchStudentProvider(
              key: key,
              query: filter,
            ).future,
          );
        },
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
              hintText: 'Pencarian...',
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
        itemAsString: (item) => '${item.namaLengkap}',
        dropdownDecoratorProps: const DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            hintText: 'Murid Perpulangan',
            labelText: 'Murid Perpulangan',
            border: OutlineInputBorder(),
            isDense: true,
            prefixIcon: Icon(Icons.person),
          ),
        ),
        onChanged: (staff) async {
          final search = '${staff?.nis}-${staff?.idSiswa}';
          final code = '${staff?.nis}-${staff?.idKelas}';
          try {
            final result = await ref.read(
              searchStudentHomecomingProvider(
                key: key,
                id: search,
                eventId: '$eventId',
              ).future,
            );
            final selected = result.firstOrNull;
            if (!context.mounted) return;
            if (selected == null) {
              context.showErrorMessage('Data tidak ditemukan');
              return;
            }
            context.goNamed(
              AppRoute.detailHomecoming.name,
              queryParameters: {
                'id': code,
                'eventId': '$eventId',
                'eventName': '$eventName',
              },
            );
          } catch (error) {
            context.showErrorMessage('Data Tidak ditemukan');
          }
        },
      ),
    );
  }
}
