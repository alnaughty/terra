// ignore_for_file: use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/helpers/custom_scrollable_stepper.dart';
import 'package:terra/models/v2/kyc_status.dart';
import 'package:terra/services/API/v2/kyc.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/landing_page_children/check_page_children/go_to_verify_email.dart';
import 'package:terra/views/landing_page_children/check_page_children/selfie_page_kyc.dart';
import 'package:terra/views/landing_page_children/check_page_children/upload_id_page.dart';

import '../home_page_children/profile_page_children/verify_email_page.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  static final AppColors _colors = AppColors.instance;
  final GlobalKey<CustomScrollableStepperState> _kStepperState =
      GlobalKey<CustomScrollableStepperState>();
  final GlobalKey<UploadIdPageState> _kUploadPage =
      GlobalKey<UploadIdPageState>();
  // final DataCacher _cacher = DataCacher.instance;
  FullIDCallback? idcard;
  String? selfie;
  bool _isLoading = false;
  KYCStatus? status;
  bool _isCheckingKYCStatus = true;
  final KYC _kycApi = KYC();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      status = await _kycApi.getKYCStatus();
      _isCheckingKYCStatus = false;
      if (status != null && status!.status == 1) {
        if (loggedUser!.hasVerifiedEmail) {
          await Navigator.pushReplacementNamed(context, "/landing_page");
          return;
        } else {
          await Navigator.pushReplacement(
            context,
            PageTransition(
              child: const VerifyEmailPage(
                reload: true,
              ),
              type: PageTransitionType.rightToLeft,
            ),
          );
        }

        // return;
      }
      if (mounted) setState(() {});
      // if (status != null && status!.status == 0) {
      //   await Future.delayed(const Duration(milliseconds: 1500));
      //   _kUploadPage.currentState!.disable();
      // }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> upload() async {
    if (selfie != null && idcard != null) {
      setState(() {
        _isLoading = true;
      });
      await _kycApi
          .uploadKYC(
        type: idcard!.type,
        idBack: idcard!.back,
        idFront: idcard!.front,
        selfie: selfie!,
      )
          .whenComplete(() {
        _isLoading = false;
        if (mounted) setState(() {});
      });
      _kStepperState.currentState!.validate(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: Stack(
        children: [
          Positioned.fill(
            child: Scaffold(
              backgroundColor: const Color(0xFFEEEEEE),
              body: SafeArea(
                child: _isCheckingKYCStatus
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                              "Checking KYC Status...",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF4A4A4A).withOpacity(.5),
                              ),
                            ),
                            Center(
                              child: Image.asset("assets/images/loader.gif"),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 30),
                        children: [
                          if (status != null && status!.status == 2) ...{
                            Container(
                              color: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Column(
                                children: [
                                  const Text(
                                    "We regret to inform you that your Know Your Customer (KYC) verification has been declined. We kindly request you to upload a higher quality image or provide an alternate document for the verification process.",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (status!.reason != null) ...{
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      status!.reason!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  },
                                ],
                              ),
                            ),
                          } else if (status != null && status!.status == 1) ...{
                            Container(
                              color: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: const Text(
                                "We are pleased to inform you that your Know Your Customer (KYC) verification has been successfully accepted.",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          },
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
                                    color:
                                        const Color(0xFF4A4A4A).withOpacity(.5),
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
                          if (status == null) ...{
                            CustomScrollableStepper(
                              key: _kStepperState,
                              steps: steps,
                              // uploadCallback: (b) {
                              //   // _kState.currentState!.
                              // },
                            ),
                          } else ...{
                            if (status!.status == 0) ...{
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Dear ${loggedUser!.fullName.capitalizeWords()},",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    const Text(
                                      "We appreciate your cooperation in submitting your KYC information. Please be informed that your verification is currently underway and will be completed within the next 24 hours. We kindly request your patience during this process, and we will promptly notify you of the outcome.",
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    const Text(
                                      "Thank you for your understanding.",
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    const Text("Yours sincerely,"),
                                    const Text(
                                      "Terra Team",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text.rich(
                                      TextSpan(
                                          text:
                                              "Do you wanna check if your account is verified by now? ",
                                          style: TextStyle(
                                            color: Colors.black.withOpacity(.5),
                                            fontSize: 12,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: "Restart",
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () async {
                                                  await Navigator
                                                      .pushReplacementNamed(
                                                    context,
                                                    "/",
                                                  );
                                                },
                                              style: TextStyle(
                                                color: _colors.top,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            )
                                          ]),
                                    ),
                                    // Text(
                                    //   "Do you wanna check if your account have been verified?",

                                    // ),
                                    // MaterialButton(
                                    //   onPressed: () async {
                                    // await Navigator.pushReplacementNamed(
                                    //   context,
                                    //   "/",
                                    // );
                                    //   },
                                    //   color: _colors.top,
                                    //   disabledColor: Colors.grey,
                                    //   height: 60,
                                    //   child: const Center(
                                    //     child: Text(
                                    //       "Restart",
                                    //       style: TextStyle(
                                    //         color: Colors.white,
                                    //         fontSize: 16,
                                    //         fontWeight: FontWeight.w500,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              )
                            } else ...{
                              CustomScrollableStepper(
                                key: _kStepperState,
                                steps: steps,
                                // uploadCallback: (b) {
                                //   // _kState.currentState!.
                                // },
                              ),
                            }
                          }
                        ],
                      ),
              ),
            ),
          ),
          if (_isLoading) ...{
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(.5),
                child: Center(
                  child: Image.asset("assets/images/loader.gif"),
                ),
              ),
            )
          },
        ],
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
        key: _kUploadPage,
        callback: (FullIDCallback callback) async {
          _kStepperState.currentState!.validate(0);
          idcard = callback;
          if (mounted) setState(() {});
          await upload();
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
        imageCallback: (String f) async {
          selfie = f;
          if (mounted) setState(() {});
          await upload();
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
        callback: () async {
          // _cacher.seUserToken();
        },
      ),
    ),
  ];
}
