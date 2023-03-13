import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/helpers/authentication.dart';
import 'package:terra/utils/color.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with AuthenticationHelper {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool isObscured = true;
  bool isRemembered = false;
  bool _isLoading = false;
  final GlobalKey<FormState> _kEmailForm = GlobalKey<FormState>();
  final GlobalKey<FormState> _kPasswordForm = GlobalKey<FormState>();
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  final AppColors _colors = AppColors.instance;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Container(
                color: Colors.white,
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        Hero(
                          tag: "logo",
                          child: Image.asset(
                            "assets/images/Logo.png",
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
                          height: 10,
                        ),
                        Form(
                          key: _kPasswordForm,
                          child: TextFormField(
                            validator: (text) {
                              if (text == null) {
                                return "Invalid type";
                              } else if (text.isEmpty) {
                                return "This field is required";
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "******",
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              label: const Text(
                                "Password",
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isObscured = !isObscured;
                                  });
                                },
                                icon: Icon(isObscured
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                              ),
                            ),
                            controller: _password,
                            obscureText: isObscured,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        LayoutBuilder(builder: (context, c) {
                          final w = c.maxWidth;
                          return SizedBox(
                            width: w,
                            child: Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              runAlignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 170,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        splashRadius: 0,
                                        value: isRemembered,
                                        onChanged: (f) {
                                          setState(() {
                                            isRemembered = !isRemembered;
                                          });
                                        },
                                      ),
                                      Text(
                                        "Remember me",
                                        style: TextStyle(
                                          color: _colors.top,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "Forgot your password?",
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(
                          height: 50,
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
                              if (_kEmailForm.currentState!.validate() &&
                                  _kPasswordForm.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                await login(
                                  context,
                                  email: _email.text,
                                  password: _password.text,
                                ).whenComplete(() {
                                  _isLoading = false;
                                  if (mounted) setState(() {});
                                });
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const SizedBox(
                              width: double.maxFinite,
                              child: Center(
                                child: Text(
                                  "LOGIN",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        RichText(
                          text: TextSpan(
                              text: "Dont have an account yet? ",
                              style: const TextStyle(
                                  color: Colors.black54, fontFamily: "Terra"),
                              children: [
                                TextSpan(
                                  text: "Sign Up",
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () async {
                                      await Navigator.pushNamed(
                                          context, "/register_page");
                                    },
                                  style: TextStyle(
                                    color: _colors.bot,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ]),
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
                color: Colors.black.withOpacity(.7),
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
