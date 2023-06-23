import 'package:shared_preferences/shared_preferences.dart';
import 'package:terra/services/facebook_auth_service.dart';
import 'package:terra/services/google_auth_service.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_data_component/user_position.dart';
import 'package:terra/view_model/applications.dart';
import 'package:terra/view_model/categories_vm.dart';
import 'package:terra/view_model/chat_rooms_vm.dart';
import 'package:terra/view_model/posted_jobs.dart';
import 'package:terra/view_model/tasks_vm.dart';
import 'package:terra/view_model/todo_vm.dart';

class DataCacher {
  DataCacher._pr();
  static final DataCacher _instance = DataCacher._pr();
  static DataCacher get instance => _instance;

  late final SharedPreferences _prefs;
  static final UserPosition _pos = UserPosition.instance;
  static final ApplicationsVm _appliVm = ApplicationsVm.instance;
  static final CategoriesVm _catVm = CategoriesVm.instance;
  static final ChatRoomsVm _chatrooms = ChatRoomsVm.instance;
  static final TasksVm _taskVm = TasksVm.instance;
  static final PostedJobsVm _postedVm = PostedJobsVm.instance;
  static final TaskTodoVm _todoVm = TaskTodoVm.instance;
  static final FacebookAuthService _fbAuth = FacebookAuthService.instance;
  static final GoogleAuthService _gAuth = GoogleAuthService.instance;
  Future<void> clearAll() async {
    await removeFcmToken();
    await removeToken();
    _pos.dispose();
    _appliVm.dispose();
    _catVm.dispose();
    _chatrooms.dispose();
    _taskVm.dispose();
    _postedVm.dispose();
    _todoVm.dispose();
    loggedUser = null;
    accessToken = null;
    int? signInType = getSignInMethod();
    if (signInType == null || signInType == 0) {
      return;
    } else if (signInType == 1) {
      await _gAuth.signOut();
    } else if (signInType == 2) {
      await _fbAuth.signOut();
    }
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  //*
  //0 = credentials
  //1 = google
  //2 = fb
  //*/
  Future<void> signInMethod(int i) async => await _prefs.setInt(
        "sign-in-method",
        i,
      );
  int? getSignInMethod() => _prefs.getInt("sign-in-method");

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
