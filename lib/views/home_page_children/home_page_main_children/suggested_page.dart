import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:terra/models/v2/task.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/view_model/tasks_vm.dart';
import 'package:terra/views/home_page_children/home_page_main_children/task_container.dart';
import 'package:timeago/timeago.dart' as timeago;

class SuggestedPostPage extends StatelessWidget {
  const SuggestedPostPage({super.key});
  static final AppColors _colors = AppColors.instance;
  static final TasksVm _vm = TasksVm.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
        stream: _vm.stream,
        builder: (_, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return Container();
          }
          final List<Task> _tasks = snapshot.data!.length > 5
              ? snapshot.data!.sublist(snapshot.data!.length - 5)
              : snapshot.data!;
          _tasks.sort((a, b) => b.datePosted.compareTo(a.datePosted));
          return LayoutBuilder(builder: (context, c) {
            final double w = c.maxWidth;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Suggested jobs for you",
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await Navigator.pushNamed(
                            context,
                            "/job_listing",
                            arguments: [null, null],
                          );
                        },
                        style: ButtonStyle(
                          foregroundColor: MaterialStateProperty.resolveWith(
                            (states) => _colors.bot,
                          ),
                        ),
                        child: const Text(
                          "Show all",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, i) {
                    final Task _task = _tasks[i];
                    return TaskContainer(task: _task);
                  },
                  separatorBuilder: (_, i) => const SizedBox(
                    height: 10,
                  ),
                  itemCount: _tasks.length,
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            );
          });
        });
  }
}
