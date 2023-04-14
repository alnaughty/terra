import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/v2/todo.dart';
import 'package:terra/services/firebase/chat_service.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/home_page_children/home_page_main_children/messaging/message_conversation_page.dart';

class TodoTaskDetails extends StatelessWidget {
  const TodoTaskDetails({super.key, required this.task});
  final TodoTask task;
  static final AppColors _colors = AppColors.instance;
  static final ChatService _chatService = ChatService.instance;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: size.height * .8,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) =>
                  LinearGradient(colors: [_colors.top, _colors.bot])
                      .createShader(bounds),
              child: Text(
                task.task.category.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              task.task.message ?? "",
              style: TextStyle(
                color: Colors.black.withOpacity(.5),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  loggedUser!.accountType == 1 ? "Employer" : "Employee",
                  style: TextStyle(
                    fontSize: 16,
                    color: _colors.bot,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Divider(
                    thickness: 1,
                    color: _colors.bot.withOpacity(.3),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: CachedNetworkImage(
                  imageUrl: task.user.avatar,
                  width: 50,
                  height: 50,
                  fit: BoxFit.fitHeight,
                  placeholder: (_, ff) => Image.asset(
                    "assets/images/loader.gif",
                    height: 100,
                  ),
                ),
              ),
              title: Text(
                task.user.fullname.capitalizeWords(),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.user.email,
                    style: TextStyle(color: Colors.black.withOpacity(.5)),
                  ),
                  Text(
                    task.user.mobileNumber,
                    style: TextStyle(color: Colors.black.withOpacity(.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
              color: _colors.top,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () async {
                Navigator.of(context).pop(null);
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    CupertinoIcons.bubble_left_fill,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Message",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
