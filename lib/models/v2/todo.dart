import 'package:terra/models/v2/raw_task.dart';
import 'package:terra/models/v2/terran.dart';

class TodoTask {
  final int id;
  final RawTaskV2 task;
  final Terran user;

  final DateTime createdAt;
  const TodoTask({
    required this.id,
    required this.task,
    required this.createdAt,
    required this.user,
  });
  factory TodoTask.fromJson(Map<String, dynamic> json) => TodoTask(
        id: json['id'].toInt(),
        task: RawTaskV2.fromJson(json['task']),
        createdAt: DateTime.parse(json['created_at']),
        user: Terran.fromJson(json['employer']),
      );
  factory TodoTask.fromJsonEmployer(Map<String, dynamic> json) => TodoTask(
        id: json['id'].toInt(),
        task: RawTaskV2.fromJson(json['task']),
        createdAt: DateTime.parse(json['created_at']),
        user: Terran.fromJson(json['employee']),
      );
  @override
  String toString() => "${toJson()}";
  Map<String, dynamic> toJson() => {
        "id": id,
        "task": task,
        "employer": user,
        "created_at": createdAt.toString(),
      };
}
