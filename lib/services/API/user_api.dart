import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/user_details.dart';
import 'package:http/http.dart' as http;
import 'package:terra/services/data_cacher.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/utils/network.dart';

class UserApi {
  final DataCacher _cacher = DataCacher.instance;
  // Future<bool> updateAccountType() async {}
  Future<UserDetails?> details() async {
    try {
      print("TOKEN : $accessToken");
      return await http
          .get("${Network.domain}/api/user-details".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      }).then((response) {
        var data = json.decode(response.body);
        print(data);
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

  Future<bool> updateSkills(String ids) async {
    try {
      return await http
          .post("${Network.domain}/api/update-skills".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }, body: {
        "skills": ids,
      }).then((response) {
        print("RESPONSE : ${response.statusCode}");
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

  Future<void> saveFcm(
    String tok,
  ) async {
    if (tok == _cacher.getFcmToken()) return;
    try {
      return await http.post("${Network.domain}/api/fcm-token".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }, body: {
        "fcm_token": tok,
      }).then((response) {
        if (response.statusCode == 200) {
          _cacher.saveFcmToken(tok);
        }
        return;
      });
    } catch (e, s) {
      print("ERROR : $e $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing.",
      );
      return;
    }
  }

  Future<List<UserDetails>?> searchBySkill(String? skills) async {
    try {
      return await http.get(
          "${Network.domain}/api/users?skills=${skills ?? ""}".toUri,
          headers: {
            "Accept": "application/json",
            HttpHeaders.authorizationHeader: "Bearer $accessToken"
          }).then((response) {
        if (response.statusCode == 200) {
          var d = json.decode(response.body);
          final List<UserDetails> _result =
              (d['data'] as List).map((e) => UserDetails.fromJson(e)).toList();
          return _result;
        }
        Fluttertoast.showToast(
          msg: "An error occurred while processing, please contact developer",
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
}
