import 'package:flutter/material.dart';
import 'package:terra/utils/color.dart';

class MyMessages extends StatefulWidget {
  const MyMessages({super.key});

  @override
  State<MyMessages> createState() => _MyMessagesState();
}

class _MyMessagesState extends State<MyMessages> {
  static final AppColors _colors = AppColors.instance;
  final List _displayData = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: "Compose",
        onPressed: () async {},
        backgroundColor: _colors.top,
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.add,
        ),
      ),
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
                    "My Messages",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  actions: [
                    PopupMenuButton(
                        itemBuilder: (_) => ["Mark all as read", "Delete all"]
                            .map((e) => PopupMenuItem(
                                  value: e,
                                  child: Text(
                                    e,
                                  ),
                                ))
                            .toList())
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: _displayData.isEmpty
                  ? const Center(
                      child: Text(
                        "No messages recorded",
                      ),
                    )
                  : Container(),
            ),
          )
        ],
      ),
    );
  }
}
