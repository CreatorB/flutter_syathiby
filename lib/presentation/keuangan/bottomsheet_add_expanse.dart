import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/category_expense/category_expense.dart';
import 'package:syathiby/models/transaction/request_spending.dart';
import 'package:syathiby/presentation/keuangan/student_savings_controller.dart';

import '../../di/providers.dart';

class BottomSheetAddExpanse extends HookConsumerWidget {
  const BottomSheetAddExpanse({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final nominal = useTextEditingController();
    final expanseName = useTextEditingController();
    final categorySelected = useState<CategoryExpense?>(null);
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final formatter = CurrencyTextInputFormatter.currency(
      locale: 'id',
      decimalDigits: 0,
      symbol: 'Rp',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pengeluaran'),
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
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownSearch<CategoryExpense?>(
              selectedItem: categorySelected.value,
              asyncItems: (String filter) {
                return ref.watch(
                  fetchAllCategoryExpanseProvider(
                    key: key,
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
              itemAsString: (item) => '${item?.nameExpenseCategory}',
              dropdownDecoratorProps: const DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  hintText: 'Jenis Pengeluaran',
                  labelText: 'Jenis Pengeluaran',
                  border: OutlineInputBorder(),
                  isDense: true,
                  prefixIcon: Icon(Icons.money),
                ),
              ),
              validator: FormBuilderValidators.required(),
              onChanged: (item) {
                categorySelected.value = item;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nominal,
              textInputAction: TextInputAction.done,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                labelText: 'Nominal Pengeluaran'.hardcoded,
                prefixIcon: const Icon(Icons.monetization_on),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                formatter,
              ],
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: expanseName,
              textInputAction: TextInputAction.done,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                labelText: 'Nama Pengeluaran'.hardcoded,
                prefixIcon: const Icon(Icons.description),
              ),
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                final expanse = BarangSpending(
                  id: '${categorySelected.value?.nameExpenseCategory}',
                  nameSpending:
                      '${categorySelected.value?.nameExpenseCategory}',
                  note: expanseName.text,
                  nominal: formatter.numberFormat.parse(nominal.text),
                );
                context.pop(expanse);
              },
              child: const Text('Proses'),
            )
          ],
        ),
      ),
    );
  }
}
