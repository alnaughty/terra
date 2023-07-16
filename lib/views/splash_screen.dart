import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_data_component/splash_screen_dc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SplashScreenDc {
  final DataCacher _cacher = DataCacher.instance;
  final UserApi _api = UserApi();
  void initPlatform() async {
    await hasString().then((value) async {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (value) {
        setState(() {
          accessToken = _cacher.getUserToken();
        });
        await _api.details().then((value) {
          setState(() {
            loggedUser = value;
          });
        });
        print("EMAIL : ${loggedUser?.email}");

        ///GO TO HOME PAGE
        print("GO TO GHOME");
        // ignore: use_build_context_synchronously
        await Navigator.pushReplacementNamed(context, "/check_page");
      } else {
        /// GO TO LANDING PAGE

        print("GO TO LANDING");
        // ignore: use_build_context_synchronously
        await Navigator.pushReplacementNamed(context, "/login_page");
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
            Hero(
              tag: "logo",
              child: Image.asset(
                "assets/images/Logo.png",
              ),
            ),
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
