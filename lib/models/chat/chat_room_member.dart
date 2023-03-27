class ChatRoomMember {
  final String id;
  final String displayName;
  final String avatar;
  const ChatRoomMember(
      {required this.id, required this.displayName, required this.avatar});
  factory ChatRoomMember.fromMap(Map<String, dynamic> map) {
    return ChatRoomMember(
      id: map['id'] as String,
      displayName: map['displayName'] as String,
      avatar: map['avatar'] as String,
    );
  }
  Map<String, dynamic> toMap() => {
        "id": id,
        "displayName": displayName,
        "avatar": avatar,
      };
}
