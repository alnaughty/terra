import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:terra/models/chat/chat_room.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/services/firebase/chat_service.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_model/chat_rooms_vm.dart';

class MyFCMService {
  MyFCMService._pr();
  static final ChatService chatRoomService = ChatService.instance;
  static final ChatRoomsVm _vm = ChatRoomsVm.instance;
  Future<void> listenMessages() async {
    chatRoomService.getUserChatrooms().listen((List<ChatRoom> rooms) {
      _vm.populate(rooms);
    });
  }

  final UserApi _api = UserApi();
  static final AppColors _colors = AppColors.instance;
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

  Future<void> showPopUp(BuildContext context,
      {required String title, required String message}) async {
    await showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (_, a1, a2, child) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;
        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
      barrierDismissible: false,
      barrierLabel: '',
      pageBuilder: (_, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  "assets/images/icon-logo.png",
                  width: 50,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                "This is an important notice, please DO NOT disregard this.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade900,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "This is regarding to your recent transaction that needs to be updated",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: _colors.top,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  color: _colors.top,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  height: 55,
                  child: const Center(
                    child: Text(
                      "Confirm",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
        // return Center(
        //   child: Container(
        //     decoration: BoxDecoration(
        //         color: Colors.white, borderRadius: BorderRadius.circular(10)),
        //     child: SingleChildScrollView(
        //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        //       child: Column(
        //         children: [
        //           Text(
        //             title,
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // );
      },
    );
  }

  void listen(BuildContext context) async {
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print("MESSAGE ${message.toMap()}");
        print("Message DATA: ${message.data}");

        if (message.notification == null) return;

        final String? image = Platform.isAndroid
            ? message.notification?.android?.imageUrl
            : Platform.isIOS || Platform.isMacOS
                ? message.notification?.apple?.imageUrl
                : null;
        if (message.data['type'] != null && message.data['type'] == "popup") {
          await showPopUp(
            context,
            title: "From ${message.notification!.title ?? "Anonymous"}",
            message: message.notification!.body ?? "",
          );
          return;
        }
        listenMessages();
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
                child: image == null
                    ? Image.asset(
                        "assets/images/icon-logo.png",
                        width: 45,
                      )
                    : CachedNetworkImage(
                        imageUrl: image,
                        width: 45,
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

      FirebaseMessaging.onMessageOpenedApp
          .listen((RemoteMessage message) async {
        print("MESSAGE ${message.toMap()}");
        print("Message DATA: ${message.data}");

        if (message.notification == null) return;

        final String? image = Platform.isAndroid
            ? message.notification?.android?.imageUrl
            : Platform.isIOS || Platform.isMacOS
                ? message.notification?.apple?.imageUrl
                : null;
        if (message.data['type'] != null && message.data['type'] == "popup") {
          await showPopUp(
            context,
            title: "From ${message.notification!.title ?? "Anonymous"}",
            message: "${message.notification!.body ?? ""} Transaction",
          );
          return;
        }
        listenMessages();
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
                child: image == null
                    ? Image.asset(
                        "assets/images/icon-logo.png",
                        width: 45,
                      )
                    : CachedNetworkImage(
                        imageUrl: image,
                        width: 45,
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
      await _fcm.getInitialMessage().then((message) async {
        if (message != null) {
          if (message.data['type'] != null && message.data['type'] == "popup") {
            await showPopUp(
              context,
              title: "From ${message.notification!.title ?? "Anonymous"}",
              message: "${message.notification!.body ?? ""} Transaction",
            );
            return;
          }
        }
      });
    } catch (e, s) {
      print("ERROR LISTENING : $e");
      print("TRACE : $s");
    }
  }

  Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage? message) async {
    print("BG MESSAGE ${message?.toMap()}");
    print("BG Message DATA: ${message?.data}");
    if (message == null) return;
    if (message.notification == null) return;

    // final String? image = message.notification?.android?.imageUrl;
    // if (message.data['type'] != null && message.data['type'] == "popup") {
    //   await showPopUp(
    //     context,
    //     title: "From ${message.notification!.title ?? "Anonymous"}",
    //     message: message.notification!.body ?? "",
    //   );
    //   return;
    // }
  }
}
