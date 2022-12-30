import 'package:terra/models/category.dart';
import 'package:terra/models/user_details.dart';

class RawJob {
  final int id;
  final String title;
  final String address;
  final String brgy;
  final String city;
  final int urgency;
  final double price;
  final String? landmark;
  final String? details;
  final String status;
  final String latlong;
  final int categoryId;
  final bool isNegotiable;
  final int limit;
  bool hasApplied;

  RawJob({
    required this.id,
    required this.title,
    required this.address,
    required this.brgy,
    required this.city,
    required this.urgency,
    required this.isNegotiable,
    required this.details,
    required this.landmark,
    required this.latlong,
    required this.price,
    required this.status,
    required this.hasApplied,
    required this.categoryId,
    required this.limit,
  });

  factory RawJob.fromJson(Map<String, dynamic> json) => RawJob(
        id: json['id'].toInt(),
        title: json['title'],
        address: json['complete_address'],
        brgy: json['barangay'],
        city: json['city'],
        urgency: json['urgency'].toInt(),
        isNegotiable: json['is_negotiable'] == null
            ? false
            : json['is_negotiable'].toInt() == 1,
        details: json['details'],
        landmark: json['landmark'] ?? "",
        latlong: json['latlong'],
        price: json['rate'].toDouble(),
        status: json["status"] ?? "Unavailable",
        hasApplied: json['is_apply'] == null ? false : json['is_apply'] == 1,
        categoryId: json['category_id'].toInt(),
        limit: json['employee_limit'] ?? 1,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "category_id": categoryId,
        "is_negotiable": isNegotiable,
        "complete_address": address,
        "latlong": latlong,
        "rate": price,
        "status": status,
        "limit": limit,
      };
  @override
  String toString() => "${toJson()}";
}
