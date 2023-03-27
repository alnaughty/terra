import 'package:flutter/material.dart';
import 'package:terra/services/API/job.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/home_page_children/home_page_main_children/employer_view/job_posting.dart';

class EmployerHeader extends StatefulWidget {
  const EmployerHeader({super.key, required this.isLoading});
  final ValueChanged<bool> isLoading;
  @override
  State<EmployerHeader> createState() => _EmployerHeaderState();
}

class _EmployerHeaderState extends State<EmployerHeader> {
  final AppColors _colors = AppColors.instance;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final double w = c.maxWidth;
      return Container(
        width: w,
        height: 330,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _colors.bot,
              _colors.top,
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SafeArea(
              bottom: false,
              child: SizedBox(
                height: 10,
              ),
            ),
            Row(
              children: [
                IconButton(
                  tooltip: "Show all transactions",
                  onPressed: () async {
                    await Navigator.pushNamed(
                        context, "/transaction_history_page");
                  },
                  icon: const Icon(
                    Icons.list,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await Navigator.pushNamed(context, "/my_messages");
                      },
                      tooltip: "Messages",
                      icon: const Icon(
                        Icons.message,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      tooltip: "Browse",
                      icon: const Icon(
                        Icons.open_in_browser_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, ${loggedUser!.firstName}",
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          // const Spacer(),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "What services do\nyou need ?",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          // const Spacer(),
                          const SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await Navigator.pushNamed(
                                    context,
                                    "/browse_employees_page",
                                  );
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (_) => _colors.mid),
                                  foregroundColor:
                                      MaterialStateProperty.resolveWith(
                                          (_) => Colors.white),
                                  padding: MaterialStateProperty.resolveWith(
                                      (_) => const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          )),
                                ),
                                child: const Text("Quick hire"),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              MaterialButton(
                                onPressed: () async {
                                  await showGeneralDialog(
                                    context: context,
                                    barrierColor: Colors.black.withOpacity(.5),
                                    barrierDismissible: true,
                                    barrierLabel: "JOB POSTING",
                                    transitionBuilder: (_, a1, a2, w) =>
                                        Transform.scale(
                                      scale: a1.value,
                                      child: FadeTransition(
                                        opacity: a1,
                                        child: AlertDialog(
                                          title: const Text("Post a job"),
                                          content: JobPostingPage(
                                            scrollController:
                                                ScrollController(),
                                            loadingCallback: widget.isLoading,
                                            // onPost: () async {
                                            //   Navigator.of(context).pop(null);
                                            //   widget.isLoading(true);
                                            //   await Future.delayed(
                                            //       const Duration(
                                            //           milliseconds: 1500));
                                            //   widget.isLoading(false);
                                            //   // await _api
                                            //   //     .postAJob(
                                            //   //   title: title,
                                            //   //   completeAddress: completeAddress,
                                            //   //   brgy: brgy,
                                            //   //   city: city,
                                            //   //   landmark: landmark,
                                            //   //   urgency: urgency,
                                            //   //   rate: rate,
                                            //   //   latlong: latlong,
                                            //   //   categoryId: categoryId,
                                            //   // )
                                            //   //     .whenComplete(() {
                                            //   //   widget.isLoading(false);
                                            //   // });
                                            // },
                                          ),
                                        ),
                                      ),
                                    ),
                                    transitionDuration:
                                        const Duration(milliseconds: 500),
                                    pageBuilder: (_, a1, a2) => Container(),
                                  );
                                },
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 2,
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Text(
                                  "Post a job",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 50,
                    bottom: 0,
                    // left: 0,
                    child: Image.asset(
                      "assets/images/girl1.png",
                      height: 180,
                      fit: BoxFit.fitHeight,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
