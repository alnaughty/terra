import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/services/firebase_messaging.dart';
import 'package:terra/terra.dart';

final DataCacher _cacher = DataCacher.instance;
final MyFCMService _fcm = MyFCMService.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // var port = ReceivePort();
  // IsolateNameServer.removePortNameMapping('port');
  // IsolateNameServer.registerPortWithName(port.sendPort, 'port');
  await dotenv.load();
  await _cacher.init();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(
    _fcm.firebaseMessagingBackgroundHandler,
  );
  runApp(const TerraApp());
}
