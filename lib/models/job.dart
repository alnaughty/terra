import 'package:terra/models/category.dart';
import 'package:terra/models/user_details.dart';

class Job {
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
  final bool isNegotiable;
  final Category category;
  final UserDetails postedBy;
  bool hasApplied;

  Job({
    required this.id,
    required this.title,
    required this.address,
    required this.brgy,
    required this.city,
    required this.urgency,
    required this.isNegotiable,
    required this.details,
    required this.category,
    required this.landmark,
    required this.latlong,
    required this.postedBy,
    required this.price,
    required this.status,
    required this.hasApplied,
  });

  factory Job.fromJson(Map<String, dynamic> json) => Job(
        id: json['id'].toInt(),
        title: json['title'] ?? "",
        address: json['complete_address'],
        brgy: json['barangay'],
        city: json['city'],
        urgency: json['urgency'].toInt(),
        isNegotiable: json['is_negotiable'] == null
            ? false
            : json['is_negotiable'].toInt() == 1,
        details: json['details'],
        category: Category.fromJson(json['category']),
        landmark: json['landmark'] ?? "",
        latlong: json['latlong'],
        postedBy: UserDetails.fromJson(json['user']),
        price: json['rate'].toDouble(),
        status: json["status"] ?? "Unavailable",
        hasApplied: json['is_apply'] == null ? false : json['is_apply'] == 1,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "category": category,
        "is_negotiable": isNegotiable,
        "complete_address": address,
        "latlong": latlong,
        "rate": price,
        "status": status,
      };
  @override
  String toString() => "${toJson()}";
}
