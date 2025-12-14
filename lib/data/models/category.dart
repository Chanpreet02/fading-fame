class Category {
  final int id;
  final String name;
  final String slug;
  final String? description;
  bool isVisible;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.isVisible = true,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      slug: map['slug'] as String,
      description: map['description'] as String?,
      isVisible: map['is_visible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'is_visible': isVisible,
    };
  }
}
