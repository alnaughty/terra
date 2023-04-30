import 'dart:async';
import 'dart:math';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:terra/models/task_history.dart' as model;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:terra/models/v2/todo.dart';
import 'package:terra/services/API/v2/task_api.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';

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
