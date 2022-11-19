import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';

class TaskHistory extends StatefulWidget {
  const TaskHistory({super.key});

  @override
  State<TaskHistory> createState() => _TaskHistoryState();
}

class _TaskHistoryState extends State<TaskHistory> {
  static final AppColors _colors = AppColors.instance;

  final List<Map<String, dynamic>> _data = List.generate(
      20,
      (index) => {
            "name": categoryList[Random().nextInt(categoryList.length)],
            "status": Random().nextInt(3),
            "date": DateTime(
                2022, Random().nextInt(11) + 1, Random().nextInt(29) + 1),
          });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _colors.bot,
                  _colors.top,
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              // child: Row(),
              child: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: AppBar(
                  iconTheme: const IconThemeData(
                    color: Colors.white,
                  ),
                  title: const Text(
                    "Task History",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Legend",
                  style: TextStyle(
                      color: Colors.grey.shade900,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Map<String, dynamic>>[
                    {
                      "name": "Completed",
                      "color": Colors.green,
                    },
                    {
                      "name": "Unfinished\nTransaction",
                      "color": Colors.orange,
                    },
                    {
                      "name": "Declined/\nCancelled",
                      "color": Colors.red,
                    },
                  ]
                      .map((e) => Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      color: e['color'],
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  e['name'],
                                  maxLines: 2,
                                )
                              ],
                            ),
                          ))
                      .toList(),
                )
              ],
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemBuilder: (_, i) => ListTile(
                    onTap: () {
                      print("SHOW TASK DETAILS");
                    },
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    title: Text(
                      _data[i]['name'],
                    ),
                    subtitle: Text(
                        DateFormat("MMMM dd, yyyy").format(_data[i]['date'])),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _data[i]['status'] == 0
                              ? Icons.cancel_rounded
                              : _data[i]['status'] == 1
                                  ? Icons.stop_circle_rounded
                                  : Icons.check_circle_rounded,
                          color: _data[i]['status'] == 0
                              ? Colors.red
                              : _data[i]['status'] == 1
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ],
                    )),
                separatorBuilder: (_, i) =>
                    const Divider(color: Colors.black45),
                itemCount: _data.length,
              ),
            ),
          ),
          // const SizedBox(
          //   height: 40,
          // )
        ],
      ),
    );
  }
}
