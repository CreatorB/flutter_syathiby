import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/place/inventaris.dart';
import 'package:syathiby/models/unit/unit.dart';
import 'package:syathiby/presentation/data_obat/medicine_controller.dart';
import 'package:syathiby/presentation/rumah_tangga/inventory_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';

class UpsertInventoryScreen extends HookConsumerWidget {
  final String? placeId;
  final Inventaris? inventory;

  const UpsertInventoryScreen({
    super.key,
    this.inventory,
    this.placeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(inventoryControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final inventoryController = ref.watch(inventoryControllerProvider);
    final name = useTextEditingController();
    final code = useTextEditingController();
    final goodCondition = useTextEditingController(text: '0');
    final mediumCondition = useTextEditingController(text: '0');
    final badCondition = useTextEditingController(text: '0');
    final unitTypeSelected = useState<Unit?>(null);
    final imageSelected =
        useState<(File? localFile, String? imageUrl)>((null, null));
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final isUpdate = inventory != null;

    useEffect(() {
      if (!isUpdate) return;
      code.text = inventory?.code ?? '';
      goodCondition.text = inventory?.bagus ?? '';
      mediumCondition.text = inventory?.cukupbaik ?? '';
      badCondition.text = inventory?.rusak ?? '';
      name.text = inventory?.nama_inventaris ?? '';
      unitTypeSelected.value = Unit(
        name_unit: '${inventory?.unit}',
      );
      imageSelected.value = (null, inventory?.img);
      return null;
    }, []);

    Future<void> upsertInventory() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      if (unitTypeSelected.value == null) {
        context.showErrorMessage('Satuan unit harus diisi');
        return;
      }
      final future = isUpdate
          ? ref.read(inventoryControllerProvider.notifier).updateInventory(
                key: key,
                id: '${inventory?.id_inventaris}',
                unit: '${unitTypeSelected.value?.name_unit}',
                name: name.text,
                code: code.text,
                goodCondition: goodCondition.text,
                mediumCondition: mediumCondition.text,
                badCondition: badCondition.text,
                image: imageSelected.value.$1,
              )
          : ref.read(inventoryControllerProvider.notifier).addInventory(
                key: key,
                placeId: '$placeId',
                unit: '${unitTypeSelected.value?.name_unit}',
                name: name.text,
                code: code.text,
                goodCondition: goodCondition.text,
                mediumCondition: mediumCondition.text,
                badCondition: badCondition.text,
                image: imageSelected.value.$1,
              );
      final result = await future;

      if (result == null || !context.mounted) return;
      context.showSuccessMessage(
        result.msg,
      );
      context.pop();
      ref.invalidate(fetchAllInventoryProvider);
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${isUpdate ? 'Ubah' : 'Tambah'} Inventaris'.hardcoded),
        ),
        body: ListView(
          children: [
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      onTap: () async {
                        final file = await _openImagePicker(context);
                        imageSelected.value = (file, null);
                      },
                      child: AdvancedAvatar(
                        size: 120,
                        decoration: BoxDecoration(
                          color: context.colorSurface,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.colorOutline,
                          ),
                        ),
                        image: imageSelected.value.$1 != null
                            ? FileImage(
                                imageSelected.value.$1!,
                              ) as ImageProvider
                            : NetworkImage('${imageSelected.value.$2}'),
                        child: const Icon(
                          Icons.image,
                          size: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Center(
                      child: Text(
                        'Foto Pendukung',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: name,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Nama Barang'.hardcoded,
                        prefixIcon: const Icon(Icons.inventory),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    DropdownSearch<Unit>(
                      selectedItem: unitTypeSelected.value,
                      asyncItems: (String filter) {
                        return ref.watch(
                          fetchAllUnitProvider(
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
                      itemAsString: (item) => '${item.name_unit}',
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: 'Pilih satuan unit',
                          labelText: 'Pilih satuan unit',
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.ad_units),
                        ),
                      ),
                      validator: FormBuilderValidators.required(),
                      onChanged: (item) {
                        unitTypeSelected.value = item;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: code,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Kode Barang'.hardcoded,
                        prefixIcon: const Icon(Icons.barcode_reader),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: goodCondition,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Kondisi Baik'.hardcoded,
                        prefixIcon: const Icon(Icons.done_all),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: mediumCondition,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Kondisi Cukup Baik'.hardcoded,
                        prefixIcon: const Icon(Icons.done),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: badCondition,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Kondisi Rusak'.hardcoded,
                        prefixIcon: const Icon(Icons.close),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: inventoryController.isLoading
                          ? null
                          : upsertInventory,
                      child: inventoryController.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Text(
                              isUpdate ? 'Edit' : 'Simpan'.hardcoded,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<File?> _openImagePicker(
    BuildContext context,
  ) async {
    final ImagePicker picker = ImagePicker();
    final result = await showModalActionSheet(
      title: 'Pilih foto menggunakan',
      context: context,
      actions: [
        SheetAction(
          key: 'photo',
          label: 'Ambil foto'.hardcoded,
          icon: Icons.camera_alt,
        ),
        SheetAction(
          key: 'galery',
          label: 'Pilih dari galeri'.hardcoded,
          icon: Icons.photo,
        ),
      ],
    );
    XFile? image;
    if (result == 'galery') {
      image = await picker.pickImage(source: ImageSource.gallery);
    } else if (result == 'photo') {
      image = await picker.pickImage(source: ImageSource.camera);
    } else {
      return null;
    }
    if (image == null) return null;
    final imageCompressed = await FlutterImageCompress.compressWithList(
      await image.readAsBytes(),
      quality: 10,
    );
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/${DateTime.timestamp()}').create();
    file.writeAsBytesSync(imageCompressed);
    return file;
  }
}
