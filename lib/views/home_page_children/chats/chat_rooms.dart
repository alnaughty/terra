import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/chat/chat_room.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_model/chat_rooms_vm.dart';
import 'package:terra/views/home_page_children/home_page_main_children/messaging/message_conversation_page.dart';

class ChatRoomsPage extends StatelessWidget {
  const ChatRoomsPage({super.key});
  static final ChatRoomsVm _vm = ChatRoomsVm.instance;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            "Messages",
            style: TextStyle(
              color: Colors.grey.shade900,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          StreamBuilder<List<ChatRoom>>(
              stream: _vm.stream,
              builder: (_, snapshot) {
                if (snapshot.hasError || !snapshot.hasData) {
                  return SizedBox(
                    width: size.width,
                    height: size.height - 200,
                    child: Center(
                      child: Image.asset(
                        "assets/images/loader.gif",
                        width: size.width * .5,
                      ),
                    ),
                  );
                }
                final List<ChatRoom> _rooms = snapshot.data!;

                if (_rooms.isEmpty) {
                  return SizedBox(
                    width: size.width,
                    height: size.height - 200,
                    child: const Center(
                      child: Text(
                        "No Messages Available",
                        style: TextStyle(
                          color: Colors.black38,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }
                _rooms.sort((a, b) => (b.lastMessage?.timeStamp ?? b.createdAt)
                    .compareTo(a.lastMessage?.timeStamp ?? a.createdAt));
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, i) {
                    final ChatRoom room = _rooms[i];
                    return ListTile(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            PageTransition(
                              child: MessageConversationPage(
                                chatroomId: room.id,
                                targetAvatar:
                                    room.members[0].id == loggedUser!.firebaseId
                                        ? room.members[1].avatar
                                        : room.members[0].avatar,
                                targetName:
                                    room.members[0].id == loggedUser!.firebaseId
                                        ? room.members[1].displayName
                                            .capitalizeWords()
                                        : room.members[0].displayName
                                            .capitalizeWords(),
                              ),
                              type: PageTransitionType.leftToRight,
                            ));
                      },
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: CachedNetworkImage(
                          imageUrl: room.members[0].id == loggedUser!.firebaseId
                              ? room.members[1].avatar
                              : room.members[0].avatar,
                          width: 40,
                          height: 40,
                          fit: BoxFit.fitHeight,
                          placeholder: (_, ff) => Image.asset(
                            "assets/images/loader.gif",
                            height: 100,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              room.members[0].id == loggedUser!.firebaseId
                                  ? room.members[1].displayName
                                      .capitalizeWords()
                                  : room.members[0].displayName
                                      .capitalizeWords(),
                            ),
                          ),
                          if (room.lastMessage != null) ...{
                            Text(
                              DateFormat("MMM dd, yyyy").format(
                                room.lastMessage!.timeStamp,
                              ),
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            )
                          },
                        ],
                      ),
                      subtitle: Text.rich(
                        TextSpan(
                          text: room.lastMessage?.message ??
                              "No Conversations Yet",
                          style: TextStyle(
                            height: 1,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      // subtitle: Row(
                      //   children: [
                      //     Expanded(
                      //       child: Text(
                      // room.lastMessage?.message ??
                      //     "No Conversations Yet",
                      // style: TextStyle(
                      //   color: Colors.grey.shade600,
                      // ),
                      //       ),
                      //     ),

                      //   ],
                      // ),
                    );
                  },
                  separatorBuilder: (_, i) => const SizedBox(
                    height: 10,
                  ),
                  itemCount: _rooms.length,
                );
              })
        ],
      ),
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      // const SizedBox(
      //   height: 20,
      // ),
      // Text(
      //   "Messages",
      //   style: TextStyle(
      //     color: Colors.grey.shade900,
      //     fontWeight: FontWeight.w600,
      //     fontSize: 17,
      //   ),
      // ),
      //   ],
      // ),
    );
  }
}
