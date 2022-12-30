import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';

class JobSeekerHeader extends StatefulWidget {
  const JobSeekerHeader({super.key});

  @override
  State<JobSeekerHeader> createState() => _JobSeekerHeaderState();
}

class _JobSeekerHeaderState extends State<JobSeekerHeader> {
  late final TextEditingController _search;
  final AppColors _colors = AppColors.instance;
  @override
  void initState() {
    _search = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final double w = c.maxWidth;
      return Container(
        width: w,
        height: 330,
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
        child: Column(
          children: [
            const SafeArea(
              bottom: false,
              child: SizedBox(
                height: 10,
              ),
            ),
            Row(
              children: [
                IconButton(
                  tooltip: "Show all tasks",
                  onPressed: () async {
                    await Navigator.pushNamed(context, "/my_task_page");
                  },
                  icon: const Icon(
                    Icons.list,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: _colors.top,
                          size: 20,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            // expands: true,
                            maxLines: 1,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              alignLabelWithHint: true,
                              isDense: true,
                              hintText: "Search",
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                            ),
                            controller: _search,
                            selectionHeightStyle:
                                BoxHeightStyle.includeLineSpacingMiddle,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await Navigator.pushNamed(context, "/my_messages");
                      },
                      tooltip: "Messages",
                      icon: const Icon(
                        Icons.message,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      tooltip: "Browse",
                      icon: const Icon(
                        Icons.open_in_browser_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Hi, ${loggedUser!.firstName} we're glad you are here!",
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          TextButton(
                            onPressed: () async {
                              await Navigator.pushNamed(
                                  context, "/job_listing");
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                      (_) => _colors.mid),
                              foregroundColor:
                                  MaterialStateProperty.resolveWith(
                                      (_) => Colors.white),
                              padding: MaterialStateProperty.resolveWith(
                                  (_) => const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      )),
                            ),
                            child: const Text("Quick apply"),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 1,
                      bottom: 0,
                      // left: 0,
                      child: Image.asset(
                        "assets/images/Men.png",
                        height: 160,
                        fit: BoxFit.fitHeight,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      );
    });
  }
}
