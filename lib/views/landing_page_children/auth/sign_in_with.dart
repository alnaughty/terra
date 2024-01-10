import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/services/API/auth.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/services/facebook_auth_service.dart';
import 'package:terra/services/google_auth_service.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/fill_user_data.dart';

class SignInWith extends StatelessWidget {
  const SignInWith({super.key, required this.loadingCallback});
  final ValueChanged<bool> loadingCallback;
  static final FacebookAuthService _fbAuth = FacebookAuthService.instance;
  static final GoogleAuthService _gAuth = GoogleAuthService.instance;
  static final DataCacher _cacher = DataCacher.instance;
  static final UserApi _userApi = UserApi();
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
              try {
                loadingCallback(true);
                await _fbAuth.signIn().then((user) async {
                  if (user == null) {
                    loadingCallback(false);
                    return;
                  }
                  final String firebaseUid = user.uid;
                  final String? token = await user.getIdToken();
                  if (token == null) {
                    Fluttertoast.showToast(msg: "Unable to login user");
                    return;
                  }
                  await _api.login(id: token).then(
                    (val) async {
                      if (val != null) {
                        await _userApi.details().then((v) {
                          loggedUser = v;
                        });
                        await Future.delayed(const Duration(milliseconds: 700));
                        await _cacher.setUserToken(val);
                        await _cacher.signInMethod(2);
                        accessToken = val;
                        // ignore: use_build_context_synchronously
                        await Navigator.pushReplacementNamed(
                            context, "/check_page");
                        return;
                      } else {
                        print("WARA ACCESSTOKENses");
                        // print("TOKEN : $token");
                        print("EMAIL: ${user.email!}");
                        final String defaultPwd =
                            dotenv.get("DEFAULT_TERRA_PASSWORD");
                        print("PASSWORD : $defaultPwd");
                        final String? names = user.displayName;
                        String? fname;
                        String? lname;
                        if (names != null) {
                          final List splitted = names.split(" ");
                          if (splitted.length > 1) {
                            fname = splitted.first;
                            lname = splitted.last;
                          } else if (splitted.length == 1) {
                            fname = splitted.first;
                          }
                        }
                        await Navigator.pushReplacement(
                          context,
                          PageTransition(
                            child: FillUserDataPage(
                              firebaseId: firebaseUid,
                              email: user.email!,
                              password: defaultPwd,
                              name: fname,
                              surname: lname,
                            ),
                            type: PageTransitionType.leftToRight,
                          ),
                        );
                      }
                    },
                  );
                });
              } catch (e, s) {
                loadingCallback(false);
                print("ERROR: $e");
                print("STAACK $s");
                Fluttertoast.showToast(
                  msg:
                      "This platform is still unverified, contact administrator",
                );
              }
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
                    // final String token = user.uid;
                    final String? token = await user.getIdToken();
                    if (token == null) {
                      Fluttertoast.showToast(msg: "Unable to login user");
                      return;
                    }
                    final String firebaseUid = user.uid;
                    await _api.login(id: token).then(
                      (val) async {
                        if (val != null) {
                          await _userApi.details().then((v) {
                            loggedUser = v;
                          });
                          await Future.delayed(
                              const Duration(milliseconds: 700));
                          await _cacher.setUserToken(val);
                          await _cacher.signInMethod(1);
                          accessToken = val;
                          // ignore: use_build_context_synchronously
                          await Navigator.pushReplacementNamed(
                              context, "/check_page");
                          return;
                        } else {
                          print("WARA ACCESSTOKENses");
                          // print("TOKEN : $token");
                          print("EMAIL: ${user.email!}");
                          final String defaultPwd =
                              dotenv.get("DEFAULT_TERRA_PASSWORD");
                          print("PASSWORD : $defaultPwd");
                          final String? names = user.displayName;
                          String? fname;
                          String? lname;
                          if (names != null) {
                            final List splitted = names.split(" ");
                            if (splitted.length > 1) {
                              fname = splitted.first;
                              lname = splitted.last;
                            } else if (splitted.length == 1) {
                              fname = splitted.first;
                            }
                          }
                          await Navigator.pushReplacement(
                            context,
                            PageTransition(
                              child: FillUserDataPage(
                                firebaseId: firebaseUid,
                                email: user.email!,
                                password: defaultPwd,
                                name: fname,
                                surname: lname,
                              ),
                              type: PageTransitionType.leftToRight,
                            ),
                          );
                        }
                      },
                    );
                  },
                );
                loadingCallback(false);
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
