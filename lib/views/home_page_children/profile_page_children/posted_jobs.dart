import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/models/v2/raw_task.dart';
import 'package:terra/services/API/v2/task_api.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/views/home_page_children/profile_page_children/posted_control.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostedJobsPage extends StatefulWidget {
  const PostedJobsPage({super.key});

  @override
  State<PostedJobsPage> createState() => _PostedJobsPageState();
}

class _PostedJobsPageState extends State<PostedJobsPage> {
  final AppColors _colors = AppColors.instance;
  final TaskAPIV2 _api = TaskAPIV2.instance;
  List<RawTaskV2>? _displayData;
  Future<void> fetch() async {
    setState(() {
      _displayData = null;
    });
    _displayData = await _api.getPostedTasks();
    if (_displayData == null) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(null);
    }
    _displayData!.sort((a, b) => b.datePosted.compareTo(a.datePosted));
    if (mounted) setState(() {});
    return;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();
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
        centerTitle: true,
        title: const Text("Posted Jobs"),
      ),
      body: _displayData == null
          ? SafeArea(
              top: false,
              child: Center(
                child: Image.asset(
                  "assets/images/loader.gif",
                  width: (size.width * .7) - 60,
                ),
              ),
            )
          : _displayData!.isEmpty
              ? const SafeArea(
                  top: false,
                  child: Center(
                    child: Text(
                      "No Jobs Posted",
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 17,
                      ),
                    ),
                  ),
                )
              : SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Container(
                        width: size.width,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        color: Colors.grey.shade100,
                        child: ShaderMask(
                          shaderCallback: (Rect f) =>
                              LinearGradient(colors: [_colors.top, _colors.bot])
                                  .createShader(f),
                          child: const Text(
                            "NOTE: Slide left to edit or delete this task and press the task to show details.",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: LiquidPullToRefresh(
                          onRefresh: () async {
                            final Completer<void> completer = Completer<void>();
                            await fetch().whenComplete(() {
                              completer.complete();
                            });
                            return completer.future;
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            itemBuilder: (_, i) {
                              final RawTaskV2 task = _displayData![i];
                              return LayoutBuilder(builder: (context, c) {
                                return Slidable(
                                  key: ValueKey(task.id),
                                  enabled: task.status == "pending" ||
                                      task.status == "available",
                                  endActionPane: ActionPane(
                                    motion: const ScrollMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (_) async {
                                          await Navigator.push(
                                            context,
                                            PageTransition(
                                              child: PostedControlCenter(
                                                task: task,
                                                isEditing: true,
                                                updateCallback: (bool f) async {
                                                  if (f) {
                                                    await fetch();
                                                    return;
                                                  }
                                                },
                                              ),
                                              type: PageTransitionType
                                                  .leftToRight,
                                            ),
                                          );
                                        },
                                        backgroundColor: _colors.top,
                                        foregroundColor: Colors.white,
                                        icon: Icons.edit_note_rounded,
                                        label: 'Edit',
                                      ),
                                      SlidableAction(
                                        onPressed: (_) async {
                                          await _api
                                              .delete(task.id)
                                              .then((value) async {
                                            if (value) {
                                              await fetch();
                                            }
                                          });
                                          // await _api
                                          //     .approveApplication(_app.id)
                                          //     .whenComplete(() {
                                          //   _app.status = "approved";
                                          //   if (mounted) setState(() {});
                                          // });
                                        },
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Delete',
                                      ),
                                    ],
                                  ),
                                  child: MaterialButton(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        PageTransition(
                                          child: PostedControlCenter(
                                            task: task,
                                            updateCallback: (bool f) async {
                                              if (f) {
                                                await fetch();
                                                return;
                                              }
                                            },
                                          ),
                                          type: PageTransitionType.leftToRight,
                                        ),
                                      );
                                    },
                                    padding: const EdgeInsets.all(0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: c.maxWidth * .25,
                                              height: c.maxWidth * .25,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.grey.shade100,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      offset:
                                                          const Offset(-1, 1),
                                                      color:
                                                          Colors.grey.shade400,
                                                      blurRadius: 2,
                                                    )
                                                  ]),
                                              child: Center(
                                                child: CachedNetworkImage(
                                                  imageUrl: task.category.icon,
                                                  height: 120,
                                                  fit: BoxFit.fitHeight,
                                                  placeholder: (_, ff) =>
                                                      Image.asset(
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
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          task.category.name,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      if (task.hasApplied) ...{
                                                        SvgPicture.asset(
                                                          "assets/icons/applied.svg",
                                                          width: 20,
                                                          height: 20,
                                                          colorFilter:
                                                              const ColorFilter
                                                                  .mode(
                                                            Colors.green,
                                                            BlendMode.srcIn,
                                                          ),
                                                        ),
                                                      },
                                                    ],
                                                  ),
                                                  if (task.message != null) ...{
                                                    Text(
                                                      task.message!,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        height: 1.2,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.w300,
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
                                    ),
                                  ),
                                );
                              });
                            },
                            separatorBuilder: (_, i) => const SizedBox(
                              height: 10,
                            ),
                            itemCount: _displayData!.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
