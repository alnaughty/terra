import 'package:terra/models/v2/raw_task.dart';
import 'package:terra/models/v2/terran.dart';

class MyApplication {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  String status;
  final double rate;
  final Terran applicationFrom;
  final RawTaskV2 task;
  MyApplication({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.rate,
    required this.applicationFrom,
    required this.task,
  });

  factory MyApplication.fromJson(Map<String, dynamic> json) => MyApplication(
        id: json['id'].toInt(),
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        status: json['status'] ?? "checking",
        rate: double.parse(json['rate']?.toString() ?? "0.0"),
        applicationFrom: Terran.fromJson(json['user']),
        task: RawTaskV2.fromJson(json['task']),
      );

  @override
  String toString() => "${toJson()}";

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "rate": rate,
        "user": applicationFrom.toString(),
        "task": task,
      };
}
