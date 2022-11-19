import 'package:flutter/material.dart';

class AppColors {
  AppColors._p();
  static final AppColors _instance = AppColors._p();
  static AppColors get instance => _instance;

  Color top = Color(0xff15c4ff);
  Color mid = Color(0xff58baff);
  Color bot = Color(0xff8168fe);

  LinearGradient get gradient => LinearGradient(
        colors: [top, mid, bot],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
}
