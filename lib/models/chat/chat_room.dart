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
  ChatRoom copyWith({
    String? id,
    List<ChatRoomMember>? members,
    DateTime? createdAt,
    ChatConversation? lastMessage,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
