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
import 'package:syathiby/presentation/manage/manage_staff_controller.dart';
import 'package:syathiby/presentation/rekap/recap_controller.dart';
import 'package:syathiby/utils/extension/ui.dart';

class AddManualAttendanceScreen extends HookConsumerWidget {
  const AddManualAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(recapControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final recapController = ref.watch(recapControllerProvider);
    final date = useTextEditingController();
    final hour = useTextEditingController();
    final statusSelected = useState<String?>(null);
    final staffSelected = useState<Staff?>(null);
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    Future<void> addManualAttendance() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      final result = await ref
          .read(
            recapControllerProvider.notifier,
          )
          .addManualAttendance(
            key: key,
            date: date.text,
            hour: hour.text,
            status: '${statusSelected.value}',
            staffId: '${staffSelected.value?.phoneNumber}',
          );
      if (result == null || !context.mounted) return;
      context.pop();
      ref.invalidate(fetchAllManualAttendanceProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Pelanggaran'.hardcoded),
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
                  DropdownSearch<Staff>(
                    selectedItem: staffSelected.value,
                    asyncItems: (String filter) {
                      return ref.watch(
                        searchStaffProvider(
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
                    itemAsString: (item) => '${item.fullName}',
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'Nama Pegawai',
                        labelText: 'Nama Pegawai',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    validator: FormBuilderValidators.required(),
                    onChanged: (student) {
                      if (student == null) {
                        return;
                      }
                      staffSelected.value = student;
                    },
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: date,
                    readOnly: true,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Tanggal'.hardcoded,
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
                        firstDate: DateTime(DateTime.now().year),
                        initialDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (selected == null) return;
                      final formatDate =
                          DateFormat('yyyy-MM-dd').format(selected);
                      date.text = formatDate;
                    },
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: hour,
                    readOnly: true,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Jam Absensi'.hardcoded,
                      prefixIcon: const Icon(Icons.watch_later),
                    ),
                    validator: FormBuilderValidators.required(),
                    keyboardType: TextInputType.datetime,
                    onTap: () async {
                      final selected = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selected == null || !context.mounted) return;
                      hour.text = selected.format(context);
                    },
                  ),
                  const Gap(16),
                  const Text('Level Akun'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: 'ontime',
                        groupValue: statusSelected.value,
                        onChanged: (value) {
                          statusSelected.value = value;
                        },
                      ),
                      const Text('Tepat Waktu'),
                      Radio(
                        value: 'late',
                        groupValue: statusSelected.value,
                        onChanged: (value) {
                          statusSelected.value = value;
                        },
                      ),
                      const Text('Telat'),
                    ],
                  ),
                  const Gap(8),
                  FilledButton(
                    onPressed:
                        recapController.isLoading ? null : addManualAttendance,
                    child: recapController.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Text(
                            'Absen Sekarang'.hardcoded,
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
