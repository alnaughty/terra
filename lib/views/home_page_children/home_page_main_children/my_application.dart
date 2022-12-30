import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/models/application.dart';
import 'package:terra/services/API/application.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/home_page_children/map_page.dart';

class MyApplicationPage extends StatefulWidget {
  const MyApplicationPage({super.key});

  @override
  State<MyApplicationPage> createState() => _MyApplicationPageState();
}

class _MyApplicationPageState extends State<MyApplicationPage> {
  bool isFetching = true;
  List<Application> _displayData = [];
  final AppColors _colors = AppColors.instance;
  static final ApplicationApi _api = ApplicationApi.instance;
  void init() async {
    await _api.fetchApplications().then((value) {
      if (value != null) {
        _displayData = value;
      } else {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: "Unable to retrieve data");
      }
    }).whenComplete(() {
      isFetching = false;
    });
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(vertical: 0),
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
            child: SafeArea(
              bottom: false,
              // child: Row(),
              child: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: AppBar(
                  iconTheme: const IconThemeData(
                    color: Colors.white,
                  ),
                  title: const Text(
                    "My Applications",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Container(
          //   width: double.maxFinite,
          //   padding: const EdgeInsets.symmetric(
          //     horizontal: 10,
          //   ),
          //   margin: const EdgeInsets.symmetric(vertical: 10),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         "Legend",
          //         style: TextStyle(
          //             color: Colors.grey.shade900,
          //             fontSize: 16,
          //             fontWeight: FontWeight.w600),
          //       ),
          //       const SizedBox(
          //         height: 5,
          //       ),
          //       Row(
          //         // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: legends
          //             .map((e) => Container(
          //                   margin: const EdgeInsets.only(right: 10),
          //                   child: Row(
          //                     children: [
          //                       Container(
          //                         width: 20,
          //                         height: 10,
          //                         decoration: BoxDecoration(
          //                             color: e['color'],
          //                             borderRadius: BorderRadius.circular(10)),
          //                       ),
          //                       const SizedBox(
          //                         width: 5,
          //                       ),
          //                       Text(
          //                         e['name'],
          //                         maxLines: 2,
          //                       )
          //                     ],
          //                   ),
          //                 ))
          //             .toList(),
          //       )
          //     ],
          //   ),
          // ),
          Expanded(
            child: SafeArea(
              top: false,
              child: isFetching
                  ? Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: _colors.bot,
                        size: 30,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(0),
                      itemBuilder: (_, i) => ListTile(
                        onTap: () {
                          print("SHOW TASK DETAILS");
                        },
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                        title: Text(
                          _displayData[i].task.title,
                        ),
                        subtitle: Text(
                          DateFormat("MMMM dd, yyyy").format(
                            _displayData[i].requestedOn,
                          ),
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            final List<double> _r = _displayData[i]
                                .task
                                .latlong
                                .trim()
                                .split(",")
                                .map((e) => double.parse(e))
                                .toList();
                            final LatLng latLong = LatLng(_r[0], _r[1]);
                            await Navigator.push(
                              context,
                              PageTransition(
                                  child: MapPage(
                                    targetLocation: latLong,
                                    name: _displayData[i].task.title,
                                  ),
                                  type: PageTransitionType.rightToLeft),
                            );
                          },
                          icon: const Icon(
                            Icons.location_on_rounded,
                            size: 25,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      separatorBuilder: (_, i) =>
                          const Divider(color: Colors.black45),
                      itemCount: _displayData.length,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
