import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/user/user.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'account_controller.dart';

class AccountScreen extends HookConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(accountControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final accountController = ref.watch(accountControllerProvider);
    final key = '${currentUser?.key}';
    final fetchProfile = ref.watch(fetchProfileProvider(key: key));

    final name = useTextEditingController();
    final email = useTextEditingController();
    final phoneNumber = useTextEditingController();
    final address = useTextEditingController();
    final imageSelected =
        useState<(File? localFile, String? imageUrl)>((null, null));
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    void setProfile(User? user) {
      useEffect(() {
        if (user == null) return;
        name.text = user.fullName ?? '';
        email.text = user.email ?? '';
        phoneNumber.text = user.phoneNumber ?? '';
        address.text = user.address ?? '';
        imageSelected.value = (null, user.img);
        return null;
      }, [fetchProfile]);
    }

    Future<void> updateProfile() async {
      if (!formKey.currentState!.validate() || currentUser == null) {
        return;
      }

      final result = await ref
          .read(
            accountControllerProvider.notifier,
          )
          .updateProfile(
            key: '${currentUser.key}',
            fullName: name.text,
            email: email.text.trim(),
            phoneNumber: phoneNumber.text.trim(),
            address: address.text.trim(),
            file: imageSelected.value.$1,
          );

      if (result == null || !context.mounted) return;
      context.showSuccessMessage(
        result.msg,
      );
      ref.invalidate(fetchProfileProvider(key: key));
    }

    setProfile(fetchProfile.value);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(fetchProfileProvider(key: key).future),
        child: Skeletonizer(
            enabled: fetchProfile.isLoading,
            child: ListView(
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
                            name: name.text,
                            size: 100,
                            autoTextSize: true,
                            image: imageSelected.value.$1 != null
                                ? FileImage(
                                    imageSelected.value.$1!,
                                  ) as ImageProvider
                                : CachedNetworkImageProvider(
                                    '${imageSelected.value.$2}',
                                  ),
                            children: const [
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Icon(
                                  Icons.edit,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32.0),
                        TextFormField(
                          controller: name,
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            labelText: 'Nama Lengkap'.hardcoded,
                            prefixIcon: const Icon(Icons.person),
                          ),
                        ),
                        const Gap(16),
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
                          validator: FormBuilderValidators.email(),
                        ),
                        const Gap(16),
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
                          validator: FormBuilderValidators.required(),
                        ),
                        const Gap(16),
                        TextFormField(
                          controller: address,
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            labelText: 'Alamat'.hardcoded,
                            prefixIcon: const Icon(Icons.location_on),
                          ),
                        ),
                        const Gap(24),
                        FilledButton(
                          onPressed: accountController.isLoading
                              ? null
                              : updateProfile,
                          child: accountController.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Text(
                                  'Simpan'.hardcoded,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
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
