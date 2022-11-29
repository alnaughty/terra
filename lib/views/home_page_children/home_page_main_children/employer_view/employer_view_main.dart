import 'package:flutter/material.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';

class EmployerHeader extends StatefulWidget {
  const EmployerHeader({super.key});

  @override
  State<EmployerHeader> createState() => _EmployerHeaderState();
}

class _EmployerHeaderState extends State<EmployerHeader> {
  final AppColors _colors = AppColors.instance;
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                const Spacer(),
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
                )
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Hi, ${loggedUser!.fullName}"),
                          const Spacer(),
                          const Text(
                            "What services do\nyou need ?",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
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
                            child: const Text("Post a task"),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 50,
                    bottom: 0,
                    // left: 0,
                    child: Image.asset(
                      "assets/images/girl1.png",
                      height: 180,
                      fit: BoxFit.fitHeight,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
