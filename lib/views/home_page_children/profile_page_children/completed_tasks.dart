import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/v2/todo.dart';
import 'package:terra/services/API/v2/task_api.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/views/home_page_children/profile_page_children/todo_task_details.dart';
import 'package:timeago/timeago.dart' as timeago;

class CompletedTasksPage extends StatefulWidget {
  const CompletedTasksPage({super.key});

  @override
  State<CompletedTasksPage> createState() => _CompletedTasksPageState();
}

class _CompletedTasksPageState extends State<CompletedTasksPage> {
  List<TodoTask>? _displayData;
  final TaskAPIV2 _api = TaskAPIV2.instance;
  final AppColors _colors = AppColors.instance;
  Future<void> initPlatformState() async {
    _displayData = await _api.getCompletedTasks();
    if (mounted) setState(() {});
    _displayData!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (mounted) setState(() {});
    return;
  }

  @override
  void initState() {
    initPlatformState();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Completed Tasks"),
        centerTitle: true,
      ),
      body: _displayData == null
          ? SafeArea(
              top: false,
              child: Center(
                child: Image.asset(
                  "assets/images/loader.gif",
                  width: (size.width * .7) - 60,
                ),
              ),
            )
          : _displayData!.isEmpty
              ? SafeArea(
                  top: false,
                  child: LayoutBuilder(builder: (context, c) {
                    return LiquidPullToRefresh(
                      onRefresh: () async {
                        final Completer<void> completer = Completer<void>();
                        await initPlatformState().whenComplete(() {
                          completer.complete();
                        });
                        return completer.future;
                      },
                      child: ListView(
                        children: [
                          SizedBox(
                            height: c.maxHeight,
                            child: const Center(
                              child: Text(
                                "No Completed Jobs Yet",
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
                )
              : SafeArea(
                  top: false,
                  child: LiquidPullToRefresh(
                    onRefresh: () async {
                      final Completer<void> completer = Completer<void>();
                      await initPlatformState().whenComplete(() {
                        completer.complete();
                      });
                      return completer.future;
                    },
                    child: ListView.separated(
                      separatorBuilder: (_, i) => const SizedBox(
                        height: 5,
                      ),
                      itemCount: _displayData!.length,
                      itemBuilder: (_, i) {
                        final TodoTask task = _displayData![i];
                        return LayoutBuilder(builder: (context, c) {
                          return MaterialButton(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                PageTransition(
                                  child: TodoTaskDetails(task: task),
                                  type: PageTransitionType.leftToRight,
                                ),
                              );
                              // await showGeneralDialog(
                              //   context: context,
                              //   barrierDismissible: true,
                              //   barrierColor: Colors.black.withOpacity(.5),
                              //   barrierLabel: "Details",
                              //   transitionBuilder: (_, a1, a2, child) =>
                              //       Transform.scale(
                              //     scale: a1.value,
                              //     child: FadeTransition(
                              //       opacity: a1,
                              //       child: child,
                              //     ),
                              //   ),
                              //   transitionDuration:
                              //       const Duration(milliseconds: 500),
                              //   pageBuilder: (_, a1, a2) => AlertDialog(
                              //     content: TodoTaskDetails(task: task),
                              //   ),
                              // );
                            },
                            color: Colors.grey.shade100,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: c.maxWidth * .25,
                                      height: c.maxWidth * .25,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.grey.shade100,
                                          boxShadow: [
                                            BoxShadow(
                                              offset: const Offset(-1, 1),
                                              color: Colors.grey.shade400,
                                              blurRadius: 2,
                                            )
                                          ]),
                                      child: Center(
                                        child: Hero(
                                          tag: "cat-icon",
                                          child: CachedNetworkImage(
                                            imageUrl: task.task.category.icon,
                                            height: 120,
                                            fit: BoxFit.fitHeight,
                                            placeholder: (_, ff) => Image.asset(
                                              "assets/images/loader.gif",
                                              height: 100,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  task.task.category.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              if (task.task.status ==
                                                  "paid") ...{
                                                Tooltip(
                                                  message: task.task.status
                                                      .capitalizeWords(),
                                                  child: Icon(
                                                    Icons.paid,
                                                    color: _colors.top,
                                                  ),
                                                )
                                              } else if (task.task.status ==
                                                  "pending") ...{
                                                Tooltip(
                                                  message: task.task.status
                                                      .capitalizeWords(),
                                                  child: const Icon(
                                                    Icons.pending,
                                                    color: Colors.grey,
                                                  ),
                                                )
                                              },
                                              // if (task.task.hasApplied) ...{
                                              //   SvgPicture.asset(
                                              //     "assets/icons/applied.svg",
                                              //     width: 20,
                                              //     height: 20,
                                              //     colorFilter:
                                              //         const ColorFilter.mode(
                                              //       Colors.green,
                                              //       BlendMode.srcIn,
                                              //     ),
                                              //   ),
                                              // },
                                            ],
                                          ),
                                          if (task.task.message != null) ...{
                                            Text(
                                              task.task.message!,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                height: 1.2,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            )
                                          }
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    timeago.format(task.task.datePosted),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        });
                      },
                    ),
                  ),
                ),
    );
  }
}
