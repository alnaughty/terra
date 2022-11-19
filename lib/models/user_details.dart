import 'package:terra/utils/network.dart';

class UserDetails {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final int accountType;
  final String phoneNumber;
  final String avatar;
  final String? street;
  final String? city;
  final String? country;
  final String fullName;
  final String status;

  const UserDetails({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.accountType,
    required this.phoneNumber,
    required this.avatar,
    required this.status,
    required this.fullName,
    this.street,
    this.city,
    this.country,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        id: json['id'].toInt(),
        firstName: json['first_name'] ?? "Unknown",
        lastName: json['last_name'] ?? "Unknown",
        email: json['email'] ?? "terra@app.ph",
        accountType: json['account_type'].toInt(),
        phoneNumber: json['mobile_number'],
        avatar: "${Network.domain}${json['avatar']}",
        status: json['status'],
        fullName: json['fullname'],
        city: json['city'],
        country: json['country'],
        street: json['barangay'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "avatar": avatar,
        "status": status,
        "fullName": fullName,
      };
  @override
  String toString() => "${toJson()}";
}
