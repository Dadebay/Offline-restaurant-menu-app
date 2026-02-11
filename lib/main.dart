import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant_menu_app/core/theme/app_theme.dart';
import 'package:restaurant_menu_app/features/cart/bloc/cart_bloc.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_bloc.dart';
import 'package:restaurant_menu_app/features/menu/bloc/menu_event.dart';
import 'package:restaurant_menu_app/features/menu/screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:restaurant_menu_app/core/localization/app_localizations.dart';
import 'package:restaurant_menu_app/features/language/bloc/language_bloc.dart';

void main() {
  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MenuBloc()..add(LoadMenu())),
        BlocProvider(create: (_) => CartBloc()),
        BlocProvider(create: (_) => LanguageBloc()..add(LoadSavedLanguage())),
      ],
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, languageState) {
          return MaterialApp(
            title: 'Restaurant Menu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.luxuryDarkTheme,
            themeMode: ThemeMode.dark,
            locale: languageState.locale,
            supportedLocales: const [
              Locale('en', ''),
              Locale('ru', ''),
              Locale('tk', ''),
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              const TkMaterialLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
