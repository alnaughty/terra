import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/utils/network.dart';

class AuthApi {
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
      final Map<String, dynamic> _body = {
        "first_name": firstName,
        "last_name": lastName,
        "password": password,
        "c_password": password,
        "email": email,
        "account_type": accountType.toString(),
        "mobile_number": phoneNumber,
        "firebase_id": uid,
      };
      if (brgy != null) {
        _body.addAll({
          "barangay": brgy,
        });
      }
      if (city != null) {
        _body.addAll({
          "city": city,
        });
      }
      if (country != null) {
        _body.addAll({
          "country": country,
        });
      }
      return await http
          .post(
        "${Network.domain}/api/register".toUri,
        headers: {"Accept": "application/json"},
        body: _body,
      )
          .then((response) async {
        var data = json.decode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          print("DATA : $data");

          return data['access_token'];
        }
        return null;
      });
    } catch (e, s) {
      print("ERROR : $e $s");
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
        (response) {
          var data = json.decode(response.body);
          if (response.statusCode == 200 || response.statusCode == 201) {
            print("DATA : $data");

            return data['access_token'];
          }
          return null;
        },
      );
    } catch (e, s) {
      print("ERROR : $e $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing.",
      );
      return null;
    }
  }
}