/* THIS IS A REGISTERED USER */
import 'package:terra/models/chat/chat_room_member.dart';
import 'package:terra/utils/network.dart';

class Terran {
  final int id;
  final String firstname;
  final String lastname;
  final String? middlename;
  final String email;
  final int accountType;
  final String mobileNumber;
  final String avatar;
  final String firebaseId;
  final String brgy;
  final String city;
  final String country;
  final String? gender;
  final DateTime? birthdate;
  final String status;
  final String fullname;

  const Terran({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.middlename,
    required this.email,
    required this.avatar,
    required this.accountType,
    required this.brgy,
    required this.city,
    required this.country,
    required this.firebaseId,
    required this.mobileNumber,
    required this.fullname,
    required this.status,
    this.gender,
    this.birthdate,
  });
  factory Terran.fromJson(Map<String, dynamic> json) => Terran(
        id: json['id'].toInt(),
        firstname: json['first_name'] ?? "",
        lastname: json['last_name'] ?? "",
        email: json['email'] ?? "terran@user.terra",
        middlename: json['middlename'],
        avatar: "${Network.domain}${json['avatar']}",
        accountType: json['account_type'].toInt(),
        brgy: json['barangay'] ?? "None",
        city: json['city'] ?? "None",
        country: json['country'] ?? "None",
        firebaseId: json['firebase_id'] ?? "Anonymous User",
        mobileNumber: json['mobile_number'],
        fullname: json['fullname'] ?? "None",
        status: json['status'],
        gender: json['gender'],
        birthdate: json['birthdate'] == null
            ? null
            : DateTime.parse(json['birthdate']),
      );

  ChatRoomMember toMember() => ChatRoomMember(
        id: firebaseId,
        displayName: fullname,
        avatar: avatar,
      );
}
