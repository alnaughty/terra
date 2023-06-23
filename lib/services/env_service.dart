import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  EnvService._pr();
  static final EnvService _instance = EnvService._pr();
  static EnvService get instance => _instance;
  String get domain => dotenv.get("URL_DOMAIN");
  String get localDomain => dotenv.get("LOCAL_DOMAIN");
  // Future<void> init() async {
  //   await dotenv.load(fileName: ".env");
  // }
}
