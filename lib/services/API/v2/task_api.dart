import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/v2/task.dart';
import 'package:http/http.dart' as http;
import 'package:terra/utils/global.dart';
import 'package:terra/utils/network.dart';

class TaskAPIV2 {
  TaskAPIV2._pr();
  static final TaskAPIV2 _instance = TaskAPIV2._pr();
  static TaskAPIV2 get instance => _instance;

  Future<List<Task>?> getEmployeeTasks({int? categoryId}) async {
    try {
      return await http.get(
          "${Network.domain}/api/tasks?category_id=${categoryId ?? ""}".toUri,
          headers: {
            "accept": "application/json",
            HttpHeaders.authorizationHeader: "Bearer $accessToken"
          }).then((response) {
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          final List _result = data['data'];
          return _result.map((e) => Task.fromJson(e)).toList();
        }
        Fluttertoast.showToast(
          msg: "Error ${response.statusCode}: ${response.reasonPhrase}",
        );
        return null;
      });
    } on FormatException {
      Fluttertoast.showToast(
        msg: "Format error: Contact Developer",
      );
      return null;
    } catch (e, s) {
      print("ERROR : $e");
      print("STACK TRACE : $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing the request.",
      );
      return null;
    }
  }
}
