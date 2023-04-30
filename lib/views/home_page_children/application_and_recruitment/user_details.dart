import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/extension/user.dart';
import 'package:terra/models/v2/terran.dart';
import 'package:terra/services/url_launcher.dart';
import 'package:terra/utils/color.dart';

class UserDetailsPage extends StatelessWidget {
  static final AppColors _colors = AppColors.instance;
  const UserDetailsPage({super.key, required this.user});
  final Terran user;
  static final Launcher _launcher = Launcher();
  Widget container({required String title, required Widget child}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child,
        ],
      );
  void makePhoneCall(String num) async {
    if (num.isValidPhone()) {
      await _launcher.makePhoneCall(num);
    } else {
      print("INVALID PHONE FORMAT");

      String n = num.replaceRange(0, 1, "+639");
      print("new number : $n");
      makePhoneCall(n);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.maxFinite,
            // padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [_colors.top, _colors.bot])),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              title: const Text("User Details"),
              titleTextStyle: TextStyle(
                color: Colors.grey.shade200,
                fontWeight: FontWeight.w600,
                fontSize: 17,
              ),
              actions: [
                IconButton(
                    tooltip: "Report User",
                    onPressed: () {
                      Fluttertoast.showToast(
                          msg: "Report Function is under development");
                    },
                    icon: const Icon(
                      Icons.flag,
                      color: Colors.white,
                    )),
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ),
                children: [
                  Center(
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user.avatar,
                        height: 200,
                        width: 200,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          user.fullname.capitalizeWords(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.black.withOpacity(.5),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Center(
                      child: Text(
                        user.bio ?? "No Bio Provided",
                        style: TextStyle(
                          color: Colors.black.withOpacity(.5),
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        container(
                          title: "Contacts",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                onTap: () async {
                                  await _launcher.sendEmail(user.email);
                                },
                                title: Text(
                                  user.email,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                leading: Icon(
                                  Icons.email,
                                  color: _colors.top,
                                ),
                                trailing: IconButton(
                                  onPressed: () async {
                                    await FlutterClipboard.copy(user.email)
                                        .whenComplete(() async {
                                      await Fluttertoast.showToast(
                                        msg:
                                            "${user.email} copied to clipboard",
                                      );
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.copy,
                                  ),
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                onTap: () async {
                                  makePhoneCall(user.mobileNumber);
                                },
                                title: Text(
                                  user.mobileNumber,
                                ),
                                leading: Icon(
                                  Icons.phone,
                                  color: _colors.top,
                                ),
                                trailing: IconButton(
                                  onPressed: () async {
                                    await FlutterClipboard.copy(user.email)
                                        .whenComplete(() async {
                                      await Fluttertoast.showToast(
                                        msg:
                                            "${user.mobileNumber} copied to clipboard",
                                      );
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.copy,
                                  ),
                                ),
                                contentPadding: EdgeInsets.zero,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        container(
                          title: "More Info",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.location_city_rounded,
                                  color: _colors.top,
                                ),
                                title: Text(
                                  user.city,
                                ),
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.calendar_month_rounded,
                                  color: _colors.top,
                                ),
                                title: Text(
                                  user.birthdate == null
                                      ? "No Birthdate Defined"
                                      : DateFormat("MMM dd, yyyy").format(
                                          user.birthdate!,
                                        ),
                                ),
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.group_rounded,
                                  color: _colors.top,
                                ),
                                title: Text(user.gender ?? "Undefined Gender"),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        container(
                          title: "Verification Level",
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.security,
                              color: _colors.top,
                            ),
                            title: Text(
                              user.toSecurityName,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
