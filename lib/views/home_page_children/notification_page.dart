import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:terra/utils/color.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final AppColors _colors = AppColors.instance;
  final int itemCount = Random().nextInt(30) + 10;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Notifications",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    icon: const Icon(
                      Icons.more_horiz_outlined,
                      color: Colors.white,
                    ),
                    itemBuilder: (_) => ["clear", "turn-off"].map((e) {
                      final String clean = e.replaceAll("-", " ");
                      return PopupMenuItem<String>(
                        child: Text(
                          "${clean[0].toUpperCase()}${clean.substring(1)}",
                        ),
                      );
                    }).toList(),
                  )
                ],
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
                "$itemCount Notification${itemCount > 1 ? "s" : ""}",
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
              itemBuilder: (_, i) {
                return Slidable(
                  key: Key("item$i"),
                  startActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (_) {},
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        icon: Icons.notifications_off_sharp,
                        label: 'Mute',
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    dismissible: DismissiblePane(
                      onDismissed: () {},
                    ),
                    children: [
                      SlidableAction(
                        onPressed: (_) {},
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    trailing: Text(
                      DateFormat("MMM dd").format(
                        DateTime.now().add(
                          Duration(days: i),
                        ),
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () {},
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: Icon(
                          Icons.notifications,
                          color: _colors.top,
                        ),
                      ),
                    ),
                    title: const Text("It's Super Month!"),
                    subtitle: const Text(
                      "Enjoy our services with Terra! Check it out and find more exciting offers",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
              separatorBuilder: (_, i) => const SizedBox(
                height: 10,
              ),
              itemCount: itemCount,
            ),
          )
        ],
      ),
    );
  }
}
