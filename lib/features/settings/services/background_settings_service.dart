import 'package:shared_preferences/shared_preferences.dart';

enum BackgroundType { none, color, image }

class BackgroundSettings {
  final BackgroundType type;
  final int? colorValue; // Color.value int
  final String? imagePath;

  const BackgroundSettings({this.type = BackgroundType.none, this.colorValue, this.imagePath});
}

class BackgroundSettingsService {
  static const _keyType = 'bg_type';
  static const _keyColor = 'bg_color';
  static const _keyImage = 'bg_image';

  Future<BackgroundSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final typeStr = prefs.getString(_keyType) ?? 'none';
    final type = BackgroundType.values.firstWhere((e) => e.name == typeStr, orElse: () => BackgroundType.none);
    return BackgroundSettings(
      type: type,
      colorValue: prefs.getInt(_keyColor),
      imagePath: prefs.getString(_keyImage),
    );
  }

  Future<void> saveColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyType, BackgroundType.color.name);
    await prefs.setInt(_keyColor, colorValue);
    await prefs.remove(_keyImage);
  }

  Future<void> saveImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyType, BackgroundType.image.name);
    await prefs.setString(_keyImage, imagePath);
    await prefs.remove(_keyColor);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyType, BackgroundType.none.name);
    await prefs.remove(_keyColor);
    await prefs.remove(_keyImage);
  }
}
