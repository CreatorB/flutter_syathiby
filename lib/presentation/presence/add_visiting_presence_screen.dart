import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syathiby/models/job/request_visiting.dart';
import 'package:syathiby/presentation/presence/presence_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';

class AddVisitingPresenceScreen extends HookConsumerWidget {
  const AddVisitingPresenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(presenceControllerProvider, (previous, next) {
      next.showToastOnError(context);
      debugPrint('NEXT: $next');
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final presenceController = ref.watch(presenceControllerProvider);
    final locationName = useTextEditingController();
    final address = useTextEditingController();
    final visitInformation = useTextEditingController();
    final imageSelected = useState<File?>((null));
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    Future<void> addVisiting() async {
      final position = await ref.read(getCurrentLocationProvider.future);
      if (!formKey.currentState!.validate()) {
        return;
      }
      if (imageSelected.value == null) {
        context.showErrorMessage('Anda belum melakukan foto');
        return;
      }
      final result = await ref
          .read(
            presenceControllerProvider.notifier,
          )
          .addVisiting(
            requestVisiting: RequestVisiting(
              key: key,
              name: locationName.text,
              address: address.text,
              detail: visitInformation.text,
              latitude: position.latitude,
              longitude: position.longitude,
            ),
            image: imageSelected.value,
          );

      if (result == null || !context.mounted) return;
      context.showSuccessMessage(
        'Sukses',
      );
      context.pop();
      ref.invalidate(fetchAttendanceVisitingProvider(key: key));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Kunjungan'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24.0),
                InkWell(
                  onTap: () async {
                    final file = await _openCamera(context);
                    imageSelected.value = file;
                  },
                  child: Center(
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
                      image: imageSelected.value != null
                          ? FileImage(
                              imageSelected.value!,
                            ) as ImageProvider
                          : null,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 50,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: locationName,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nama Tempat',
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: address,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Alamat',
                  ),
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: visitInformation,
                  maxLines: 5,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Keterangan Kunjungan',
                  ),
                ),
                const SizedBox(height: 24.0),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        presenceController.isLoading ? null : addVisiting,
                    child: presenceController.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Simpan'),
                  ),
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<File?> _openCamera(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return null;
    final imageCompressed = await FlutterImageCompress.compressWithList(
      await image.readAsBytes(),
      quality: 10,
    );
    final tempDir = await getTemporaryDirectory();
    File file = await File(
      '${tempDir.path}/${DateTime.timestamp()}',
    ).create();
    file.writeAsBytesSync(imageCompressed);
    return file;
  }
}
