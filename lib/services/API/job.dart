import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/job.dart';

import 'package:http/http.dart' as http;
import 'package:terra/models/user_details.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/utils/network.dart';

class JobAPI {
  JobAPI._pr();
  static final JobAPI _instance = JobAPI._pr();
  static JobAPI get instance => _instance;

  Future<List<Job>?> fetchAvailable(int? catId) async {
    try {
      print(accessToken);
      print("/api/jobs?category_id=${catId ?? ""}");
      return await http.get(
        "${Network.domain}/api/jobs?category_id=${catId ?? ""}".toUri,
        headers: {
          "accept": "application/json",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        },
      ).then((response) {
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          final List res = data['data'];
          print("RESULT : $res");
          res.removeWhere((element) => element['category'] == null);
          return res.map((e) => Job.fromJson(e)).toList();
        }
        Fluttertoast.showToast(
          msg: "An error occurred while processing, please contact developer",
        );
        return null;
      });
    } catch (e, s) {
      print("ERROR: $e");
      print("STACKTRACE : $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing the request.",
      );
      return null;
    }
  }

  Future<bool> postAJob({
    required String title,
    required String completeAddress,
    required String brgy,
    required String city,
    required String landmark,
    String? details,
    required int urgency,
    required double rate,
    required String latlong,
    required int categoryId,
    bool isNegotiable = false,
  }) async {
    try {
      final Map body = {
        "title": title,
        "complete_address": completeAddress,
        "barangay": brgy,
        "landmark": landmark,
        "city": city,
        "urgency": "$urgency",
        "rate": "$rate",
        "latlong": latlong,
        "category_id": "$categoryId",
        "is_negotiable": "$isNegotiable",
      };
      if (details != null) {
        body.addAll({
          "details": details,
        });
      }
      print(body);
      return await http
          .post(
        "${Network.domain}/api/jobs".toUri,
        headers: {
          "accept": "application/json",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        },
        body: body,
      )
          .then((response) {
        var data = json.decode(response.body);
        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "Job posted successfully");
          return true;
        }
        Fluttertoast.showToast(
            msg: "Unable to process request, please try again");
        return false;
      });
    } catch (e, s) {
      print("ERROR : $e");
      print("STACK TRACE : $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing the request.",
      );
      return false;
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

  Future<List<UserDetails>?> fetchJobseekers(String? skills) async {
    try {
      return await http.get(
          "${Network.domain}/api/users?skills=${skills ?? ""}&per_page=100"
              .toUri,
          headers: {
            "accept": "application/json",
            HttpHeaders.authorizationHeader: "Bearer $accessToken"
          }).then((response) {
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          return (data['data'] as List)
              .map((e) => UserDetails.fromJson(e))
              .toList();
        }
        Fluttertoast.showToast(
          msg: "An error occurred while processing, please contact developer",
        );
        return null;
      });
    } catch (e, s) {
      print("ERROR : $e");
      print("STACK : $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing the request.",
      );
      return null;
    }
  }
}
