class Category {
  final String id;
  final String nameEn;
  final String nameRu;
  final String nameTk;

  Category({required this.id, required this.nameEn, required this.nameRu, required this.nameTk});

  // Get name based on language code
  String getName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return nameEn;
      case 'ru':
        return nameRu;
      case 'tk':
        return nameTk;
      default:
        return nameEn;
    }
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'nameEn': nameEn, 'nameRu': nameRu, 'nameTk': nameTk};
  }

  // Create from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'] as String, nameEn: json['nameEn'] as String, nameRu: json['nameRu'] as String, nameTk: json['nameTk'] as String);
  }

  Category copyWith({String? id, String? nameEn, String? nameRu, String? nameTk}) {
    return Category(id: id ?? this.id, nameEn: nameEn ?? this.nameEn, nameRu: nameRu ?? this.nameRu, nameTk: nameTk ?? this.nameTk);
  }
}
