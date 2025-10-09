import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_expense.freezed.dart';
part 'category_expense.g.dart';

@freezed
class CategoryExpense with _$CategoryExpense {
  const factory CategoryExpense({
    @JsonKey(name: 'id_expense_category') String? idExpenseCategory,
    @JsonKey(name: 'name_expense_category', defaultValue: '')
    String? nameExpenseCategory,
  }) = _CategoryExpense;

  factory CategoryExpense.fromJson(Map<String, dynamic> json) =>
      _$CategoryExpenseFromJson(json);
}
