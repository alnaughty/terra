import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:terra/utils/global.dart';

class MyFCMService {
  MyFCMService._pr();
  static final MyFCMService _instance = MyFCMService._pr();
  static MyFCMService get instance => _instance;
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  Future<String?> get token async => await _fcm.getToken();
  void init() async {
    try {
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _fcm.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );
      fcmToken = await token;
      // print(await token);
      listen();
    } catch (e) {
      return;
    }
  }

  void listen() async {
    print("LISTENING");
    await _fcm.getInitialMessage().then((RemoteMessage? message) {
      print("INITIAL MESSAGE! : ${message?.toMap()}");
      if (message != null) {}
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("${message.toMap()}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });
  }
}
