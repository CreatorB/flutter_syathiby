import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/presentation/manage_job/manage_job_controller.dart';
import 'package:syathiby/presentation/rapat/meeting_controller.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../models/job/job.dart';
import '../../models/staff/staff.dart';

class UpsertManageJobScreen extends HookConsumerWidget {
  final Job? job;

  const UpsertManageJobScreen({super.key, this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(manageJobControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final manageJobController = ref.watch(manageJobControllerProvider);

    final jobName = useTextEditingController();
    final jobDetail = useTextEditingController();
    final staffSelected = useState<Staff?>(null);

    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final isUpdate = job != null;
    final title = isUpdate ? 'Tambah Pekerjaan' : 'Edit Pekerjaan';

    useEffect(() {
      if (!isUpdate) return;

      jobName.text = '${job?.note}';
      jobDetail.text = '${job?.detail}';
      staffSelected.value = Staff(
        phoneNumber: '${job?.phone_number}',
        fullName: '${job?.operator}',
      );

      return null;
    });

    Future<void> upsertManageJob() async {
      if (!formKey.currentState!.validate()) {
        return;
      }

      final result = isUpdate
          ? await ref
              .read(
                manageJobControllerProvider.notifier,
              )
              .editJob(
                key: key,
                jobId: '${job?.id_history_job}',
                note: jobName.text,
                detail: jobDetail.text,
                operator: '${staffSelected.value?.phoneNumber}',
              )
          : await ref
              .read(
                manageJobControllerProvider.notifier,
              )
              .addJob(
                key: key,
                note: jobName.text,
                detail: jobDetail.text,
                operator: '${staffSelected.value?.phoneNumber}',
              );
      if (result == null || !context.mounted) return;
      context.showSuccessMessage(result.msg);
      ref.invalidate(fetchAllJobProvider(key: key));
      context.pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
                  TextFormField(
                    controller: jobName,
                    textInputAction: TextInputAction.done,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Judul Pekerjaan'.hardcoded,
                      prefixIcon: const Icon(Icons.work),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: jobDetail,
                    maxLines: 5,
                    textInputAction: TextInputAction.done,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Rincian Pekerjaan'.hardcoded,
                      prefixIcon: const Icon(Icons.details),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const Gap(16),
                  DropdownSearch<Staff>(
                    selectedItem: staffSelected.value,
                    asyncItems: (text) => ref.read(
                      fetchAllStaffProvider(key: key).future,
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
                    itemAsString: (item) => '${item.fullName}',
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'Nama Staff',
                        labelText: 'Nama Staff',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    onChanged: (staff) async {
                      staffSelected.value = staff;
                    },
                    validator: FormBuilderValidators.required(),
                  ),
                  const Gap(24),
                  FilledButton(
                    onPressed:
                        manageJobController.isLoading ? null : upsertManageJob,
                    child: manageJobController.isLoading
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
      ),
    );
  }
}
