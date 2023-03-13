import 'package:terra/models/category.dart';
import 'package:terra/models/user_details.dart';

class Applicant {
  final int id;
  final UserDetails user;
  final Category category;
  int status;
  final double rate;
  final int duration;
  final DateTime startDate;
  Applicant({
    required this.id,
    required this.user,
    required this.category,
    required this.startDate,
    required this.status,
    required this.rate,
    required this.duration,
  });
  factory Applicant.fromJson(Map<String, dynamic> json) => Applicant(
      id: json['id'],
      user: UserDetails.fromJson(json['recuitee']),
      category: Category.fromJson(json['category']),
      startDate: DateTime.parse(json['expected_start_date']),
      status: json['status'],
      rate: json['rate']?.toDouble() ?? 100.0,
      duration: json['duration']?.toInt() ?? 7);
}
