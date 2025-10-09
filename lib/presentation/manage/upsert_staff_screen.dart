import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_hooks/flutter_hooks.dart' hide Store;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/staff/staff.dart';
import 'package:syathiby/models/store/store.dart';
import 'package:syathiby/presentation/manage/manage_staff_controller.dart';
import 'package:syathiby/presentation/rapat/meeting_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';

class UpsertStaffScreen extends HookConsumerWidget {
  final Staff? staff;

  const UpsertStaffScreen({
    super.key,
    this.staff,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(manageStaffControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final manageController = ref.watch(manageStaffControllerProvider);
    final name = useTextEditingController();
    final email = useTextEditingController();
    final phoneNumber = useTextEditingController();
    final address = useTextEditingController();
    final jobPosition = useTextEditingController();
    final levelSelected = useState<String?>(null);
    final officeSelected = useState<Store?>(null);
    final imageSelected =
        useState<(File? localFile, String? imageUrl)>((null, null));
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final isUpdate = staff != null;

    useEffect(() {
      if (!isUpdate) return;
      debugPrint('CEK STAFF: $staff');
      name.text = staff?.fullName ?? '';
      phoneNumber.text = staff?.phoneNumber ?? '';
      address.text = staff?.address ?? '';
      jobPosition.text = staff?.position ?? '';
      email.text = staff?.email ?? '';
      officeSelected.value = Store(
        idStore: staff?.idStore,
        nameStore: staff?.nameStore,
      );
      levelSelected.value = staff?.level ?? '';
      imageSelected.value = (null, staff?.img);
      return null;
    }, []);

    Future<void> upsertInventory() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      if (levelSelected.value == null) {
        context.showErrorMessage('Level akun harus dipilih');
        return;
      }
      final future = isUpdate
          ? ref.read(manageStaffControllerProvider.notifier).updateStaff(
                key: key,
                staffId: '${staff?.key}',
                name: name.text,
                level: '${levelSelected.value}',
                type: '',
                address: address.text,
                allowance: '0',
                comission: '0',
                email: email.text,
                overtime: '0',
                phone: phoneNumber.text,
                position: jobPosition.text,
                salary: '0',
                salaryCuts: '0',
                store: '${officeSelected.value?.idStore}',
                image: imageSelected.value.$1,
              )
          : ref.read(manageStaffControllerProvider.notifier).addStaff(
                key: key,
                name: name.text,
                level: '${levelSelected.value}',
                type: '',
                address: address.text,
                allowance: '0',
                comission: '0',
                email: email.text,
                overtime: '0',
                phone: phoneNumber.text,
                position: jobPosition.text,
                salary: '0',
                salaryCuts: '0',
                store: '${officeSelected.value?.idStore}',
                image: imageSelected.value.$1,
              );
      final result = await future;

      if (result == null || !context.mounted) return;
      context.showSuccessMessage(result.msg);
      context.pop();
      ref.invalidate(fetchAllStaffProvider);
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${isUpdate ? 'Ubah' : 'Tambah'} Pegawai'.hardcoded),
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
                        'Foto Pegawai',
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
                        labelText: 'Nama Pegawai'.hardcoded,
                        hintText: 'Nama Pegawai'.hardcoded,
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: email,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Email'.hardcoded,
                        prefixIcon: const Icon(Icons.email),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: phoneNumber,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Nomer Telepon'.hardcoded,
                        prefixIcon: const Icon(Icons.phone),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: address,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Alamat'.hardcoded,
                        prefixIcon: const Icon(Icons.directions),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: jobPosition,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Posisi Jabatan'.hardcoded,
                        prefixIcon: const Icon(Icons.work),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    DropdownSearch<Store>(
                      selectedItem: officeSelected.value,
                      asyncItems: (text) => ref.read(
                        fetchAllStoreProvider(key: key).future,
                      ),
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
                      itemAsString: (item) => '${item.nameStore}',
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: 'Kantor',
                          labelText: 'Kantor',
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.work_history),
                        ),
                      ),
                      onChanged: (item) async {
                        officeSelected.value = item;
                      },
                      validator: FormBuilderValidators.required(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Level Akun'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio(
                          value: 'admin',
                          groupValue: levelSelected.value,
                          onChanged: (value) {
                            levelSelected.value = value;
                          },
                        ),
                        const Text('Admin'),
                        Radio(
                          value: 'staff',
                          groupValue: levelSelected.value,
                          onChanged: (value) {
                            levelSelected.value = value;
                          },
                        ),
                        const Text('Staff'),
                        Radio(
                          value: 'manager',
                          groupValue: levelSelected.value,
                          onChanged: (value) {
                            levelSelected.value = value;
                          },
                        ),
                        const Text('Manager'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed:
                          manageController.isLoading ? null : upsertInventory,
                      child: manageController.isLoading
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
