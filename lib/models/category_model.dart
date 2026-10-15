class CategoryModel {
  final int id;
  final int? parentId;
  final String name;
  final String slug;
  final String? icon;
  final String? image;

  CategoryModel({
    required this.id,
    this.parentId,
    required this.name,
    required this.slug,
    this.icon,
    this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      parentId: json['parent_id'] as int?,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      icon: json['icon'] as String?,
      image: json['image'] as String?,
    );
  }
}
