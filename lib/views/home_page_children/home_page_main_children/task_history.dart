import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/models/task_history.dart' as model;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:terra/models/v2/todo.dart';
import 'package:terra/services/API/v2/task_api.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/home_page_children/home_page_main_children/task_history_children/task_history_details.dart';
import 'package:terra/views/home_page_children/profile_page_children/todo_task_details.dart';

class TaskHistory extends StatefulWidget {
  const TaskHistory({super.key});

  @override
  State<TaskHistory> createState() => _TaskHistoryState();
}

class _TaskHistoryState extends State<TaskHistory> {
  static final AppColors _colors = AppColors.instance;
  final BehaviorSubject<List<model.TaskHistory>> _subject =
      BehaviorSubject<List<model.TaskHistory>>();
  Stream<List<model.TaskHistory>> get stream => _subject.stream;
  // List<TodoTask>? _displayData;
  final TaskAPIV2 _api = TaskAPIV2.instance;
  Future<void> initPlatformState() async {
    final List<model.TaskHistory> _result = await _api.getAllHistory();
    _subject.add(_result);
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
        title: const Text("Task History"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<model.TaskHistory>>(
        stream: stream,
        builder: (_, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Image.asset(
                "assets/images/loader.gif",
                width: size.width * .5,
              ),
            );
          }
          final List<model.TaskHistory> _result = snapshot.data!;
          if (_result.isEmpty) {
            return const Center(
              child: Text("No Task history found"),
            );
          }
          _result.sort(
            (a, b) => b.applcationState.updatedAt.compareTo(
              a.applcationState.updatedAt,
            ),
          );
          // return Container();
          return LiquidPullToRefresh(
            onRefresh: () async {
              final Completer<void> completer = Completer<void>();
              await initPlatformState().whenComplete(() {
                completer.complete();
              });
              return completer.future;
            },
            child: ListView.separated(
              itemBuilder: (_, i) {
                final model.TaskHistory datum = _result[i];
                return LayoutBuilder(builder: (context, c) {
                  return MaterialButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        PageTransition(
                          child: TaskHistoryDetails(data: datum),
                          type: PageTransitionType.leftToRight,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: c.maxWidth * .25,
                              height: c.maxWidth * .25,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
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
                                  tag: "cat-icon-history-${datum.id}",
                                  child: CachedNetworkImage(
                                    imageUrl: datum.category.icon,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          datum.category.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        datum.applcationState.status
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: datum.applcationState.status ==
                                                  "pending"
                                              ? Colors.grey
                                              : datum.applcationState.status ==
                                                      "completed"
                                                  ? _colors.top
                                                  : datum.applcationState
                                                              .status ==
                                                          "declined"
                                                      ? Colors.red
                                                      : Colors.green,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                      // if (task.task.status == "paid") ...{
                                      //   Tooltip(
                                      //     message:
                                      //         task.task.status.capitalize(),
                                      //     child: Icon(
                                      //       Icons.paid,
                                      //       color: _colors.top,
                                      //     ),
                                      //   )
                                      // } else if (task.task.status ==
                                      //     "pending") ...{
                                      //   Tooltip(
                                      //     message:
                                      //         task.task.status.capitalize(),
                                      //     child: const Icon(
                                      //       Icons.pending,
                                      //       color: Colors.grey,
                                      //     ),
                                      //   )
                                      // },
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
                                  if (datum.message.isNotEmpty) ...{
                                    Text(
                                      datum.message,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.2,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    )
                                  },
                                  Text(
                                    datum.jobStatus.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                });
              },
              separatorBuilder: (_, i) => const SizedBox(
                height: 10,
              ),
              itemCount: _result.length,
            ),
          );
        },
      ),
    );
  }
}
