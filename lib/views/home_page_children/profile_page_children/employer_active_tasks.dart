import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:terra/models/v2/todo.dart';
import 'package:terra/services/API/v2/task_api.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/views/home_page_children/profile_page_children/todo_task_details.dart';
import 'package:timeago/timeago.dart' as timeago;

class EmployerActiveTasks extends StatefulWidget {
  const EmployerActiveTasks({super.key});

  @override
  State<EmployerActiveTasks> createState() => _EmployerActiveTasksState();
}

class _EmployerActiveTasksState extends State<EmployerActiveTasks> {
  final TaskAPIV2 _api = TaskAPIV2.instance;
  List<TodoTask>? _displayData;
  final AppColors _colors = AppColors.instance;
  Future<void> fetch() async {
    _displayData = await _api.getEmployerActiveTasks();
    if (_displayData == null) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(null);
    }
    print("DISPLAY DATA LENGTH : ${_displayData!.length}");
    _displayData!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _displayData = _displayData!
        .where((element) => element.task.status != "completed")
        .toList();
    if (mounted) setState(() {});
    return;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();
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
        title: const Text("Active Tasks"),
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
              ? const SafeArea(
                  top: false,
                  child: Center(
                    child: Text(
                      "No Jobs Posted",
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 17,
                      ),
                    ),
                  ),
                )
              : SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        color: Colors.grey.shade100,
                        child: ShaderMask(
                          shaderCallback: (Rect f) =>
                              LinearGradient(colors: [_colors.top, _colors.bot])
                                  .createShader(f),
                          child: const Text(
                            "NOTE: You can only mark a task as complete if the employee marked it as paid",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: LiquidPullToRefresh(
                          onRefresh: () async {
                            final Completer<void> completer = Completer<void>();
                            await fetch().whenComplete(() {
                              completer.complete();
                            });
                            return completer.future;
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 10),
                            itemBuilder: (_, i) {
                              final TodoTask task = _displayData![i];
                              return LayoutBuilder(builder: (context, c) {
                                return Slidable(
                                  key: Key(task.id.toString()),
                                  enabled: task.task.status == "paid",
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (_) async {
                                          await _api
                                              .markAsComplete(task.id)
                                              .then((value) {
                                            if (value) {
                                              Fluttertoast.showToast(
                                                  msg: "Task is complete!");
                                              setState(() {
                                                task.task.status = "completed";
                                              });
                                            }
                                          });
                                          // await _api
                                          //     .approveApplication(_app.id)
                                          //     .whenComplete(() {
                                          //   _app.status = "approved";
                                          //   if (mounted) setState(() {});
                                          // });
                                        },
                                        backgroundColor: _colors.top,
                                        foregroundColor: Colors.white,
                                        icon: Icons.check,
                                        label: 'Release Payment',
                                      ),
                                    ],
                                  ),
                                  child: MaterialButton(
                                    onPressed: () async {
                                      await showGeneralDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        barrierColor:
                                            Colors.black.withOpacity(.5),
                                        barrierLabel: "Details",
                                        transitionBuilder: (_, a1, a2, child) =>
                                            Transform.scale(
                                          scale: a1.value,
                                          child: FadeTransition(
                                            opacity: a1,
                                            child: child,
                                          ),
                                        ),
                                        transitionDuration:
                                            const Duration(milliseconds: 500),
                                        pageBuilder: (_, a1, a2) => AlertDialog(
                                          content: TodoTaskDetails(task: task),
                                        ),
                                      );
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
                                                      offset:
                                                          const Offset(-1, 1),
                                                      color:
                                                          Colors.grey.shade400,
                                                      blurRadius: 2,
                                                    )
                                                  ]),
                                              child: Center(
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      task.task.category.icon,
                                                  height: 120,
                                                  fit: BoxFit.fitHeight,
                                                  placeholder: (_, ff) =>
                                                      Image.asset(
                                                    "assets/images/loader.gif",
                                                    height: 100,
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
                                                          task.task.category
                                                              .name,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      if (task.task.status ==
                                                          "paid") ...{
                                                        Tooltip(
                                                          message: task
                                                              .task.status
                                                              .capitalize(),
                                                          child: Icon(
                                                            Icons.paid,
                                                            color: _colors.top,
                                                          ),
                                                        )
                                                      } else if (task
                                                              .task.status ==
                                                          "pending") ...{
                                                        Tooltip(
                                                          message: task
                                                              .task.status
                                                              .capitalize(),
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
                                                  if (task.task.message !=
                                                      null) ...{
                                                    Text(
                                                      task.task.message!,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        height: 1.2,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.w300,
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
                                            timeago
                                                .format(task.task.datePosted),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.black45,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              });
                            },
                            separatorBuilder: (_, i) => const SizedBox(
                              height: 5,
                            ),
                            itemCount: _displayData!.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
