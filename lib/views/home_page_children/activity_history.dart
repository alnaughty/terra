import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:terra/utils/color.dart';

class ActivityHistory extends StatefulWidget {
  const ActivityHistory({super.key});

  @override
  State<ActivityHistory> createState() => _ActivityHistoryState();
}

class _ActivityHistoryState extends State<ActivityHistory> {
  final AppColors _colors = AppColors.instance;
  final int itemCount = Random().nextInt(30) + 1;
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
            child: const SafeArea(
              bottom: false,
              child: Text(
                "Activity History",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.maxFinite,
                height: 10,
                child: Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              Text(
                "$itemCount Histor${itemCount > 1 ? "ies" : "y"}",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(0),
              itemBuilder: (_, i) => ListTile(
                title: Text("SAMPLE ACTIVITY #${i + 1}"),
                subtitle: Text(DateFormat("MMM dd, yyyy")
                    .format(DateTime.now().add(Duration(days: i)))),
              ),
              separatorBuilder: (_, __) => const SizedBox(
                height: 10,
              ),
              itemCount: itemCount,
            ),
          ),
        ],
      ),
    );
  }
}
