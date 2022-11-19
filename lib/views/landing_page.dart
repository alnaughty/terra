import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/views/landing_page_children/auth/login_page.dart';
import 'package:terra/views/landing_page_children/tutorial_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final DataCacher _cacher = DataCacher.instance;
  @override
  void initState() {
    // TODO: implement initState
    // _cacher.resetOld();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _cacher.initApp()
            ? TutorialPage(
                onPressed: () async {
                  await _cacher.setToOld();
                  setState(() {});
                },
              )
            : const LoginPage(),
      ),
    );
  }
}
