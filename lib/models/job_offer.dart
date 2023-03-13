import 'package:terra/models/category.dart';
import 'package:terra/models/user_details.dart';

class JobOffer {
  final int id;
  final double rate;
  final int duration;
  final String? message;
  int status;
  final Category category;
  final UserDetails recruiter;
  JobOffer({
    required this.id,
    required this.rate,
    required this.duration,
    required this.category,
    required this.status,
    required this.recruiter,
    required this.message,
  });

  factory JobOffer.fromJson(Map<String, dynamic> json) => JobOffer(
        id: json['id'].toInt(),
        rate: json['rate'].toDouble(),
        duration: json['duration'].toInt(),
        category: Category.fromJson(json['category']),
        status: json['status'].toInt(),
        recruiter: UserDetails.fromJson(json['recuiter']),
        message: json['message'],
      );
}
