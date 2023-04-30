import 'package:terra/models/chat/chat_conversation.dart';
import 'package:terra/models/chat/chat_room_member.dart';

class ChatRoom {
  final String id;
  final List<ChatRoomMember> members;
  final DateTime createdAt;
  ChatConversation? lastMessage;
  bool hasUser1Archived;
  bool hasUser2Archived;
  ChatRoom({
    required this.id,
    required this.members,
    required this.createdAt,
    this.lastMessage,
    required this.hasUser1Archived,
    required this.hasUser2Archived,
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
      hasUser1Archived: hasUser1Archived,
      hasUser2Archived: hasUser2Archived,
    );
  }

  @override
  String toString() => "${toJson()}";
  Map<String, dynamic> toJson() => {
        "id": id,
        "members": members,
        "createdAt": createdAt,
        "hasUser1Archived": hasUser1Archived,
        "hasUser2Archived": hasUser2Archived,
      };
}
