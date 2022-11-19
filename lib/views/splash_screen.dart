import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/view_data_component/splash_screen_dc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SplashScreenDc {
  void initPlatform() async {
    await hasString().then((value) async {
      if (value) {
        ///GO TO HOME PAGE
        print("GO TO GHOME");
      } else {
        /// GO TO LANDING PAGE
        await Future.delayed(const Duration(milliseconds: 1500));
        print("GO TO LANDING");
        await Navigator.pushReplacementNamed(context, "/landing_page");
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    initPlatform();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // gradient: _color.gradient,
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(tag: "logo", child: Image.asset("assets/images/Logo.png")),
            const SizedBox(
              height: 10,
            ),
            LoadingAnimationWidget.staggeredDotsWave(
              color: color.top,
              size: 40,
            )
          ],
        ),
      ),
    );
  }
}
