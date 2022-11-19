import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/views/landing_page_children/auth/register_components/authentication_data.dart';
import 'package:terra/views/landing_page_children/auth/register_components/personal_information.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AppColors _colors = AppColors.instance;
  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  final GlobalKey<FormState> _kEmailForm = GlobalKey<FormState>();
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phoneNumber;
  late final TextEditingController _confirmPassword;
  late final TextEditingController _address;
  late final TextEditingController _birthdate;
  late final PageController _pageController;

  @override
  void initState() {
    _pageController = PageController();
    // TODO: implement initState
    _address = TextEditingController();
    _birthdate = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _confirmPassword = TextEditingController();
    _phoneNumber = TextEditingController();

    super.initState();
  }

  late final List<Widget> contents = [
    PersonalInfoPage(
      key: _kPinfo,
      address: _address,
      firstName: _firstName,
      lastName: _lastName,
      birthdate: _birthdate,
      phoneNumber: _phoneNumber,
    ),
    AuthenticationData(
      key: _kAuth,
      email: _email,
      password: _password,
      confirmPassword: _confirmPassword,
    )
  ];
  @override
  void dispose() {
    _pageController.dispose();
    // TODO: implement dispose
    _address.dispose();
    _birthdate.dispose();
    _email.dispose();
    _password.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _confirmPassword.dispose();
    _phoneNumber.dispose();
    super.dispose();
  }

  final GlobalKey<AuthenticationDataState> _kAuth =
      GlobalKey<AuthenticationDataState>();
  final GlobalKey<PersonalInfoPageState> _kPinfo =
      GlobalKey<PersonalInfoPageState>();
  int currentIndex = 0;
  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                width: size.width,
                height: size.height * .35,
                decoration: BoxDecoration(
                  gradient: _colors.gradient,
                ),
                child: Column(
                  children: [
                    SafeArea(
                      child: PreferredSize(
                        preferredSize: const Size.fromHeight(60),
                        child: AppBar(
                          iconTheme: const IconThemeData(
                            color: Colors.white,
                          ),
                          title: const Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Hero(
                          tag: "logo",
                          child: Image.asset(
                            "assets/images/LogoT.png",
                            fit: BoxFit.fitHeight,
                            color: Colors.white,
                            // height: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  itemBuilder: (_, index) => contents[index],
                  itemCount: contents.length,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentIndex == 1) ...{
                      TextButton.icon(
                        onPressed: () async {
                          currentIndex = 0;

                          setState(() {});
                          await _pageController.animateToPage(
                            currentIndex,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.fastLinearToSlowEaseIn,
                          );
                        },
                        style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.resolveWith(
                          (states) => _colors.top,
                        )),
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          size: 25,
                        ),
                        label: const Text("Back"),
                      ),
                    } else ...{
                      Container()
                    },
                    Container(
                      decoration: currentIndex == 0
                          ? null
                          : BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _colors.bot,
                                  _colors.top,
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: GestureDetector(
                          onTap: () async {
                            if (currentIndex == 0) {
                              if (_kPinfo.currentState!.validate()) {
                                currentIndex = 1;
                                setState(() {});
                                await _pageController.animateToPage(
                                  currentIndex,
                                  duration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  curve: Curves.fastLinearToSlowEaseIn,
                                );
                              }
                            } else {
                              /// REGISTER API NA!
                              ///
                              if (!_kAuth.currentState!.validate()) {
                                print("DIRI");
                              } else {
                                print("PROCEED TO LANDING");
                                await Navigator.pushReplacementNamed(
                                    context, "/home_page");
                              }
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (currentIndex == 1) ...{
                                const SizedBox(
                                  width: 15,
                                ),
                              },
                              Text(
                                currentIndex == 0 ? "Next" : "Register",
                                style: TextStyle(
                                  color: currentIndex == 0
                                      ? _colors.top
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 25,
                                color: currentIndex == 0
                                    ? _colors.top
                                    : Colors.white,
                              )
                            ],
                          )),
                    ),
                  ],
                ),
              )

              /// BUTTON CONTROLLER
            ],
          ),
        ),
      ),
    );
  }
}
