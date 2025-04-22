class AllCategoryModel {
  final String? id;
  final String? name;
  final String? image;

  AllCategoryModel({
    this.id,
    this.name,
    this.image,
  });

  AllCategoryModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String?,
      name = json['name'] as String?,
      image = json['image'] as String?;

  Map<String, dynamic> toJson() => {
    'id' : id,
    'name' : name,
    'image' : image
  };
}