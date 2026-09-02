import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_strings.dart';

class CurrencyOption {
  final String code;
  final String symbol;
  final String name;
  final String flag;
  const CurrencyOption(this.code, this.symbol, this.name, this.flag);
}

class LanguageOption {
  final String code;
  final String name;
  final String flag;
  const LanguageOption(this.code, this.name, this.flag);
}

class AppSettingsProvider extends ChangeNotifier {
  static const List<CurrencyOption> currencies = [
    CurrencyOption('MXN', 'MX\$', 'Mexican Peso', '🇲🇽'),
    CurrencyOption('USD', '\$', 'US Dollar', '🇺🇸'),
    CurrencyOption('EUR', '€', 'Euro', '🇪🇺'),
    CurrencyOption('GBP', '£', 'British Pound', '🇬🇧'),
    CurrencyOption('PKR', 'Rs', 'Pakistani Rupee', '🇵🇰'),
    CurrencyOption('INR', '₹', 'Indian Rupee', '🇮🇳'),
    CurrencyOption('CAD', 'CA\$', 'Canadian Dollar', '🇨🇦'),
    CurrencyOption('AUD', 'A\$', 'Australian Dollar', '🇦🇺'),
    CurrencyOption('BRL', 'R\$', 'Brazilian Real', '🇧🇷'),
    CurrencyOption('JPY', '¥', 'Japanese Yen', '🇯🇵'),
    CurrencyOption('CNY', '¥', 'Chinese Yuan', '🇨🇳'),
    CurrencyOption('AED', 'د.إ', 'UAE Dirham', '🇦🇪'),
    CurrencyOption('SAR', '﷼', 'Saudi Riyal', '🇸🇦'),
    CurrencyOption('ZAR', 'R', 'South African Rand', '🇿🇦'),
    CurrencyOption('CHF', 'CHF', 'Swiss Franc', '🇨🇭'),
  ];

  static const List<LanguageOption> languages = [
    LanguageOption('es', 'Español', '🇪🇸'),
    LanguageOption('en', 'English', '🇺🇸'),
  ];

  String _currencyCode = 'MXN';
  String _languageCode = 'es';

  String get currencyCode => _currencyCode;
  CurrencyOption get currency => currencies.firstWhere(
    (c) => c.code == _currencyCode,
    orElse: () => currencies.first,
  );
  String get currencySymbol => currency.symbol;
  String get languageCode => _languageCode;
  LanguageOption get language => languages.firstWhere(
    (l) => l.code == _languageCode,
    orElse: () => languages.first,
  );

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _currencyCode = prefs.getString('currencyCode') ?? 'MXN';
    _languageCode = prefs.getString('languageCode') ?? 'es';
    AppStrings.currentLanguage = _languageCode;
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    _currencyCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencyCode', code);
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    AppStrings.currentLanguage = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', code);
  }
}
