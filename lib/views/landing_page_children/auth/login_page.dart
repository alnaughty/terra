import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/helpers/authentication.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/views/landing_page_children/auth/forgot_password.dart';
import 'package:terra/views/landing_page_children/auth/sign_in_with.dart';

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
              backgroundColor: const Color(0xFFEEEEEE),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Hero(
                        tag: "logo",
                        child: Column(children: [
                          Image.asset(
                            "assets/images/Logo.png",
                            height: 150,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Image.asset(
                            "assets/images/Terra-name.png",
                            height: 60,
                          )
                        ]),
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
                            fillColor: Colors.white,
                            filled: true,
                            hintStyle: TextStyle(
                              color: Colors.grey,
                            ),
                            label: Text(
                              "Enter Email",
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
                            fillColor: Colors.white,
                            filled: true,
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
                              icon: Icon(
                                isObscured
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
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
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  PageTransition(
                                    child: const ForgotPasswordPage(),
                                    type: PageTransitionType.rightToLeft,
                                  ),
                                );
                              },
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.resolveWith(
                                  (states) => _colors.top,
                                ),
                                textStyle: MaterialStateProperty.resolveWith(
                                  (states) => TextStyle(
                                    color: _colors.top,
                                    fontFamily: "Poppins",
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              child: const Text(
                                "Forgot password?",
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(
                        height: 50,
                      ),

                      MaterialButton(
                        height: 60,
                        color: _colors.top,
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
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
                          borderRadius: BorderRadius.circular(5),
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
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFF4A4A4A),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: const Text(
                              "Or continue with",
                              style: TextStyle(
                                color: Color(0xFF4A4A4A),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFF4A4A4A),
                                  ],
                                  end: Alignment.centerLeft,
                                  begin: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      SignInWith(
                        loadingCallback: (b) {
                          _isLoading = b;
                          if (mounted) setState(() {});
                        },
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      RichText(
                        text: TextSpan(
                            text: "New to our plaform? ",
                            style: const TextStyle(
                              color: Colors.black54,
                              fontFamily: "Terra",
                              fontSize: 15,
                            ),
                            children: [
                              TextSpan(
                                text: "Register now",
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    await Navigator.pushNamed(
                                        context, "/register_page");
                                  },
                                style: TextStyle(
                                  color: _colors.top,
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
