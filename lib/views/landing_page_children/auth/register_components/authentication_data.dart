import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/services/url_launcher.dart';
import 'package:terra/utils/color.dart';

class AuthenticationData extends StatefulWidget {
  const AuthenticationData(
      {super.key,
      required this.email,
      required this.password,
      required this.hasAcceptedCallback,
      required this.confirmPassword});
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController confirmPassword;
  final ValueChanged<bool> hasAcceptedCallback;

  @override
  State<AuthenticationData> createState() => AuthenticationDataState();
}

class AuthenticationDataState extends State<AuthenticationData> {
  final AppColors _colors = AppColors.instance;
  final Launcher _launcher = Launcher();
  final List<String> _accountType = [
    "Job Seeker",
    "Employer",
  ];
  bool acceptedF = false;
  bool acceptedS = false;
  bool hasAccount() {
    if (_accountTypeChoice != null) {
      return true;
    }
    Fluttertoast.showToast(msg: "You must choose an account type!");
    return false;
  }

  String? _accountTypeChoice;
  int get type => _accountTypeChoice == null
      ? 1
      : _accountTypeChoice! == "Job Seeker"
          ? 1
          : 2;

  bool validate() => _kForm.currentState!.validate() && hasAccount();
  Widget namedField({required String name, required Widget child}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
                text: name,
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                children: const [
                  TextSpan(
                      text: " *",
                      style: TextStyle(
                        color: Colors.red,
                      ))
                ]),
          ),
          // Text(
          //   name,

          // ),
          const SizedBox(
            height: 5,
          ),
          child,
        ],
      );
  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 15,
      ),
      children: [
        Text(
          "Authentication",
          style: TextStyle(
            color: Colors.grey.shade900,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Text(
          "Make sure to remember all the inputs as those data will be used to login.",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Form(
          key: _kForm,
          child: Column(
            children: [
              namedField(
                name: "Email",
                child: TextFormField(
                  validator: (text) {
                    if (text == null) {
                      return "Invalid type";
                    } else if (text.isEmpty) {
                      return "This field is required";
                    } else if (!text.isValidEmail()) {
                      return "Invalid email";
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                  controller: widget.email,
                  decoration: const InputDecoration(
                    hintText: "sample@email.com",
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              namedField(
                name: "Password",
                child: TextFormField(
                  controller: widget.password,
                  obscureText: _isObscured,
                  validator: (text) {
                    if (text!.isEmpty) {
                      return "This Field is required";
                    } else if (text != widget.confirmPassword.text) {
                      return "Password mismatched!";
                    }
                  },
                  keyboardType: TextInputType.visiblePassword,
                  decoration: const InputDecoration(
                    hintText: "*****",
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              namedField(
                name: "Confirm password",
                child: TextFormField(
                  controller: widget.confirmPassword,
                  obscureText: _isObscured,
                  validator: (text) {
                    if (text!.isEmpty) {
                      return "This Field is required";
                    } else if (text != widget.password.text) {
                      return "Password mismatched!";
                    }
                  },
                  keyboardType: TextInputType.visiblePassword,
                  decoration: const InputDecoration(
                    hintText: "*****",
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            Checkbox(
              value: !_isObscured,
              onChanged: (val) {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
            ),
            Expanded(
              child: Text(
                "Show Password",
                style: TextStyle(
                  color: _colors.top,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        namedField(
          name: "Account type",
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _accountTypeChoice,
                hint: const Text("Job Seeker/Employer"),
                isExpanded: true,
                items: _accountType
                    .map(
                      (String e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(
                    () {
                      _accountTypeChoice = val;
                    },
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Row(
          children: [
            Theme(
              data: ThemeData(
                unselectedWidgetColor: Colors.black,
              ),
              child: Checkbox(
                fillColor:
                    MaterialStateProperty.resolveWith((states) => Colors.black),
                value: acceptedF,
                onChanged: (val) {
                  setState(() {
                    acceptedF = !acceptedF;
                  });
                  widget.hasAcceptedCallback(acceptedS &&
                      acceptedF &&
                      _kForm.currentState!.validate());
                },
              ),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: "I agree to the ",
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      text: "Terms of Services",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await _launcher
                              .launch("https://terra-app.ph/terms-of-services");
                        },
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationColor: _colors.top,
                        color: _colors.top,
                      ),
                    ),
                    const TextSpan(text: " of Terra.Ph")
                  ],
                ),
              ),
            ),
            // const Expanded(
            //   child: Text(
            //     "I agree to the Terms of Services of Terra.Ph",
            // style: TextStyle(
            //   color: Colors.black,
            // ),
            //   ),
            // ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Theme(
              data: ThemeData(
                unselectedWidgetColor: Colors.black,
              ),
              child: Checkbox(
                fillColor:
                    MaterialStateProperty.resolveWith((states) => Colors.black),
                value: acceptedS,
                onChanged: (val) {
                  setState(() {
                    acceptedS = !acceptedS;
                  });
                  widget.hasAcceptedCallback(acceptedS &&
                      acceptedF &&
                      _kForm.currentState!.validate());
                },
              ),
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                    text:
                        "I agree to the processing of my personal data in accordance with the ",
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: "Privacy Policy",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            await _launcher
                                .launch("https://terra-app.ph/privacy-policy");
                          },
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationColor: _colors.top,
                          color: _colors.top,
                        ),
                      ),
                      const TextSpan(text: " of Terra.Ph")
                    ]),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

              // child: Text(
              //   "I agree to the processing of my personal data in accordance with the Privacy Policy of Terra.Ph",
                // style: TextStyle(
                //   color: Colors.black,
                // ),
              // ),