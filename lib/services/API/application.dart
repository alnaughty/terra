import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/application.dart';
import 'package:http/http.dart' as http;
import 'package:terra/models/raw_application.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/utils/network.dart';

class ApplicationApi {
  ApplicationApi._pr();
  static final ApplicationApi _instance = ApplicationApi._pr();
  static ApplicationApi get instance => _instance;

  Future<List<RawApplication>?> fetchApplicationsByEmployer() async {
    try {
      return await http.get(
        "${Network.domain}/api/applications".toUri,
        headers: {
          "accept": "application/json",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        },
      ).then((response) {
        var data = json.decode(response.body);
        if (response.statusCode == 200) {
          return (data['data'] as List)
              .map((e) => RawApplication.fromJson(e))
              .toList();
        }
        Fluttertoast.showToast(
          msg: "An error occurred while processing, please contact developer",
        );
        return null;
      });
    } catch (e, s) {
      print("STACKTRACE : $s");
      print("ERROR : $e");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing the request.",
      );
      return null;
    }
  }

  Future<List<Application>?> fetchApplicationsByJobseeker() async {
    try {
      return await http.get(
        "${Network.domain}/api/applications".toUri,
        headers: {
          "accept": "application/json",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        },
      ).then((response) {
        var data = json.decode(response.body);
        if (response.statusCode == 200) {
          return (data['data'] as List)
              .map((e) => Application.fromJson(e))
              .toList();
        }
        Fluttertoast.showToast(
          msg: "An error occurred while processing, please contact developer",
        );
        return null;
      });
    } catch (e, s) {
      print("STACKTRACE : $s");
      print("ERROR : $e");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing the request.",
      );
      return null;
    }
  }

  Future<bool> approveApplication(int id) async {
    try {
      return await http
          .post("${Network.domain}/api/approve-application".toUri, headers: {
        "accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }, body: {
        "application_id": "$id",
      }).then((response) => response.statusCode == 200);
    } catch (e, s) {
      print("STACKTRACE : $s");
      print("ERROR : $e");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing the request.",
      );
      return false;
    }
  }
}
