import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/chat/chat_room.dart';
import 'package:terra/models/chat/chat_room_member.dart';
import 'package:terra/services/firebase/chat_service.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_model/chat_rooms_vm.dart';
import 'package:terra/views/home_page_children/home_page_main_children/messaging/message_conversation_page.dart';

class ChatRoomsPage extends StatefulWidget {
  const ChatRoomsPage({super.key});
  static final ChatRoomsVm _vm = ChatRoomsVm.instance;

  @override
  State<ChatRoomsPage> createState() => _ChatRoomsPageState();
}

class _ChatRoomsPageState extends State<ChatRoomsPage> {
  static final AppColors _colors = AppColors.instance;
  static final ChatService _service = ChatService.instance;

  Future<bool> archiveChat(chatroomId, List<ChatRoomMember> members) async {
    print("ROOM ID : $chatroomId");
    int index = members.first.id == loggedUser!.firebaseId ? 1 : 2;
    print("INDEX $index");
    return await _service.archiveChatroom(
      chatroomId,
      index,
      !showArchivedOnly,
    );
  }

  bool showArchivedOnly = false;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      children: [
        Container(
          width: double.maxFinite,
          // padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_colors.top, _colors.bot])),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text("${showArchivedOnly ? "Archived " : ""}Messages"),
            titleTextStyle: TextStyle(
              color: Colors.grey.shade200,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  setState(() {
                    showArchivedOnly = !showArchivedOnly;
                  });
                },
                icon: Icon(
                  showArchivedOnly ? Icons.archive : Icons.archive_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          // child: SafeArea(
          //   child: Pref,
          //   // child: Text(
          //   //   "Messages",

          //   // ),
          // ),
        ),
        StreamBuilder<List<ChatRoom>>(
            stream: ChatRoomsPage._vm.stream,
            builder: (_, snapshot) {
              if (snapshot.hasError) {
                return SizedBox(
                  width: size.width,
                  height: size.height - 200,
                  child: const Center(
                    child: Text(
                      "Unable to load message",
                      style: TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  width: size.width,
                  height: size.height - 200,
                  child: const Center(
                    child: Text(
                      "No Message found!",
                      style: TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }
              final List<ChatRoom> _rooms = snapshot.data!.where((element) {
                if (element.members.first.id == loggedUser!.firebaseId) {
                  if (showArchivedOnly) {
                    return element.hasUser1Archived;
                  }
                  return !element.hasUser1Archived;
                } else {
                  if (showArchivedOnly) {
                    return element.hasUser2Archived;
                  }
                  return !element.hasUser2Archived;
                }
              }).toList();

              if (_rooms.isEmpty) {
                return SizedBox(
                  width: size.width,
                  height: size.height - 200,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "No ${showArchivedOnly ? "Archived" : ""} Messages Available",
                        style: const TextStyle(
                          color: Colors.black38,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      IconButton(
                        onPressed: () {
                          // _service
                          //     .getUserChatrooms()
                          //     .listen((List<ChatRoom> rooms) {
                          //   print("ROOMS LENGTH : ${rooms.length}");
                          //   print(rooms.last.lastMessage);
                          //   print(rooms.first.id);
                          //   ChatRoomsPage._vm.populate(rooms);
                          // });
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  )),
                );
              }
              print(_rooms);
              _rooms.sort((a, b) => (b.lastMessage?.timeStamp ?? b.createdAt)
                  .compareTo(a.lastMessage?.timeStamp ?? a.createdAt));
              return LiquidPullToRefresh(
                onRefresh: () async {
                  final Completer<void> completer = Completer<void>();
                  // await Future.delayed(const Duration(milliseconds: 500));
                  // if (mounted) setState(() {});
                  // completer.complete();
                  _service.getUserChatrooms().listen((List<ChatRoom> rooms) {
                    print("ROOMS LENGTH : ${rooms.length}");
                    print(rooms.last.lastMessage);

                    ChatRoomsPage._vm.populate(rooms);
                    completer.complete();
                  });
                  // });
                  return completer.future;
                },
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  // physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, i) {
                    final ChatRoom room = _rooms[i];
                    return Slidable(
                      key: ValueKey(room.id),
                      enabled: true,
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) async {
                              await archiveChat(room.id, room.members)
                                  .then((value) {
                                if (room.members.first.id ==
                                    loggedUser!.firebaseId) {
                                  room.hasUser1Archived = !showArchivedOnly;
                                } else {
                                  room.hasUser2Archived = !showArchivedOnly;
                                }
                                if (mounted) setState(() {});
                              });
                              // await _api
                              //     .approveApplication(_app.id)
                              //     .whenComplete(() {
                              //   _app.status = "approved";
                              //   if (mounted) setState(() {});
                              // });
                            },
                            backgroundColor: _colors.top,
                            foregroundColor: Colors.white,
                            icon: Icons.archive_rounded,
                            label: showArchivedOnly ? "Unarchive" : 'Archive',
                          ),
                        ],
                      ),
                      child: ListTile(
                        onTap: () async {
                          await Navigator.push(
                              context,
                              PageTransition(
                                child: MessageConversationPage(
                                  chatroomId: room.id,
                                  targetAvatar: room.members[0].id ==
                                          loggedUser!.firebaseId
                                      ? room.members[1].avatar
                                      : room.members[0].avatar,
                                  targetName: room.members[0].id ==
                                          loggedUser!.firebaseId
                                      ? room.members[1].displayName
                                          .capitalizeWords()
                                      : room.members[0].displayName
                                          .capitalizeWords(),
                                  targetId: room.members[0].id ==
                                          loggedUser!.firebaseId
                                      ? room.members[1].id
                                      : room.members[0].id,
                                  targetServerId: room.members[0].serverId ==
                                          loggedUser!.id.toString()
                                      ? room.members[1].serverId
                                      : room.members[0].serverId,
                                ),
                                type: PageTransitionType.leftToRight,
                              ));
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: CachedNetworkImage(
                            imageUrl:
                                room.members[0].id == loggedUser!.firebaseId
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
                            text: room.lastMessage == null
                                ? "No Conversations Yet"
                                : room.lastMessage!.message.isNotEmpty
                                    ? room.lastMessage!.message
                                    : room.lastMessage!.file != null
                                        ? room.lastMessage!.file!
                                                .contains("chatroom_images")
                                            ? "Sent an image"
                                            : "Sent an attachment"
                                        : "",
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
                      ),
                    );
                  },
                  separatorBuilder: (_, i) => const SizedBox(
                    height: 10,
                  ),
                  itemCount: _rooms.length,
                ),
              );
            })
      ],
    );
  }
}
