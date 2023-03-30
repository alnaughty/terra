import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/services/API/auth.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/services/firebase_auth.dart';
import 'package:terra/utils/global.dart';

class AuthenticationHelper {
  static final FirebaseAuthenticator _authenticator = FirebaseAuthenticator();
  final DataCacher _cacher = DataCacher.instance;
  static final AuthApi _api = AuthApi();
  Future<void> register(
    context, {
    required String email,
    required String password,
    required String firstname,
    required String lastName,
    required int accountType,
    required String phoneNumber,
    required String birthdate,
    String? city,
    String? brgy,
    String? country,
  }) async {
    try {
      final String fullname =
          "${firstname[0].toUpperCase()}${firstname.substring(1)} ${lastName[0].toUpperCase()}${lastName.substring(1)}";
      await _authenticator
          .registerViaEmailAndPassword(
        fullname: fullname,
        email: email,
        password: password,
      )
          .then((val) async {
        if (val != null) {
          return await _api
              .register(
            firstName: firstname,
            lastName: lastName,
            email: email,
            password: password,
            accountType: accountType,
            phoneNumber: phoneNumber,
            birthdate: birthdate,
            uid: val,
            city: city == null
                ? null
                : city.isEmpty
                    ? null
                    : city,
            country: country == null
                ? null
                : country.isEmpty
                    ? null
                    : country,
            brgy: brgy == null
                ? null
                : brgy.isEmpty
                    ? null
                    : brgy,
          )
              .then((value) async {
            if (value != null) {
              await _cacher.seUserToken(value);
              accessToken = value;
              print("PROCEED TO LANDING");
              await Navigator.pushReplacementNamed(context, "/home_page");
            } else {
              return;
            }
          });
        }
        return;
      });
    } catch (e) {
      return;
    }
    return;
  }

  Future<void> login(context,
      {required String email, required String password}) async {
    try {
      await _authenticator
          .loginViaEmailAndPassword(email: email, password: password)
          .then(
        (value) async {
          if (value != null) {
            return await _api.login(id: value).then(
              (val) async {
                if (val != null) {
                  await _cacher.seUserToken(val);
                  accessToken = val;
                  await Navigator.pushReplacementNamed(context, "/home_page");
                  return;
                } else {
                  print("WARA ACCESSTOKEN");
                }
              },
            );
          }
        },
      );
    } catch (e) {
      return;
    }
  }
}
