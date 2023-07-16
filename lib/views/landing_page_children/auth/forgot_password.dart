import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/services/firebase_auth.dart';
import 'package:terra/utils/color.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _kEmailForm = GlobalKey<FormState>();
  final FirebaseAuthenticator _auth = FirebaseAuthenticator();
  late final TextEditingController _email;
  final AppColors _colors = AppColors.instance;
  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
  }

  bool _isLoading = false;
  bool showCheckYourEmail = false;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Positioned.fill(
            child: Scaffold(
              appBar: AppBar(
                title: Image.asset("assets/images/Terra-name.png", height: 40),
                centerTitle: true,
              ),
              body: SafeArea(
                top: false,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: showCheckYourEmail
                      ? Column(
                          children: [
                            const SizedBox(
                              height: 80,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    width: 130,
                                    height: 130,
                                    padding: const EdgeInsets.all(30),
                                    decoration: BoxDecoration(
                                      color: _colors.top.withOpacity(.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child:
                                        Image.asset("assets/icons/email.png"),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    "Check your mail",
                                    style: TextStyle(
                                      color: Colors.grey.shade900,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30),
                                    child: Text(
                                      "We have sent a password recovery instructions to your email.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(.5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth: (size.width - 60) * .5),
                                    child: MaterialButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      height: 55,
                                      color: _colors.top,
                                      child: const Center(
                                        child: Text("Return to Login",
                                            style: TextStyle(
                                              color: Colors.white,
                                            )),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(30),
                              child: Text.rich(
                                TextSpan(
                                    text:
                                        "Did not receive the email? Check your spam filter, or ",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black.withOpacity(.6),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "try another email adress",
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            setState(() {
                                              showCheckYourEmail = false;
                                            });
                                          },
                                        style: TextStyle(
                                          color: _colors.top,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                    ]),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          children: [
                            const Text(
                              "Reset password",
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Enter the email associated with your account and we'll send an email with instructions to reset your password.",
                              style: TextStyle(
                                color: Colors.black.withOpacity(.5),
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            Form(
                              key: _kEmailForm,
                              child: TextFormField(
                                // key: _kEmailForm,
                                onChanged: (text) {
                                  _kEmailForm.currentState!.validate();
                                },
                                validator: (text) {
                                  if (text == null) {
                                    return "Invalid type";
                                  } else if (text.isEmpty) {
                                    return "This field is required";
                                  } else if (!text.isValidEmail()) {
                                    return "Invalid email";
                                  }
                                },
                                decoration: const InputDecoration(
                                  hintText: "sample@email.com",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  label: Text(
                                    "Email",
                                  ),
                                ),
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            // Hero(tag: "logo", child: Image.asset("assets/images/Logo.png")),
                            const SizedBox(
                              height: 20,
                            ),
                            MaterialButton(
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                if (_kEmailForm.currentState!.validate()) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await _auth.sendForgotPassword(_email.text);
                                  _email.clear();
                                  setState(() {
                                    _isLoading = false;
                                    showCheckYourEmail = true;
                                  });
                                }
                              },
                              height: 60,
                              color: _colors.top,
                              child: const Center(
                                child: Text(
                                  "Send Instructions",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                ),
              ),
            ),
          ),
          if (_isLoading) ...{
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(.7),
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
}
