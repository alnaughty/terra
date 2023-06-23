import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:rxdart/rxdart.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/v2/negotiation_model.dart';
import 'package:terra/services/API/v2/task_api.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';

class NegotiationPage extends StatefulWidget {
  const NegotiationPage({super.key, required this.taskId});
  final int taskId;

  @override
  State<NegotiationPage> createState() => _NegotiationPageState();
}

class _NegotiationPageState extends State<NegotiationPage> {
  final BehaviorSubject<List<NegotiationModel>> _subject =
      BehaviorSubject<List<NegotiationModel>>();
  final TaskAPIV2 _api = TaskAPIV2.instance;
  final AppColors _colors = AppColors.instance;
  Future<void> fetch() async {
    await _api.getNegotiations(widget.taskId).then((value) {
      _subject.add(value);
    });
  }

  Future<void> approveNegotiation(int id) async {
    setState(() {
      _isLoading = true;
    });

    await _api.approveNegotiation(id);
    _isLoading = false;
    if (mounted) setState(() {});
  }

  // Future<>
  @override
  void initState() {
    fetch();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Negotiation Page"),
              centerTitle: true,
            ),
            body: StreamBuilder<List<NegotiationModel>>(
              stream: _subject.stream,
              builder: (_, snapshot) {
                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: Image.asset("assets/images/loader.gif"),
                  );
                }
                final List<NegotiationModel> data = snapshot.data!;
                if (data.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "No Negotiations found",
                        style: TextStyle(
                          color: Colors.black.withOpacity(.6),
                        ),
                      ),
                    ),
                  );
                }
                data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                return Column(
                  children: [
                    Container(
                      width: double.maxFinite,
                      color: Colors.grey.shade100,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      child: const Text(
                        "NOTE: Slide left to accept the negotiation (You can only do the action if its not your offer).",
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: LiquidPullToRefresh(
                        onRefresh: () async {
                          final Completer<void> completer = Completer<void>();
                          await fetch().whenComplete(() {
                            completer.complete();
                          });
                          return completer.future;
                        },
                        child: ListView.separated(
                          itemBuilder: (_, i) {
                            final NegotiationModel value = data[i];
                            final bool isMe =
                                value.negotiatorId == loggedUser!.id;
                            return Slidable(
                              key: Key(value.id.toString()),
                              enabled: !isMe &&
                                  !(value.employerApproved &&
                                      value.jobseekerApproved),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) async {
                                      await approveNegotiation(value.id)
                                          .whenComplete(() async {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        await fetch().whenComplete(() {
                                          _isLoading = false;
                                          if (mounted) setState(() {});
                                        });
                                      });
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
                              child: ListTile(
                                title: Text(
                                    isMe ? "Your Offer" : "Other User's Offer"),
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
                                      DateFormat("MMM dd, yyyy hh:mm aa")
                                          .format(
                                        value.createdAt,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade900,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (_, i) => const SizedBox(
                            height: 10,
                          ),
                          itemCount: data.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: _colors.top,
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  barrierColor: Colors.black.withOpacity(.5),
                  isDismissible: true,
                  isScrollControlled: true,
                  // constraints: const BoxConstraints(
                  //   maxHeight: 300,
                  // ),
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20))),
                  builder: (context) => SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: NegotiationSheet(
                        priceCallback: (String price) async {
                          print("PRICE : $price");
                          setState(() {
                            _isLoading = true;
                          });
                          await _api
                              .negotiate(price, widget.taskId)
                              .then((value) async {
                            if (value) {
                              await fetch();
                            }
                          }).whenComplete(() {
                            _isLoading = false;
                            if (mounted) setState(() {});
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
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
          )
        },
      ],
    );
  }
}

class NegotiationSheet extends StatefulWidget {
  const NegotiationSheet({super.key, required this.priceCallback});
  final ValueChanged<String> priceCallback;

  @override
  State<NegotiationSheet> createState() => _NegotiationSheetState();
}

class _NegotiationSheetState extends State<NegotiationSheet> {
  final AppColors _colors = AppColors.instance;
  late final TextEditingController _price;

  @override
  void initState() {
    _price = TextEditingController();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _price.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  final GlobalKey<FormState> _k = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Form(
        key: _k,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Negotiate Your Price",
              style: TextStyle(
                color: Colors.black.withOpacity(1),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _price,
              validator: (text) {
                if (text == null) {
                  return "Something went wrong";
                } else if (text.isEmpty) {
                  return "You need to provide an amount";
                } else if (!text.isValidInt()) {
                  return "Invalid format";
                }
              },
              onChanged: (text) {
                _k.currentState!.validate();
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  hintText: "Enter any price you want",
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(.5),
                  )),
            ),
            const SizedBox(
              height: 30,
            ),
            MaterialButton(
              height: 60,
              color: _colors.top,
              onPressed: () {
                if (_k.currentState!.validate()) {
                  Navigator.of(context).pop(null);
                  widget.priceCallback(_price.text);
                }
              },
              child: const Center(
                child: Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
