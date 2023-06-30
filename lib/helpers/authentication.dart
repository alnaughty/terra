import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/services/API/auth.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/services/firebase_auth.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/fill_user_data.dart';

class AuthenticationHelper {
  static final FirebaseAuthenticator _authenticator = FirebaseAuthenticator();
  final DataCacher _cacher = DataCacher.instance;
  static final AuthApi _api = AuthApi();
  static final UserApi _userApi = UserApi();
  Future<void> rawRegister(
    context, {
    required String email,
    required String password,
  }) async {
    try {
      await _authenticator
          .registerViaEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) async {
        // if (value == null) return;
        print("REGISTERED VALUE : $value");
        if (value != null) {
          await Navigator.pushReplacement(
            context,
            PageTransition(
              child: FillUserDataPage(
                firebaseId: value,
                email: email,
                password: password,
              ),
              type: PageTransitionType.leftToRight,
            ),
          );
          // return await _api.login(id: value).then((val) async {
          //   if (val != null) {
          //     await _userApi.details().then((v) {
          //       loggedUser = v;
          //     });
          //     await _cacher.seUserToken(val);
          //     await _cacher.signInMethod(0);
          //     accessToken = val;
          //     await Navigator.pushReplacementNamed(context, "/check_page");
          //     return;
          //   } else {
          // await Navigator.pushReplacement(
          //   context,
          //   PageTransition(
          //     child: FillUserDataPage(firebaseId: value),
          //     type: PageTransitionType.leftToRight,
          //   ),
          // );
          //     print("WARA ACCESSTOKEN");
          //   }
          // });
        }
        return null;
        // return await _api.login(id: value).then(
        //   (val) async {
        // if (val != null) {
        //   await Future.delayed(const Duration(milliseconds: 700));
        //   await _cacher.seUserToken(val);
        //   await _cacher.signInMethod(0);
        //   accessToken = val;
        //   await Navigator.pushReplacementNamed(context, "/check_page");
        //   return;
        // } else {
        //   print("WARA ACCESSTOKEN");
        // }
        //   },
        // );
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        Fluttertoast.showToast(msg: "Email already in use");
      } else if (e.code == "invalid-email") {
        Fluttertoast.showToast(
          msg: "Invalid email format",
          toastLength: Toast.LENGTH_LONG,
        );
      } else if (e.code == "weak-password") {
        Fluttertoast.showToast(
          msg: "Weak password",
        );
      }
      return;
    } catch (e) {
      Fluttertoast.showToast(msg: "Unable to register, please contact admin");
      return;
    }
  }

  // Future<void> register(
  //   context, {
  //   required String email,
  //   required String password,
  //   required String firstname,
  //   required String lastName,
  //   required int accountType,
  //   required String phoneNumber,
  //   required String birthdate,
  //   String? city,
  //   String? brgy,
  //   String? country,
  // }) async {
  //   try {
  //     final String fullname =
  //         "${firstname[0].toUpperCase()}${firstname.substring(1)} ${lastName[0].toUpperCase()}${lastName.substring(1)}";
  //     await _authenticator
  //         .registerViaEmailAndPassword(
  //       email: email,
  //       password: password,
  //     )
  //         .then((val) async {
  //       if (val != null) {
  // return await _api
  //     .register(
  //   firstName: firstname,
  //   lastName: lastName,
  //   email: email,
  //   password: password,
  //   accountType: accountType,
  //   phoneNumber: phoneNumber,
  //   birthdate: birthdate,
  //   uid: val,
  //   city: city == null
  //       ? null
  //       : city.isEmpty
  //           ? null
  //           : city,
  //   country: country == null
  //       ? null
  //       : country.isEmpty
  //           ? null
  //           : country,
  //   brgy: brgy == null
  //       ? null
  //       : brgy.isEmpty
  //           ? null
  //           : brgy,
  // )
  //     .then((value) async {
  //   if (value != null) {
  //     await _cacher.seUserToken(value);
  //     accessToken = value;
  //     print("PROCEED TO LANDING");
  //     await Navigator.pushReplacementNamed(context, "/home_page");
  //   } else {
  //     return;
  //   }
  // });
  //       }
  //       return;
  //     });
  //   } catch (e) {
  //     return;
  //   }
  //   return;
  // }

  Future<void> login(context,
      {required String email, required String password}) async {
    try {
      await _cacher.clearAll();
      await _authenticator
          .loginViaEmailAndPassword(email: email, password: password)
          .then(
        (value) async {
          if (value != null) {
            print("LOGGED VALUE : $value");
            return await _api.login(id: value).then(
              (val) async {
                if (val != null) {
                  await _userApi.details().then((v) {
                    loggedUser = v;
                  });
                  await Future.delayed(const Duration(milliseconds: 700));
                  await _cacher.seUserToken(val);
                  await _cacher.signInMethod(0);
                  accessToken = val;
                  await Navigator.pushReplacementNamed(context, "/check_page");
                  return;
                } else {
                  await Navigator.pushReplacement(
                    context,
                    PageTransition(
                      child: FillUserDataPage(
                        firebaseId: value,
                        email: email,
                        password: password,
                      ),
                      type: PageTransitionType.leftToRight,
                    ),
                  );
                  print("WARA ACCESSTOKEN");
                }
              },
            );
          }
        },
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: "User not found");
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: "Wrong Password");
      }
      // Fluttertoast.showToast(
      //     msg: "Impossible de s'authentifier depuis le serveur : $e");
      return;
    } catch (e) {
      Fluttertoast.showToast(msg: "Unable to register, please contact admin");
      return;
    }
  }
}
