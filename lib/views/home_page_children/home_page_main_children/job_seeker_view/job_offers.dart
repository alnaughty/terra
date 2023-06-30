import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:terra/extension/int.dart';
import 'package:terra/models/job_offer.dart';
import 'package:terra/services/API/offers.dart';
import 'package:terra/services/url_launcher.dart';
import 'package:terra/utils/color.dart';

class JobOffers extends StatefulWidget {
  const JobOffers({super.key});

  @override
  State<JobOffers> createState() => _JobOffersState();
}

class _JobOffersState extends State<JobOffers> {
  final OfferApi _api = OfferApi();
  final Launcher _launcher = Launcher();
  List<JobOffer> _displayData = [];
  bool isFetching = true;
  bool isLoading = false;
  final AppColors _colors = AppColors.instance;
  fetch() async {
    setState(() => isFetching = true);
    await _api.getJobOffers().then((value) async {
      if (value != null) {
        _displayData = value;
        if (mounted) setState(() {});
        return;
      }
      Navigator.of(context).pop();
      await Fluttertoast.showToast(
        msg: "Internal server error,please contact developer",
      );
    }).whenComplete(() {
      isFetching = false;
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetch();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  updateStatus(
    JobOffer job,
    int status,
  ) async {
    setState(() {
      isLoading = true;
    });
    // // await
    await _api.updateOfferStatus(job.id, status: status).then((value) {
      if (value) {
        Fluttertoast.showToast(msg: "Application approved");
        job.status = status;
      } else {
        Fluttertoast.showToast(
            msg: "Failed to update status, please contact the developer");
      }
    }).whenComplete(() {
      isLoading = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Scaffold(
              appBar: AppBar(
                title: const Text("Job offers"),
                titleTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              body: SafeArea(
                top: false,
                child: isFetching
                    ? Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: _colors.bot,
                          size: 30,
                        ),
                      )
                    : _displayData.isNotEmpty
                        ? ListView.separated(
                            itemBuilder: (_, i) {
                              final JobOffer job = _displayData[i];
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Colors.white,
                                            child: job.recruiter.avatar.isEmpty
                                                ? Image.asset(
                                                    "assets/images/icon-logo.png",
                                                    width: 50,
                                                    height: 50,
                                                  )
                                                : Image.network(
                                                    job.recruiter.avatar,
                                                    height: 50,
                                                    width: 50,
                                                  ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  job.recruiter.fullName,
                                                  style: TextStyle(
                                                    color: _colors.top,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  "wants to offer you a job!",
                                                  style: TextStyle(
                                                    color: Colors.black
                                                        .withOpacity(.5),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                                color: _colors.bot,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Text(
                                              job.status
                                                  .applicationStatusFormat(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text.rich(
                                                  TextSpan(
                                                    text: "Looking for",
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            " ${job.category.name}!",
                                                        style: TextStyle(
                                                          color: _colors.top,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                if (job.message != null &&
                                                    job.message!
                                                        .isNotEmpty) ...{
                                                  Text(
                                                    job.message!,
                                                    style: TextStyle(
                                                      color: Colors.black
                                                          .withOpacity(.5),
                                                    ),
                                                  )
                                                },
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              gradient: LinearGradient(
                                                colors: [
                                                  _colors.top,
                                                  _colors.bot,
                                                ],
                                              ),
                                            ),
                                            child: Image.network(
                                              job.category.icon,
                                              height: 25,
                                            ),
                                          )
                                        ],
                                      ),
                                      if (job.status == 0) ...{
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  await updateStatus(job, 3);
                                                },
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
                                                  await updateStatus(job, 1);
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
                                      } else if (job.status == 1 ||
                                          job.status == 2) ...{
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Recruiter contact:",
                                          style: TextStyle(
                                            color: _colors.top,
                                            fontSize: 17,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.phone),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                print("OPEN NUBMER");
                                                await _launcher.makePhoneCall(
                                                  job.recruiter.phoneNumber,
                                                );
                                              },
                                              child: Text(
                                                job.recruiter.phoneNumber,
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color: _colors.bot,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.email),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                print("OPEN EMAIL");
                                                await _launcher.sendEmail(
                                                  job.recruiter.email,
                                                );
                                              },
                                              child: Text(
                                                job.recruiter.email,
                                                style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color: _colors.bot,
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      },
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, i) => Divider(
                                  color: Colors.black.withOpacity(.4),
                                ),
                            itemCount: _displayData.length)
                        : const Center(
                            child: Text("You have no job offers"),
                          ),
              )),
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
        }
      ],
    );
  }
}
