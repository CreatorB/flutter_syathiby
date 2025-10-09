import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/staff/staff.dart';
import 'package:syathiby/presentation/ubah_jadwal/change_shift_controller.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AddChangeShiftScreen extends HookConsumerWidget {
  const AddChangeShiftScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(changeShiftControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final shiftController = ref.watch(changeShiftControllerProvider);
    final fetchStaffReplacement = ref.watch(
      fetchAllStaffReplacementProvider(key: key),
    );
    final shiftDate = useTextEditingController();
    final shiftReason = useTextEditingController();
    final staffShiftReplacement = useState<Staff?>(null);
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    Future<void> addChangeShift() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      final result = await ref
          .read(
            changeShiftControllerProvider.notifier,
          )
          .addChangeShift(
            key: key,
            staff: '${staffShiftReplacement.value?.phoneNumber}',
            date: shiftDate.text,
            reason: shiftReason.text,
          );

      if (result == null || !context.mounted) return;
      context.showSuccessMessage(
        '${result.msg} silahkan refresh untuk memperbarui data',
        autoCloseDuration: 5,
      );
      context.pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Izin'.hardcoded),
      ),
      body: Skeletonizer(
        enabled: fetchStaffReplacement.isLoading,
        child: RefreshIndicator(
          onRefresh: () =>
              ref.refresh(fetchAllStaffReplacementProvider(key: key).future),
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
                      TextFormField(
                        controller: shiftDate,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Tanggal Tukar Jadwal'.hardcoded,
                          prefixIcon: const Icon(Icons.today),
                        ),
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.date(),
                            FormBuilderValidators.required(),
                          ],
                        ),
                        keyboardType: TextInputType.datetime,
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            initialDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (selected == null) return;
                          final formatDate =
                              DateFormat('yyyy-MM-dd').format(selected);
                          shiftDate.text = formatDate;
                        },
                      ),
                      const Gap(16),
                      DropdownSearch<Staff>(
                        selectedItem: staffShiftReplacement.value,
                        items: fetchStaffReplacement.valueOrNull ?? [],
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
                            hintText: 'Staff Pengganti',
                            labelText: 'Staff Pengganti',
                            border: OutlineInputBorder(),
                            isDense: true,
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        onChanged: (staff) async {
                          staffShiftReplacement.value = staff;
                        },
                        validator: FormBuilderValidators.required(),
                      ),
                      const Gap(16),
                      TextFormField(
                        controller: shiftReason,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Alasan Tukar Jadwal'.hardcoded,
                          prefixIcon: const Icon(Icons.details),
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                      const Gap(24),
                      FilledButton(
                        onPressed:
                            shiftController.isLoading ? null : addChangeShift,
                        child: shiftController.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                'Ajukan'.hardcoded,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
