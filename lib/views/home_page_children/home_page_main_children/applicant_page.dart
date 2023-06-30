import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:terra/extension/int.dart';
import 'package:terra/models/applicant.dart';
import 'package:terra/models/raw_application.dart';
import 'package:terra/services/API/application.dart';
import 'package:terra/utils/color.dart';

class ApplicantPage extends StatefulWidget {
  const ApplicantPage({Key? key}) : super(key: key);

  @override
  State<ApplicantPage> createState() => _ApplicantPageState();
}

class _ApplicantPageState extends State<ApplicantPage> {
  // final OfferApi _api = OfferApi();
  final ApplicationApi _api = ApplicationApi.instance;
  List<RawApplication>? _offer;
  init() async {
    await _api.fetchApplicationsByEmployer().then((val) {
      if (val != null) {
        _offer = val;
        if (mounted) setState(() {});
      } else {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: "Unable to fetch data");
      }
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await init();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  int? selectedOfferId;

  final AppColors _colors = AppColors.instance;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Applicants"),
              titleTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            body: _offer == null
                ? Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: _colors.bot,
                      size: 50,
                    ),
                  )
                : _offer!.isEmpty
                    ? const Center(
                        child: Text("No Applicants for you"),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        itemBuilder: (_, i) {
                          final RawApplication _u = _offer![i];
                          return Card(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: _u.user.avatar.isEmpty
                                        ? Image.asset(
                                            "assets/images/icon-logo.png",
                                          )
                                        : Image.network(_u.user.avatar),
                                  ),
                                  title: Text(
                                    _u.user.fullName,
                                  ),
                                  subtitle: Text(
                                    _u.user.email,
                                  ),
                                  trailing: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        if (selectedOfferId == _u.id) {
                                          selectedOfferId = null;
                                        } else {
                                          selectedOfferId = _u.id;
                                        }
                                      });
                                    },
                                    child: Text(selectedOfferId == _u.id
                                        ? "View less"
                                        : "View more"),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        height:
                                            selectedOfferId == _u.id ? 80 : 0,
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Date applied",
                                                    style: TextStyle(
                                                      color: _colors.bot,
                                                    ),
                                                  ),
                                                  Text(DateFormat(
                                                          "MMM. dd, yyyy")
                                                      .format(_u.createdAt))
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Rate",
                                                    style: TextStyle(
                                                      color: _colors.bot,
                                                    ),
                                                  ),
                                                  Text(
                                                    "₱${_u.rate.toStringAsFixed(2)}",
                                                  )
                                                ],
                                              ),
                                            ),
                                            // Expanded(
                                            //   child: Row(
                                            //     mainAxisAlignment:
                                            //         MainAxisAlignment
                                            //             .spaceBetween,
                                            //     children: [
                                            //       Text(
                                            //         "Duration",
                                            //         style: TextStyle(
                                            //           color: _colors.bot,
                                            //         ),
                                            //       ),
                                            //       Text(
                                            //         "${_u.duration} days",
                                            //       )
                                            //     ],
                                            //   ),
                                            // ),
                                            Expanded(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "Status",
                                                    style: TextStyle(
                                                      color: _colors.bot,
                                                    ),
                                                  ),
                                                  Text(
                                                    _u.status,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_u.status == "checking") ...{
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {},
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith(
                                                    (states) => Colors.red,
                                                  ),
                                                ),
                                                child: const Text("Decline"),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  // await
                                                  await _api
                                                      .approveApplication(_u.id)
                                                      .then((value) {
                                                    if (value) {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Application approved");
                                                      _u.status = "approved";
                                                    } else {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Failed to update status, please contact the developer");
                                                    }
                                                  }).whenComplete(() {
                                                    isLoading = false;
                                                    if (mounted)
                                                      setState(() {});
                                                  });
                                                },
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith(
                                                    (states) => _colors.top,
                                                  ),
                                                ),
                                                child: const Text("Approve"),
                                              ),
                                            ),
                                          ],
                                        ),
                                      } else if (_u.status == "confirmed") ...{
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Contact number",
                                              style: TextStyle(
                                                color: _colors.bot,
                                              ),
                                            ),
                                            Text(
                                              _u.user.phoneNumber,
                                            )
                                          ],
                                        ),
                                      },
                                      const SizedBox(
                                        height: 10,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (_, i) => Divider(
                          color: Colors.black.withOpacity(.3),
                        ),
                        itemCount: _offer!.length,
                      ),
          ),
        ),
        if (isLoading) ...{
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
