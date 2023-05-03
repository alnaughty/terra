import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/extension/user.dart';
import 'package:terra/models/task_history.dart';
import 'package:terra/services/firebase/chat_service.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/home_page_children/application_and_recruitment/user_details.dart';
import 'package:terra/views/home_page_children/home_page_main_children/messaging/message_conversation_page.dart';
import 'package:terra/views/home_page_children/map_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/cupertino.dart' as cup;

class TaskHistoryDetails extends StatefulWidget {
  const TaskHistoryDetails({
    super.key,
    required this.data,
  });
  final TaskHistory data;

  @override
  State<TaskHistoryDetails> createState() => _TaskHistoryDetailsState();
}

class _TaskHistoryDetailsState extends State<TaskHistoryDetails> {
  static final AppColors _colors = AppColors.instance;
  static final ChatService _chatService = ChatService.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task History Details"),
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
              tag: "cat-icon-history-${widget.data.id}",
              child: CachedNetworkImage(
                imageUrl: widget.data.category.icon,
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
                    widget.data.category.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.data.message.isNotEmpty) ...{
                  Text(
                    widget.data.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withOpacity(.5),
                      fontWeight: FontWeight.w300,
                      fontSize: 15,
                    ),
                  ),
                },
                Text(
                  widget.data.applcationState.status == "pending"
                      ? "The employer is still checking your identity"
                      : widget.data.applcationState.status == "available"
                          ? "This is still available for you"
                          : widget.data.applcationState.status == "declined"
                              ? "You have been declined by the author"
                              : widget.data.applcationState.status == "approved"
                                  ? "This task is given to you and is approved by the author"
                                  : "This task is completed",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  widget.data.address,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black.withOpacity(.5),
                      fontWeight: FontWeight.w300,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.black.withOpacity(.5)),
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
                            child: MapPage(
                                targetLocation: widget.data.coordinates),
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
                      user: widget.data.postedBy,
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
                    widget.data.postedBy.avatar,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              trailing: IconButton(
                onPressed: () async {
                  await _chatService.getOrCreateChatroom([
                    widget.data.postedBy.toMember(),
                    loggedUser!.toMember(),
                  ]).then((val) async {
                    await Navigator.push(
                        context,
                        PageTransition(
                            child: MessageConversationPage(
                              chatroomId: val,
                              targetName: widget.data.postedBy.fullname,
                              targetAvatar: widget.data.postedBy.avatar,
                              targetId: widget.data.postedBy.firebaseId,
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
                "${widget.data.postedBy.firstname[0].toUpperCase()}${widget.data.postedBy.firstname.substring(1).toLowerCase()}${widget.data.postedBy.middlename != null ? " ${widget.data.postedBy.middlename![0].toUpperCase()}${widget.data.postedBy.middlename!.substring(1).toLowerCase()}" : ""} ${widget.data.postedBy.lastname[0].toUpperCase()}${widget.data.postedBy.lastname.substring(1).toLowerCase()}",
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.data.postedBy.toSecurityName,
                    style: TextStyle(color: Colors.black.withOpacity(.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
