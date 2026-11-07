import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/allocation/allocation.dart';
import 'package:syathiby/models/product/product.dart';
import 'package:syathiby/models/transaction/petugas_pengajuan.dart';
import 'package:syathiby/models/transaction/request_transaction.dart';
import 'package:syathiby/presentation/transaction/transaction_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';
import '../../utils/custom_avatar_widget.dart';

const _jenisPerbaikan = 'Perbaikan';

bool _isPerbaikan(String? jenis) =>
    jenis?.trim().toLowerCase() == _jenisPerbaikan.toLowerCase();

class AddRequestTransactionScreen extends HookConsumerWidget {
  /// null = pengajuan perbaikan tanpa barang (dibuka dari tombol "Ajukan
  /// Perbaikan" di daftar barang).
  final Product? item;

  const AddRequestTransactionScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      transactionControllerProvider,
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final controller = ref.watch(transactionControllerProvider);
    final currentUser = ref.watch(getCurrentUserProvider);
    final activityName = useTextEditingController();
    final description = useTextEditingController();
    final locationSelected = useState<Allocation?>(null);
    final typeSelected = useState<Allocation?>(null);

    final key = '${currentUser?.key}';
    final initialItem = item;
    final productItems = useState<List<Product>>(
      [
        if (initialItem != null) initialItem.copyWith(amount: 1),
      ],
    );
    final petugasSelected = useState<List<Petugas>>([]);
    final petugasPengajuan =
        ref.watch(fetchPetugasPengajuanProvider(key: key)).valueOrNull;
    final isPerbaikan = _isPerbaikan(typeSelected.value?.allocationName);

