import 'package:flutter/material.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/routes.dart';
import 'package:terra/views/splash_screen.dart';

class TerraApp extends StatelessWidget {
  const TerraApp({super.key});
  static final AppColors _colors = AppColors.instance;
  static final RouteData _route = RouteData.instance;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Terra",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: _colors.top,
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith(
            (states) => _colors.top,
          ),
          side: BorderSide(
            color: _colors.top,
          ),
        ),
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.black54,
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor:
                MaterialStateProperty.resolveWith((states) => _colors.top),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: _colors.top,
            ),
          ),
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
      home: const SplashScreen(),
      onGenerateRoute: _route.settings,
    );
  }
}
