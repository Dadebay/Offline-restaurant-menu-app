import 'package:restaurant_menu_app/features/settings/services/category_service.dart';
import 'package:restaurant_menu_app/features/menu/services/excel_service.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';

Future<void> generateTestData() async {
  final categoryService = CategoryService();
  final excelService = ExcelService();

  print('🔄 Generating test data...');

  // Create 10 test categories
  final categories = [
    {'en': 'Appetizers', 'ru': 'Закуски', 'tk': 'Täze tagamlar'},
    {'en': 'Soups', 'ru': 'Супы', 'tk': 'Çorbalar'},
    {'en': 'Salads', 'ru': 'Салаты', 'tk': 'Salatlar'},
    {'en': 'Main Dishes', 'ru': 'Основные блюда', 'tk': 'Esasy tagamlar'},
    {'en': 'Grilled', 'ru': 'Гриль', 'tk': 'Kebaplar'},
    {'en': 'Desserts', 'ru': 'Десерты', 'tk': 'Süýji tagamlar'},
    {'en': 'Beverages', 'ru': 'Напитки', 'tk': 'Içgiler'},
    {'en': 'Pizza', 'ru': 'Пицца', 'tk': 'Pitsa'},
    {'en': 'Pasta', 'ru': 'Паста', 'tk': 'Makaron'},
    {'en': 'Sea Food', 'ru': 'Морепродукты', 'tk': 'Deňiz önümleri'},
  ];

  print('📝 Creating categories...');
  for (var cat in categories) {
    await categoryService.addCategory(nameEn: cat['en']!, nameRu: cat['ru']!, nameTk: cat['tk']!);
    print('✅ Created category: ${cat['en']}');
  }

  print('\n📝 Creating products...');
  int productCount = 0;

  // For each category, create 10 products
  for (var i = 0; i < categories.length; i++) {
    final categoryName = categories[i]['en']!;

    for (var j = 1; j <= 10; j++) {
      final item = MenuItem(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + i.toString() + '_' + j.toString(),
        category: categoryName,
        nameEn: '$categoryName Item $j',
        nameRu: '${categories[i]['ru']} Блюдо $j',
        nameTk: '${categories[i]['tk']} $j',
        descriptionEn: 'Delicious $categoryName item number $j with amazing taste',
        descriptionRu: 'Вкусное блюдо ${categories[i]['ru']} номер $j с потрясающим вкусом',
        descriptionTk: '${categories[i]['tk']} tagamy $j ajaýyp tagamly',
        price: (15 + (i * 5) + j).toDouble(),
        imageUrl: '', // Empty as requested
        available: true,
      );

      await excelService.addMenuItem(item);
      productCount++;
    }
    print('✅ Created 10 products for: $categoryName');
  }

  print('\n🎉 Test data generation complete!');
  print('📊 Total: ${categories.length} categories, $productCount products');
}
