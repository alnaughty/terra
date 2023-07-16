import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/utils/global.dart';

class MyFCMService {
  MyFCMService._pr();
  final UserApi _api = UserApi();
  static final MyFCMService _instance = MyFCMService._pr();
  static MyFCMService get instance => _instance;
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  Future<String?> get token async => await _fcm.getToken();
  void init(BuildContext context) async {
    try {
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _fcm
          .requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      )
          .then((NotificationSettings status) async {
        if (status.authorizationStatus == AuthorizationStatus.authorized ||
            status.authorizationStatus == AuthorizationStatus.provisional) {
          fcmToken = await token;
          if (fcmToken != null) {
            await _api.saveFcm(fcmToken!);
            print("FCM TOKEN : $fcmToken ");
          }
          // print(await token);
          listen(context);
        }
      });
    } catch (e) {
      return;
    }
  }

  void listen(BuildContext context) async {
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("MESSAGE ${message.toMap()}");

        if (message.notification == null) return;
        InAppNotification.show(
          context: context,
          duration: const Duration(seconds: 5),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              tileColor: Colors.grey.shade100,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/images/icon-logo.png",
                ),
              ),
              title: Text(
                message.notification!.title ?? "Anonymous",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                message.notification!.body ?? "",
                style: TextStyle(
                  color: Colors.black.withOpacity(.5),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
        if (message.notification == null) return;
        InAppNotification.show(
          context: context,
          duration: const Duration(seconds: 5),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              tileColor: Colors.grey.shade100,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/images/icon-logo.png",
                ),
              ),
              title: Text(
                message.notification!.title ?? "Anonymous",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                message.notification!.body ?? "",
                style: TextStyle(
                  color: Colors.black.withOpacity(.5),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      });
      print("LISTENING");
    } catch (e, s) {
      print("ERROR LISTENING : $e");
      print("TRACE : $s");
    }
  }
}
