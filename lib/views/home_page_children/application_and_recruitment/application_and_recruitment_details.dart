import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/v2/application.dart';
import 'package:terra/services/firebase/chat_service.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/home_page_children/home_page_main_children/messaging/message_conversation_page.dart';

class ApplicationAndRecruitmentDetails extends StatefulWidget {
  const ApplicationAndRecruitmentDetails({super.key, required this.data});
  final MyApplication data;
  @override
  State<ApplicationAndRecruitmentDetails> createState() =>
      _ApplicationAndRecruitmentDetailsState();
}

class _ApplicationAndRecruitmentDetailsState
    extends State<ApplicationAndRecruitmentDetails> {
  final AppColors _colors = AppColors.instance;
  final ChatService _chatService = ChatService.instance;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: size.height * .6, minWidth: size.width * .9),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: CachedNetworkImage(
                  imageUrl: widget.data.applicationFrom.avatar,
                  height: 50,
                  width: 50,
                ),
              ),
              title: Text(
                widget.data.applicationFrom.fullname.capitalizeWords(),
              ),
              subtitle: Text(
                widget.data.applicationFrom.email,
              ),
              trailing: loggedUser!.accountType == 1
                  ? null
                  : IconButton(
                      onPressed: () async {
                        await _chatService.getOrCreateChatroom([
                          widget.data.applicationFrom.toMember(),
                          loggedUser!.toMember(),
                        ]).then((val) async {
                          await Navigator.push(
                              context,
                              PageTransition(
                                  child: MessageConversationPage(
                                    chatroomId: val,
                                    targetName:
                                        widget.data.applicationFrom.fullname,
                                    targetAvatar:
                                        widget.data.applicationFrom.avatar,
                                    targetId:
                                        widget.data.applicationFrom.firebaseId,
                                  ),
                                  type: PageTransitionType.leftToRight));
                        });
                      },
                      icon: Icon(
                        CupertinoIcons.bubble_left_fill,
                        color: _colors.top,
                      ),
                    ),
            ),

            Row(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: const Text(
                    "Task",
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 15,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Divider(
                    color: Colors.grey.shade300,
                    thickness: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  // width: (size.width * .9) * .25,
                  // height: (size.width * .9) * .25,
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
                      imageUrl: widget.data.task.category.icon,
                      height: 60,
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
                      ShaderMask(
                        shaderCallback: (Rect rect) =>
                            LinearGradient(colors: [_colors.top, _colors.bot])
                                .createShader(rect),
                        child: Text(
                          widget.data.task.category.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/icons/peso.png",
                            height: 25,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              widget.data.task.rate?.toStringAsFixed(2) ??
                                  "0.0",
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.data.task.message ?? "NO MESSAGE/SPECIFICATIONS",
                      ),
                    ],
                  ),
                )
              ],
            )
            // Row(
            //   children: [
            // Container(
            //   width: (size.width * .9) * .25,
            //   height: (size.width * .9) * .25,
            //   decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(10),
            //       color: Colors.grey.shade100,
            //       boxShadow: [
            //         BoxShadow(
            //           offset: const Offset(-1, 1),
            //           color: Colors.grey.shade400,
            //           blurRadius: 2,
            //         )
            //       ]),
            //   child: Center(
            //     child: CachedNetworkImage(
            //       imageUrl: widget.data.task.category.icon,
            //       height: 120,
            //       fit: BoxFit.fitHeight,
            //       placeholder: (_, ff) => Image.asset(
            //         "assets/images/loader.gif",
            //         height: 100,
            //       ),
            //     ),
            //   ),
            // ),
            //   ],
            // )
          ],
        ),
      ),
    );
  }
}
