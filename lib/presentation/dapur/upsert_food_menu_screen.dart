import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
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
import 'package:syathiby/models/product/product.dart';
import 'package:syathiby/presentation/dapur/kitchen_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';

class UpsertFoodMenuScreen extends HookConsumerWidget {
  final Product? product;

  const UpsertFoodMenuScreen({
    super.key,
    this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(kitchenControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final kitchenController = ref.watch(kitchenControllerProvider);
    final name = useTextEditingController();
    final imageSelected =
        useState<(File? localFile, String? imageUrl)>((null, null));
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final isUpdate = product != null;

    useEffect(() {
      if (!isUpdate) return;
      name.text = product?.nameProduct ?? '';
      imageSelected.value = (null, product?.img);
      return null;
    }, []);

    Future<void> upsertInventory() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      final future = isUpdate
          ? ref.read(kitchenControllerProvider.notifier).editFoodMenu(
                key: key,
                menuId: '${product?.idProduct}',
                name: name.text,
                image: imageSelected.value.$1,
              )
          : ref.read(kitchenControllerProvider.notifier).addFoodMenu(
                key: key,
                name: name.text,
                image: imageSelected.value.$1,
              );
      final result = await future;

      if (result == null || !context.mounted) return;
      context.showSuccessMessage(
        result.msg,
      );
      context.pop();
      ref.invalidate(fetchAllFoodMenuProvider);
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${isUpdate ? 'Ubah' : 'Tambah'} Menu Masakan'.hardcoded),
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
                        'Foto Menu Masakan',
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
                        labelText: 'Nama Masakan'.hardcoded,
                        prefixIcon: const Icon(Icons.fastfood),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed:
                          kitchenController.isLoading ? null : upsertInventory,
                      child: kitchenController.isLoading
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
