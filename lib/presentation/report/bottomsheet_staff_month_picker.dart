import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/presentation/manage/manage_staff_controller.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';
import '../../models/staff/staff.dart';

class BottomSheetStaffMonthPicker extends HookConsumerWidget {
  final String? title, routeName;

  const BottomSheetStaffMonthPicker({
    super.key,
    this.title,
    this.routeName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final month = useTextEditingController();
    final staffSelected = useState<Staff?>(null);
    final dateStartSelected = useState<String?>(null);
    final dateEndSelected = useState<String?>(null);

    return Scaffold(
      appBar: AppBar(
        title: Text('$title'),
        leading: Container(),
        actions: [
          IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.close),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownSearch<Staff>(
            asyncItems: (text) => ref.read(
              searchStaffProvider(key: key, query: text).future,
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
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: month,
            readOnly: true,
            decoration: InputDecoration(
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              labelText: 'Pilih Bulan'.hardcoded,
              prefixIcon: const Icon(Icons.today),
            ),
            keyboardType: TextInputType.datetime,
            onTap: () async {
              final monthSelected = await showMonthPicker(
                context: context,
                initialDate: DateTime.now(),
                lastDate: DateTime.now(),
              );
              if (monthSelected == null || !context.mounted) return;
              month.text = DateFormat('MMMM').format(monthSelected);
              final startDate = DateFormat('yyyy-MM-dd').format(monthSelected);
              final endDayOfMonth = monthSelected.copyWith(
                month: monthSelected.month + 1,
                day: 0,
              );
              final endDate = DateFormat('yyyy-MM-dd').format(endDayOfMonth);
              dateStartSelected.value = startDate;
              dateEndSelected.value = endDate;
            },
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (routeName == null) return;
              if (dateStartSelected.value == null) {
                context.showErrorMessage('Silahkan pilih bulan dahulu');
                return;
              }
              if (staffSelected.value == null) {
                context.showErrorMessage('Silahkan pilih pegawai dahulu');
                return;
              }
              context.goNamed(
                routeName!,
                queryParameters: {
                  'userKey': '${staffSelected.value?.key}',
                  'name': '${staffSelected.value?.fullName}',
                  'startDate': '${dateStartSelected.value}',
                  'endDate': '${dateEndSelected.value}',
                },
              );
            },
            child: Text('Lihat $title'),
          )
        ],
      ),
    );
  }
}
