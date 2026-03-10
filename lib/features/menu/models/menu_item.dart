import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final String id;
  final String category;
  final String nameRu;
  final String nameTk;
  final double price;
  final String imageUrl;
  final bool available;

  const MenuItem({
    required this.id,
    required this.category,
    required this.nameRu,
    required this.nameTk,
    required this.price,
    required this.imageUrl,
    required this.available,
  });

  String getName(String languageCode) {
    switch (languageCode) {
      case 'tk':
        return nameTk;
      case 'ru':
      default:
        return nameRu;
    }
  }

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final ru = (json['nameRu'] ?? json['nameEn'] ?? '').toString();
    final tk = (json['nameTk'] ?? '').toString();

    return MenuItem(
      id: (json['id'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      nameRu: ru,
      nameTk: tk,
      price: (json['price'] as num).toDouble(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      available: json['available'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'nameRu': nameRu,
      'nameTk': nameTk,
      'price': price,
      'imageUrl': imageUrl,
      'available': available,
    };
  }

  @override
  List<Object?> get props => [id, category, nameRu, nameTk, price, imageUrl, available];
}
