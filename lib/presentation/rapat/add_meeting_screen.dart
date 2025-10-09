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
import 'package:syathiby/presentation/rapat/meeting_controller.dart';
import 'package:syathiby/utils/extension/ui.dart';

class AddMeetingScreen extends HookConsumerWidget {
  const AddMeetingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(meetingControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final meetingController = ref.watch(meetingControllerProvider);
    final meetingName = useTextEditingController();
    final date = useTextEditingController();
    final hour = useTextEditingController();
    final detail = useTextEditingController();
    final howManyHour = useTextEditingController();
    final location = useTextEditingController();
    final meetingType = useTextEditingController();

    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    Future<void> addStudentHealth() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      ref
          .read(
            meetingControllerProvider.notifier,
          )
          .addMeeting(
            key: key,
            meetingName: meetingName.text,
            date: date.text,
            finish: howManyHour.text,
            description: detail.text,
            location: location.text,
            meetingFor: meetingType.text,
            startTime: hour.text,
          );

      ref.invalidate(
        fetchAllMeetingProvider(key: key),
      );

      Future.delayed(
        const Duration(seconds: 3),
        () {
          context.pop();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Meeting'.hardcoded),
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
                    controller: meetingName,
                    textInputAction: TextInputAction.done,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Nama Agenda'.hardcoded,
                      prefixIcon: const Icon(Icons.question_answer),
                    ),
                    validator: FormBuilderValidators.required(),
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
                      labelText: 'Tanggal Pertemuan'.hardcoded,
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
                      labelText: 'Jam Pertemuan'.hardcoded,
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
                  TextFormField(
                    controller: howManyHour,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Berapa Jam'.hardcoded,
                      prefixIcon: const Icon(Icons.numbers),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.numeric(),
                    ]),
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: location,
                    textInputAction: TextInputAction.done,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Lokasi'.hardcoded,
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: detail,
                    textInputAction: TextInputAction.done,
                    maxLines: 3,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Detail Pertemuan'.hardcoded,
                      prefixIcon: const Icon(Icons.info),
                    ),
                    validator: FormBuilderValidators.required(),
                  ),
                  const Gap(16),
                  DropdownSearch<String>(
                    items: const ['Pertemuan Offline', 'Pertemuan Online'],
                    popupProps: const PopupProps.menu(),
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'Pertemuan',
                        labelText: 'Pertemuan',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.meeting_room),
                      ),
                    ),
                    validator: FormBuilderValidators.required(),
                    onChanged: (value) {
                      if (value == null) return;
                      meetingType.text = value;
                    },
                  ),
                  const Gap(24),
                  FilledButton(
                    onPressed:
                        meetingController.isLoading ? null : addStudentHealth,
                    child: meetingController.isLoading
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
