import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant_menu_app/features/settings/services/background_settings_service.dart';

class BackgroundCubit extends Cubit<BackgroundSettings> {
  final BackgroundSettingsService _service;

  BackgroundCubit(this._service) : super(const BackgroundSettings());

  Future<void> load() async {
    final settings = await _service.load();
    emit(settings);
  }

  Future<void> setColor(int colorValue) async {
    await _service.saveColor(colorValue);
    emit(BackgroundSettings(type: BackgroundType.color, colorValue: colorValue));
  }

  Future<void> setImage(String imagePath) async {
    await _service.saveImage(imagePath);
    emit(BackgroundSettings(type: BackgroundType.image, imagePath: imagePath));
  }

  Future<void> clear() async {
    await _service.clear();
    emit(const BackgroundSettings());
  }
}
