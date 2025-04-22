class CategoryModel {
  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.categoryImage,
    required this.backgroundDarkColor,
    required this.backgroundLightColor,
    this.totalProviders,
  });

  CategoryModel.fromJson(final Map<String?, dynamic> json) {
    id = json["id"] ?? '';
    name = json["name"] ?? '';
    slug = json["slug"] ?? '';
    categoryImage = json["category_image"] ?? '';
    backgroundLightColor = json['light_color'] ?? '';
    backgroundDarkColor = json['dark_color'] ?? '';
    totalProviders = json['total_providers'].toString();
  }

  String? id;
  String? name;
  String? slug;
  String? categoryImage;
  String? backgroundDarkColor;
  String? backgroundLightColor;
  String? totalProviders;
}
