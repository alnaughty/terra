import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart' as cup;
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:terra/extension/user.dart';
import 'package:terra/models/v2/todo.dart';
import 'package:terra/services/firebase/chat_service.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/home_page_children/application_and_recruitment/user_details.dart';
import 'package:terra/views/home_page_children/home_page_main_children/messaging/message_conversation_page.dart';
import 'package:terra/views/home_page_children/map_page.dart';

class TodoTaskDetails extends StatelessWidget {
  const TodoTaskDetails({super.key, required this.task});
  final TodoTask task;
  static final AppColors _colors = AppColors.instance;
  static final ChatService _chatService = ChatService.instance;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Details"),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          children: [
            const SizedBox(
              height: 20,
            ),
            Hero(
              tag: "cat-icon",
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) =>
                      LinearGradient(colors: [_colors.top, _colors.bot])
                          .createShader(bounds),
                  child: Text(
                    task.task.category.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  task.task.message ?? "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(.5),
                    fontWeight: FontWeight.w300,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  task.task.address,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black.withOpacity(.5),
                      fontWeight: FontWeight.w300,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.black.withOpacity(.5)),
                ),
                Text(
                  "You got this transaction ${timeago.format(
                    task.createdAt,
                  )}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(.3),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black),
                  ),
                  child: MaterialButton(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // color: Colors.grey.shade200,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        PageTransition(
                            child:
                                MapPage(targetLocation: task.task.coordinates),
                            type: PageTransitionType.leftToRight),
                      );
                    },
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.location_on_rounded,
                        ),
                        SizedBox(width: 10),
                        Text("Show Location")
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Container(
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(100),
            //     gradient: LinearGradient(
            //       colors: [_colors.top, _colors.bot],
            //     ),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.black.withOpacity(.3),
            //         offset: const Offset(3, 3),
            //         blurRadius: 4,
            //       )
            //     ],
            //   ),
            //   padding: const EdgeInsets.all(5),
            //   child: Image.network(
            //     task.task.category.icon,
            //     height: 50,
            //   ),
            // ),
            // ShaderMask(
            // shaderCallback: (Rect bounds) =>
            //     LinearGradient(colors: [_colors.top, _colors.bot])
            //         .createShader(bounds),
            //   child: Text(
            //     task.task.category.name,
            //     style: const TextStyle(
            //       color: Colors.white,
            //       fontSize: 17,
            //       fontWeight: FontWeight.w500,
            //     ),
            //   ),
            // ),
            // Text(
            //   task.task.message ?? "",
            //   style: TextStyle(
            //     color: Colors.black.withOpacity(.5),
            //   ),
            // ),
            // const SizedBox(
            //   height: 10,
            // ),

            const SizedBox(
              height: 20,
            ),
            Text(
              "${(loggedUser!.accountType == 1 ? "Employer" : "Employee").toUpperCase()}:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ListTile(
              onTap: () async {
                await Navigator.push(
                  context,
                  PageTransition(
                    child: UserDetailsPage(
                      user: task.user,
                    ),
                    type: PageTransitionType.leftToRight,
                  ),
                );
              },
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.white,
                  child: Image.network(
                    task.user.avatar,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              trailing: IconButton(
                onPressed: () async {
                  await _chatService.getOrCreateChatroom([
                    task.user.toMember(),
                    loggedUser!.toMember(),
                  ]).then((val) async {
                    await Navigator.push(
                        context,
                        PageTransition(
                            child: MessageConversationPage(
                              chatroomId: val,
                              targetName: task.user.fullname,
                              targetAvatar: task.user.avatar,
                              targetId: task.user.firebaseId,
                            ),
                            type: PageTransitionType.leftToRight));
                  });
                },
                icon: Icon(
                  cup.CupertinoIcons.bubble_left_fill,
                  color: _colors.top,
                ),
              ),
              title: Text(
                "${task.user.firstname[0].toUpperCase()}${task.user.firstname.substring(1).toLowerCase()}${task.user.middlename != null ? " ${task.user.middlename![0].toUpperCase()}${task.user.middlename!.substring(1).toLowerCase()}" : ""} ${task.user.lastname[0].toUpperCase()}${task.user.lastname.substring(1).toLowerCase()}",
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.user.toSecurityName,
                    style: TextStyle(color: Colors.black.withOpacity(.5)),
                  ),
                ],
              ),
            ),
            // ListTile(
            //   contentPadding: EdgeInsets.zero,
            //   leading: ClipRRect(
            //     borderRadius: BorderRadius.circular(40),
            //     child: CachedNetworkImage(
            //       imageUrl: task.user.avatar,
            //       width: 50,
            //       height: 50,
            //       fit: BoxFit.fitHeight,
            //       placeholder: (_, ff) => Image.asset(
            //         "assets/images/loader.gif",
            //         height: 100,
            //       ),
            //     ),
            //   ),
            //   title: Text(
            //     task.user.fullname.capitalizeWords(),
            //   ),
            //   subtitle: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         task.user.email,
            //         style: TextStyle(color: Colors.black.withOpacity(.5)),
            //       ),
            //       Text(
            //         task.user.mobileNumber,
            //         style: TextStyle(color: Colors.black.withOpacity(.5)),
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(
              height: 20,
            ),

            // Text(
            //   timeago.format(
            //     widget.task.datePosted,
            //   ),
            //   style:
            //       TextStyle(fontSize: 12, color: Colors.black.withOpacity(.5)),
            // ),
            // MaterialButton(
            //   color: _colors.top,
            //   padding: const EdgeInsets.symmetric(vertical: 15),
            //   shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10)),
            //   onPressed: () async {
            //     await _chatService.getOrCreateChatroom([
            //       task.user.toMember(),
            //       loggedUser!.toMember(),
            //     ]).then((val) async {
            //       await Navigator.push(
            //           context,
            //           PageTransition(
            //               child: MessageConversationPage(
            //                 chatroomId: val,
            //                 targetName: task.user.fullname,
            //                 targetAvatar: task.user.avatar,
            //                 targetId: task.user.firebaseId,
            //               ),
            //               type: PageTransitionType.leftToRight));
            //     });
            //   },
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: const [
            //       Icon(
            //         cup.CupertinoIcons.bubble_left_fill,
            //         color: Colors.white,
            //       ),
            //       SizedBox(
            //         width: 10,
            //       ),
            //       Text(
            //         "Message",
            //         style: TextStyle(
            //           color: Colors.white,
            //         ),
            //       )
            //     ],
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
