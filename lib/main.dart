import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/terra.dart';

final DataCacher _cacher = DataCacher.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await _cacher.init();
  await Firebase.initializeApp();
  runApp(const TerraApp());
}
