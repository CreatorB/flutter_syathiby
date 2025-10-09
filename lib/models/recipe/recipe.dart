import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

@freezed
class Recipe with _$Recipe {
  const factory Recipe({
    @JsonKey(name: 'id_recipe') String? idRecipe,
    @JsonKey(name: 'raw_material') String? rawMaterial,
    @JsonKey(name: 'id_product') String? idProduct,
    String? name,
    @JsonKey(name: 'name_product') String? nameProduct,
    String? detail,
    String? stock,
    String? unit,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
}
