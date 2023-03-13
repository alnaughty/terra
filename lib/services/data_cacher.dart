import 'package:shared_preferences/shared_preferences.dart';

class DataCacher {
  DataCacher._pr();
  static final DataCacher _instance = DataCacher._pr();
  static DataCacher get instance => _instance;

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveFcmToken(String tok) async {
    await _prefs.setString("fcm-token", tok);
  }

  Future<void> removeFcmToken() async => await _prefs.remove('fcm-token');
  String? getFcmToken() => _prefs.getString('fcm-token');
  bool initApp() => _prefs.getBool("initial") ?? true;
  Future<void> setToOld() async {
    await _prefs.setBool("initial", false);
  }

  Future<void> resetOld() async {
    await _prefs.setBool("initial", true);
  }

  String? getUserToken() => _prefs.getString("access-token");
  Future<void> seUserToken(String token) async {
    await _prefs.setString("access-token", token);
  }

  Future<void> removeToken() async => await _prefs.remove("access-token");
}
