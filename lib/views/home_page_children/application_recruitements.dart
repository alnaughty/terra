import 'dart:async';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/v2/application.dart';
import 'package:terra/services/API/application.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_model/applications.dart';
import 'package:terra/views/home_page_children/application_and_recruitment/application_and_recruitment_details.dart';
import 'package:timeago/timeago.dart' as timeago;

class JobsRecordPage extends StatefulWidget {
  const JobsRecordPage({super.key});

  @override
  State<JobsRecordPage> createState() => _JobsRecordPageState();
}

class _JobsRecordPageState extends State<JobsRecordPage> {
  final AppColors _colors = AppColors.instance;
  static final ApplicationsVm _vm = ApplicationsVm.instance;
  static final ApplicationApi _api = ApplicationApi.instance;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: size.width,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _colors.top,
                  _colors.bot,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Text(
                "Job ${loggedUser!.accountType == 1 ? "Recruitments" : "Applicants"}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Container(
            width: double.maxFinite,
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: const Text(
              "NOTE: Slide left to accept or reject and press to show details.",
              style: TextStyle(
                color: Colors.black38,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: StreamBuilder<List<MyApplication>>(
                stream: _vm.stream,
                builder: (_, snapshot) {
                  if (snapshot.hasError || !snapshot.hasData) {
                    return SizedBox(
                      width: size.width,
                      // height: size.height - 60,
                      child: Center(
                        child: Image.asset(
                          "assets/images/loader.gif",
                          width: size.width * .5,
                        ),
                      ),
                    );
                  }
                  final List<MyApplication> _applications = snapshot.data!;
                  if (_applications.isEmpty) {
                    return Center(
                      child: Text(
                        "No ${loggedUser!.accountType == 1 ? "Recruitement" : "Applicants"} Available",
                        style: const TextStyle(
                          color: Colors.black38,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                  _applications
                      .sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  // return ListVie
                  return LiquidPullToRefresh(
                    onRefresh: () async {
                      final Completer<void> completer = Completer<void>();
                      await _api.fetchUserApplication().then((value) {
                        _vm.populate(value);
                        completer.complete();
                        print("REFETCHED!");
                      });
                      return completer.future;
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 5),
                      itemBuilder: (_, i) {
                        final MyApplication _app = _applications[i];
                        return Slidable(
                          key: ValueKey(_app.id),
                          enabled: _app.status == "checking",
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              // SlidableAction(
                              //   onPressed: (_) async {
                              //     // await _api.approveApplication(id)
                              //   },
                              //   backgroundColor: Colors.red,
                              //   foregroundColor: Colors.white,
                              //   icon: Icons.close,
                              //   label: 'Reject',
                              // ),
                              if (_app.status != "approved") ...{
                                SlidableAction(
                                  onPressed: (_) async {
                                    await _api
                                        .approveApplication(_app.id)
                                        .whenComplete(() {
                                      _app.status = "approved";
                                      if (mounted) setState(() {});
                                    });
                                  },
                                  backgroundColor: _colors.top,
                                  foregroundColor: Colors.white,
                                  icon: Icons.check,
                                  label: 'Accept',
                                ),
                              },
                            ],
                          ),
                          child: ListTile(
                            onTap: () async {
                              await showGeneralDialog(
                                context: context,
                                barrierColor: Colors.black.withOpacity(.5),
                                barrierLabel: "",
                                barrierDismissible: true,
                                transitionBuilder: (_, a1, a2, c) =>
                                    Transform.scale(
                                  scale: a1.value,
                                  child: FadeTransition(
                                    opacity: a1,
                                    child: c,
                                  ),
                                ),
                                transitionDuration: const Duration(
                                  milliseconds: 500,
                                ),
                                pageBuilder: (_, a1, a2) => AlertDialog(
                                  backgroundColor: Colors.white,
                                  actions: [
                                    TextButton(
                                      style: ButtonStyle(
                                          foregroundColor:
                                              MaterialStateProperty.resolveWith(
                                        (states) => Colors.red,
                                      )),
                                      onPressed: () {
                                        Navigator.of(context).pop(null);
                                      },
                                      child: const Text("Close"),
                                    )
                                  ],
                                  content: ApplicationAndRecruitmentDetails(
                                    data: _app,
                                  ),
                                ),
                              );
                            },
                            trailing: _app.status == "approved"
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                    size: 20,
                                  )
                                : null,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            tileColor: Colors.grey.shade100,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: CachedNetworkImage(
                                imageUrl: _app.applicationFrom.avatar,
                                height: 50,
                                width: 50,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _app.applicationFrom.fullname
                                        .capitalizeWords(),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  timeago.format(
                                    _app.updatedAt,
                                  ),
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black.withOpacity(.3)),
                                )
                              ],
                            ),
                            subtitle: Text(
                              loggedUser!.accountType == 1
                                  ? "Wants to Hire you for ${_app.task.category.name}"
                                  : "Is Applying for ${_app.task.category.name}",
                              style: const TextStyle(
                                color: Colors.black38,
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, i) {
                        return const SizedBox(
                          height: 10,
                        );
                      },
                      itemCount: _applications.length,
                    ),
                  );
                },
              ),
            ),
          ),
          // Column(
          //   children: [
          //     const SizedBox(
          //       height: 10,
          //     ),
          //     SizedBox(
          //       width: double.maxFinite,
          //       height: 10,
          //       child: Center(
          //         child: Container(
          //           width: 50,
          //           height: 5,
          //           decoration: BoxDecoration(
          //               color: Colors.grey.shade600,
          //               borderRadius: BorderRadius.circular(20)),
          //         ),
          //       ),
          //     ),
          //     Text(
          //       "$itemCount Histor${itemCount > 1 ? "ies" : "y"}",
          //       style: TextStyle(
          //         color: Colors.grey.shade700,
          //         fontSize: 12,
          //       ),
          //     ),
          //     const SizedBox(
          //       height: 10,
          //     ),
          //   ],
          // ),
          // Expanded(
          //   child: ListView.separated(
          //     padding: const EdgeInsets.all(0),
          //     itemBuilder: (_, i) => ListTile(
          //       title: Text("SAMPLE ACTIVITY #${i + 1}"),
          //       subtitle: Text(DateFormat("MMM dd, yyyy")
          //           .format(DateTime.now().add(Duration(days: i)))),
          //     ),
          //     separatorBuilder: (_, __) => const SizedBox(
          //       height: 10,
          //     ),
          //     itemCount: itemCount,
          //   ),
          // ),
        ],
      ),
    );
  }
}
