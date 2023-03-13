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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Text(
          //   senderName,
          //   style: const TextStyle(
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
          // const SizedBox(height: 4.0),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: size.width * .75,
            ),
            child: Material(
              color: isMe ? _colors.bot : Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
              elevation: 5.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      messageText,
                      style: const TextStyle(
                        fontSize: 15.0,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      "${DateFormat("MMM dd, yyyy").format(time)} - ${timeago.format(time)}",
                      style: const TextStyle(
                        fontSize: 10.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
