import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:terra/models/chat/chat_conversation.dart';
import 'package:terra/services/firebase/chat_service.dart';
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
  final ChatService _chatService = ChatService.instance;
  final AppColors _colors = AppColors.instance;
  late final TextEditingController _text;
  late final ScrollController _scroll;
  late final DatabaseReference _chatRoomRef;
  bool isInit = true;
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
      try {
        _scroll.animateTo(
          _scroll.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } catch (e) {
        print("SCROLL ERROR");
      }
      if (mounted) setState(() {});
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
          titleTextStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatConversation>>(
                stream: _chatService.getChatroomMessages(widget.chatroomId),
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "No conversation found",
                        style: TextStyle(
                          color: Colors.black.withOpacity(.5),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  final List<ChatConversation> event = snapshot.data!;
                  event.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
                  // final Map<String, dynamic> messages =
                  //     Map<String, dynamic>.from(event.snapshot.value as Map);
                  // final List messageList = messages.entries.toList()
                  //   ..sort((a, b) =>
                  //       b.value['timestamp'].compareTo(a.value['timestamp']));
                  return ListView.separated(
                      controller: _scroll,
                      reverse: true,
                      itemBuilder: (_, i) {
                        final ChatConversation message = event[i];
                        return MessageWidget(
                          messageText: message.message,
                          senderName: message.senderId == loggedUser!.firebaseId
                              ? loggedUser!.fullName
                              : widget.targetName,
                          time: message.timeStamp,
                          isMe: message.senderId == loggedUser!.firebaseId,
                        );
                      },
                      separatorBuilder: (_, i) => const SizedBox(
                            height: 10,
                          ),
                      itemCount: event.length);
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
                        await _chatService.sendMessage(
                          widget.chatroomId,
                          _text.text,
                          loggedUser!.firebaseId,
                        );
                        _text.clear();
                      },
                      icon: Icon(
                        Icons.send,
                        color: _colors.top,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
