import 'package:terra/utils/network.dart';

class Category {
  final int id;
  final String name;
  final String icon;
  const Category({required this.id, required this.icon, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'].toInt(),
        icon: "${Network.domain}${json['icon']}",
        name: json['name'],
      );
  @override
  String toString() => "${toJson()}";

  Map<String, dynamic> toJson() => {
        "id": id,
        "icon": icon,
        "name": name,
      };
}
