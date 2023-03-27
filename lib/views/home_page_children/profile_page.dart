import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/services/API/auth.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_data_component/user_position.dart';
import 'package:terra/views/home_page_children/home_page_main_children/skill_update.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.loadingCallback,
  });
  final ValueChanged<bool> loadingCallback;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AppColors _colors = AppColors.instance;
  final AuthApi _api = AuthApi();
  final double headerHeight = 350;
  static final UserPosition _pos = UserPosition.instance;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_colors.top, _colors.bot],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: SafeArea(
              bottom: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      color: Colors.white,
                      child: Image.network(
                        loggedUser!.avatar,
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome, ${loggedUser!.firstName.capitalize()}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          loggedUser!.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(.8),
                            fontWeight: FontWeight.w300,
                            height: 1,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  TextButton(
                    onPressed: () async {
                      widget.loadingCallback(true);
                      await _api.logout(context).whenComplete(
                            () => widget.loadingCallback(false),
                          );
                    },
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.white,
                    )),
                    child: const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 20,
              ),
              children: [
                Container(
                  width: size.width,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black12,
                      ),
                    ),
                  ),
                  child: const Text(
                    "My Account",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ),
                ...[
                  {
                    "title": "User Data",
                    "avatar": "profile_picture.png",
                    "initial_data": loggedUser!.fullName.capitalizeWords(),
                    "onTap": () {
                      print("DATA");
                    },
                  },
                  {
                    "title": "Profile Picture",
                    "avatar": "profile_picture.png",
                    "initial_data": null,
                    "onTap": () {
                      print("DATA");
                    },
                  },
                  {
                    "title": "Password",
                    "avatar": "lock.svg",
                    "initial_data": "*****",
                    "onTap": () {
                      print("DATA");
                    },
                  },
                  {
                    "title": "Skills",
                    "avatar": "skills.png",
                    "initial_data": "${loggedUser!.skills.length} Skills",
                    "onTap": () {
                      print("DATA");
                    },
                  },
                  {
                    "title": "Type",
                    "avatar": "types.png",
                    "initial_data": loggedUser!.accountType == 2
                        ? "Employer"
                        : loggedUser!.accountType == 1
                            ? "Job Seeker"
                            : "Hybrid",
                    "onTap": () {
                      print("DATA");
                    },
                  },
                ].map(
                  (e) => ListTile(
                    onTap: e['onTap'] as Function(),
                    leading: e['avatar'].toString().contains(".svg")
                        ? SvgPicture.asset(
                            "assets/icons/${e['avatar']}",
                            width: 20,
                            height: 20,
                            color: Colors.black54,
                          )
                        : Image.asset(
                            "assets/icons/${e['avatar']}",
                            width: 20,
                            height: 20,
                            color: Colors.black54,
                          ),
                    trailing: e['onTap'] != null
                        ? const Icon(
                            Icons.chevron_right_outlined,
                            color: Colors.black54,
                          )
                        : null,
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e['title'].toString(),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (e['initial_data'] != null) ...{
                          const SizedBox(
                            width: 10,
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: size.width * .3,
                            ),
                            child: Text(
                              e['initial_data'].toString(),
                              maxLines: 1,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black38,
                                fontSize: 14,
                              ),
                            ),
                          )
                        },
                      ],
                    ),
                  ),
                ),
                StreamBuilder<LatLng>(
                  stream: _pos.stream,
                  builder: (_, snapshot) {
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Container();
                    }
                    final LatLng pos = snapshot.data!;
                    return FutureBuilder<Placemark?>(
                      future: _pos.translateCoordinate(),
                      builder: (_, future) {
                        if (future.hasError || !future.hasData) {
                          return Container();
                        }
                        final Placemark placemark = future.data!;
                        return Column(
                          children: [
                            Container(
                              width: size.width,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.black12,
                                  ),
                                ),
                              ),
                              child: const Text(
                                "Location",
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            ...[
                              {
                                "title": "Country",
                                "avatar": "country.png",
                                "initial_data": placemark.country ?? "UNSET",
                                // "onTap": () {
                                //   print("DATA");
                                // },
                              },
                              {
                                "title": "City",
                                "avatar": "city.png",
                                "initial_data": placemark.locality ?? "UNSET",
                                // "onTap": () {
                                //   print("DATA");
                                // },
                              },
                            ].map(
                              (e) => ListTile(
                                onTap: e['onTap'] as Function()?,
                                leading: e['avatar'].toString().contains(".svg")
                                    ? SvgPicture.asset(
                                        "assets/icons/${e['avatar']}",
                                        width: 20,
                                        height: 20,
                                        color: Colors.black54,
                                      )
                                    : Image.asset(
                                        "assets/icons/${e['avatar']}",
                                        width: 20,
                                        height: 20,
                                        color: Colors.black54,
                                      ),
                                trailing: e['onTap'] != null
                                    ? const Icon(
                                        Icons.chevron_right_outlined,
                                        color: Colors.black54,
                                      )
                                    : null,
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        e['title'].toString(),
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (e['initial_data'] != null) ...{
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: size.width * .3,
                                        ),
                                        child: Text(
                                          e['initial_data'].toString(),
                                          style: const TextStyle(
                                            color: Colors.black38,
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                    },
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                        // return Text(
                        //   "${placemark.street ?? ""} ${placemark.locality ?? ""} ${placemark.country}",
                        //   style: TextStyle(
                        //     fontSize: 14.5,
                        //     color: Colors.grey.shade600,
                        //   ),
                        // );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      // body: SingleChildScrollView(
      //   child: Column(
      //     children: [
      //       SizedBox(
      //         width: size.width,
      //         height: headerHeight,
      //         child: Stack(
      //           children: [
      //             Container(
      //               width: size.width,
      //               height: headerHeight * .5,
      //               decoration: BoxDecoration(
      //                   gradient: LinearGradient(
      //                 colors: [
      //                   _colors.top,
      //                   _colors.bot,
      //                 ],
      //               )),
      //             ),
      //             Positioned(
      //               top: (headerHeight * .5) - 50,
      //               child: SizedBox(
      //                 width: size.width,
      //                 height: headerHeight * .65,
      //                 child: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.center,
      //                   children: [
      // ClipRRect(
      //   borderRadius: BorderRadius.circular(100),
      //   child: Container(
      //     color: Colors.white,
      //     child: Image.network(
      //       loggedUser!.avatar,
      //       width: 100,
      //       height: 100,
      //     ),
      //   ),
      //   // child: Container(
      //   //   width: 100,
      //   //   height: 100,
      //   //   // decoration: BoxDecoration(
      //   //   //   borderRadius: BorderRadius.circular(100),
      //   //   //   color: Colors.orange,
      //   //   // ),
      //   // ),
      // ),
      //                     const SizedBox(
      //                       height: 5,
      //                     ),
      //                     Row(
      //                       mainAxisAlignment: MainAxisAlignment.center,
      //                       children: List.generate(
      //                         5,
      //                         (index) => Icon(
      //                           index < 4 ? Icons.star : Icons.star_border,
      //                           color: index < 4 ? Colors.orange : Colors.grey,
      //                           size: 15,
      //                         ),
      //                       ),
      //                     ),
      //                     const SizedBox(
      //                       height: 5,
      //                     ),
      //                     Text(
      //                       loggedUser!.fullName,
      //                       style: const TextStyle(
      //                         fontWeight: FontWeight.w600,
      //                         fontSize: 16,
      //                       ),
      //                     ),
      //                     Text(
      //                       loggedUser!.email,
      //                       style: TextStyle(
      //                         fontWeight: FontWeight.w300,
      //                         fontSize: 12,
      //                         color: Colors.black.withOpacity(.6),
      //                       ),
      //                     ),
      //                     const SizedBox(
      //                       height: 10,
      //                     ),
      //                     // Center(
      //                     //   child: SizedBox(
      //                     //     width: size.width * .4,
      //                     //     height: 25,
      //                     //     child: Row(
      //                     //       mainAxisAlignment:
      //                     //           MainAxisAlignment.spaceBetween,
      //                     //       children: List.generate(
      //                     //         5,
      //                     //         (index) => Container(
      //                     //           width: 25,
      //                     //           height: 25,
      //                     //           decoration: BoxDecoration(
      //                     //             borderRadius: BorderRadius.circular(5),
      //                     //             gradient: LinearGradient(
      //                     //               begin: Alignment.topCenter,
      //                     //               end: Alignment.bottomCenter,
      //                     //               colors: [
      //                     //                 _colors.top,
      //                     //                 _colors.bot,
      //                     //               ],
      //                     //             ),
      //                     //           ),
      //                     //         ),
      //                     //       ),
      //                     //     ),
      //                     //   ),
      //                     // ),
      //                     // const SizedBox(
      //                     //   height: 10,
      //                     // ),
      //                     Align(
      //                       alignment: Alignment.center,
      //                       child: Row(
      //                         mainAxisAlignment: MainAxisAlignment.center,
      //                         children: const [
      //                           Icon(
      //                             Icons.verified_user,
      //                             color: Colors.green,
      //                             size: 20,
      //                           ),
      //                           SizedBox(
      //                             width: 10,
      //                           ),
      //                           Text(
      //                             "Verified",
      //                             style: TextStyle(
      //                               color: Colors.green,
      //                               fontSize: 13,
      //                             ),
      //                           )
      //                         ],
      //                       ),
      //                     )
      //                   ],
      //                 ),
      //               ),
      //             )
      //           ],
      //         ),
      //       ),
      //       const SizedBox(
      //         height: 30,
      //       ),
      //       Container(
      //         width: size.width,
      //         padding: const EdgeInsets.symmetric(
      //           horizontal: 20,
      //           vertical: 0,
      //         ),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             ListTile(
      //               contentPadding: const EdgeInsets.all(0),
      //               title: const Text("Country"),
      //               subtitle: Text(
      //                 loggedUser!.country ?? "Unknown",
      //               ),
      //             ),
      //             ListTile(
      //               contentPadding: const EdgeInsets.all(0),
      //               title: const Text("Location"),
      //               subtitle: Text(
      //                 loggedUser!.city ?? "Unknown",
      //               ),
      //             ),
      //             ListTile(
      //               contentPadding: const EdgeInsets.all(0),
      //               title: Row(
      //                 children: [
      //                   const Expanded(
      //                     child: Text("Skills"),
      //                   ),
      //                   IconButton(
      //                     onPressed: () async {
      //                       await showGeneralDialog(
      //                         context: context,
      //                         pageBuilder: (_, a1, a2) => Container(),
      //                         barrierColor: Colors.black.withOpacity(0.5),
      //                         transitionBuilder: (context, a1, a2, c) {
      //                           return Transform.scale(
      //                             scale: a1.value,
      //                             child: Opacity(
      //                               opacity: a1.value,
      //                               child: AlertDialog(
      //                                 shape: OutlineInputBorder(
      //                                   borderRadius:
      //                                       BorderRadius.circular(16.0),
      //                                 ),
      //                                 title: Text(
      //                                     "${loggedUser!.skills.isEmpty ? 'Add' : "Update"} your skills"),
      //                                 content: SkillUpdateView(
      //                                   loadingCallback:
      //                                       (bool isLoading) async {
      //                                     print("ROMAR : $isLoading");
      //                                     widget.loadingCallback(isLoading);
      //                                     if (!isLoading) {
      //                                       if (mounted) setState(() {});
      //                                     } else {}
      //                                   },
      //                                   currentSkills: loggedUser!.skills,
      //                                 ),
      //                               ),
      //                             ),
      //                           );
      //                         },
      //                         transitionDuration:
      //                             const Duration(milliseconds: 200),
      //                         barrierDismissible: true,
      //                         barrierLabel: '',
      //                       );
      //                     },
      //                     icon: const Icon(Icons.add),
      //                   )
      //                 ],
      //               ),
      //               subtitle: loggedUser!.skills.isNotEmpty
      //                   ? SizedBox(
      //                       height: 50,
      //                       child: ListView.separated(
      //                         scrollDirection: Axis.horizontal,
      //                         itemBuilder: (_, i) => InputChip(
      //                           avatar:
      //                               Image.network(loggedUser!.skills[i].icon),
      //                           label: Text(loggedUser!.skills[i].name),
      //                           onPressed: () {},
      //                         ),
      //                         separatorBuilder: (_, i) => const SizedBox(
      //                           width: 10,
      //                         ),
      //                         itemCount: loggedUser!.skills.length,
      //                       ),
      //                     )
      //                   : Container(),
      //             ),
      //             const SizedBox(
      //               height: 30,
      //             ),
      //             Center(
      //               child: TextButton.icon(
      //                 style: ButtonStyle(
      //                     overlayColor: MaterialStateProperty.resolveWith(
      //                         (states) => Colors.red.withOpacity(.2))),
      //                 onPressed: () async {
      // widget.loadingCallback(true);
      // await _api.logout(context).whenComplete(
      //       () => widget.loadingCallback(false),
      //     );
      //                 },
      //                 icon: const Icon(
      //                   Icons.exit_to_app,
      //                   color: Colors.red,
      //                 ),
      //                 label: const Text(
      //                   "LOGOUT",
      //                   style: TextStyle(
      //                     color: Colors.red,
      //                   ),
      //                 ),
      //               ),
      //             )
      //             // ListTile(
      //             //   contentPadding: const EdgeInsets.all(0),
      //             //   title: const Text(
      //             //     "Work Album",
      //             //   ),
      //             //   subtitle: Container(
      //             //     height: 100,
      //             //     width: size.width - 40,
      //             //     child: Row(
      //             //       children: [
      //             //         Container(
      //             //           width: 85,
      //             //           height: 100,
      //             //           decoration: BoxDecoration(
      //             //             color: Colors.grey.shade400,
      //             //             borderRadius: BorderRadius.circular(10),
      //             //           ),
      //             //           child: MaterialButton(
      //             //             onPressed: () {},
      //             //             height: 100,
      //             //             child: Center(
      //             //               child: Icon(
      //             //                 Icons.add,
      //             //                 color: _colors.mid,
      //             //                 size: 30,
      //             //               ),
      //             //             ),
      //             //           ),
      //             //         ),
      //             //         const SizedBox(
      //             //           width: 10,
      //             //         ),
      //             //         Expanded(
      //             //           child: ListView.separated(
      //             //             scrollDirection: Axis.horizontal,
      //             //             itemBuilder: (_, i) => Container(
      //             //               width: 85,
      //             //               height: 100,
      //             //               decoration: BoxDecoration(
      //             //                 color: Colors.grey.shade400,
      //             //                 borderRadius: BorderRadius.circular(10),
      //             //               ),
      //             //             ),
      //             //             separatorBuilder: (_, i) => const SizedBox(
      //             //               width: 10,
      //             //             ),
      //             //             itemCount: 5,
      //             //           ),
      //             //         )
      //             //       ],
      //             //     ),
      //             //   ),
      //             // )
      //           ],
      //         ),
      //       )
      //     ],
      //   ),
      // ),
    );
  }
}
