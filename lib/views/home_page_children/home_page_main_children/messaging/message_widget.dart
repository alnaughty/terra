import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:terra/services/url_launcher.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/views/home_page_children/home_page_main_children/file_viewer.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageWidget extends StatelessWidget {
  final String messageText;
  final String senderName;
  final bool isMe;
  final String? file;
  final DateTime time;

  const MessageWidget({
    super.key,
    required this.messageText,
    required this.senderName,
    required this.time,
    required this.isMe,
    this.file,
  });
  static final AppColors _colors = AppColors.instance;
  static final Launcher _launcher = Launcher();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    print(file);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: file == null
            ? null
            : () async {
                if (file!.contains('chatroom_images')) {
                  await _launcher.launchWebView(context, url: file!);
                } else {
                  await showGeneralDialog(
                    context: context,
                    transitionBuilder: (_, a1, a2, child) => Transform.scale(
                      scale: a1.value,
                      child: FadeTransition(
                        opacity: a1,
                        child: child,
                      ),
                    ),
                    barrierColor: Colors.black.withOpacity(.5),
                    barrierDismissible: true,
                    barrierLabel: "",
                    transitionDuration: const Duration(milliseconds: 600),
                    pageBuilder: (_, a1, a2) => SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CustomFileViewer(
                          url: file!,
                          isPdf: file!.contains('chatroom_files'),
                        ),
                      ),
                    ),
                  );
                }
              },
        child: Column(
          children: [
            if (file != null && (file!.contains("chatroom_images"))) ...{
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: file!,
                  width: 200,
                ),
              )
            },
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
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
                  if (messageText.isNotEmpty) ...{
                    Text(
                      messageText,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: isMe ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                  },
                  if (file != null &&
                      (file!.contains('chatroom_files') ||
                          file!.contains('chatroom_docs'))) ...{
                    Container(
                      alignment: Alignment.center,
                      width: 200,
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: FittedBox(
                              child: Text(
                                "Sent an attachment",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: (isMe
                                          ? Colors.white
                                          : Colors.grey.shade800)
                                      .withOpacity(.7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.attach_file,
                            color: Colors.white.withOpacity(1),
                            size: 17,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 4.0),
                  },
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
          ],
        ),
      ),
    );
  }
}
