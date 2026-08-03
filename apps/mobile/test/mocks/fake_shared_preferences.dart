import 'package:shared_preferences/shared_preferences.dart';

class FakeSharedPreferences implements SharedPreferences {
  final Map<String, String> _strings = {};

  @override
  String? getString(String key) => _strings[key];

  @override
  Future<bool> setString(String key, String value) async {
    _strings[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _strings.remove(key);
    return true;
  }

  @override
  bool getBool(String key) => false;

  @override
  Future<bool> setBool(String key, bool value) async => true;

  @override
  int getInt(String key) => 0;

  @override
  Future<bool> setInt(String key, int value) async => true;

  @override
  double getDouble(String key) => 0.0;

  @override
  Future<bool> setDouble(String key, double value) async => true;

  @override
  List<String> getStringList(String key) => [];

  @override
  Future<bool> setStringList(String key, List<String> value) async => true;

  @override
  Set<String> getKeys() => _strings.keys.toSet();

  @override
  Future<bool> commit() async => true;

  @override
  Future<bool> clear() async {
    _strings.clear();
    return true;
  }

  @override
  bool containsKey(String key) => _strings.containsKey(key);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
