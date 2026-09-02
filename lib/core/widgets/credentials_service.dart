import 'package:shared_preferences/shared_preferences.dart';

class CredentialsService {
  CredentialsService._();

  static Future<void> save(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedEmail', email);
    await prefs.setString('savedPassword', password);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedEmail');
    await prefs.remove('savedPassword');
  }

  static Future<Map<String, String>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('savedEmail');
    final password = prefs.getString('savedPassword');
    if (email == null || password == null) return null;
    return {'email': email, 'password': password};
  }
}
