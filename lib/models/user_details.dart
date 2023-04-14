import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/category.dart';
import 'package:terra/models/chat/chat_room_member.dart';
import 'package:terra/utils/network.dart';

class UserDetails {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final int accountType;
  final String phoneNumber;
  String avatar;
  final String? street;
  final String? city;
  final String? country;
  final String fullName;
  final String status;
  final DateTime birthdate;
  List<Category> skills;
  final String firebaseId;
  bool hasVerifiedEmail;
  bool hasUploadedId;
  bool hasVerifiedNumber;
  UserDetails({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.accountType,
    required this.phoneNumber,
    required this.avatar,
    required this.status,
    required this.fullName,
    required this.skills,
    this.street,
    this.city,
    this.country,
    required this.hasUploadedId,
    required this.hasVerifiedEmail,
    required this.hasVerifiedNumber,
    required this.firebaseId,
    required this.birthdate,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    final List _skills = json['skills'] ?? [];

    return UserDetails(
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
        skills: _skills.map((e) => Category.fromJson(e)).toList(),
        firebaseId: json['firebase_id'] ?? "Anonymous User",
        hasUploadedId: json['has_id_email'].toString().toInt() == 1,
        hasVerifiedEmail: json['has_valid_email'].toString().toInt() == 1,
        hasVerifiedNumber:
            json['has_mobile_number_email'].toString().toInt() == 1,
        birthdate: json['birthdate'] == null
            ? DateTime.now()
            : DateTime.parse(json['birthdate']));
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "avatar": avatar,
        "status": status,
        "fullName": fullName,
        "skills": skills,
        "firebase_id": firebaseId,
      };
  @override
  String toString() => "${toJson()}";

  ChatRoomMember toMember() =>
      ChatRoomMember(id: firebaseId, displayName: fullName, avatar: avatar);
}
