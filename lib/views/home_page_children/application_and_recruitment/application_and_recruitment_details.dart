import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rxdart/rxdart.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/v2/application.dart';
import 'package:terra/models/v2/negotiation_model.dart';
import 'package:terra/services/API/v2/task_api.dart';
import 'package:terra/services/firebase/chat_service.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/home_page_children/application_and_recruitment/user_details.dart';
import 'package:terra/views/home_page_children/home_page_main_children/messaging/message_conversation_page.dart';
import 'package:terra/views/home_page_children/home_page_main_children/negotiation_page.dart';

class ApplicationAndRecruitmentDetails extends StatefulWidget {
  const ApplicationAndRecruitmentDetails({super.key, required this.data});
  final MyApplication data;
  @override
  State<ApplicationAndRecruitmentDetails> createState() =>
      _ApplicationAndRecruitmentDetailsState();
}

class _ApplicationAndRecruitmentDetailsState
    extends State<ApplicationAndRecruitmentDetails> {
  BehaviorSubject<List<NegotiationModel>> _subject =
      BehaviorSubject<List<NegotiationModel>>();
  final TaskAPIV2 _api = TaskAPIV2.instance;
  final AppColors _colors = AppColors.instance;
  final ChatService _chatService = ChatService.instance;
  getCounterOffers() async {
    await _api.getNegotiations(widget.data.task.id).then((value) {
      _subject.add(value);
    });
  }

  @override
  void initState() {
    getCounterOffers();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> approveNegotiation(int id) async {
    Navigator.of(context).pop(null);
    await _api.approveNegotiation(id);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: size.height * .6, minWidth: size.width * .9),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              onTap: loggedUser!.accountType != 1
                  ? () async {
                      Navigator.of(context).pop(null);
                      await Navigator.push(
                        context,
                        PageTransition(
                          child: UserDetailsPage(
                            user: widget.data.applicationFrom,
                          ),
                          type: PageTransitionType.leftToRight,
                        ),
                      );
                    }
                  : null,
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: CachedNetworkImage(
                  imageUrl: widget.data.applicationFrom.avatar,
                  height: 50,
                  width: 50,
                ),
              ),
              title: Text(
                widget.data.applicationFrom.fullname.capitalizeWords(),
              ),
              subtitle: Text(
                widget.data.applicationFrom.email,
              ),
              trailing: loggedUser!.accountType == 1
                  ? null
                  : IconButton(
                      onPressed: () async {
                        await _chatService.getOrCreateChatroom([
                          widget.data.applicationFrom.toMember(),
                          loggedUser!.toMember(),
                        ]).then((val) async {
                          await Navigator.push(
                              context,
                              PageTransition(
                                  child: MessageConversationPage(
                                    chatroomId: val,
                                    targetName:
                                        widget.data.applicationFrom.fullname,
                                    targetAvatar:
                                        widget.data.applicationFrom.avatar,
                                    targetId:
                                        widget.data.applicationFrom.firebaseId,
                                    targetServerId: widget
                                        .data.applicationFrom.id
                                        .toString(),
                                  ),
                                  type: PageTransitionType.leftToRight));
                        });
                      },
                      icon: Icon(
                        CupertinoIcons.bubble_left_fill,
                        color: _colors.top,
                      ),
                    ),
            ),
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: const Text(
                    "Task",
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 15,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Divider(
                    color: Colors.grey.shade300,
                    thickness: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  // width: (size.width * .9) * .25,
                  // height: (size.width * .9) * .25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade100,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(-1, 1),
                          color: Colors.grey.shade400,
                          blurRadius: 2,
                        )
                      ]),
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: widget.data.task.category.icon,
                      height: 60,
                      fit: BoxFit.fitHeight,
                      placeholder: (_, ff) => Image.asset(
                        "assets/images/loader.gif",
                        height: 100,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (Rect rect) =>
                            LinearGradient(colors: [_colors.top, _colors.bot])
                                .createShader(rect),
                        child: Text(
                          widget.data.task.category.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/icons/peso.png",
                            height: 25,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              widget.data.task.rate?.toStringAsFixed(2) ??
                                  "0.0",
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.data.task.message ?? "NO MESSAGE/SPECIFICATIONS",
                      ),
                    ],
                  ),
                )
              ],
            ),
            StreamBuilder<List<NegotiationModel>>(
              stream: _subject.stream,
              builder: (_, snapshot) {
                if (snapshot.hasError || !snapshot.hasData) {
                  if (!snapshot.hasData) {
                    return SizedBox(
                      height: 100,
                      width: double.maxFinite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Loading Negotiations",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ],
                      ),
                    );
                  }
                  return Container();
                }
                final List<NegotiationModel> _result = snapshot.data!;
                if (_result.isEmpty) {
                  return const SizedBox(
                    height: 60,
                    width: double.maxFinite,
                    child: Center(
                      child: Text(
                        "No recorded negotiations",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  );
                }
                NegotiationModel? deltPrice;
                try {
                  deltPrice = _result
                      .where((e) => e.employerApproved && e.jobseekerApproved)
                      .first;
                } catch (e) {
                  deltPrice = null;
                }
                final List<NegotiationModel> negos = deltPrice != null
                    ? _result
                        .where((element) => element.id != deltPrice!.id)
                        .toList()
                    : _result;
                negos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Counter Offers",
                            style: TextStyle(
                              fontSize: 15,
                              color: _colors.top,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(context).pop(null);
                            await Navigator.push(
                              context,
                              PageTransition(
                                  child: NegotiationPage(
                                    taskId: widget.data.task.id,
                                  ),
                                  type: PageTransitionType.leftToRight),
                            );
                          },
                          child: const Text("View More"),
                        )
                      ],
                    ),
                    if (deltPrice != null) ...{},
                    ...negos
                        .sublist(0, negos.length > 5 ? 5 : negos.length)
                        .map((value) {
                      final bool isMe = value.negotiatorId == loggedUser!.id;
                      return Slidable(
                        key: Key(value.id.toString()),
                        enabled: deltPrice == null,
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) async {
                                await approveNegotiation(value.id);
                                // await _api
                                //     .approveApplication(_app.id)
                                //     .whenComplete(() {
                                //   _app.status = "approved";
                                //   if (mounted) setState(() {});
                                // });
                              },
                              backgroundColor: _colors.top,
                              foregroundColor: Colors.white,
                              icon: Icons.check,
                              label: 'Deal',
                            ),
                          ],
                        ),
                        child: Container(
                          color: Colors.white,
                          child: ListTile(
                            title: Text(
                              isMe ? "Your Offer" : "Other User's Offer",
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                            trailing: value.employerApproved &&
                                    value.jobseekerApproved
                                ? Image.asset(
                                    "assets/icons/negotiation.png",
                                    color: Colors.green,
                                    width: 30,
                                  )
                                : null,
                            subtitle: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        "Price : ",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      Image.asset(
                                        "assets/icons/peso.png",
                                        width: 20,
                                      ),
                                      Expanded(
                                          child: Text(
                                        value.price.toStringAsFixed(2),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade800,
                                        ),
                                      ))
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  DateFormat("MMM dd, yyyy hh:mm aa").format(
                                    value.createdAt,
                                  ),
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey.shade900,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                    // ListView.separated(
                    //   shrinkWrap: true,
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   itemBuilder: (_, i) {
                    //     final NegotiationModel value = _result[i];
                    //     final bool isMe = value.negotiatorId == loggedUser!.id;
                    // return Slidable(
                    //   key: Key(value.id.toString()),
                    //   enabled: (!value.employerApproved &&
                    //           !value.jobseekerApproved) &&
                    //       !isMe,
                    //   endActionPane: ActionPane(
                    //     motion: const ScrollMotion(),
                    //     children: [
                    //       SlidableAction(
                    //         onPressed: (_) async {
                    //           await approveNegotiation(value.id);
                    //           // await _api
                    //           //     .approveApplication(_app.id)
                    //           //     .whenComplete(() {
                    //           //   _app.status = "approved";
                    //           //   if (mounted) setState(() {});
                    //           // });
                    //         },
                    //         backgroundColor: _colors.top,
                    //         foregroundColor: Colors.white,
                    //         icon: Icons.check,
                    //         label: 'Deal',
                    //       ),
                    //     ],
                    //   ),
                    //   child: ListTile(
                    //     title: Text(
                    //         isMe ? "Your Offer" : "Other User's Offer"),
                    //     trailing: value.employerApproved &&
                    //             value.jobseekerApproved
                    //         ? Image.asset(
                    //             "assets/icons/negotiation.png",
                    //             color: Colors.green,
                    //             width: 30,
                    //           )
                    //         : null,
                    //     subtitle: Row(
                    //       children: [
                    //         Expanded(
                    //           child: Row(
                    //             children: [
                    //               Text(
                    //                 "Price : ",
                    //                 style: TextStyle(
                    //                   fontSize: 12,
                    //                   color: Colors.grey.shade800,
                    //                 ),
                    //               ),
                    //               Image.asset(
                    //                 "assets/icons/peso.png",
                    //                 width: 20,
                    //               ),
                    //               Expanded(
                    //                   child: Text(
                    //                 value.price.toStringAsFixed(2),
                    //                 style: TextStyle(
                    //                   fontSize: 12,
                    //                   color: Colors.grey.shade800,
                    //                 ),
                    //               ))
                    //             ],
                    //           ),
                    //         ),
                    //         const SizedBox(
                    //           width: 10,
                    //         ),
                    //         Text(
                    //           DateFormat("MMM dd, yyyy hh:mm aa").format(
                    //             value.createdAt,
                    //           ),
                    //           style: TextStyle(
                    //             fontSize: 12,
                    //             color: Colors.grey.shade900,
                    //           ),
                    //         )
                    //       ],
                    //     ),
                    //   ),
                    // );
                    //   },
                    //   separatorBuilder: (_, i) => const SizedBox(
                    //     height: 10,
                    //   ),
                    // itemCount: deltPrice != null
                    //     ? _result
                    //         .where((element) => element.id != deltPrice!.id)
                    //         .toList()
                    //         .length
                    //     : _result.length,
                    // )
                  ],
                );
                // return Column(
                //   children: [
                // const Text("Counter Offers"),
                // if (deltPrice != null) ...{},
                //     // ListView.separated(
                //     //   shrinkWrap: true,
                //     //   physics: const NeverScrollableScrollPhysics(),
                //     //   itemBuilder: (_, i) {
                //     //     final NegotiationModel value = _result[i];
                //     //     final bool isMe = value.negotiatorId == loggedUser!.id;
                //     //     return ListTile(
                //     //       title:
                //     //           Text(isMe ? "Your Offer" : "Other User's Offer"),
                //     //       trailing:
                //     //           value.employerApproved && value.jobseekerApproved
                //     //               ? Image.asset(
                //     //                   "assets/icons/negotiation.png",
                //     //                   color: Colors.green,
                //     //                   width: 30,
                //     //                 )
                //     //               : null,
                //     //       subtitle: Row(
                //     //         children: [
                //     //           Expanded(
                //     //             child: Row(
                //     //               children: [
                //     //                 Text(
                //     //                   "Price : ",
                //     //                   style: TextStyle(
                //     //                     fontSize: 12,
                //     //                     color: Colors.grey.shade800,
                //     //                   ),
                //     //                 ),
                //     //                 Image.asset(
                //     //                   "assets/icons/peso.png",
                //     //                   width: 20,
                //     //                 ),
                //     //                 Expanded(
                //     //                     child: Text(
                //     //                   value.price.toStringAsFixed(2),
                //     //                   style: TextStyle(
                //     //                     fontSize: 12,
                //     //                     color: Colors.grey.shade800,
                //     //                   ),
                //     //                 ))
                //     //               ],
                //     //             ),
                //     //           ),
                //     //           const SizedBox(
                //     //             width: 10,
                //     //           ),
                //     //           Text(
                //     //             DateFormat("MMM dd, yyyy hh:mm aa").format(
                //     //               value.createdAt,
                //     //             ),
                //     //             style: TextStyle(
                //     //               fontSize: 12,
                //     //               color: Colors.grey.shade900,
                //     //             ),
                //     //           )
                //     //         ],
                //     //       ),
                //     //     );
                //     //   },
                //     //   separatorBuilder: (_, i) => const SizedBox(
                //     //     height: 10,
                //     //   ),
                //     //   itemCount: _result.length,
                //     // ),
                //   ],
                // );
              },
            )
          ],
        ),
      ),
    );
  }
}
