import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart' as cup;
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:rxdart/rxdart.dart';
import 'package:terra/models/v2/negotiation_model.dart';
import 'package:terra/services/API/v2/task_api.dart';
import 'package:terra/views/home_page_children/home_page_main_children/negotiation_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:terra/extension/user.dart';
import 'package:terra/models/v2/todo.dart';
import 'package:terra/services/firebase/chat_service.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/home_page_children/application_and_recruitment/user_details.dart';
import 'package:terra/views/home_page_children/home_page_main_children/messaging/message_conversation_page.dart';
import 'package:terra/views/home_page_children/map_page.dart';

class TodoTaskDetails extends StatefulWidget {
  const TodoTaskDetails({super.key, required this.task});

  final TodoTask task;
  static final AppColors _colors = AppColors.instance;
  static final ChatService _chatService = ChatService.instance;

  @override
  cup.State<TodoTaskDetails> createState() => _TodoTaskDetailsState();
}

class _TodoTaskDetailsState extends cup.State<TodoTaskDetails> {
  static final BehaviorSubject<List<NegotiationModel>> _subject =
      BehaviorSubject<List<NegotiationModel>>();
  static final TaskAPIV2 _api = TaskAPIV2.instance;
  Future<void> approveNegotiation(int id) async {
    // Navigator.of(context).pop(null);
    await _api.approveNegotiation(id);
    await getCounterOffers();
  }

