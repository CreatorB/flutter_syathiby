import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_category.freezed.dart';
part 'sub_category.g.dart';

@freezed
class SubCategory with _$SubCategory {
  const factory SubCategory({
    required String status,
    required String errCode,
    required String msg,
    required List<SubCategoryData> data,
  }) = _SubCategory;

  factory SubCategory.fromJson(Map<String, dynamic> json) =>
      _$SubCategoryFromJson(json);
}

@freezed
class SubCategoryData with _$SubCategoryData {
  const factory SubCategoryData({
    required String id_subcategory,
    required String id_category,
    required String name_category,
  }) = _SubCategoryData;

  factory SubCategoryData.fromJson(Map<String, dynamic> json) =>
      _$SubCategoryDataFromJson(json);
}
