class ChatRoomMember {
  final String id;

  final String displayName;
  final String avatar;
  final String serverId;
  const ChatRoomMember(
      {required this.id,
      required this.displayName,
      required this.avatar,
      required this.serverId});
  factory ChatRoomMember.fromMap(Map<String, dynamic> map) {
    return ChatRoomMember(
      id: map['id'] as String,
      displayName: map['displayName'] as String,
      avatar: map['avatar'] as String,
      serverId: map['server_id'] as String,
    );
  }
  Map<String, dynamic> toMap() => {
        "id": id,
        "server_id": serverId,
        "displayName": displayName,
        "avatar": avatar,
      };
}
