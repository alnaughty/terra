import 'package:flutter/material.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/terra.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final DataCacher _cacher = DataCacher.instance;
  await _cacher.init();
  runApp(const TerraApp());
}
