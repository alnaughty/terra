import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:terra/models/v2/terran.dart';
import 'package:terra/services/firebase/chatroom_services.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/home_page_children/home_page_main_children/messaging/message_widget.dart';

class MessageConversationPage extends StatefulWidget {
  const MessageConversationPage({
    super.key,
    required this.chatroomId,
    required this.targetName,
    required this.targetAvatar,
  });
  final String chatroomId;
  final String targetName;
  final String targetAvatar;
  // final Terran target;
  @override
  State<MessageConversationPage> createState() =>
      _MessageConversationPageState();
}

class _MessageConversationPageState extends State<MessageConversationPage> {
  final ChatRoomService _chatService = ChatRoomService.instance;
  final AppColors _colors = AppColors.instance;
  late final TextEditingController _text;
  late final ScrollController _scroll;
  late final DatabaseReference _chatRoomRef;
  @override
  void initState() {
    // TODO: implement initState
    _scroll = ScrollController();
    _text = TextEditingController();
    _chatRoomRef = FirebaseDatabase.instance
        .ref()
        .child('chat_rooms')
        .child(widget.chatroomId);
    _chatRoomRef.child('messages').onChildAdded.listen((event) {
      setState(() {});
      _scroll.animateTo(
        _scroll.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _text.dispose();

    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Container(
                  width: 40,
                  height: 40,
                  color: Colors.white,
                  child: Image.network(
                    widget.targetAvatar,
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  widget.targetName.toUpperCase(),
                ),
              )
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<DatabaseEvent>(
                stream: _chatService.getChatMessages(widget.chatroomId),
                builder: (_, snapshot) {
                  if (!snapshot.hasData ||
                      snapshot.data?.snapshot.value == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final DatabaseEvent event = snapshot.data!;
                  final Map<String, dynamic> messages =
                      Map<String, dynamic>.from(event.snapshot.value as Map);
                  final List messageList = messages.entries.toList()
                    ..sort((a, b) =>
                        b.value['timestamp'].compareTo(a.value['timestamp']));
                  return ListView.separated(
                      controller: _scroll,
                      reverse: true,
                      itemBuilder: (_, i) {
                        final MapEntry message = messageList[i];
                        return MessageWidget(
                          messageText: message.value['message'],
                          senderName: message.value['sender_id'] ==
                                  loggedUser!.firebaseId
                              ? loggedUser!.fullName
                              : widget.targetName,
                          time: DateTime.fromMillisecondsSinceEpoch(
                              message.value['timestamp']),
                          isMe: message.value['sender_id'] ==
                              loggedUser!.firebaseId,
                        );
                        // return Text(message.value['message'].toString());
                      },
                      separatorBuilder: (_, i) => const SizedBox(
                            height: 10,
                          ),
                      itemCount: messageList.length);
                  // messages.forEach((key, value) {
                  //   final message = value as Map<dynamic, dynamic>;
                  // final messageWidget = MessageWidget(
                  // senderName: message['sender_id'] == loggedUser!.firebaseId
                  //     ? loggedUser!.fullName
                  //     : widget.target.fullname,
                  //   messageText: message['text'],
                  //   isMe: message['sender_id'] == loggedUser!.firebaseId,
                  //   time: DateTime.parse(message['timestamp']),
                  // );
                  //   messageList.add(messageWidget);
                  // });
                  // return ListView(
                  //   controller: _scroll,
                  //   children: [Text(messageList.toString())],
                  // );
                  // return ListView.separated(
                  //   controller: _scroll,
                  //   itemBuilder: (_, i) {
                  //     final message = messageList[i].value;
                  //     final bool isOwnMessage =
                  //         message['user_id'] == loggedUser!.firebaseId;
                  //     return Container();
                  //   },
                  //   separatorBuilder: (_, i) => const SizedBox(
                  //     height: 1,
                  //   ),
                  //   reverse: true,
                  //   itemCount: messageList.length,
                  // );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _text,
                        decoration: const InputDecoration(
                          hintText: 'Type a message',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          await _chatService.sendChatMessage(widget.chatroomId,
                              loggedUser!.firebaseId, _text.text);
                          _text.clear();
                        },
                        icon: Icon(
                          Icons.send,
                          color: _colors.top,
                        ))
                    // FloatingActionButton(
                    //   onPressed: () {},
                    //   child: Icon(Icons.send),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
