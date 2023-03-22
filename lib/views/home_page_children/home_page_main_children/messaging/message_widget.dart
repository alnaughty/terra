import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:terra/utils/color.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageWidget extends StatelessWidget {
  final String messageText;
  final String senderName;
  final bool isMe;
  final DateTime time;

  const MessageWidget({
    super.key,
    required this.messageText,
    required this.senderName,
    required this.time,
    required this.isMe,
  });
  static final AppColors _colors = AppColors.instance;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        constraints: BoxConstraints(
          maxWidth: size.width * .75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: isMe
                ? [_colors.top, _colors.bot]
                : [Colors.grey.shade300, Colors.grey.shade200],
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              messageText,
              style: TextStyle(
                fontSize: 15.0,
                color: isMe ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              "${DateFormat("MMM dd, yyyy").format(time)} - ${timeago.format(time)}",
              style: TextStyle(
                fontSize: 10.0,
                color: isMe ? Colors.white : Colors.black45,
              ),
            ),
          ],
        ),
        // child: Column(
        //   crossAxisAlignment:
        //       isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        //   children: [
        //     Container(
        //       child: Material(
        //         color: isMe ? _colors.bot : Colors.grey[300],
        //         borderRadius: BorderRadius.circular(20),
        //         elevation: 5.0,
        //         child: Padding(
        //           padding: const EdgeInsets.symmetric(
        //               vertical: 10.0, horizontal: 15.0),
        //           child: ,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
