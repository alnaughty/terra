import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terra/utils/global.dart';

class TaskHistory {
  final int id;
  final String address;
  final int? urgency;
  final double rate;
  final String message;
  final String jobStatus;
  final LatLng coordinates;
  final bool isNegotiable;
  final int type;
  final int limit;
  final ApplicationState applcationState;
  const TaskHistory({
    required this.id,
    required this.address,
    required this.applcationState,
    required this.coordinates,
    required this.isNegotiable,
    required this.jobStatus,
    required this.limit,
    required this.message,
    required this.rate,
    required this.type,
    required this.urgency,
  });

  factory TaskHistory.fromJson(Map<String, dynamic> json) {
    final List<double> _latlng = (json['latlong'] ?? "0.0,0.0")
        .toString()
        .split(',')
        .map((e) => double.parse(e))
        .toList();
    return TaskHistory(
      id: json['id'],
      address: json['complete_address'] ?? "Unknown Address",
      applcationState: ApplicationState.fromJson(
        json['applicant'] ??
            {
              "id": 0,
              "created_at": DateTime.now().toString(),
              "updated_at": DateTime.now().toString(),
              "status": "pending",
              "rate": 0.0,
              "user_id": loggedUser!.id,
              "task_id": 0,
            },
      ),
      coordinates: json['latlong'] == null
          ? const LatLng(0.0, 0.0)
          : LatLng(_latlng.first, _latlng.last),
      isNegotiable: json['is_negotiable'] == 1,
      jobStatus: json['status'] ?? "pending",
      limit: json['limit'],
      message: json['message'] ?? "",
      rate: json['rate'] == null ? 0.0 : double.parse(json['rate'].toString()),
      type: json['type'] ?? 1,
      urgency: json['urgency'] ?? 1,
    );
  }
}

class ApplicationState {
  final int id;
  final DateTime updatedAt;
  final String status;
  final double applicationPrice;

  const ApplicationState({
    required this.id,
    required this.updatedAt,
    required this.status,
    required this.applicationPrice,
  });

  factory ApplicationState.fromJson(Map<String, dynamic> json) =>
      ApplicationState(
        id: json['id'],
        updatedAt: DateTime.parse(json['updated_at']),
        status: json['status'] ?? "pending",
        applicationPrice:
            json['rate'] == null ? 0.0 : double.parse(json['rate'].toString()),
      );
}
