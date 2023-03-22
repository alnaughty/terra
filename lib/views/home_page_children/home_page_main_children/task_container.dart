import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/models/v2/task.dart';
import 'package:terra/views/home_page_children/home_page_main_children/job_seeker_view/job_details_viewer.dart';
import 'package:timeago/timeago.dart' as timeago;

class TaskContainer extends StatelessWidget {
  const TaskContainer({super.key, required this.task, this.height = 120});
  final Task task;
  final double height;
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(20),
      height: height,
      onPressed: () async {
        await Navigator.push(
          context,
          PageTransition(
            child: JobDetailsViewer(
              task: task,
            ),
            type: PageTransitionType.leftToRight,
          ),
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: LayoutBuilder(builder: (context, c) {
        return Column(
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
                    child: CachedNetworkImage(
                      imageUrl: task.category.icon,
                      height: 120,
                      fit: BoxFit.fitHeight,
                      placeholder: (_, ff) => Image.asset(
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.category.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (task.hasApplied) ...{
                            SvgPicture.asset(
                              "assets/icons/applied.svg",
                              width: 20,
                              height: 20,
                              colorFilter: const ColorFilter.mode(
                                Colors.green,
                                BlendMode.srcIn,
                              ),
                            ),
                          },
                        ],
                      ),
                      if (task.message != null || task.message!.isNotEmpty) ...{
                        Text(
                          task.message!,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.2,
                            color: Colors.black54,
                            fontWeight: FontWeight.w300,
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
                timeago.format(task.datePosted),
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black45,
                  fontWeight: FontWeight.w300,
                ),
              ),
            )
          ],
        );
      }),
    );
  }
}
