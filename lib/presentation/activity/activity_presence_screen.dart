import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/tahfidz/tahfidz.dart';
import 'package:syathiby/presentation/activity/activity_presence_controller.dart';
import 'package:syathiby/routing/app_router.dart';

import '../../di/providers.dart';

class ActivityPresenceScreen extends HookConsumerWidget {
  final String? type;

  const ActivityPresenceScreen({
    super.key,
    this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final date = useTextEditingController();
    final activitySelected = useState<Tahfidz?>(null);
    final dateNow = useState<DateTime?>(null);
    final dateSelected = useState<DateTime?>(null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi Kegiatan'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: date,
              readOnly: true,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                labelText: 'Tanggal Presensi'.hardcoded,
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
                  firstDate: DateTime(2000),
                  initialDate: dateSelected.value,
                  lastDate: dateNow.value ?? DateTime.now(),
                );
                if (selected == null) return;
                final formatDate = DateFormat('yyyy-MM-dd').format(selected);
                date.text = formatDate;
                dateSelected.value = selected;
              },
            ),
            const SizedBox(height: 16),
            DropdownSearch<Tahfidz>(
              asyncItems: (text) => ref.read(
                fetchAllActivityProvider(key: key).future,
              ),
              selectedItem: activitySelected.value,
              itemAsString: (item) => '${item.waktu_tahfidz}',
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  hintText: 'Nama Kegiatan',
                  labelText: 'Nama Kegiatan',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.watch_later),
                ),
              ),
              validator: FormBuilderValidators.required(),
              onChanged: (selected) {
                if (selected == null) {
                  return;
                }
                activitySelected.value = selected;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  context.goNamed(
                    AppRoute.studentActivity.name,
                    queryParameters: {
                      'date': date.text,
                      'time': '${activitySelected.value?.waktu_tahfidz}',
                    },
                  );
                },
                child: const Text('Buka Presensi'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
