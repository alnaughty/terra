import 'package:terra/models/chat/chat_conversation.dart';
import 'package:terra/models/chat/chat_room_member.dart';

class ChatRoom {
  final String id;
  final List<ChatRoomMember> members;
  final DateTime createdAt;
  final ChatConversation? lastMessage;
  const ChatRoom({
    required this.id,
    required this.members,
    required this.createdAt,
    this.lastMessage,
  });
}
