// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:terra/helpers/authentication.dart';
// import 'package:terra/utils/color.dart';
// import 'package:terra/views/landing_page_children/auth/register_components/authentication_data.dart';
// import 'package:terra/views/landing_page_children/auth/register_components/personal_information.dart';

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> with AuthenticationHelper {
//   final AppColors _colors = AppColors.instance;
//   late final ScrollController _scrollController;
//   late final TextEditingController _email;
//   late final TextEditingController _password;
//   late final TextEditingController _firstName;
//   late final TextEditingController _lastName;
//   late final TextEditingController _phoneNumber;
//   late final TextEditingController _confirmPassword;
//   late final TextEditingController _city;
//   late final TextEditingController _street;
//   late final TextEditingController _country;
//   late final TextEditingController _birthdate;
//   late final PageController _pageController;
//   bool _isLoading = false;
//   @override
//   void initState() {
//     _pageController = PageController();
//     // TODO: implement initState
//     _city = TextEditingController();
//     _country = TextEditingController();
//     _street = TextEditingController();
//     _birthdate = TextEditingController();
//     _email = TextEditingController();
//     _password = TextEditingController();
//     _firstName = TextEditingController();
//     _lastName = TextEditingController();
//     _confirmPassword = TextEditingController();
//     _phoneNumber = TextEditingController();
//     _scrollController = ScrollController()..addListener(addListener);
//     super.initState();
//   }

//   late final List<Widget> contents = [
//     PersonalInfoPage(
//       key: _kPinfo,
//       city: _city,
//       firstName: _firstName,
//       lastName: _lastName,
//       birthdate: _birthdate,
//       phoneNumber: _phoneNumber,
//       country: _country,
//       street: _street,
//     ),
//     AuthenticationData(
//       key: _kAuth,
//       email: _email,
//       password: _password,
//       confirmPassword: _confirmPassword,
//       hasAcceptedCallback: (bool f) {
//         setState(() {
//           hasAcceptedTerms = f;
//         });
//       },
//     )
//   ];
//   double opacity = 1;
//   void addListener() {
//     double op = (_scrollController.position.pixels / tabHeight) >= 1
//         ? 1
//         : (_scrollController.position.pixels / tabHeight);

//     opacity = (op - 1).abs();
//     if (mounted) setState(() {});
//   }

//   bool hasAcceptedTerms = false;

// @override
// void dispose() {
//   _pageController.dispose();
//   // TODO: implement dispose
//   _city.dispose();
//   _country.dispose();
//   _street.dispose();
//   _birthdate.dispose();
//   _email.dispose();
//   _password.dispose();
//   _firstName.dispose();
//   _lastName.dispose();
//   _confirmPassword.dispose();
//   _phoneNumber.dispose();
//   _scrollController.removeListener(addListener);
//   _scrollController.dispose();
//   super.dispose();
// }

//   final GlobalKey<AuthenticationDataState> _kAuth =
//       GlobalKey<AuthenticationDataState>();
//   final GlobalKey<PersonalInfoPageState> _kPinfo =
//       GlobalKey<PersonalInfoPageState>();
//   int currentIndex = 0;
//   bool _isObscured = true;
//   double tabHeight = 0.0;
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//     final Size size = MediaQuery.of(context).size;
//     tabHeight =
//         (size.width > size.height ? size.width * .8 : size.height) * .35;
//     return WillPopScope(
//       onWillPop: () async => !_isLoading,
//       child: Stack(
//         children: [
//           GestureDetector(
//             onTap: () => FocusScope.of(context).unfocus(),
//             child: Scaffold(
//               backgroundColor: Colors.white,
//               body: Column(
//                 children: [
//                   Expanded(
//                     child: CustomScrollView(
//                       controller: _scrollController,
//                       slivers: [
//                         SliverAppBar(
//                           pinned: true,
//                           iconTheme: const IconThemeData(
//                             color: Colors.white,
//                           ),
//                           backgroundColor: Colors.white,
//                           flexibleSpace: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.blue,
//                               gradient: LinearGradient(
//                                 colors: [
//                                   _colors.top,
//                                   _colors.bot,
//                                 ],
//                               ),
//                             ),
//                             child: Container(
//                               padding: const EdgeInsets.all(10),
//                               child: Center(
//                                 child: Hero(
//                                   tag: "logo",
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.center,
//                                     children: [
//                                       Image.asset(
//                                         "assets/images/Logo.png",
//                                         fit: BoxFit.fitHeight,
//                                         color:
//                                             Colors.white.withOpacity(opacity),
//                                         height: (tabHeight * .3) * opacity,
//                                       ),
//                                       Image.asset(
//                                         "assets/images/Terra-name.png",
//                                         fit: BoxFit.fitHeight,
//                                         color:
//                                             Colors.white.withOpacity(opacity),
//                                         height: (tabHeight * .2) * opacity,
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           expandedHeight: tabHeight,
//                           title: const Text(
//                             "Create Account",
//                             style: TextStyle(
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                         SliverToBoxAdapter(
//                           child: SizedBox(
//                             height: (size.height),
//                             child: PageView.builder(
//                               physics: const NeverScrollableScrollPhysics(),
//                               controller: _pageController,
//                               itemBuilder: (_, index) => contents[index],
//                               itemCount: contents.length,
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                   SafeArea(
//                     top: false,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 10,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           if (currentIndex == 1) ...{
//                             TextButton.icon(
//                               onPressed: () async {
//                                 currentIndex = 0;

//                                 setState(() {});
//                                 await _pageController.animateToPage(
//                                   currentIndex,
//                                   duration: const Duration(milliseconds: 500),
//                                   curve: Curves.fastLinearToSlowEaseIn,
//                                 );
//                               },
//                               style: ButtonStyle(
//                                   foregroundColor:
//                                       MaterialStateProperty.resolveWith(
//                                 (states) => _colors.top,
//                               )),
//                               icon: const Icon(
//                                 Icons.chevron_left_rounded,
//                                 size: 25,
//                               ),
//                               label: const Text("Back"),
//                             ),
//                           } else ...{
//                             Container()
//                           },
//                           Container(
//                             decoration: currentIndex == 0
//                                 ? null
//                                 : BoxDecoration(
//                                     gradient:
//                                         currentIndex == 1 && !hasAcceptedTerms
//                                             ? null
//                                             : LinearGradient(
//                                                 colors: [
//                                                   _colors.bot,
//                                                   _colors.top,
//                                                 ],
//                                                 begin: Alignment.bottomLeft,
//                                                 end: Alignment.topRight,
//                                               ),
//                                     borderRadius: BorderRadius.circular(10),
//                                     color:
//                                         currentIndex == 1 && !hasAcceptedTerms
//                                             ? Colors.grey.shade400
//                                             : Colors.white,
//                                   ),
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 5,
//                             ),
//                             child: GestureDetector(
//                               onTap: currentIndex == 1 && !hasAcceptedTerms
//                                   ? null
//                                   : () async {
//                                       print("AF");

//                                       if (currentIndex == 0) {
//                                         if (_kPinfo.currentState!.validate()) {
//                                           currentIndex = 1;
//                                           await _pageController.animateToPage(
//                                             currentIndex,
//                                             duration: const Duration(
//                                               milliseconds: 500,
//                                             ),
//                                             curve:
//                                                 Curves.fastLinearToSlowEaseIn,
//                                           );
//                                           if (mounted) setState(() {});
//                                         }
//                                       } else {
//                                         print("ASDASD");

//                                         /// REGISTER API NA!
//                                         if (_kAuth.currentState!.validate()) {
//                                           setState(() {
//                                             _isLoading = true;
//                                           });

//                                           print("REGIUSTER!");
//                                           await register(
//                                             context,
//                                             email: _email.text,
//                                             password: _password.text,
//                                             firstname: _firstName.text,
//                                             lastName: _lastName.text,
//                                             accountType:
//                                                 _kAuth.currentState!.type,
//                                             birthdate: _birthdate.text,
//                                             phoneNumber: _phoneNumber.text,
//                                             brgy: _street.text,
//                                             city: _city.text,
//                                             country: _country.text,
//                                           ).whenComplete(() {
//                                             _isLoading = false;
//                                             if (mounted) setState(() {});
//                                           });
//                                         }
//                                       }
//                                     },
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   if (currentIndex == 1) ...{
//                                     const SizedBox(
//                                       width: 15,
//                                     ),
//                                   },
//                                   Text(
//                                     currentIndex == 0 ? "Next" : "Register",
//                                     style: TextStyle(
//                                       color: currentIndex == 0
//                                           ? _colors.top
//                                           : Colors.white,
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     width: 5,
//                                   ),
//                                   Icon(
//                                     Icons.chevron_right_rounded,
//                                     size: 25,
//                                     color: currentIndex == 0
//                                         ? _colors.top
//                                         : Colors.white,
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               // body: Container(
//               //   color: Colors.white,
//               //   child: SafeArea(
//               //     top: false,
//               //     child: Column(
//               //       children: [
//               //         Container(
//               //           width: size.width,
//               //           height: tabHeight,
//               //           decoration: BoxDecoration(
//               //             gradient: _colors.gradient,
//               //           ),
//               //           child: Column(
//               //             children: [
//               //               SafeArea(
//               //                 bottom: false,
//               //                 child: PreferredSize(
//               //                   preferredSize: const Size.fromHeight(60),
//               //                   child: AppBar(
//               // iconTheme: const IconThemeData(
//               //   color: Colors.white,
//               // ),
//               // title: const Text(
//               //   "Create Account",
//               //   style: TextStyle(
//               //     color: Colors.white,
//               //   ),
//               // ),
//               //                   ),
//               //                 ),
//               //               ),
//               //               Expanded(
//               // child: Container(
//               //   padding: const EdgeInsets.all(10),
//               //   child: Hero(
//               //     tag: "logo",
//               //     child: Column(
//               //       children: [
//               //         Image.asset(
//               //           "assets/images/Logo.png",
//               //           fit: BoxFit.fitHeight,
//               //           color: Colors.white,
//               //           height: tabHeight * .3,
//               //         ),
//               //         Image.asset(
//               //           "assets/images/Terra-name.png",
//               //           fit: BoxFit.fitHeight,
//               //           color: Colors.white,
//               //           height: tabHeight * .2,
//               //         ),
//               //       ],
//               //     ),
//               //   ),
//               // ),
//               //               ),
//               //             ],
//               //           ),
//               //         ),
//               //         Expanded(
//               // child: PageView.builder(
//               //   physics: const NeverScrollableScrollPhysics(),
//               //   controller: _pageController,
//               //   itemBuilder: (_, index) => contents[index],
//               //   itemCount: contents.length,
//               // ),
//               //         ),

//               //         const SafeArea(
//               //           top: false,
//               //           child: SizedBox(
//               //             height: 10,
//               //           ),
//               //         ),

//               //         /// BUTTON CONTROLLER
//               //       ],
//               //     ),
//               //   ),
//               // ),
//             ),
//           ),
//           if (_isLoading) ...{
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black.withOpacity(.7),
//                 child: Center(
//                   child: Image.asset("assets/images/loader.gif"),
//                 ),
//               ),
//             )
//           }
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/helpers/authentication.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/views/landing_page_children/auth/sign_in_with.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with AuthenticationHelper {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  final GlobalKey<FormState> _kEmailForm = GlobalKey<FormState>();
  final GlobalKey<FormState> _kPasswordForm = GlobalKey<FormState>();
  final AppColors _colors = AppColors.instance;

  bool _isLoading = false;
  bool isObscured = true;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
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
                        Center(
                          child: Hero(
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
                        const SizedBox(
                          height: 10,
                        ),
                        Form(
                          key: _kPasswordForm,
                          child: Column(
                            children: [
                              TextFormField(
                                validator: (text) {
                                  if (text == null) {
                                    return "Invalid type";
                                  } else if (text.isEmpty) {
                                    return "This field is required";
                                  } else if (text != _confirmPassword.text) {
                                    return "Password Mismatch";
                                  }
                                },
                                decoration: const InputDecoration(
                                  hintText: "******",
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  label: Text(
                                    "Password",
                                  ),
                                  // suffixIcon: IconButton(
                                  //   onPressed: () {
                                  //     setState(() {
                                  //       isObscured = !isObscured;
                                  //     });
                                  //   },
                                  //   icon: Icon(
                                  //     isObscured
                                  //         ? Icons.visibility
                                  //         : Icons.visibility_off,
                                  //     color: Colors.grey,
                                  //   ),
                                  // ),
                                ),
                                controller: _password,
                                obscureText: isObscured,
                                keyboardType: TextInputType.text,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                validator: (text) {
                                  if (text == null) {
                                    return "Invalid type";
                                  } else if (text.isEmpty) {
                                    return "This field is required";
                                  } else if (text != _password.text) {
                                    return "Password Mismatch";
                                  }
                                },
                                decoration: const InputDecoration(
                                  hintText: "******",
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  label: Text(
                                    "Confirm Password",
                                  ),
                                  // suffixIcon: IconButton(
                                  //   onPressed: () {
                                  //     setState(() {
                                  //       isObscured = !isObscured;
                                  //     });
                                  //   },
                                  //   icon: Icon(
                                  //     isObscured
                                  //         ? Icons.visibility
                                  //         : Icons.visibility_off,
                                  //     color: Colors.grey,
                                  //   ),
                                  // ),
                                ),
                                controller: _confirmPassword,
                                obscureText: isObscured,
                                keyboardType: TextInputType.text,
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Checkbox.adaptive(
                                value: !isObscured,
                                onChanged: (bool? f) {
                                  setState(() {
                                    isObscured = !(f ?? true);
                                  });
                                },
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "${isObscured ? "Show" : "Hide"} Password",
                                style: TextStyle(
                                  color: _colors.top,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        MaterialButton(
                          height: 60,
                          color: _colors.top,
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            // if (_accountTypeChoice == null) {
                            //   Fluttertoast.showToast(
                            //       msg: "Please choose an account type");
                            //   return;
                            // }
                            final bool _isEmailValid =
                                _kEmailForm.currentState!.validate();
                            final bool _isPasswordValid =
                                _kPasswordForm.currentState!.validate();
                            if (_isEmailValid && _isPasswordValid) {
                              setState(() {
                                _isLoading = true;
                              });
                              await rawRegister(
                                context,
                                email: _email.text,
                                password: _password.text,
                                // accountType: type,
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
                                "REGISTER",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: MaterialButton(
                            height: 60,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Center(
                              child: Text(
                                "I already have an account",
                                style: TextStyle(
                                  color: Color(0xFF4A4A4A),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
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
