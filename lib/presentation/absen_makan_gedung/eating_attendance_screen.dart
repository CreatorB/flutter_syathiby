import 'package:dropdown_search/dropdown_search.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/routing/app_router.dart';

import '../../di/providers.dart';

class EatingAttendanceScreen extends HookConsumerWidget {
  const EatingAttendanceScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';

    final date = useTextEditingController();
    final scheduleSelected = useState<String?>(null);
    final dateSelected = useState<DateTime>(DateTime.now());
    final formatDate = DateFormat('yyyy-MM-dd').format(dateSelected.value);
    date.text = formatDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi Makan'),
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
                  lastDate: DateTime.now(),
                );
                if (selected == null) return;
                final formatDate = DateFormat('yyyy-MM-dd').format(selected);
                date.text = formatDate;
                dateSelected.value = selected;
              },
            ),
            const SizedBox(height: 16),
            DropdownSearch<String>(
              items: const ['pagi', 'siang', 'sore', 'malam'],
              selectedItem: scheduleSelected.value,
              itemAsString: (item) => item.capitalize,
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  hintText: 'Waktu Presensi',
                  labelText: 'Waktu Presensi',
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
                scheduleSelected.value = selected;
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
                    AppRoute.addEatingAttendance.name,
                    queryParameters: {
                      'date': date.text,
                      'time': '${scheduleSelected.value}',
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
