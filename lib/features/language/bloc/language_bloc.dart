import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class ChangeLanguage extends LanguageEvent {
  final Locale locale;

  const ChangeLanguage(this.locale);

  @override
  List<Object> get props => [locale];
}

class LoadSavedLanguage extends LanguageEvent {}

// State
class LanguageState extends Equatable {
  final Locale locale;

  const LanguageState(this.locale);

  @override
  List<Object> get props => [locale];
}

// Bloc
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  static const String _languageKey = 'selected_language';

  LanguageBloc() : super(const LanguageState(Locale('en'))) {
    on<LoadSavedLanguage>(_onLoadSavedLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  Future<void> _onLoadSavedLanguage(
    LoadSavedLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    if (languageCode != null) {
      emit(LanguageState(Locale(languageCode)));
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, event.locale.languageCode);
    emit(LanguageState(event.locale));
  }
}
