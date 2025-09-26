import 'package:flutter_app_itse500/core/utils/unified_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  var logger = UnifiedLogger.instance;
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> saveString(String key, String value) async {
    final p = await prefs;
    await p.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final p = await prefs;
    return p.getString(key);
  }

  Future<void> saveInt(String key, int value) async {
    final p = await prefs;
    await p.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    final p = await prefs;
    return p.getInt(key);
  }

  Future<void> saveBool(String key, bool value) async {
    final p = await prefs;
    await p.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final p = await prefs;
    return p.getBool(key);
  }

  Future<void> saveDouble(String key, double value) async {
    final p = await prefs;
    await p.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    final p = await prefs;
    return p.getDouble(key);
  }

  Future<void> saveStringList(String key, List<String> value) async {
    final p = await prefs;
    await p.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    final p = await prefs;
    return p.getStringList(key);
  }

  Future<void> remove(String key) async {
    final p = await prefs;
    await p.remove(key);
  }

  Future<bool> containsKey(String key) async {
    final p = await prefs;
    return p.containsKey(key);
  }

  Future<void> clear() async {
    final p = await prefs;
    await p.clear();
  }

  Future<void> _checkKey() async {
    final prefs = await SharedPreferences.getInstance();
    final bool containsCounter = prefs.containsKey('counter');
    print('Contains counter: $containsCounter');
  }

  Future<void> _removeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('counter');
  }

  Future<void> _clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _readData() async {
    final prefs = await SharedPreferences.getInstance();
    final int? counter = prefs.getInt('counter');
    final String? username = prefs.getString('username');
    final bool? isLoggedIn = prefs.getBool('isLoggedIn');

    logger.i('Counter: $counter');
    logger.i('Username: $username');
    logger.i('Is Logged In: $isLoggedIn');
  }
}
