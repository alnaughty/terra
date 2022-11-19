import 'package:terra/services/data_cacher.dart';
import 'package:terra/utils/app.dart';
import 'package:terra/utils/color.dart';

class SplashScreenDc {
  final DataCacher _cacher = DataCacher.instance;
  final AppColors color = AppColors.instance;

  Future<bool> hasString() async {
    userToken = _cacher.getUserToken();
    return userToken != null;
  }
}
