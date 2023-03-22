class ChatConversation {
  final String id;
  final String message;
  final DateTime timeStamp;
  const ChatConversation(
      {required this.id, required this.message, required this.timeStamp});
  factory ChatConversation.fromMap(Map<dynamic, dynamic> map) =>
      ChatConversation(
        id: map.keys.first,
        message: map.values.first['message'],
        timeStamp: DateTime.fromMillisecondsSinceEpoch(
          map.values.first['timestamp'] as int,
        ),
      );

  @override
  String toString() => "${toJson()}";

  Map<String, dynamic> toJson() => {
        "id": id,
        "message": message,
        "timestamp": timeStamp.millisecondsSinceEpoch,
      };
}
