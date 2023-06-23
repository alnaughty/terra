import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/services/API/auth.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/services/facebook_auth_service.dart';
import 'package:terra/services/google_auth_service.dart';
import 'package:terra/utils/global.dart';

class SignInWith extends StatelessWidget {
  const SignInWith({super.key, required this.loadingCallback});
  final ValueChanged<bool> loadingCallback;
  static final FacebookAuthService _fbAuth = FacebookAuthService.instance;
  static final GoogleAuthService _gAuth = GoogleAuthService.instance;
  static final DataCacher _cacher = DataCacher.instance;
  static final AuthApi _api = AuthApi();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: ListTile(
            onTap: () async {
              Fluttertoast.showToast(
                msg: "Available when App is available on Play Store",
              );
              // loadingCallback(true);
              // await _fbAuth.signIn().then((user) async {
              //   if (user == null) {
              //     loadingCallback(false);
              //     return;
              //   }
              //   await _api.login(id: await user.getIdToken()).then(
              //     (val) async {
              //       if (val != null) {
              //         await Future.delayed(const Duration(milliseconds: 700));
              //         await _cacher.seUserToken(val);
              //         accessToken = val;
              //         // ignore: use_build_context_synchronously
              //         await Navigator.pushReplacementNamed(
              //             context, "/home_page");
              //         return;
              //       } else {
              //         print("WARA ACCESSTOKEN");
              //       }
              //     },
              //   );
              // });
            },
            title: const Center(
              child: Text(
                "Login with Facebook",
                style: TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            leading: Image.asset(
              "assets/images/fb-logo.png",
              height: 30,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          child: ListTile(
            onTap: () async {
              try {
                loadingCallback(true);
                await _gAuth.signIn().then(
                  (user) async {
                    if (user == null) {
                      loadingCallback(false);
                      return;
                    }
                    await _api.login(id: await user.getIdToken()).then(
                      (val) async {
                        if (val != null) {
                          await Future.delayed(
                              const Duration(milliseconds: 700));
                          await _cacher.seUserToken(val);
                          await _cacher.signInMethod(1);
                          accessToken = val;
                          // ignore: use_build_context_synchronously
                          await Navigator.pushReplacementNamed(
                              context, "/check_page");
                          return;
                        } else {
                          print("WARA ACCESSTOKEN");
                        }
                      },
                    );
                  },
                );
              } catch (e, s) {
                loadingCallback(false);
                print("ERROR: $e");
                print("STAACK $s");
              }
            },
            title: const Center(
              child: Text(
                "Login with Google",
                style: TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            leading: Image.asset(
              "assets/images/google-logo.png",
              height: 30,
            ),
          ),
        ),
      ],
    );
  }
}
