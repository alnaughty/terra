import 'package:flutter/material.dart';
import 'package:terra/helpers/custom_scrollable_stepper.dart';
import 'package:terra/views/landing_page_children/check_page_children/go_to_verify_email.dart';
import 'package:terra/views/landing_page_children/check_page_children/selfie_page_kyc.dart';
import 'package:terra/views/landing_page_children/check_page_children/upload_id_page.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  final GlobalKey<CustomScrollableStepperState> _kStepperState =
      GlobalKey<CustomScrollableStepperState>();
  // final DataCacher _cacher = DataCacher.instance;
  IDCardCallback? idcard;
  String? selfie;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 30),
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Know Your Customer (KYC)",
                    style: TextStyle(
                      color: Color(0xFF4A4A4A),
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    "Before you can use our application, we would like to get to know you more.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF4A4A4A).withOpacity(.5),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Image.asset(
                    "assets/images/Logo.png",
                    height: 150,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "We conduct KYC to ensure user safety and compliance with our terms of use.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            CustomScrollableStepper(
              key: _kStepperState,
              steps: steps,
              // uploadCallback: (b) {
              //   // _kState.currentState!.
              // },
            ),
          ],
        ),
      ),
    );
  }

  late final List<ScrollableStep> steps = [
    ScrollableStep(
      subtitle: const Text(
        "Note: Before you can use our app, the KYC team needs to validate this ID.",
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      title: const Text(
        "Identification Card",
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w500,
        ),
      ),
      content: UploadIdPage(
        callback: (IDCardCallback callback) {
          _kStepperState.currentState!.validate(0);
          setState(() {
            idcard = callback;
          });
        },
      ),
    ),
    ScrollableStep(
      subtitle: const Text(
        "Note: Before you can use our app, the KYC team needs to validate your selfie.",
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      title: const Text(
        "Selfie",
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      content: SelfieKYCPage(
        imageCallback: (String f) {
          selfie = f;
          _kStepperState.currentState!.validate(1);
          if (mounted) setState(() {});
        },
      ),
    ),
    ScrollableStep(
      subtitle: const Text(
        "Note: Before you can use our app, the KYC team needs to validate your email.",
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      title: const Text(
        "Email Verification",
        style: TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      content: GoToVerifyEmailPage(
        callback: () {
          // _cacher.seUserToken();
        },
      ),
    ),
  ];
}
