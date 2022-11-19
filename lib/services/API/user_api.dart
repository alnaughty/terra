import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/user_details.dart';
import 'package:http/http.dart' as http;
import 'package:terra/utils/global.dart';
import 'package:terra/utils/network.dart';

class UserApi {
  Future<UserDetails?> details() async {
    try {
      return await http
          .get("${Network.domain}/api/user-details".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      }).then((response) {
        var data = json.decode(response.body);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return UserDetails.fromJson(data);
        }
        Fluttertoast.showToast(
          msg: "Error ${response.statusCode} : ${response.reasonPhrase}",
        );
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

  // Future<bool> updatePassword({required String newPassword}) async {

  // }
  Future<bool> updateAvatar({required String base64Image}) async {
    try {
      return await http
          .post("${Network.domain}/api/update-profile".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }, body: {
        "avatar": "data:image/png;base64,$base64Image"
      }).then((response) {
        return response.statusCode == 200;
      });
    } catch (e, s) {
      print("ERROR : $e $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing.",
      );
      return false;
    }
  }
}
