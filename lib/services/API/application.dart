import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/application.dart';
import 'package:http/http.dart' as http;
import 'package:terra/utils/global.dart';
import 'package:terra/utils/network.dart';

class ApplicationApi {
  ApplicationApi._pr();
  static final ApplicationApi _instance = ApplicationApi._pr();
  static ApplicationApi get instance => _instance;

  Future<List<Application>?> fetchApplications({
    bool byJobseeker = true,
  }) async {
    try {
      return await http.get(
        "${Network.domain}/api/applications?by_jobseeker=$byJobseeker".toUri,
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
}
