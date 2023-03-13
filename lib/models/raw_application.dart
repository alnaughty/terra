import 'package:terra/models/raw_job.dart';
import 'package:terra/models/user_details.dart';

class RawApplication {
  final int id;
  String status;
  final double rate;
  final DateTime createdAt;
  final UserDetails user;
  final RawJob task;

  RawApplication(
      {required this.id,
      required this.status,
      required this.rate,
      required this.createdAt,
      required this.user,
      required this.task});

  factory RawApplication.fromJson(Map<String, dynamic> json) => RawApplication(
        id: json['id'].toInt(),
        status: json['status'] ?? "checking",
        rate: json['rate'].toDouble(),
        createdAt: DateTime.parse(json['created_at']),
        user: UserDetails.fromJson(json['user']),
        task: RawJob.fromJson(json['task']),
      );
}
