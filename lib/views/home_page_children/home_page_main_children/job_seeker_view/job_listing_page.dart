import 'package:flutter/cupertino.dart' as cup;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/models/v2/task.dart';
import 'package:terra/services/API/v2/task_api.dart';
import 'package:terra/services/firebase/chatroom_services.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/home_page_children/home_page_main_children/job_seeker_view/job_details_viewer.dart';
import 'package:terra/views/home_page_children/home_page_main_children/messaging/message_conversation_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class JobListingPage extends StatefulWidget {
  const JobListingPage({super.key, required this.catId});
  final int? catId;
  @override
  State<JobListingPage> createState() => _JobListingPageState();
}

class _JobListingPageState extends State<JobListingPage> {
  static final AppColors _colors = AppColors.instance;
  List<Task> _displayData = [];
  final TaskAPIV2 _api = TaskAPIV2.instance;
  bool isFetching = true;
  final ChatRoomService _chatService = ChatRoomService.instance;
  late int? catId = widget.catId;

  fetch() async {
    setState(() => isFetching = true);
    await _api.getEmployeeTasks(categoryId: catId).then((value) async {
      if (value == null) {
        Navigator.of(context).pop();
        await Fluttertoast.showToast(
          msg: "Internal server error,please contact developer",
        );
        return;
      }
      _displayData = value;
      _displayData.sort((a, b) => b.datePosted.compareTo(a.datePosted));
      if (mounted) setState(() {});
      return;
    }).whenComplete(() {
      isFetching = false;
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetch();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text("Job List"),
              elevation: 1,
              titleTextStyle: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade900,
              ),
              actions: [
                if (catId != null) ...{
                  IconButton(
                      tooltip: "Clear category",
                      onPressed: () async {
                        setState(() {
                          catId = null;
                        });
                        await fetch();
                      },
                      icon: const Icon(
                        Icons.clear_all,
                      ))
                },
              ],
            ),
            body: isFetching
                ? Center(
                    child: Image.asset("assets/images/loader.gif"),
                  )
                : SafeArea(
                    child: _displayData.isEmpty
                        ? const Center(
                            child: Text("No jobs available"),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            itemBuilder: (_, i) {
                              final Task task = _displayData[i];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: MaterialButton(
                                  padding: EdgeInsets.zero,
                                  color: Colors.grey.shade200,
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
                                    // await showGeneralDialog(
                                    //   context: context,
                                    //   barrierColor:
                                    //       Colors.black.withOpacity(.5),
                                    //   barrierDismissible: true,
                                    //   barrierLabel: "Task details",
                                    //   transitionDuration:
                                    //       const Duration(milliseconds: 500),
                                    //   transitionBuilder: (_, a1, a2, child) =>
                                    //       FadeTransition(
                                    //     opacity: a1,
                                    //     child: Opacity(
                                    //       opacity: a1.value,
                                    //       child: Transform.scale(
                                    //         scale: a1.value,
                                    //         child: AlertDialog(
                                    //           content: child,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ),
                                    //   pageBuilder: (_, a1, a2) =>
                                    //       JobDetailsViewer(
                                    //     task: task,
                                    //     loadingCallback: (bool isLoading) {
                                    //       _isLoading = isLoading;
                                    //       if (mounted) setState(() {});
                                    //     },
                                    //   ),
                                    // );
                                  },
                                  child: LayoutBuilder(builder: (_, c) {
                                    return Column(
                                      children: [
                                        ListTile(
                                          leading: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(60),
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              color: Colors.white,
                                              child: Image.network(
                                                task.postedBy.avatar,
                                                height: 40,
                                                width: 40,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          trailing: task.hasApplied
                                              ? IconButton(
                                                  onPressed: () async {
                                                    await _chatService
                                                        .gegtOrCreateChatRoom(
                                                      userId1: task
                                                          .postedBy.firebaseId,
                                                      userId2: loggedUser!
                                                          .firebaseId,
                                                      name1: task
                                                          .postedBy.fullname,
                                                      name2:
                                                          loggedUser!.fullName,
                                                      avatar1:
                                                          task.postedBy.avatar,
                                                      avatar2:
                                                          loggedUser!.avatar,
                                                    )
                                                        .then((val) async {
                                                      if (val == null) return;
                                                      await Navigator.push(
                                                          context,
                                                          PageTransition(
                                                              child:
                                                                  MessageConversationPage(
                                                                chatroomId: val,
                                                                targetName: task
                                                                    .postedBy
                                                                    .fullname,
                                                                targetAvatar:
                                                                    task.postedBy
                                                                        .avatar,
                                                              ),
                                                              type: PageTransitionType
                                                                  .leftToRight));
                                                    });
                                                  },
                                                  icon: Icon(
                                                    cup.CupertinoIcons
                                                        .bubble_left_fill,
                                                    color: _colors.top,
                                                  ),
                                                )
                                              : null,
                                          title: Text(
                                            "${task.postedBy.firstname[0].toUpperCase()}${task.postedBy.firstname.substring(1).toLowerCase()}${task.postedBy.middlename != null ? " ${task.postedBy.middlename![0].toUpperCase()}${task.postedBy.middlename!.substring(1).toLowerCase()}" : ""} ${task.postedBy.lastname[0].toUpperCase()}${task.postedBy.lastname.substring(1).toLowerCase()}",
                                          ),
                                          subtitle: Text(
                                            timeago.format(
                                              task.datePosted,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: c.maxWidth,
                                          // height: 80,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                _colors.top,
                                                _colors.bot
                                              ],
                                            ),
                                          ),
                                          child: ListTile(
                                            leading: i % 2 != 0
                                                ? SizedBox(
                                                    width: 50,
                                                    height: 50,
                                                    child: Center(
                                                      child: Image.network(
                                                        task.category.icon,
                                                      ),
                                                    ),
                                                  )
                                                : null,
                                            title: Text.rich(
                                              TextSpan(
                                                text: "Is looking for ",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 13,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: task.category.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            subtitle: task.message != null
                                                ? Text(
                                                    task.message!,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : null,
                                            trailing: i % 2 == 0
                                                ? SizedBox(
                                                    width: 50,
                                                    height: 50,
                                                    child: Center(
                                                      child: Image.network(
                                                        task.category.icon,
                                                      ),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              );
                            },
                            separatorBuilder: (_, i) => const SizedBox(
                                  height: 10,
                                ),
                            itemCount: _displayData.length),
                  ),
          ),
        ),
        if (_isLoading) ...{
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(.5),
              child: Center(
                child: Image.asset("assets/images/loader.gif"),
              ),
            ),
          ),
        }
      ],
    );
  }
}
