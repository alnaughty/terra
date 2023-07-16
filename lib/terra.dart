import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/routes.dart';
import 'package:terra/views/splash_screen.dart';

class TerraApp extends StatelessWidget {
  const TerraApp({super.key});
  static final AppColors _colors = AppColors.instance;
  static final RouteData _route = RouteData.instance;
  @override
  Widget build(BuildContext context) {
    return InAppNotification(
      child: MaterialApp(
        title: "Terra",
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: "Poppins",
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
          inputDecorationTheme: const InputDecorationTheme(
            // border: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(10),
            // ),
            border: InputBorder.none,
            // focusedBorder: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(10),
            //   borderSide: BorderSide(
            //     color: _colors.top,
            //   ),
            // ),
            focusedBorder: InputBorder.none,
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            labelStyle: TextStyle(
              color: Color(0xFFB5AEAE),
            ),
          ),
        ),
        home: const SplashScreen(),
        onGenerateRoute: _route.settings,
      ),
    );
  }
}
