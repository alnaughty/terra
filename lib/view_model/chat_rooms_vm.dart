import 'package:rxdart/rxdart.dart';
import 'package:terra/models/chat/chat_room.dart';

class ChatRoomsVm {
  ChatRoomsVm._pr();
  static final ChatRoomsVm _instance = ChatRoomsVm._pr();
  static ChatRoomsVm get instance => _instance;

  BehaviorSubject<List<ChatRoom>> _subject = BehaviorSubject<List<ChatRoom>>();
  Stream<List<ChatRoom>> get stream => _subject.stream;
  List<ChatRoom>? get current => _subject.value;
  void populate(List<ChatRoom> data) {
    _subject.add(data);
  }
  // void append(ChatRoom chatroom) {
  //   final List<ChatRoom> _res = List.from(current ?? []);
  //   _res.add(chatroom);
  //   _subject.add(_res);
  // }

  void dispose() {
    _subject = BehaviorSubject<List<ChatRoom>>();
  }
}
