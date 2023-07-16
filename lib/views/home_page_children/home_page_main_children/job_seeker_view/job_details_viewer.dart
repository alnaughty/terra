import 'package:flutter/cupertino.dart' as cup;
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/extension/int.dart';
import 'package:terra/extension/user.dart';
import 'package:terra/models/v2/task.dart';
import 'package:terra/services/API/job.dart';
import 'package:terra/services/firebase/chat_service.dart';
import 'package:terra/services/firebase/chatroom_services.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/home_page_children/application_and_recruitment/user_details.dart';
import 'package:terra/views/home_page_children/home_page_main_children/messaging/message_conversation_page.dart';
import 'package:terra/views/home_page_children/home_page_main_children/negotiation_page.dart';
import 'package:terra/views/home_page_children/map_page.dart';
import 'package:timeago/timeago.dart' as timeago;

class JobDetailsViewer extends StatefulWidget {
  const JobDetailsViewer({super.key, required this.task});
  final Task task;
  @override
  State<JobDetailsViewer> createState() => _JobDetailsViewerState();
}

class _JobDetailsViewerState extends State<JobDetailsViewer> {
  final AppColors _colors = AppColors.instance;
  final JobAPI _api = JobAPI.instance;
  late final TextEditingController _negotiate;
  final ChatService _chatService = ChatService.instance;
  bool _isLoading = false;
  void apply(double price) async {
    // widget.loadingCallback(true);
    setState(() {
      _isLoading = true;
    });
    await _api
        .apply(
      id: widget.task.id,
      rate: price,
    )
        .then((value) {
      widget.task.hasApplied = value;
      _isLoading = false;
      if (mounted) setState(() {});
      // widget.loadingCallback(false);
    });
  }

  void cancelApplication() async {
    // widget.loadingCallback(true);
    setState(() {
      _isLoading = true;
    });
    await _api
        .cancel(
      id: widget.task.id,
    )
        .then((value) {
      if (value) {
        widget.task.hasApplied = false;
      }
      _isLoading = false;
      if (mounted) setState(() {});
      // widget.loadingCallback(false);
    });
  }

