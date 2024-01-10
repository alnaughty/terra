import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rxdart/rxdart.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/chat/chat_conversation.dart';
import 'package:terra/models/chat/chat_room.dart';
import 'package:terra/models/chat/chat_room_member.dart';
import 'package:terra/utils/global.dart';
import 'package:http/http.dart' as http;
import 'package:terra/utils/network.dart';

class ChatService {
  ChatService._pr();
  static final ChatService _instance = ChatService._pr();
  static ChatService get instance => _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getOrCreateChatroom(List<ChatRoomMember> members) async {
    // Sort member IDs alphabetically to ensure consistent chatroom ID
    final List<String> memberIds = members.map((member) => member.id).toList()
      ..sort();
    final String chatroomId = memberIds.join('_');
    final DocumentReference<Map<String, dynamic>> chatroomRef =
        _firestore.collection('chatrooms').doc(chatroomId);
    final DocumentSnapshot<Map<String, dynamic>> chatroomSnapshot =
        await chatroomRef.get();
    if (chatroomSnapshot.exists) {
      // Chatroom already exists, return its ID
      return chatroomId;
    } else {
      final data = {
        'id': chatroomId,
        'members': members
            .map(
              (member) => member.toMap(),
            )
            .toList(),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'lastMessage': null,
        'hasUser1Archived': false,
        'hasUser2Archived': false,
      };
      await chatroomRef.set(data);
      // Add chatroom ID to each member's chatroom list
      for (final member in members) {
        final memberRef = _firestore.collection('users').doc(member.id);
        await memberRef.set({
          'chatrooms': FieldValue.arrayUnion([chatroomId]),
        }, SetOptions(merge: true));
      }

      return chatroomId;
    }
  }

  Stream<List<ChatRoom>> getUserChatrooms() {
    try {
      final userId = loggedUser!.firebaseId;
      final userRef = _firestore.collection('users').doc(userId);

      return userRef.snapshots().asyncMap((doc) async {
        final chatroomIds = List<String>.from(doc.data()?['chatrooms'] ?? []);
        final chatrooms = <ChatRoom>[];
        for (final chatroomId in chatroomIds) {
          final chatroom = await _getChatroom(chatroomId).first;
          if (chatroom != null) {
            chatrooms.add(chatroom);
          }
        }
        return chatrooms;
      }).asyncExpand((chatrooms) {
        final chatroomRefs = chatrooms
            .map((chatroom) =>
                _firestore.collection('chatrooms').doc(chatroom.id))
            .toList();
        final chatroomSnapshots = chatroomRefs.map((chatroomRef) => chatroomRef
            .collection('messages')
            .orderBy('timestamp')
            .snapshots());

        return Rx.combineLatest(
          chatroomSnapshots,
          (snapshots) {
            final lastMessages = <ChatConversation?>[];
            for (final snapshot in snapshots) {
              if (snapshot.docs.isNotEmpty) {
                final lastDoc = snapshot.docs.last;
                final lastMessage = ChatConversation.fromJson(lastDoc.data());
                lastMessages.add(lastMessage);
              } else {
                lastMessages.add(null);
              }
            }
            print("LAST MESSAGE : $lastMessages");
            for (ChatRoom room in chatrooms) {
              room = room.copyWith(
                  lastMessage: lastMessages[chatrooms.indexOf(room)]);
            }
            return chatrooms;
          },
        ).asBroadcastStream();
      });
    } catch (e, s) {
      print("ERROR : LISTENING $e");
      print("STACK : $s");
      return const Stream.empty();
    }
  }
  // Stream<List<ChatRoom>> getUserChatrooms() {
  //   final userId = loggedUser!.firebaseId;
  //   final DocumentReference<Map<String, dynamic>> userRef =
  //       _firestore.collection('users').doc(userId);
  //   return userRef.collection("chatrooms").snapshots().map(
  //         (event) => event.docs
  //             .map(
  //               (e) => ChatRoom(id: id, members: members, createdAt: createdAt),
  //             )
  //             .toList(),
  //       );