    useEffect(() {
      if (initialItem != null) return null;
      Future.microtask(() async {
        final types =
            await ref.read(fetchAllTransactionTypeProvider(key: key).future);
        final perbaikan =
            types.where((e) => _isPerbaikan(e.allocationName)).firstOrNull;
        if (perbaikan != null && typeSelected.value == null) {
          typeSelected.value = perbaikan;
        }
      });
      return null;
    }, const []);
    final total = _getTotalSpending(productItems.value);
    final totalFormat = ref.watch(formatCurrencyProvider('$total'));

    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Form(
        key: formKey,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Permohonan'),
            actions: [
              TextButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  if (isPerbaikan && petugasSelected.value.isEmpty) {
                    context.showErrorMessage(
                      'Pilih minimal satu petugas perbaikan',
                    );
                    return;
                  }
                  // Perbaikan boleh tanpa barang; Barang/Jasa wajib ada.
                  if (!isPerbaikan && productItems.value.isEmpty) {
                    context.showErrorMessage('Produk tidak boleh kosong');
                    return;
                  }
                  final items = productItems.value
                      .map(
                        (e) => Barang(
                          idProduct: e.idProduct,
                          amountProduct: e.amount,
                          newPrice: '0',
                        ),
                      )
                      .toList();

                  final result = await ref
                      .read(transactionControllerProvider.notifier)
                      .addOrderTransaction(
                        requestTransaction: RequestTransaction(
                          key: key,
                          id: '${locationSelected.value?.allocationId}',
                          jenisKegiatan:
                              '${typeSelected.value?.allocationName}',
                          note: description.text,
                          nameKegiatan: activityName.text,
                          paymentAmount: 0,
                          paymentType: 1,
                          totalOrder: total.toDouble(),
                          product: items,
                          petugas: isPerbaikan
                              ? petugasSelected.value
                                  .map((e) => '${e.telp}')
                                  .toList()
                              : null,
                        ),
                      );
                  if (result == null || !context.mounted) return;
                  context.showSuccessMessage(
                    'Berhasil menambah permohonan ${result.invoice}',
                  );
                  ref.invalidate(fetchHistoryTransactionProvider);
                  context.goNamed(AppRoute.historyTransaction.name);
                },
                child: const Text('Simpan'),
              )
            ],
          ),
          body: Stack(
            children: [
              ListView(
                children: [
                  _buildFlowInfo(
                    context,
                    isPerbaikan: isPerbaikan,
                    petugasPengajuan: petugasPengajuan,
                  ),
                  if (isPerbaikan)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: DropdownSearch<Petugas>.multiSelection(
                        items: petugasPengajuan?.petugas ?? [],
                        selectedItems: petugasSelected.value,
                        compareFn: (a, b) => a.telp == b.telp,
                        itemAsString: (e) => '${e.nama}',
                        popupProps: PopupPropsMultiSelection.menu(
                          showSearchBox: true,
                          showSelectedItems: true,
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
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: 'Pilih petugas yang mengerjakan',
                            labelText: 'Petugas Perbaikan *',
                            border: OutlineInputBorder(),
                            isDense: true,
                            prefixIcon: Icon(Icons.engineering),
                          ),
                        ),
                        validator: (value) => (value == null || value.isEmpty)
                            ? 'Pilih minimal satu petugas'
                            : null,
                        onChanged: (value) {
                          petugasSelected.value = value;
                        },
                      ),
                    ),
                  if (productItems.value.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        isPerbaikan
                            ? 'Belum ada barang. Untuk perbaikan, barang boleh dikosongkan.'
                            : 'Belum ada barang. Tambahkan lewat "Tambah Barang" di bawah.',
                        style: context.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  for (var index = 0;
                      index < productItems.value.length;
                      index++)
                    _buildItem(
                      context,
                      ref,
                      productItems.value.elementAt(index),
                      productItems,
                      index,
                    ),
                ],
              ),
              Visibility(
                visible: controller.isLoading,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
          bottomNavigationBar: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Perkiraan Belanja',
                        style: context.bodyMediumBold,
                      ),
                      Text(
                        totalFormat,
                        style: context.bodyMediumBold?.copyWith(
                          color: context.colorPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownSearch<Product>(
                    asyncItems: (String filter) {
                      return ref.watch(
                        fetchAllItemProvider(
                          key: key,
                          haveStock: '',
                          trx: 'YES',
                          page: 1,
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
                    itemAsString: (item) {
                      final total = ref.watch(
                          formatCurrencyProvider('${item.sellingPrice}'));
                      return '${item.nameProduct} ($total)';
                    },
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'Tambah Barang',
                        labelText: 'Tambah Barang',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.add_box),
                      ),
                    ),
                    onChanged: (item) {
                      if (item == null) {
                        return;
                      }
                      final currentIndex = productItems.value.indexWhere(
                        (element) => element.idProduct == item.idProduct,
                      );
                      if (currentIndex != -1) {
                        context.showErrorMessage(
                          'barang sudah ada, silahkan rubah kuantitas',
                        );
                        return;
                      }
                      productItems.value.add(
                        item.copyWith(
                          amount: 1,
                        ),
                      );
                      productItems.value = [...productItems.value];
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: activityName,
                    textInputAction: TextInputAction.done,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Nama Kegiatan'.hardcoded,
                      prefixIcon: const Icon(Icons.local_activity),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownSearch<Allocation>(
                          selectedItem: locationSelected.value,
                          asyncItems: (String filter) {
                            return ref.watch(
                              fetchAllAllocationProvider(
                                key: key,
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
                          itemAsString: (item) => '${item.allocationName}',
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              hintText: 'Lokasi Kegiatan',
                              labelText: 'Lokasi Kegiatan',
                              border: OutlineInputBorder(),
                              isDense: true,
                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),
                          validator: FormBuilderValidators.required(),
                          onChanged: (item) {
                            locationSelected.value = item;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownSearch<Allocation>(
                          selectedItem: typeSelected.value,
                          asyncItems: (String filter) {
                            return ref.watch(
                              fetchAllTransactionTypeProvider(
                                key: key,
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
                          itemAsString: (item) => '${item.allocationName}',
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              hintText: 'Jenis Kegiatan',
                              labelText: 'Jenis Kegiatan',
                              border: OutlineInputBorder(),
                              isDense: true,
                              prefixIcon: Icon(Icons.ad_units),
                            ),
                          ),
                          validator: FormBuilderValidators.required(),
                          onChanged: (item) {
                            typeSelected.value = item;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: description,
                    textInputAction: TextInputAction.done,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Keterangan Tambahan'.hardcoded,
                      prefixIcon: const Icon(Icons.description),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlowInfo(
    BuildContext context, {
    required bool isPerbaikan,
    required PetugasPengajuan? petugasPengajuan,
  }) {
    final atasanNama = petugasPengajuan?.atasanNama ?? '';
    final namaTampil = atasanNama.isNotEmpty ? atasanNama : '-';
    final atasanOtomatis = petugasPengajuan?.atasanOtomatis == 1;
    final String atasanText;
    final String alurText;
    if (isPerbaikan) {
      atasanText = 'Atasan: $namaTampil (disetujui otomatis)';
      alurText = 'Alur perbaikan: diajukan -> petugas menerima & mengerjakan '
          '-> petugas klaim selesai -> Anda konfirmasi. Atasan masih bisa '
          'menolak selama pekerjaan belum dimulai.';
    } else {
      atasanText = atasanOtomatis
          ? 'Atasan yang menyetujui: $namaTampil (otomatis, Anda pimpinan)'
          : 'Atasan yang menyetujui: $namaTampil';
      alurText = 'Alur pengadaan: diajukan -> ACC atasan -> Mudir -> Keuangan '
          '-> pencairan -> logistik -> selesai -> Anda konfirmasi diterima.';
    }
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(atasanText, style: context.bodyMediumBold),
            const SizedBox(height: 4),
            Text(alurText, style: context.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    WidgetRef ref,
    Product item,
    ValueNotifier<List<Product>> items,
    int index,
  ) {
    final price = ref.watch(formatCurrencyProvider('${item.sellingPrice}'));
    return ListTile(
      leading: CustomAvatar(
        name: '${item.nameProduct}',
        imageUrl: '${item.img}',
        size: 40,
      ),
      title: Text(
        '${item.nameProduct}',
        style: context.bodyMediumBold,
      ),
      subtitle: Text(
        price,
        style: context.bodyMedium?.copyWith(color: context.colorPrimary),
      ),
      trailing: Transform.translate(
        offset: const Offset(8, 0),
        child: InputQty.double(
          initVal: item.amount ?? 1,
          onQtyChanged: (qty) {
            if (qty <= 0) {
              final currentList = items.value;
              currentList.remove(item);
              items.value = [...currentList];
              return;
            }
            final currentItem = item.copyWith(amount: qty);
            items.value[index] = currentItem;
            items.value = [...items.value];
          },
        ),
      ),
    );
  }

  num _getTotalSpending(List<Product> items) {
    num total = 0;
    for (final i in items) {
      total = total +
          ((double.tryParse('${i.sellingPrice}') ?? 0) * (i.amount ?? 0));
    }
    return total;
  }
}
