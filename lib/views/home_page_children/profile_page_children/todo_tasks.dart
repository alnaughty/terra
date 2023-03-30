import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:terra/models/v2/todo.dart';
import 'package:terra/services/API/v2/task_api.dart';
import 'package:timeago/timeago.dart' as timeago;

class TodoTasks extends StatefulWidget {
  const TodoTasks({super.key});

  @override
  State<TodoTasks> createState() => _TodoTasksState();
}

class _TodoTasksState extends State<TodoTasks> {
  final TaskAPIV2 _api = TaskAPIV2.instance;
  List<TodoTask>? _displayData;
  Future<void> fetch() async {
    _displayData = await _api.getTodos();
    if (_displayData == null) {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(null);
    }
    _displayData!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (mounted) setState(() {});
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
        title: Text("Tasks to do"),
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
              : ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemBuilder: (_, i) {
                    final TodoTask task = _displayData![i];
                    return LayoutBuilder(builder: (context, c) {
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
                                    imageUrl: task.task.category.icon,
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
                                            task.task.category.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (task.task.hasApplied) ...{
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
                                    if (task.task.message != null) ...{
                                      Text(
                                        task.task.message!,
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
                              timeago.format(task.task.datePosted),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black45,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          )
                        ],
                      );
                    });
                  },
                  separatorBuilder: (_, i) => const SizedBox(
                    height: 10,
                  ),
                  itemCount: _displayData!.length,
                ),
    );
  }
}
