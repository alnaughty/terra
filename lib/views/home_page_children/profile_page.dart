import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/extension/user.dart';
import 'package:terra/services/API/auth.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/services/image_processor.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_data_component/user_position.dart';
import 'package:terra/view_model/posted_jobs.dart';
import 'package:terra/view_model/todo_vm.dart';
import 'package:terra/views/home_page_children/home_page_main_children/skill_update.dart';
import 'package:terra/views/home_page_children/profile_page_children/password_reset_page.dart';
import 'package:terra/views/home_page_children/profile_page_children/security_choice.dart';

import 'profile_page_children/my_negotiation_page.dart';

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
  final DataCacher _cacher = DataCacher.instance;
  final ImageProcessor _image = ImageProcessor.instance;
  final AuthApi _api = AuthApi();
  final double headerHeight = 350;
  static final UserPosition _pos = UserPosition.instance;
  static final UserApi _userApi = UserApi();
  static final PostedJobsVm _posted = PostedJobsVm.instance;
  static final TaskTodoVm _tasksTodo = TaskTodoVm.instance;
  bool isEditingBio = false;
  @override
  void initState() {
    print("PRFILE");
    _bio = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // await Future.delayed(timeStamp);
      if (loggedUser!.accountType != 1) {
        _posted.stream.listen((event) {
          if (event.isNotEmpty) {
            accountContent.add({
              "title": "Posted Jobs",
              "avatar": "posts.svg",
              "initial_data":
                  "${event.length} Job${event.length > 1 ? "s" : ""}",
              "onTap": () async {
                await Navigator.pushNamed(context, '/posted-jobs');
              },
            });
          }
        });
      } else {
        _tasksTodo.stream.listen((event) {
          if (event.isNotEmpty) {
            accountContent.add({
              "title": "Activities",
              "avatar": "todo.svg",
              "initial_data":
                  "${event.length} Task${event.length > 1 ? "s" : ""}",
              "onTap": () async {
                await Navigator.pushNamed(context, '/todo-tasks');
              },
            });
          }
        });
      }
      if (mounted) setState(() {});
    });
    super.initState();
  }

  late List<Map> accountContent = [
    {
      "title": "Details",
      "avatar": "profile_picture.png",
      "initial_data": loggedUser!.fullName.capitalizeWords(),
      "onTap": () async {
        await Navigator.pushNamed(context, "/update_user_details_page");
      },
    },
    {
      "title": "Profile Picture",
      "avatar": "profile_picture.png",
      "initial_data": null,
      "onTap": () async {
        await showModalBottomSheet(
          context: context,
          barrierColor: Colors.black.withOpacity(.5),
          isDismissible: true,
          useSafeArea: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(20),
          // ),
          constraints: const BoxConstraints(
            maxHeight: 180,
          ),
          builder: (_) => SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListTile(
                    onTap: () async {
                      await _image.pickImageGallery().then((File? value) async {
                        if (value == null) return;
                        print(value.path);
                        await _image.cropImage(value).then((ba) async {
                          if (ba == null) return;
                          Navigator.of(context).pop(null);
                          widget.loadingCallback(true);
                          await _userApi
                              .updateAvatar(base64Image: ba)
                              .whenComplete(() async {
                            await _userApi.details().then((u) {
                              loggedUser = u;
                              if (mounted) setState(() {});
                            });
                            widget.loadingCallback(false);
                          });
                        });
                      });
                    },
                    leading: const Icon(
                      CupertinoIcons.photo,
                    ),
                    title: const Text("Gallery"),
                  ),
                  ListTile(
                    onTap: () async {
                      await _image.pickImageCamera().then((value) async {
                        if (value == null) return;
                        await _image.cropImage(value).then((ba) async {
                          if (ba == null) return;
                          Navigator.of(context).pop(null);
                          widget.loadingCallback(true);
                          await _userApi
                              .updateAvatar(base64Image: ba)
                              .whenComplete(() async {
                            await _userApi.details().then((u) {
                              loggedUser = u;
                              if (mounted) setState(() {});
                            });
                            widget.loadingCallback(false);
                          });
                        });
                      });
                    },
                    leading: const Icon(
                      CupertinoIcons.camera,
                    ),
                    title: const Text("Camera"),
                  )
                ],
              ),
            ),
          ),
        );
      },
    },
    {
      "title": "Password",
      "avatar": "lock.svg",
      "initial_data": "*****",
      "onTap": () async {
        await showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: '',
          transitionDuration: const Duration(milliseconds: 500),
          transitionBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation, Widget child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          pageBuilder: (_, a1, a2) => Align(
            alignment: Alignment.topCenter,
            child: PasswordResetPage(
              onLoading: widget.loadingCallback,
            ),
          ),
        );
      },
    },
    {
      "title": "Security Level",
      "avatar": "shield-check.svg",
      "initial_data": loggedUser!.toSecurityName,
      "onTap": () async {
        await showModalBottomSheet(
          context: context,
          barrierColor: Colors.black.withOpacity(.5),
          isDismissible: true,
          useSafeArea: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(20),
          // ),
          // constraints: const BoxConstraints(
          //   maxHeight: 280,
          // ),
          builder: (_) => SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.white),
              child: const SecurityChoice(),
            ),
          ),
        );
      },
    },
    if (loggedUser!.accountType != 2) ...{
      {
        "title": "Skills",
        "avatar": "skills.png",
        "initial_data": "${loggedUser!.skills.length} Skills",
        "onTap": () async {
          await showModalBottomSheet(
            context: context,
            builder: (_) => SafeArea(
              top: false,
              child: SkillUpdateView(
                currentSkills: loggedUser!.skills,
                loadingCallback: (bool value) {
                  widget.loadingCallback(value);
                  if (mounted && !value) setState(() {});
                },
              ),
            ),
          );
        },
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
    {
      "title": "Completed Tasks",
      "avatar": "complete_task.svg",
      "initial_data": "",
      "onTap": () async {
        await Navigator.pushNamed(context, "/completed_tasks_page");
      },
    },
    {
      "title": "Task History",
      "avatar": "todo.svg",
      "initial_data": "",
      "onTap": () async {
        await Navigator.pushNamed(context, "/task_history_page");
      }
    },
    if (loggedUser!.accountType == 2) ...{
      {
        "title": "Active Tasks",
        "avatar": "todo.svg",
        "initial_data": "",
        "onTap": () async {
          await Navigator.pushNamed(context, "/employer_active_tasks");
        },
      },
    },
  ];

  @override
  void dispose() {
    _bio.dispose();
    super.dispose();
  }

  final GlobalKey<FormState> _kBio = GlobalKey<FormState>();
  late final TextEditingController _bio;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // resizeToAvoidBottomInset: true,
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
                        child: loggedUser!.avatar.isEmpty
                            ? Image.asset(
                                "assets/images/icon-logo.png",
                                width: 40,
                                height: 40,
                              )
                            : Image.network(
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
                            "Welcome, ${loggedUser!.firstName.capitalizeWords()}",
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
                          () {
                            widget.loadingCallback(false);
                          },
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
            Container(
              padding: const EdgeInsets.only(
                  left: 20, right: 15, top: 15, bottom: 15),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      child: isEditingBio
                          ? Form(
                              key: _kBio,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _bio,
                                    validator: (String? text) {
                                      if (text == null) {
                                        return "Something went wrong";
                                      } else if (text.isEmpty) {
                                        return "You cannot put an empty bio";
                                      }
                                    },
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 3,
                                    cursorColor: Colors.black,
                                    decoration: InputDecoration(
                                      hintText: loggedUser!.bio ?? "Your Bio",
                                      hintStyle: TextStyle(
                                        color: Colors.black.withOpacity(.5),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  MaterialButton(
                                    onPressed: () async {
                                      if (_kBio.currentState!.validate()) {
                                        FocusScope.of(context).unfocus();
                                        final String b = _bio.text;
                                        _bio.clear();
                                        await _userApi
                                            .updateBio(b)
                                            .then((value) {
                                          if (value) {
                                            loggedUser!.bio = b;
                                          }
                                          isEditingBio = false;
                                          if (mounted) setState(() {});
                                        });
                                      }
                                    },
                                    height: 55,
                                    padding: EdgeInsets.zero,
                                    child: Center(
                                      child: Container(
                                        height: 55,
                                        width: double.maxFinite,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          gradient: LinearGradient(
                                            colors: [_colors.top, _colors.bot],
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "Submit",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                loggedUser!.bio ?? "No bio found",
                                style: TextStyle(
                                  fontSize: 14.5,
                                  color: Colors.black.withOpacity(.5),
                                ),
                              ),
                            ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isEditingBio = !isEditingBio;
                      });
                      if (loggedUser!.bio == null) {
                        // ADD BIO
                      } else {
                        // UPDATE BIO
                      }
                    },
                    icon: Icon(
                      loggedUser!.bio == null
                          ? Icons.add_circle_outline_rounded
                          : Icons.edit_note_rounded,
                      color: _colors.top,
                    ),
                  )
                ],
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
                  ...accountContent.map(
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
                  // Container(
                  //   width: size.width,
                  //   padding:
                  //       const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                  //   decoration: const BoxDecoration(
                  //     color: Colors.white,
                  //     border: Border(
                  //       bottom: BorderSide(
                  //         color: Colors.black12,
                  //       ),
                  //     ),
                  //   ),
                  //   child: const Text(
                  //     "Transactions",
                  //     style: TextStyle(
                  //       color: Colors.black54,
                  //     ),
                  //   ),
                  // ),
                  // ListTile(
                  //   onTap: () async {
                  //     await Navigator.push(
                  //       context,
                  //       PageTransition(
                  //           child: const MyNegotiationPage(),
                  //           type: PageTransitionType.leftToRight),
                  //     );
                  //   },
                  //   leading: Image.asset(
                  //     "assets/icons/negotiation.png",
                  //     width: 20,
                  //     height: 20,
                  //     color: Colors.black54,
                  //   ),
                  //   trailing: const Icon(
                  //     Icons.chevron_right_outlined,
                  //     color: Colors.black54,
                  //   ),
                  //   title: Row(
                  //     children: const [
                  //       Expanded(
                  //         child: Text(
                  //           "My Negotiations",
                  //           style: TextStyle(
                  //             color: Colors.black54,
                  //             fontSize: 14,
                  //           ),
                  //         ),
                  //       ),
                  //       // if (e['initial_data'] != null) ...{
                  //       //   const SizedBox(
                  //       //     width: 10,
                  //       //   ),
                  //       //   ConstrainedBox(
                  //       //     constraints: BoxConstraints(
                  //       //       maxWidth: size.width * .3,
                  //       //     ),
                  //       //     child: Text(
                  //       //       e['initial_data'].toString(),
                  //       //       maxLines: 1,
                  //       //       textAlign: TextAlign.right,
                  //       //       overflow: TextOverflow.ellipsis,
                  //       //       style: const TextStyle(
                  //       //         color: Colors.black38,
                  //       //         fontSize: 14,
                  //       //       ),
                  //       //     ),
                  //       //   )
                  //       // },
                  //     ],
                  //   ),
                  // ),
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
                                },
                                {
                                  "title": "City",
                                  "avatar": "city.png",
                                  "initial_data": placemark.locality ?? "UNSET",
                                },
                              ].map(
                                (e) => ListTile(
                                  onTap: e['onTap'] as Function()?,
                                  leading:
                                      e['avatar'].toString().contains(".svg")
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
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
