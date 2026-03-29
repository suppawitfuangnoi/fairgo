import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_translations.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'locale';
  Locale _locale = const Locale('th'); // Default: Thai

  LocaleProvider() {
    _loadSaved();
  }

  Locale get locale => _locale;

  /// The current translations object. Use `context.watch<LocaleProvider>().t`
  AppTranslations get t => AppTranslations.fromLocale(_locale);

  bool get isThai => _locale.languageCode == 'th';

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    _save();
    notifyListeners();
  }

  void toggleLocale() {
    setLocale(isThai ? const Locale('en') : const Locale('th'));
  }

  Future<void> _loadSaved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key);
      if (code != null) {
        _locale = Locale(code);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, _locale.languageCode);
    } catch (_) {}
  }
}
