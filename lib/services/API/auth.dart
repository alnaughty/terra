import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/services/firebase_auth.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/utils/network.dart';

class AuthApi {
  final FirebaseAuthenticator _auth = FirebaseAuthenticator();
  final DataCacher _cacher = DataCacher.instance;
  Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required int accountType,
    required String phoneNumber,
    required String birthdate,
    required String uid,
    String? brgy,
    String? city,
    String? country,
  }) async {
    try {
      final Map<String, dynamic> _body = Map<String, dynamic>.from({
        "first_name": firstName,
        "last_name": lastName,
        "password": password,
        "c_password": password,
        "email": email,
        "account_type": accountType.toString(),
        "mobile_number": phoneNumber,
        "firebase_id": uid,
        "birthdate": birthdate,
        "barangay": brgy,
        "city": city,
        "country": country,
      }..removeWhere((_, value) => value == null));
      return await http
          .post(
        "${Network.domain}/api/register".toUri,
        headers: {"Accept": "application/json"},
        body: _body,
      )
          .then((response) async {
        var data = json.decode(response.body);
        print("DATA : $data");
        if (response.statusCode == 200 || response.statusCode == 201) {
          _cacher.setUserToken(data['access_token']);
          accessToken = data['access_token'];
          return data['access_token'];
        } else if (response.statusCode == 400) {
          Fluttertoast.showToast(msg: "This account is already taken");
        }
        Fluttertoast.showToast(
            msg: "Error ${response.statusCode} : ${response.reasonPhrase}");
        print("ERROR : ${response.statusCode}");
        return null;
      });
    } catch (e, s) {
      print("ERROR : $e $s");
      print("STRACE : $s");

      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing.",
      );
      return null;
    }
  }

  Future<String?> login({required String id}) async {
    try {
      return await http.post("${Network.domain}/api/login".toUri, headers: {
        "Accept": "application/json",
      }, body: {
        "device_name": "mobile",
        "firebase_token": id,
      }).then(
        (response) async {
          var data = json.decode(response.body);
          print("DATA : $data");
          if (response.statusCode == 200 || response.statusCode == 201) {
            _cacher.setUserToken(data['access_token']);
            accessToken = data['access_token'];
            return data['access_token'];
          } else if (response.statusCode == 400 ||
              response.statusCode == 404 ||
              response.statusCode == 401) {
            Fluttertoast.showToast(
              msg: "Account incomplete, please complete the setup",
            );
            return null;
          }
          Fluttertoast.showToast(
              msg: "Error ${response.statusCode} : ${response.reasonPhrase}");
          print("ERROR : ${response.statusCode}");
          return null;
        },
      );
    } on HandshakeException {
      print("HANDSHAKE LA PROCEED TO ACCOUNT SETUP");
      Fluttertoast.showToast(
        msg: "Please complete the setup",
      );
    } catch (e, s) {
      print("ERROR : $e $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing.",
      );
      return null;
    }
  }

  Future<bool> deleteAccount(String email) async {
    try {
      return await http
          .post("${Network.domain}/api/account/delete/delete-account".toUri)
          .then((response) {
        return response.statusCode == 200;
      });
    } catch (e) {
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      return await http
          .post("${Network.domain}/api/logout".toUri,
              headers: {
                "accept": "application/json",
                HttpHeaders.authorizationHeader: "Bearer $accessToken"
              },
              body: {
                "fcm_token": fcmToken,
              }..removeWhere((key, value) => value == null))
          .then((response) async {
        print(response.body);
        if (response.statusCode == 200) {
          await _cacher.clearAll();
          await _auth.logout().whenComplete(
                () async => await Navigator.pushReplacementNamed(context, "/"),
              );

          return;
        } else {
          var data = json.decode(response.body);
          if (data['message'] != null) {
            Fluttertoast.showToast(msg: data['message']);
          }
          return;
        }
      });
    } catch (e, s) {
      print("ERROR : $e $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing.",
      );
      return;
    }
  }
}