  getCounterOffers() async {
    print(widget.task.task.id);
    await _api.getNegotiations(widget.task.task.id).then((value) {
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Details"),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          children: [
            const SizedBox(
              height: 20,
            ),
            Hero(
              tag: "cat-icon",
              child: CachedNetworkImage(
                imageUrl: widget.task.task.category.icon,
                height: 120,
                fit: BoxFit.fitHeight,
                placeholder: (_, ff) => Image.asset(
                  "assets/images/loader.gif",
                  height: 100,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (Rect bounds) => LinearGradient(colors: [
                    TodoTaskDetails._colors.top,
                    TodoTaskDetails._colors.bot
                  ]).createShader(bounds),
                  child: Text(
                    widget.task.task.category.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  widget.task.task.message ?? "",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black.withOpacity(.5),
                    fontWeight: FontWeight.w300,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  widget.task.task.address,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black.withOpacity(.5),
                      fontWeight: FontWeight.w300,
                      fontSize: 15,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.black.withOpacity(.5)),
                ),
                Text(
                  "You got this transaction ${timeago.format(
                    widget.task.createdAt,
                  )}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withOpacity(.3),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black),
                  ),
                  child: MaterialButton(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // color: Colors.grey.shade200,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        PageTransition(
                            child: MapPage(
                                targetLocation: widget.task.task.coordinates),
                            type: PageTransitionType.leftToRight),
                      );
                    },
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.location_on_rounded,
                        ),
                        SizedBox(width: 10),
                        Text("Show Location")
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "${(loggedUser!.accountType == 1 ? "Employer" : "Employee").toUpperCase()}:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ListTile(
              onTap: () async {
                await Navigator.push(
                  context,
                  PageTransition(
                    child: UserDetailsPage(
                      user: widget.task.user,
                    ),
                    type: PageTransitionType.leftToRight,
                  ),
                );
              },
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.white,
                  child: Image.network(
                    widget.task.user.avatar,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              trailing: IconButton(
                onPressed: () async {
                  await TodoTaskDetails._chatService.getOrCreateChatroom([
                    widget.task.user.toMember(),
                    loggedUser!.toMember(),
                  ]).then((val) async {
                    await Navigator.push(
                        context,
                        PageTransition(
                            child: MessageConversationPage(
                              chatroomId: val,
                              targetName: widget.task.user.fullname,
                              targetAvatar: widget.task.user.avatar,
                              targetId: widget.task.user.firebaseId,
                            ),
                            type: PageTransitionType.leftToRight));
                  });
                },
                icon: Icon(
                  cup.CupertinoIcons.bubble_left_fill,
                  color: TodoTaskDetails._colors.top,
                ),
              ),
              title: Text(
                "${widget.task.user.firstname[0].toUpperCase()}${widget.task.user.firstname.substring(1).toLowerCase()}${widget.task.user.middlename != null ? " ${widget.task.user.middlename![0].toUpperCase()}${widget.task.user.middlename!.substring(1).toLowerCase()}" : ""} ${widget.task.user.lastname[0].toUpperCase()}${widget.task.user.lastname.substring(1).toLowerCase()}",
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.user.toSecurityName,
                    style: TextStyle(color: Colors.black.withOpacity(.5)),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder(
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
                              color: TodoTaskDetails._colors.top,
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
                                    taskId: widget.task.id,
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
                              backgroundColor: TodoTaskDetails._colors.top,
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
              },
            )
          ],
        ),
      ),
    );
  }
}
// Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Counter Offers",
//                             style: TextStyle(
//                               fontSize: 15,
//                               color: _colors.top,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: () async {
//                             Navigator.of(context).pop(null);
//                             await Navigator.push(
//                               context,
//                               PageTransition(
//                                   child: NegotiationPage(
//                                     taskId: widget.data.task.id,
//                                   ),
//                                   type: PageTransitionType.leftToRight),
//                             );
//                           },
//                           child: const Text("View More"),
//                         )
//                       ],
//                     ),
//                     if (deltPrice != null) ...{},
//                     ...negos
//                         .sublist(0, negos.length > 5 ? 5 : negos.length)
//                         .map((value) {
//                       final bool isMe = value.negotiatorId == loggedUser!.id;
//                       return Slidable(
//                         key: Key(value.id.toString()),
//                         enabled: !isMe &&
//                             !(value.employerApproved &&
//                                 value.jobseekerApproved),
//                         endActionPane: ActionPane(
//                           motion: const ScrollMotion(),
//                           children: [
//                             SlidableAction(
//                               onPressed: (_) async {
//                                 await approveNegotiation(value.id);
//                                 // await _api
//                                 //     .approveApplication(_app.id)
//                                 //     .whenComplete(() {
//                                 //   _app.status = "approved";
//                                 //   if (mounted) setState(() {});
//                                 // });
//                               },
//                               backgroundColor: _colors.top,
//                               foregroundColor: Colors.white,
//                               icon: Icons.check,
//                               label: 'Deal',
//                             ),
//                           ],
//                         ),
//                         child: Container(
//                           color: Colors.white,
//                           child: ListTile(
//                             title: Text(
//                               isMe ? "Your Offer" : "Other User's Offer",
//                               style: const TextStyle(
//                                 fontSize: 13,
//                               ),
//                             ),
//                             trailing: value.employerApproved &&
//                                     value.jobseekerApproved
//                                 ? Image.asset(
//                                     "assets/icons/negotiation.png",
//                                     color: Colors.green,
//                                     width: 30,
//                                   )
//                                 : null,
//                             subtitle: Row(
//                               children: [
//                                 Expanded(
//                                   child: Row(
//                                     children: [
//                                       Text(
//                                         "Price : ",
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.grey.shade800,
//                                         ),
//                                       ),
//                                       Image.asset(
//                                         "assets/icons/peso.png",
//                                         width: 20,
//                                       ),
//                                       Expanded(
//                                           child: Text(
//                                         value.price.toStringAsFixed(2),
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.grey.shade800,
//                                         ),
//                                       ))
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   width: 10,
//                                 ),
//                                 Text(
//                                   DateFormat("MMM dd, yyyy hh:mm aa").format(
//                                     value.createdAt,
//                                   ),
//                                   style: TextStyle(
//                                     fontSize: 9,
//                                     color: Colors.grey.shade900,
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     })
//                     // ListView.separated(
//                     //   shrinkWrap: true,
//                     //   physics: const NeverScrollableScrollPhysics(),
//                     //   itemBuilder: (_, i) {
//                     //     final NegotiationModel value = _result[i];
//                     //     final bool isMe = value.negotiatorId == loggedUser!.id;
//                     // return Slidable(
//                     //   key: Key(value.id.toString()),
//                     //   enabled: (!value.employerApproved &&
//                     //           !value.jobseekerApproved) &&
//                     //       !isMe,
//                     //   endActionPane: ActionPane(
//                     //     motion: const ScrollMotion(),
//                     //     children: [
//                     //       SlidableAction(
//                     //         onPressed: (_) async {
//                     //           await approveNegotiation(value.id);
//                     //           // await _api
//                     //           //     .approveApplication(_app.id)
//                     //           //     .whenComplete(() {
//                     //           //   _app.status = "approved";
//                     //           //   if (mounted) setState(() {});
//                     //           // });
//                     //         },
//                     //         backgroundColor: _colors.top,
//                     //         foregroundColor: Colors.white,
//                     //         icon: Icons.check,
//                     //         label: 'Deal',
//                     //       ),
//                     //     ],
//                     //   ),
//                     //   child: ListTile(
//                     //     title: Text(
//                     //         isMe ? "Your Offer" : "Other User's Offer"),
//                     //     trailing: value.employerApproved &&
//                     //             value.jobseekerApproved
//                     //         ? Image.asset(
//                     //             "assets/icons/negotiation.png",
//                     //             color: Colors.green,
//                     //             width: 30,
//                     //           )
//                     //         : null,
//                     //     subtitle: Row(
//                     //       children: [
//                     //         Expanded(
//                     //           child: Row(
//                     //             children: [
//                     //               Text(
//                     //                 "Price : ",
//                     //                 style: TextStyle(
//                     //                   fontSize: 12,
//                     //                   color: Colors.grey.shade800,
//                     //                 ),
//                     //               ),
//                     //               Image.asset(
//                     //                 "assets/icons/peso.png",
//                     //                 width: 20,
//                     //               ),
//                     //               Expanded(
//                     //                   child: Text(
//                     //                 value.price.toStringAsFixed(2),
//                     //                 style: TextStyle(
//                     //                   fontSize: 12,
//                     //                   color: Colors.grey.shade800,
//                     //                 ),
//                     //               ))
//                     //             ],
//                     //           ),
//                     //         ),
//                     //         const SizedBox(
//                     //           width: 10,
//                     //         ),
//                     //         Text(
//                     //           DateFormat("MMM dd, yyyy hh:mm aa").format(
//                     //             value.createdAt,
//                     //           ),
//                     //           style: TextStyle(
//                     //             fontSize: 12,
//                     //             color: Colors.grey.shade900,
//                     //           ),
//                     //         )
//                     //       ],
//                     //     ),
//                     //   ),
//                     // );
//                     //   },
//                     //   separatorBuilder: (_, i) => const SizedBox(
//                     //     height: 10,
//                     //   ),
//                     // itemCount: deltPrice != null
//                     //     ? _result
//                     //         .where((element) => element.id != deltPrice!.id)
//                     //         .toList()
//                     //         .length
//                     //     : _result.length,
//                     // )
//                   ],
//                 )