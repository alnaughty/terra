import 'package:terra/services/env_service.dart';

class Network {
  static final EnvService _env = EnvService.instance;
  static final domain = _env.domain;
}
