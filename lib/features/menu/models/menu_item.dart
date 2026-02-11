import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final String id;
  final String category;
  final String nameEn;
  final String nameRu;
  final String nameTk;
  final String descriptionEn;
  final String descriptionRu;
  final String descriptionTk;
  final double price;
  final String imageUrl;
  final bool available;

  const MenuItem({
    required this.id,
    required this.category,
    required this.nameEn,
    required this.nameRu,
    required this.nameTk,
    required this.descriptionEn,
    required this.descriptionRu,
    required this.descriptionTk,
    required this.price,
    required this.imageUrl,
    required this.available,
  });

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

  // Get description based on language code
  String getDescription(String languageCode) {
    switch (languageCode) {
      case 'en':
        return descriptionEn;
      case 'ru':
        return descriptionRu;
      case 'tk':
        return descriptionTk;
      default:
        return descriptionEn;
    }
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      category: json['category'] as String,
      nameEn: json['nameEn'] as String,
      nameRu: json['nameRu'] as String,
      nameTk: json['nameTk'] as String,
      descriptionEn: json['descriptionEn'] as String,
      descriptionRu: json['descriptionRu'] as String,
      descriptionTk: json['descriptionTk'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      available: json['available'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'nameEn': nameEn,
      'nameRu': nameRu,
      'nameTk': nameTk,
      'descriptionEn': descriptionEn,
      'descriptionRu': descriptionRu,
      'descriptionTk': descriptionTk,
      'price': price,
      'imageUrl': imageUrl,
      'available': available,
    };
  }

  @override
  List<Object?> get props => [id, category, nameEn, nameRu, nameTk, descriptionEn, descriptionRu, descriptionTk, price, imageUrl, available];
}
