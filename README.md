# 🍽️ Restaurant Menu App

A modern and elegant restaurant menu management application. A professional mobile app built with Flutter, featuring multi-language support and advanced capabilities.

![Flutter](https://img.shields.io/badge/Flutter-3.7.2-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.7.2-0175C2?logo=dart)
![BLoC](https://img.shields.io/badge/State-BLoC-4285F4)

## 📱 About the Project

Restaurant Menu App is a modern digital menu application designed for restaurants. Users can browse the menu, add products to cart, and use the app in different languages. The app stands out with its luxury dark theme design and user-friendly interface.

### ✨ Key Features

- **📋 Menu Management**: Categorized product listing and detailed viewing
- **🛒 Cart System**: Add, remove products and order management
- **🌐 Multi-language Support**: English, Russian, and Turkmen language options
- **📊 Excel Integration**: Import/export menu data in Excel format
- **📸 Image Management**: Add and edit product images
- **💾 Data Persistence**: Store user preferences with SharedPreferences
- **📱 Sharing**: Share menu and product information
- **🎨 Luxury Theme**: Custom-designed dark theme with Gilroy font family
- **⚡ Performance**: Caching system and optimized image loading

## 🏗️ Architecture

The project is developed using **BLoC (Business Logic Component)** pattern following clean architecture principles.

```
lib/
├── core/
│   ├── localization/      # Multi-language support
│   └── theme/             # Theme and style definitions
├── features/
│   ├── cart/              # Cart module
│   │   ├── bloc/          # Cart state management
│   │   ├── models/        # Cart data models
│   │   ├── screens/       # Cart screens
│   │   ├── services/      # Cart services
│   │   └── widgets/       # Cart widgets
│   ├── menu/              # Menu module
│   │   ├── bloc/          # Menu state management
│   │   ├── models/        # Menu data models
│   │   ├── screens/       # Menu screens
│   │   ├── services/      # Menu services
│   │   └── widgets/       # Menu widgets
│   ├── language/          # Language selection module
│   │   └── bloc/          # Language state management
│   └── settings/          # Settings module
├── main.dart              # Application entry point
└── test_data_generator.dart  # Test data generator
```

## 🚀 Technologies Used

### State Management
- **flutter_bloc** (9.1.1): BLoC pattern implementation
- **equatable** (2.0.8): Value equality comparisons

### UI/UX
- **iconly** (1.0.1): Modern icons
- **hugeicons** (1.1.5): Extensive icon library
- **shimmer** (3.0.0): Loading animations
- **badges** (3.1.2): Notification badges
- **cached_network_image** (3.4.1): Optimized image loading

### File and Data Management
- **excel**: Manage menu data in Excel format
- **file_picker** (8.1.6): File selection
- **path_provider** (2.1.2): File path management
- **shared_preferences** (2.5.3): Local data storage

### Image Processing
- **image_picker** (1.0.7): Camera and gallery access
- **flutter_image_compress** (2.4.0): Image compression

### Other
- **share_plus** (10.1.2): Content sharing
- **permission_handler** (11.3.1): Permission management
- **intl** (0.20.2): Internationalization

## 📦 Installation

### Requirements
- Flutter SDK (3.7.2 or higher)
- Dart SDK (3.7.2 or higher)
- Android Studio / VS Code
- For iOS: Xcode (macOS)
- For Android: Android SDK

### Steps

1. **Clone the repository:**
```bash
git clone <repository-url>
cd restaurant_menu
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Generate localization files:**
```bash
flutter gen-l10n
```

4. **Run the application:**
```bash
flutter run
```

### Platform-Specific Installation

#### Android
```bash
flutter run -d android
```

#### iOS
```bash
flutter run -d ios
```

## 🎨 Customization

### Theme Changes
You can edit theme settings from [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) file.

### Adding Languages
1. Add a new language file to `lib/core/localization/` folder
2. Add the new language to the `supportedLocales` list in `main.dart`
3. Run `flutter gen-l10n` command

### Changing Fonts
You can add custom fonts by modifying the font definitions in the `pubspec.yaml` file.

## 🧪 Testing

```bash
# Run all tests
flutter test

# View test coverage
flutter test --coverage
```

## 📱 Screenshots

*(Screenshots can be added)*

## 🔒 Permissions

### Android
- `READ_EXTERNAL_STORAGE`: Photo selection
- `WRITE_EXTERNAL_STORAGE`: File saving
- `CAMERA`: Camera access

### iOS
- `NSPhotoLibraryUsageDescription`: Photo library access
- `NSCameraUsageDescription`: Camera access

## 🤝 Contributing

1. Fork the project
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Create a Pull Request

## 📄 License

This is a private project.

## 👨‍💻 Developer

Feel free to contact for any questions.

## 📝 Notes

- This project is developed with the latest stable version of Flutter
- State management is provided using the BLoC pattern
- ARB files are used for multi-language support
- The Excel package is kept separately in the `packages/` folder

---

**⭐ Don't forget to star the project if you like it!**
