import 'package:terra/models/chat/chat_room_member.dart';

class ChatRoom {
  final String id;
  final List<ChatRoomMember> members;
  const ChatRoom({
    required this.id,
    required this.members,
  });
}
