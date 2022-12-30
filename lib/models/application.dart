import 'package:terra/models/raw_job.dart';

class Application {
  final int id;
  final String status;
  final double rate;
  final RawJob task;
  final DateTime requestedOn;
  const Application({
    required this.id,
    required this.status,
    required this.rate,
    required this.task,
    required this.requestedOn,
  });

  factory Application.fromJson(Map<String, dynamic> json) => Application(
        id: json['id'].toInt(),
        status: json['status'] ?? "APPROVED",
        rate: json['rate'].toDouble(),
        task: RawJob.fromJson(json['task']),
        requestedOn: json['created_at'] == null
            ? DateTime.now()
            : DateTime.parse(
                json['created_at'].toString(),
              ),
      );
  Map<String, dynamic> toJson() => {
        "id": id,
        "status": status,
        "requested_on": requestedOn,
        "rate": rate,
        "task": task,
      };

  @override
  String toString() => "${toJson()}";
}