  @override
  void initState() {
    _negotiate = TextEditingController();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _negotiate.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  late double negotiatedPrice = widget.task.rate ?? 0.0;
  bool isNegotiating = false;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Job Detail"),
              centerTitle: true,
              // actions: [
              //   IconButton(
              //       onPressed: () async {
              // await Navigator.push(
              //   context,
              //   PageTransition(
              //       child: MapPage(
              //           targetLocation: widget.task.coordinates),
              //       type: PageTransitionType.leftToRight),
              // );
              //       },
              //       icon: const Icon(cup.CupertinoIcons.location))
              // ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            gradient: LinearGradient(
                              colors: [_colors.top, _colors.bot],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.3),
                                offset: const Offset(3, 3),
                                blurRadius: 4,
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(5),
                          child: Image.network(
                            widget.task.category.icon,
                            height: 50,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.task.category.name,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.task.address,
                          style: TextStyle(
                            color: Colors.black.withOpacity(.5),
                            fontWeight: FontWeight.w300,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        if (widget.task.isNegotiable) ...{
                          Align(
                            alignment: AlignmentDirectional.center,
                            child: Text(
                              "To negotiate, you can edit the allocated prize by clicking on `Negotiable Price`.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black.withOpacity(.3),
                                fontSize: 12,
                                height: 1,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          )
                        },
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InputChip(
                              avatar: Image.asset(
                                "assets/icons/negotiation.png",
                                width: 20,
                                height: 20,
                                color: Colors.black54,
                              ),
                              // disabledColor: Colors.red,
                              surfaceTintColor: Colors.red,
                              selectedShadowColor: Colors.red,
                              disabledColor: Colors.transparent,
                              onPressed: () {},
                              label: Text(widget.task.isNegotiable
                                  ? "Negotiable Price"
                                  : "Fixed Price"),
                            ),
                            Chip(
                              avatar: Image.asset(
                                "assets/icons/urgency.png",
                                width: 20,
                                height: 20,
                                color: Colors.black54,
                              ),
                              label: Text(
                                (widget.task.urgency ?? 1)
                                    .toUrgency()
                                    .toUpperCase(),
                              ),
                            ),
                          ],
                        ),
                        // if (widget.task.isNegotiable) ...{
                        //   const SizedBox(
                        //     height: 10,
                        //   ),
                        //   AnimatedContainer(
                        //     duration: const Duration(milliseconds: 500),
                        //     height: isNegotiating ? 60 : 0,
                        //     child: Row(
                        //       children: [
                        //         Text(
                        //           "Your Price:",
                        //           style: TextStyle(
                        //             color: Colors.grey.shade700,
                        //             fontWeight: FontWeight.w400,
                        //           ),
                        //         ),
                        //         const SizedBox(
                        //           width: 30,
                        //         ),
                        //         if (isNegotiating) ...{
                        //           Expanded(
                        //             child: TextField(
                        //               controller: _negotiate,
                        //               keyboardType: TextInputType.number,
                        //               onSubmitted: (text) {
                        //                 negotiatedPrice = double.parse(text);
                        //                 if (mounted) setState(() {});
                        //               },
                        //             ),
                        //           )
                        //         },
                        //       ],
                        //     ),
                        //     // child: isNegotiating ? : Container(),
                        //   ),
                        // },
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
                                        targetLocation:
                                            widget.task.coordinates),
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
                        if (widget.task.isNegotiable) ...{
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
                              color: _colors.bot,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              // color: Colors.grey.shade200,
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  PageTransition(
                                      child: NegotiationPage(
                                        taskId: widget.task.id,
                                      ),
                                      type: PageTransitionType.leftToRight),
                                );
                              },
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/icons/negotiation.png",
                                    width: 20,
                                    height: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Start Negotiating",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        },
                        const SizedBox(
                          height: 20,
                        ),
                        if (widget.task.message != null) ...{
                          Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Job Description",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(widget.task.message!),
                                ],
                              )),
                          const SizedBox(
                            height: 20,
                          )
                        },
                        const Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            "Posted by",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ListTile(
                          onTap: loggedUser!.accountType != 1
                              ? () async {
                                  await Navigator.push(
                                    context,
                                    PageTransition(
                                      child: UserDetailsPage(
                                        user: widget.task.postedBy,
                                      ),
                                      type: PageTransitionType.leftToRight,
                                    ),
                                  );
                                }
                              : null,
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Container(
                              width: 40,
                              height: 40,
                              color: Colors.white,
                              child: Image.network(
                                widget.task.postedBy.avatar,
                                height: 40,
                                width: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          trailing: loggedUser!.accountType == 1
                              ? null
                              : widget.task.hasApplied
                                  ? IconButton(
                                      onPressed: () async {
                                        await _chatService.getOrCreateChatroom([
                                          widget.task.postedBy.toMember(),
                                          loggedUser!.toMember(),
                                        ]).then((val) async {
                                          await Navigator.push(
                                              context,
                                              PageTransition(
                                                  child:
                                                      MessageConversationPage(
                                                    chatroomId: val,
                                                    targetName: widget
                                                        .task.postedBy.fullname,
                                                    targetAvatar: widget
                                                        .task.postedBy.avatar,
                                                    targetId: widget.task
                                                        .postedBy.firebaseId,
                                                    targetServerId: widget
                                                        .task.postedBy.id
                                                        .toString(),
                                                  ),
                                                  type: PageTransitionType
                                                      .leftToRight));
                                        });
                                      },
                                      icon: Icon(
                                        cup.CupertinoIcons.bubble_left_fill,
                                        color: _colors.top,
                                      ),
                                    )
                                  : null,
                          title: Text(
                            "${widget.task.postedBy.firstname[0].toUpperCase()}${widget.task.postedBy.firstname.substring(1).toLowerCase()}${widget.task.postedBy.middlename != null ? " ${widget.task.postedBy.middlename![0].toUpperCase()}${widget.task.postedBy.middlename!.substring(1).toLowerCase()}" : ""} ${widget.task.postedBy.lastname[0].toUpperCase()}${widget.task.postedBy.lastname.substring(1).toLowerCase()}",
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.task.postedBy.toSecurityName,
                                style: TextStyle(
                                    color: Colors.black.withOpacity(.5)),
                              ),
                              Text(
                                timeago.format(
                                  widget.task.datePosted,
                                ),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black.withOpacity(.5)),
                              ),
                            ],
                          ),
                        ),
                        const Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            "Pricing",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Original Price",
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        "assets/icons/peso.png",
                                        width: 20,
                                        height: 20,
                                        color: Colors.black54,
                                      ),
                                      Text(
                                        (widget.task.rate ?? 0)
                                            .toStringAsFixed(2),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: _colors.bot,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (negotiatedPrice != widget.task.rate) ...{
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Negotiated price",
                                    ),
                                    cup.Row(
                                      children: [
                                        Image.asset(
                                          "assets/icons/peso.png",
                                          width: 20,
                                          height: 20,
                                          color: Colors.black54,
                                        ),
                                        Text(
                                          negotiatedPrice.toStringAsFixed(2),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: _colors.bot,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              }
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: MaterialButton(
                    onPressed: () async {
                      if (!widget.task.hasApplied) {
                        apply(negotiatedPrice);
                      } else {
                        cancelApplication();
                      }
                    },
                    height: 80,
                    color: widget.task.hasApplied ? _colors.bot : _colors.top,
                    child: Center(
                      child: Text(
                        widget.task.hasApplied
                            ? "Cancel ${loggedUser!.accountType == 1 ? "Application" : loggedUser!.accountType == 2 ? "Hiring" : widget.task.postedBy.accountType == 1 ? "Hiring" : "Application"}"
                            : "${loggedUser!.accountType == 1 ? "Apply" : loggedUser!.accountType == 2 ? "Hire" : widget.task.postedBy.accountType == 1 ? "Hire" : "Apply"} Now",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        if (_isLoading) ...{
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(.5),
              child: Center(
                child: Image.asset("assets/images/loader.gif"),
              ),
            ),
          ),
        },
      ],
    );
  }
}
