class ChatConversation {
  String id;
  final String message;
  final String senderId;
  final DateTime timeStamp;
  final String? file;
  ChatConversation({
    required this.id,
    required this.message,
    required this.timeStamp,
    this.file,
    required this.senderId,
  });
  factory ChatConversation.fromMap(Map<dynamic, dynamic> map) =>
      ChatConversation(
        senderId: map.values.first['sender_id'],
        id: map.keys.first,
        message: map.values.first['message'],
        timeStamp: DateTime.fromMillisecondsSinceEpoch(
          map.values.first['timestamp'] as int,
        ),
      );
  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    print("DATA ${json['senderId']}");
    return ChatConversation(
      senderId: json['senderId'],
      id: "",
      message: json['message'],
      timeStamp: DateTime.fromMillisecondsSinceEpoch(
        json['timestamp'] as int,
      ),
      file: json['file'],
    );
  }

  @override
  String toString() => "${toJson()}";

  Map<String, dynamic> toJson() => {
        "id": id,
        "message": message,
        "timestamp": timeStamp.millisecondsSinceEpoch,
        "senderId": senderId,
        "file": file,
      };
}
