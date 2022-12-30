import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/models/job.dart';
import 'package:terra/services/API/job.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/views/home_page_children/home_page_main_children/job_seeker_view/job_details_viewer.dart';

class JobListingPage extends StatefulWidget {
  const JobListingPage({super.key});

  @override
  State<JobListingPage> createState() => _JobListingPageState();
}

class _JobListingPageState extends State<JobListingPage> {
  static final AppColors _colors = AppColors.instance;
  List<Job> _displayData = [];
  final JobAPI _api = JobAPI.instance;
  bool isFetching = true;

  fetch() async {
    setState(() => isFetching = true);
    await _api.fetchAvailable().then((value) async {
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

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: const Text("Job List"),
              elevation: 1,
              titleTextStyle: TextStyle(
                fontSize: 20,
                color: Colors.grey.shade900,
              ),
            ),
            body: isFetching
                ? Center(
                    child: Image.asset("assets/images/loader.gif"),
                  )
                : SafeArea(
                    child: ListView.separated(
                        padding: const EdgeInsets.only(top: 10),
                        itemBuilder: (_, i) => ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      colors: [_colors.top, _colors.bot],
                                    )),
                                child: Image.network(
                                    _displayData[i].category.icon),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _displayData[i].title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _colors.bot,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: _colors.top),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        child: Text(
                                          _displayData[i].status.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                      if (_displayData[i].hasApplied) ...{
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.orange,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          child: Text(
                                            "Applied".toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                            ),
                                          ),
                                        )
                                      }
                                    ],
                                  )
                                ],
                              ),
                              onTap: () async {
                                await showGeneralDialog(
                                  barrierColor: Colors.black.withOpacity(.5),
                                  barrierLabel: "",
                                  barrierDismissible: true,
                                  context: context,
                                  transitionDuration: const Duration(
                                    milliseconds: 500,
                                  ),
                                  transitionBuilder: ((context, animation,
                                          secondaryAnimation, __) =>
                                      ScaleTransition(
                                        scale: animation,
                                        child: Opacity(
                                          opacity: animation.value,
                                          child: Center(
                                              child: JobDetailsViewer(
                                            job: _displayData[i],
                                            loadingCallback:
                                                (final bool loading) {
                                              _isLoading = loading;
                                              if (mounted) setState(() {});
                                            },
                                          )),
                                        ),
                                      )),
                                  pageBuilder: (_, a1, a2) => Container(),
                                );
                              },
                              subtitle: Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: _colors.top,
                                    size: 18,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Text(
                                      _displayData[i].address,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(.4),
                                        decoration: TextDecoration.underline,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              // trailing: IconButton(
                              //     onPressed: () {},
                              //     tooltip: "Locate via google map",
                              // icon: Icon(
                              //   Icons.location_searching,
                              //   color: _colors.top,
                              // )),
                            ),
                        separatorBuilder: (_, i) => Divider(
                              color: Colors.black.withOpacity(.3),
                            ),
                        itemCount: _displayData.length),
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
        }
      ],
    );
  }
}
