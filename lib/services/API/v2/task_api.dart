import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/task_history.dart' as model;
import 'package:terra/models/v2/negotiation_model.dart';
import 'package:terra/models/v2/raw_task.dart';
import 'package:terra/models/v2/task.dart';
import 'package:http/http.dart' as http;
import 'package:terra/models/v2/todo.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/utils/network.dart';
import 'package:terra/views/home_page_children/home_page_main_children/task_history.dart';

class TaskAPIV2 {
  TaskAPIV2._pr();
  static final TaskAPIV2 _instance = TaskAPIV2._pr();
  static TaskAPIV2 get instance => _instance;

  Future<List<TodoTask>?> getCompletedTasks() async {
    try {
      return await http.get(
          "${Network.domain}/api/${loggedUser!.accountType == 1 ? "employee" : "employer"}-complete-todos"
              .toUri,
          headers: {
            "accept": "application/json",
            HttpHeaders.authorizationHeader: "Bearer $accessToken"
          }).then((response) {
        var data = json.decode(response.body);
        if (response.statusCode == 200) {
          final List _result = data['todos'];
          print("COMPLETED $_result");
          if (loggedUser!.accountType != 1) {
            return _result.map((e) => TodoTask.fromJsonEmployer(e)).toList();
          } else {
            return _result.map((e) => TodoTask.fromJson(e)).toList();
          }
        }
        return null;
      });
    } catch (e, s) {
      print("ERROR $e");
      print("STACKTRACE : $s");
      return null;
    }
  }

  Future<bool> update(int id, Map<String, dynamic> body) async {
    try {
      return await http
          .put("${Network.domain}/api/task/$id".toUri,
              headers: {
                "accept": "application/json",
                HttpHeaders.authorizationHeader: "Bearer $accessToken"
              },
              body: body)
          .then((response) {
        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "Updated Successfully");
          return true;
        }
        Fluttertoast.showToast(
          msg: "Error${response.statusCode} : ${response.reasonPhrase}",
        );
        return false;
      });
    } catch (e, s) {
      print("ERROR: $e");
      print("STACKTRACE : $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing the request.",
      );
      return false;
    }
  }

  Future<bool> approveNegotiation(int id) async {
    try {
      return await http
          .put("${Network.domain}/api/approve-negotiation/$id".toUri, headers: {
        "accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }).then((response) {
        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "You Approved a Negotiation");
          return true;
        }
        Fluttertoast.showToast(
            msg: "Error ${response.statusCode} : ${response.reasonPhrase}");
        return false;
      });
    } catch (e) {
      return false;
    }
  }

  Future<bool> negotiate(String price, int taskId) async {
    try {
      return await http
          .post("${Network.domain}/api/negotiation".toUri, headers: {
        "accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }, body: {
        "price": price,
        "task_id": "$taskId",
        "applicant_id": "${loggedUser!.id}",
      }).then((response) {
        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "Offer submitted");
          return true;
        }
        Fluttertoast.showToast(
          msg: "Error${response.statusCode} : ${response.reasonPhrase}",
        );
        return false;
      });
    } catch (e, s) {
      print("ERROR: $e");
      print("STACKTRACE : $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing the request.",
      );
      return false;
    }
  }

  Future<List<NegotiationModel>> getNegotiations(int id) async {
    try {
      return await http
          .get("${Network.domain}/api/task-negotiation/$id".toUri, headers: {
        "accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }).then((response) {
        var data = json.decode(response.body);
        if (response.statusCode == 200) {
          print("DATA $data");
          var nego = data['negotiations'] ?? [];
          final bool isList = nego.runtimeType == List;
          if (!isList) {
            final Map res = nego;
            final List allData =
                res.entries.expand((element) => element.value).toList();
            print("ALL DATA $allData");
            return allData.map((e) => NegotiationModel.fromJson(e)).toList();
          }
          final List res = nego;

          print("IS LIST : $isList");

          return res.map((e) => NegotiationModel.fromJson(e)).toList();
        }
        return List.empty();
      });
    } catch (e) {
      return List.empty();
    }
  }

  Future<bool> delete(int id) async {
    try {
      return await http
          .delete("${Network.domain}/api/task/$id".toUri, headers: {
        "accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }).then((response) {
        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "Deleted Successfully");
          return true;
        } else if (response.statusCode == 401) {
          Fluttertoast.showToast(
              msg: "This task is already active, you cannot delete this.");
          return false;
        }
        Fluttertoast.showToast(
          msg: "Error${response.statusCode} : ${response.reasonPhrase}",
        );
        return false;
      });
    } catch (e, s) {
      print("ERROR: $e");
      print("STACKTRACE : $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing the request.",
      );
      return false;
    }
  }

  Future<List<RawTaskV2>?> getPostedTasks() async {
    try {
      return await http
          .get("${Network.domain}/api/posted-tasks".toUri, headers: {
        "accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }).then((response) {
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          final List _result = data['tasks']['data'];
          return _result.map((e) => RawTaskV2.fromJson(e)).toList();
        }
        Fluttertoast.showToast(
          msg: "Error ${response.statusCode}: ${response.reasonPhrase}",
        );
        return null;
      });
    } catch (e) {
      return null;
    }
  }

  Future<bool> markAsPaid(int id) async {
    try {
      return await http
          .post("${Network.domain}/api/mark-as-paid".toUri, headers: {
        "accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }, body: {
        "todo_id": "$id",
      }).then((response) {
        print("status code ${response.statusCode}");
        return response.statusCode == 200;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Unable to update task");
      return false;
    }
  }

  Future<bool> markAsComplete(int id) async {
    try {
      return await http
          .post("${Network.domain}/api/mark-as-complete".toUri, headers: {
        "accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }, body: {
        "todo_id": "$id",
      }).then((response) {
        print(response.body);
        return response.statusCode == 200;
      });
    } catch (e) {
      print("ERROR : $e");
      return false;
    }
  }

  Future<List<TodoTask>?> getEmployerActiveTasks() async {
    try {
      return await http
          .get("${Network.domain}/api/employer-todos".toUri, headers: {
        "accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }).then((response) {
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          final List _result = data['todos'];
          print("ACTIVE TASKS $_result");
          return _result.map((e) => TodoTask.fromJsonEmployer(e)).toList();
        }
        Fluttertoast.showToast(
          msg: "Error ${response.statusCode}: ${response.reasonPhrase}",
        );
        return null;
      });
    } catch (e) {
      return null;
    }
  }

  Future<List<TodoTask>?> getTodos() async {
    try {
      return await http
          .get("${Network.domain}/api/employee-todos".toUri, headers: {
        "accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }).then((response) {
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          final List _result = data['todos'];
          return _result.map((e) => TodoTask.fromJson(e)).toList();
        }
        Fluttertoast.showToast(
          msg: "Error ${response.statusCode}: ${response.reasonPhrase}",
        );
        return null;
      });
    } catch (e) {
      return null;
    }
  }

  Future<List<model.TaskHistory>> getAllHistory() async {
    try {
      return await http.get("${Network.domain}/api/history".toUri, headers: {
        "accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }).then((response) {
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          final List _res = data['task_history']['data'];
          print("DATA $_res");
          return _res.map((e) => model.TaskHistory.fromJson(e)).toList();
        }
        print("ERROR : ${response.statusCode} ${response.reasonPhrase}");
        return List.empty();
      });
    } catch (e, s) {
      print("ERROR : $e $s");
      return List.empty();
    }
  }

  Future<List<Task>?> getTasks({int? categoryId}) async {
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
          print("TASK RESULT : $_result");
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
