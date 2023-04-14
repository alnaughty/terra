import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/landing_page_children/auth/forgot_password.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final AppColors _colors = AppColors.instance;
  final UserApi _api = UserApi();
  bool _hasSent = false;
  late final TextEditingController _code;
  @override
  void initState() {
    // TODO: implement initState
    _code = TextEditingController();
    super.initState();

    initPlatformState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _code.dispose();
    super.dispose();
  }

  initPlatformState() async {
    setState(() {
      _hasSent = false;
      _isLoading = true;
    });
    await _api.validateEmail().whenComplete(() {
      setState(() {
        _hasSent = true;
        _isLoading = false;
      });
    });
  }

  bool _isLoading = false;
  final GlobalKey<FormState> _kCodeForm = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Positioned.fill(
            child: Scaffold(
              backgroundColor: Colors.grey.shade200,
              appBar: AppBar(
                title: const Text("Verify Email"),
                centerTitle: true,
                backgroundColor: Colors.white,
                // actions: [
                //   IconButton(
                //     onPressed: () async {
                //       await Navigator.push(
                //         context,
                //         PageTransition(
                //           child: const ForgotPasswordPage(),
                //           type: PageTransitionType.rightToLeft,
                //         ),
                //       );
                //     },
                //     icon: Icon(
                //       Icons.password_outlined,
                //     ),
                //   )
                // ],
              ),
              body: SafeArea(
                top: false,
                child: Container(
                  width: double.maxFinite,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            // gradient: LinearGradient(
                            //   colors: [
                            //     // Colors.white,
                            //     _colors.top,
                            //     _colors.bot,
                            //     // _colors.top,
                            //   ],
                            // ),
                            color: _colors.top.withOpacity(.2),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.black.withOpacity(.3),
                            //     offset: const Offset(2, 2),
                            //     blurRadius: 2,
                            //   )
                            // ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(150),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  bottom: -20,
                                  child: Image.asset(
                                    "assets/images/safe-mail.png",
                                    height: 130,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Verify Your Email",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            text:
                                "A 7 character code ${_hasSent ? "has been" : "will be"} sent to ",
                            style: TextStyle(
                              color: Colors.black.withOpacity(.5),
                            ),
                            children: [
                              TextSpan(
                                text: loggedUser!.email,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: " Resend Code ",
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    initPlatformState();
                                  },
                                style: TextStyle(
                                  color: _colors.top,
                                  decoration: TextDecoration.underline,
                                  decorationColor: _colors.top,
                                ),
                              )
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Form(
                          key: _kCodeForm,
                          child: TextFormField(
                            // key: _kEmailForm,
                            onChanged: (text) {
                              _kCodeForm.currentState!.validate();
                            },
                            validator: (text) {
                              if (text == null) {
                                return "Invalid type";
                              } else if (text.isEmpty) {
                                return "This field is required";
                              } else if (text.length < 7 || text.length > 7) {
                                return "Code only contains 7 characters";
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: "1234567",
                              hintStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              label: Text(
                                "Verification Code",
                              ),
                            ),
                            controller: _code,
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "- Code will expire in an hour.",
                                style: TextStyle(
                                  color: Colors.black.withOpacity(.5),
                                ),
                              ),
                              Text(
                                "- Didn't receive a code? Check your spam section, if no email received click `Resend Code`",
                                style: TextStyle(
                                  color: Colors.black.withOpacity(.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _colors.bot,
                                _colors.top,
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                            // color: _colors.bot,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: MaterialButton(
                            height: 60,
                            onPressed: () async {
                              if (_kCodeForm.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                await _api
                                    .verifyEmailCode(_code.text)
                                    .then((v) {
                                  setState(() {
                                    loggedUser!.hasVerifiedEmail = v;
                                    _isLoading = false;
                                  });
                                  Navigator.of(context).pop();
                                });
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.verified,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Verify",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
          }
        ],
      ),
    );
  }
}
