import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/job.dart';

import 'package:http/http.dart' as http;
import 'package:terra/utils/global.dart';
import 'package:terra/utils/network.dart';

class JobAPI {
  JobAPI._pr();
  static final JobAPI _instance = JobAPI._pr();
  static JobAPI get instance => _instance;

  Future<List<Job>?> fetchAvailable() async {
    try {
      return await http.get(
        "${Network.domain}/api/jobs".toUri,
        headers: {
          "accept": "application/json",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        },
      ).then((response) {
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          final List res = data['data'];

          return res.map((e) => Job.fromJson(e)).toList();
        }
        Fluttertoast.showToast(
          msg: "An error occurred while processing, please contact developer",
        );
        return null;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing the request.",
      );
      return null;
    }
  }

  Future<bool> apply({required int id, required double rate}) async {
    try {
      return await http.post("${Network.domain}/api/apply".toUri, headers: {
        "accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }, body: {
        "task_id": "$id",
        "rate": "$rate"
      }).then((response) {
        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "Application sent");
          return true;
        }
        Fluttertoast.showToast(
          msg: "An error occurred while processing, please contact developer",
        );
        return false;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing the request.",
      );
      return false;
    }
  }

  Future<bool> cancel({
    required int id,
  }) async {
    try {
      return await http
          .post("${Network.domain}/api/cancel-application".toUri, headers: {
        "accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }, body: {
        "task_id": "$id",
      }).then((response) {
        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "Application cancelled");
          return true;
        }
        Fluttertoast.showToast(
          msg: "An error occurred while processing, please contact developer",
        );
        return false;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing the request.",
      );
      return false;
    }
  }

  Future<bool> approve({required int id}) async {
    try {
      return await http
          .post("${Network.domain}/api/approve-application".toUri, headers: {
        "accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }, body: {
        "application_id": "$id",
      }).then((response) {
        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "Application approved!");
          return true;
        }
        Fluttertoast.showToast(
          msg: "An error occurred while processing, please contact developer",
        );
        return false;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing the request.",
      );
      return false;
    }
  }
}
