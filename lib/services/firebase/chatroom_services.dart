import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:terra/models/chat/chat_conversation.dart';
import 'package:terra/models/chat/chat_room.dart';
import 'package:terra/models/chat/chat_room_member.dart';
import 'package:terra/view_model/chat_rooms_vm.dart';

class ChatRoomServicse {
  ChatRoomServicse._pr();
  static final ChatRoomsVm _vm = ChatRoomsVm.instance;
  static final ChatRoomServicse _instance = ChatRoomServicse._pr();
  static ChatRoomServicse get instance => _instance;
  static final DatabaseReference databaseReference =
      FirebaseDatabase.instance.ref();
  Future<String?> gegtOrCreateChatRoom(
      {required String userId1,
      required String userId2,
      required String name1,
      required String name2,
      required String avatar1,
      required String avatar2}) async {
    try {
      print("CREATE OR GET");
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
          "user1_avatar": avatar1,
          "user2_name": name2,
          'user2_id': userId2,
          "user2_avatar": avatar2,
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

  Stream<DatabaseEvent> streamChatRoomsForUser(String userId) =>
      databaseReference.child('chat_rooms').onValue;
  void getChatRoomsForUser(String userId) {
    print("INIT LISTENING MESSAGE for $userId");
    DatabaseReference chatRoomsRef = databaseReference.child('chat_rooms');
    chatRoomsRef.onValue.listen((event) {
      print("VALUE: ${event.snapshot.value}");
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> chatRooms =
            (event.snapshot.value as Map<dynamic, dynamic>);
        final List<ChatRoom> _result = [];
        chatRooms.forEach((key, value) async {
          if ((value['user1_id'] == userId || value['user2_id'] == userId)) {
            final Query messagesRef = databaseReference
                .child('chat_rooms/$key/messages')
                .orderByChild('timestamp')
                .limitToLast(1);
            DatabaseEvent messageSnapshot = await messagesRef.once();
            Map<dynamic, dynamic>? messageData =
                messageSnapshot.snapshot.value == null
                    ? null
                    : (messageSnapshot.snapshot.value as Map<dynamic, dynamic>);
            ChatConversation? convo = messageData == null
                ? null
                : ChatConversation.fromMap(messageData);
            // Query to get the last message in this chat room
            // DatabaseReference messagesRef = databaseReference
            //     .child('chat_rooms/$key/messages')
            //     .orderByChild('timestamp')
            //     .limitToLast(1);

            // DataSnapshot messageSnapshot = await messagesRef.once();
            // Map<dynamic, dynamic> messageData =
            //     (messageSnapshot.value as Map<dynamic, dynamic>);

            final ChatRoom chatroom = ChatRoom(
              id: key,
              createdAt: DateTime.fromMillisecondsSinceEpoch(
                  value['created_at'] as int),
              hasUser1Archived: value['hasUser1Archived'] ?? false,
              hasUser2Archived: value['hasUser2Archived'] ?? false,
              lastMessage: convo,
              members: [
                ChatRoomMember(
                  id: value['user1_id'],
                  displayName: value['user1_name'],
                  avatar: value['user1_avatar'],
                ),
                ChatRoomMember(
                  id: value['user2_id'],
                  displayName: value['user2_name'],
                  avatar: value['user2_avatar'],
                ),
              ],
            );
            _result.add(chatroom);
          }
        });
        _vm.populate(_result);
      }
    });
  }
}
