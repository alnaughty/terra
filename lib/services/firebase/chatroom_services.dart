import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

class ChatRoomService {
  ChatRoomService._pr();
  static final ChatRoomService _instance = ChatRoomService._pr();
  static ChatRoomService get instance => _instance;
  static final DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref();
  Future<String?> gegtOrCreateChatRoom(
      {required String userId1,
      required String userId2,
      required String name1,
      required String name2}) async {
    try {
      final DatabaseReference chatRoomsRef =
          databaseReference.child('chat_rooms');
      // Check if a chatroom already exists with both users
      final Query query =
          chatRoomsRef.orderByChild('user1_id').equalTo(userId1);
      final DatabaseEvent snapshot = await query.limitToFirst(1).once();
      if (snapshot.snapshot.value != null) {
        final Map values = snapshot.snapshot.value as Map;
        final String chatRoomId = values.keys.first;
        return chatRoomId;
      } else {
        // Create a new chatroom
        final newChatRoomRef = chatRoomsRef.push();
        final String chatRoomId = newChatRoomRef.key!;
        final Map<String, dynamic> chatRoomData = {
          'user1_id': userId1,
          "user1_name": name1,
          "user2_name": name2,
          'user2_id': userId2,
          'created_at': ServerValue.timestamp,
        };
        await newChatRoomRef.set(chatRoomData);
        return chatRoomId;
      }
      // if (snapshot.value != null) {
      //   // Chat room already exists
      //   Map<dynamic, dynamic> rooms = snapshot.value as Map;
      //   String? chatRoomId = rooms.keys.firstWhere(
      //       (key) =>
      //           rooms[key]['user2_id'] == userId2 ||
      //           rooms[key]['user1_id'] == userId2,
      //       orElse: () => null);
      //   if (chatRoomId != null) {
      //     // Found existing chat room
      //     return chatRoomId;
      //   }
      // }

      // if (chatRoomId == null) {
      //   // Chatroom does not exist with both users, create a new chatroom
      //   final chatRoomsRef = databaseReference.child('chat_rooms');
      //   final newChatRoomRef = chatRoomsRef.push();
      //   chatRoomId = newChatRoomRef.key!;
      //   final chatRoomData = {
      //     'user1_id': userId1,
      //     'user1_name': name1,
      //     'user2_id': userId2,
      //     'user2_name': name2,
      //     'created_at': ServerValue.timestamp,
      //   };
      //   await newChatRoomRef.set(chatRoomData);
      // }

      // return chatRoomId;
      // DatabaseReference chatRoomsRef = databaseReference.child('chat_rooms');
      // DatabaseReference newChatRoomRef = chatRoomsRef.push();
      // String chatRoomId = newChatRoomRef.key!;
      // Map<String, dynamic> chatRoomData = {
      //   'user1_id': userId1,
      //   "user1_name": name1,
      //   "user2_name": name2,
      //   'user2_id': userId2,
      //   'created_at': ServerValue.timestamp,
      // };
      // await newChatRoomRef.set(chatRoomData);
      // return chatRoomId;
    } catch (e) {
      print("ERROR : $e");
      return null;
    }
  }

  Stream<DatabaseEvent> getChatMessages(String chatRoomId) {
    // DatabaseReference messagesRef =
    //     databaseReference.child('chat_rooms/$chatRoomId/messages');
    final DatabaseReference chatRef =
        databaseReference.child('chat_rooms').child(chatRoomId);
    return chatRef.child("messages").orderByChild('timestamp').onValue;
    // messagesRef.onValue.listen((event) {
    //   if (event.snapshot.value != null) {
    //     Map<dynamic, dynamic> messages =
    //         (event.snapshot.value as Map<dynamic, dynamic>);
    //     messages.forEach((key, value) {
    //       // Parse message data and display in the UI
    //     });
    //   }
    // });
  }

  Future<void> sendChatMessage(
      String chatRoomId, String senderId, String message) async {
    await databaseReference
        .child('chat_rooms/$chatRoomId/messages')
        .push()
        .set({
      'sender_id': senderId,
      'message': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch
    });
    print("SENT");
  }

  void getChatRoomsForUser(String userId) {
    DatabaseReference chatRoomsRef = databaseReference.child('chat_rooms');
    chatRoomsRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> chatRooms =
            (event.snapshot.value as Map<dynamic, dynamic>);
        List<String> chatRoomIds = [];
        chatRooms.forEach((key, value) {
          if ((value['user1_id'] == userId || value['user2_id'] == userId)) {
            chatRoomIds.add(key);
          }
        });
        // navigateToChatRoomsScreen(chatRoomIds);
      }
    });
  }
}
