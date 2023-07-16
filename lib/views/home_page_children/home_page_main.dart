import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:terra/services/API/application.dart';
import 'package:terra/services/API/category_api.dart';
import 'package:terra/services/landing_processes.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_data_component/user_position.dart';
import 'package:terra/view_model/applications.dart';
import 'package:terra/views/home_page_children/category_listview_horizontal.dart';
import 'package:terra/views/home_page_children/home_page_main_children/employer_view/employer_view_main.dart';
import 'package:terra/views/home_page_children/home_page_main_children/employer_view/job_posting.dart';
import 'package:terra/views/home_page_children/home_page_main_children/job_seeker_view/job_seeker_main.dart';
import 'package:terra/views/home_page_children/home_page_main_children/search_field.dart';
import 'package:terra/views/home_page_children/home_page_main_children/suggested_page.dart';

class HomePageMain extends StatefulWidget {
  const HomePageMain({super.key, required this.onLoading});
  final ValueChanged<bool> onLoading;
  @override
  State<HomePageMain> createState() => _HomePageMainState();
}

class _HomePageMainState extends State<HomePageMain> with CategoryApi {
  final AppColors _colors = AppColors.instance;
  static final UserPosition _pos = UserPosition.instance;
  static final ApplicationApi _appApi = ApplicationApi.instance;
  static final ApplicationsVm _applicationVM = ApplicationsVm.instance;
  late Widget content = loggedUser!.accountType == 1
      // ignore: prefer_const_constructors
      ? JobSeekerHeader()
      : EmployerHeader(
          isLoading: widget.onLoading,
        );
  late final TextEditingController _search;
  @override
  void initState() {
    _search = TextEditingController();
    super.initState();
  }

  static final LandingProcesses _process = LandingProcesses.instance;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> refetch() async {
    await fetchAll();
    await _appApi
        .fetchUserApplication()
        .then((value) => _applicationVM.populate(value));
    await _process.loadProcesses();
    return;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return LayoutBuilder(builder: (_, c) {
      final double w = c.maxWidth;
      final double h = c.maxHeight;
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: LiquidPullToRefresh(
            onRefresh: () async {
              final Completer<void> completer = Completer<void>();
              await refetch().whenComplete(() {
                completer.complete();
              });

              return completer.future;
            },
            child: ListView(
              // padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: loggedUser!.avatar.isEmpty
                                ? Image.asset(
                                    "assets/images/icon-logo.png",
                                    width: 40,
                                    height: 40,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: loggedUser!.avatar,
                                    height: 40,
                                    width: 40,
                                    placeholder: (_, s) => Image.asset(
                                      "assets/images/loader.gif",
                                      width: 40,
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
                                Text(
                                  "Hello,",
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                ShaderMask(
                                  shaderCallback: (Rect rect) => LinearGradient(
                                          colors: [_colors.top, _colors.bot])
                                      .createShader(rect),
                                  child: Text(
                                    "${loggedUser!.firstName[0].toUpperCase()}${loggedUser!.firstName.substring(1).toLowerCase()} ${loggedUser!.lastName[0].toUpperCase()}${loggedUser!.lastName.substring(1).toLowerCase()}",
                                    style: const TextStyle(
                                      fontSize: 25,
                                      height: 1,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      StreamBuilder<LatLng>(
                        stream: _pos.stream,
                        builder: (_, snapshot) {
                          if (snapshot.hasError || !snapshot.hasData) {
                            return Container();
                          }
                          final LatLng pos = snapshot.data!;
                          return Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/marker.svg",
                                width: 15,
                                height: 15,
                                color: _colors.top,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: FutureBuilder<Placemark?>(
                                  future: _pos.translateCoordinate(),
                                  builder: (_, future) {
                                    if (future.hasError || !future.hasData) {
                                      return Container();
                                    }
                                    final Placemark placemark = future.data!;
                                    return Text(
                                      "${placemark.street ?? ""} ${placemark.locality ?? ""} ${placemark.country}",
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        color: Colors.grey.shade600,
                                      ),
                                    );
                                  },
                                ),
                              )
                              // Expanded(child: cc)
                            ],
                          );
                        },
                      ),
                      // const SizedBox(
                      //   height: 40,
                      // ),
                      // SearchField(
                      //   controller: _search,
                      //   onFinished: (String text) async {
                      //     await Navigator.pushNamed(
                      //       context,
                      //       "/job_listing",
                      //       arguments: [null, text],
                      //     );
                      //   },
                      // )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const CategoryListviewHorizontal(),
                const SizedBox(
                  height: 45,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      if (loggedUser!.accountType == 1 ||
                          loggedUser!.accountType != 2) ...{
                        // JOBSEEKER OR BOTH
                        Container(
                          height: 130,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              end: Alignment.bottomCenter,
                              begin: Alignment.topCenter,
                              colors: [_colors.top, _colors.bot],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: MaterialButton(
                                  onPressed: () async {
                                    await Navigator.pushNamed(
                                        context, "/job_listing",
                                        arguments: [null, null]);
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        "assets/images/Logo.png",
                                        width: size.width * .25,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Browse jobs".toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                "Say goodbye to job search stress, Terra will help you!",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(.7),
                                                  fontSize: 13,
                                                  height: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 130,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              end: Alignment.bottomCenter,
                              begin: Alignment.topCenter,
                              colors: [_colors.top, _colors.bot],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: MaterialButton(
                                  onPressed: () async {
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      barrierColor: Colors.black45,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => SafeArea(
                                        top: false,
                                        child: DraggableScrollableSheet(
                                          maxChildSize: 1,
                                          minChildSize: .5,
                                          initialChildSize: 1,
                                          snap: true,
                                          snapAnimationDuration:
                                              const Duration(milliseconds: 500),
                                          builder: (_, scroll) =>
                                              JobPostingPage(
                                            scrollController: scroll,
                                            loadingCallback: (bool f) {
                                              widget.onLoading(f);
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Post a skill".toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                "Let your skills shine and be discovered",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(.7),
                                                  fontSize: 13,
                                                  height: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Image.asset(
                                        "assets/images/Logo.png",
                                        width: size.width * .25,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // ignore: equal_elements_in_set
                        const SizedBox(
                          height: 10,
                        ),
                      },
                      if (loggedUser!.accountType != 1 ||
                          loggedUser!.accountType == 2) ...{
                        // EMPLOYER OR BOTH
                        Container(
                          height: 130,
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              end: Alignment.bottomCenter,
                              begin: Alignment.topCenter,
                              colors: [_colors.top, _colors.bot],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: MaterialButton(
                                  onPressed: () async {
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      barrierColor: Colors.black45,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => SafeArea(
                                        top: false,
                                        child: DraggableScrollableSheet(
                                          maxChildSize: 1,
                                          minChildSize: .5,
                                          initialChildSize: 1,
                                          snap: true,
                                          snapAnimationDuration:
                                              const Duration(milliseconds: 500),
                                          builder: (_, scroll) =>
                                              JobPostingPage(
                                            scrollController: scroll,
                                            loadingCallback: (bool f) {
                                              widget.onLoading(f);
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Post a job".toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                "Find Your Perfect Candidate - Let Us Help You",
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(.7),
                                                  fontSize: 13,
                                                  height: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Image.asset(
                                        "assets/images/Logo.png",
                                        width: size.width * .25,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      }
                    ],
                  ),
                ),
                const SuggestedPostPage(),
              ],
            ),
          ),
        ),
      );
    });
  }
}
