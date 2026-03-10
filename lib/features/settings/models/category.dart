class Category {
  final String id;
  final String nameRu;
  final String nameTk;
  final int sortOrder;

  Category({required this.id, required this.nameRu, required this.nameTk, this.sortOrder = 0});

  // Get name based on language code
  String getName(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return nameRu;
      case 'tk':
        return nameTk;
      default:
        return nameRu;
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'nameRu': nameRu, 'nameTk': nameTk, 'sortOrder': sortOrder};
  }

  // Create from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] ?? '').toString(),
      nameRu: (json['nameRu'] ?? json['nameEn'] ?? '').toString(),
      nameTk: (json['nameTk'] ?? '').toString(),
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  Category copyWith({String? id, String? nameRu, String? nameTk, int? sortOrder}) {
    return Category(id: id ?? this.id, nameRu: nameRu ?? this.nameRu, nameTk: nameTk ?? this.nameTk, sortOrder: sortOrder ?? this.sortOrder);
  }
}