  // }
  Future<bool> archiveChatroom(chatroomId, int userIndex, bool status) async {
    try {
      final DocumentReference chatroomRef =
          _firestore.collection('chatrooms').doc(chatroomId);
      chatroomRef.update({"hasUser${userIndex}Archived": status});
      return status;
    } catch (e) {
      return false;
    }
  }

  Stream<ChatRoom?> _getChatroom(String chatroomId) {
    final chatroomRef = _firestore.collection('chatrooms').doc(chatroomId);
    return chatroomRef.snapshots().map((docSnapshot) {
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        print("DOCUMENT DATA : ${data}");
        final membersData = List<Map<String, dynamic>>.from(data['members']);
        final members = membersData
            .map(
              (memberData) => ChatRoomMember(
                id: memberData['id'],
                displayName: memberData['displayName'],
                avatar: memberData['avatar'],
                serverId: memberData['server_id'] ?? "0",
              ),
            )
            .toList();
        final lastMessageData = data['lastMessage'];
        print("LAST MESSAGE $lastMessageData");
        print("HAS ARCHIVED : ${data}");
        final ChatConversation? lastMessage = lastMessageData != null
            ? ChatConversation.fromJson(lastMessageData)
            : null;
        return ChatRoom(
          id: chatroomId,
          members: members,
          createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
          lastMessage: lastMessage,
          hasUser1Archived: data['hasUser1Archived'] ?? false,
          hasUser2Archived: data['hasUser2Archived'] ?? false,
        );
      } else {
        return null;
      }
    });
  }

  Stream<List<ChatConversation>> getChatroomMessages(String chatroomId) {
    try {
      print(chatroomId);
      final DocumentReference<Map<String, dynamic>> chatroomRef =
          _firestore.collection('chatrooms').doc(chatroomId);
      return chatroomRef
          .collection("messages")
          .orderBy('timestamp')
          .snapshots()
          .map(
            (event) => event.docs.map((e) {
              print(e.data());
              return ChatConversation(
                id: e.id,
                message: e.get('message'),
                timeStamp: DateTime.fromMillisecondsSinceEpoch(
                    e.get("timestamp") as int),
                senderId: e.get('senderId'),
                file: e.data()['file'],
              );
            }).toList(),
          );
    } catch (e, s) {
      print("ERROR :$e");
      print("STACKTRACE : $s");
      return const Stream.empty();
    }
  }

  Future<void> sendNotification(
      {required String receiverId, required String message}) async {
    try {
      await http
          .post("${Network.domain}/api/message-notification".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      }, body: {
        "receiver_id": receiverId,
        "message": message,
      });
    } catch (e, s) {
      Fluttertoast.showToast(
          msg:
              "Unable to notify the receiver, but recorded, please contact admin.");
      return;
    }
  }

  Future<void> sendMessage(String chatroomId, String message, String senderId,
      {String? file, required String receiverId}) async {
    try {
      final chatroomRef = _firestore.collection('chatrooms').doc(chatroomId);
      final messagesRef = chatroomRef.collection('messages');
      final int timestamp = DateTime.now().millisecondsSinceEpoch;
      final ChatConversation conversation = ChatConversation(
        id: '',
        message: message,
        sent: false,
        senderId: senderId,
        timeStamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
        file: file,
      );
      final messageData = conversation.toJson();
      final messageRef = await messagesRef.add(messageData);
      final messageId = messageRef.id;
      conversation.id = messageId;
      await chatroomRef.update({
        'lastMessage': {
          'message': message,
          'timestamp': timestamp,
          'senderId': senderId,
          'file': file,
        },
      });
      await sendNotification(receiverId: receiverId, message: message);
    } catch (e) {
      print("ERROR SENDING MESSAGE");
      return;
    }
  }
}
