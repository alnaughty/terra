import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terra/models/category.dart';
import 'package:terra/models/v2/terran.dart';

class Task {
  final int id;
  final String address;
  final int? urgency;
  final double? rate;
  final String? message;
  final String status;
  final LatLng coordinates;
  final bool isNegotiable;
  final int type;
  final int limit;
  bool hasApplied;
  final DateTime datePosted;
  final Category category;
  final Terran postedBy;
  Task({
    required this.id,
    required this.address,
    required this.category,
    required this.postedBy,
    required this.hasApplied,
    required this.datePosted,
    required this.limit,
    required this.coordinates,
    required this.isNegotiable,
    required this.status,
    required this.type,
    this.message,
    this.rate,
    this.urgency,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final List<double> _latlng = json['latlong']
        .toString()
        .split(",")
        .map((e) => double.parse(e))
        .toList();
    return Task(
      id: json['id'].toInt(),
      address: json['complete_address'] ?? "",
      category: Category.fromJson(json['category']),
      postedBy: Terran.fromJson(json['user']),
      hasApplied: json['is_apply'] == 1,
      datePosted: DateTime.parse(json['created_at']),
      limit: json['limit'],
      coordinates: LatLng(_latlng[0], _latlng[1]),
      isNegotiable: json['is_negotiable'] == 1,
      status: json['status'],
      type: json['type'],
      message: json['message'],
      rate: json['rate'] == null ? null : double.parse(json['rate'].toString()),
      urgency: json['urgency'],
    );
  }
  @override
  String toString() => "${toJson()}";

  Map<String, dynamic> toJson() => {
        "id": id,
        "has_applied": hasApplied,
        "is_negotiable": isNegotiable,
        "category": category,
      };
}
