import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_data_component/user_position.dart';

class PopupLocationDisplay extends StatelessWidget {
  const PopupLocationDisplay({super.key});
  static final AppColors _colors = AppColors.instance;
  static final UserPosition _pos = UserPosition.instance;
  static final List<String> _contents = [
    "Tagging and sharing your location for more efficient service delivery",
    "Tracking clients and delivery personnel for more convenient and reliable transactions",
    "Implementing dynamic pricing models that adjust based on demand and distance for fairer and more accurate delivery costs",
  ];
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          // borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * .05,
              ),
              Image.asset(
                "assets/images/location-mockup.png",
                width: size.width * .7,
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                "How can we find you?",
                style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Enabling location services allows us to offer enhanced features, such as:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              // const Text(
              //   "Enabling location services allows us to offer enhanced features, such as:",
              //   textAlign: TextAlign.start,
              //   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              // ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, i) => Text(
                  _contents[i],
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w400),
                ),
                separatorBuilder: (_, i) => Divider(
                  color: Colors.black.withOpacity(.3),
                ),
                itemCount: _contents.length,
              ),
              // Text(
              //   loggedUser!.accountType == 1
              //       ? "We request your permission to access your location to track order delivery, and get nearby orders."
              //       : "We request your permission to access your location for order delivery purposes.",
              //   textAlign: TextAlign.center,
              // style:
              //     const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              // ),
              const SizedBox(
                height: 30,
              ),
              MaterialButton(
                color: _colors.top,
                onPressed: () async {
                  Navigator.of(context).pop();
                  // final LocationPermission permission =
                  //     await Geolocator.checkPermission();
                  // await Geolocator.requestPermission().then((permission) async {
                  //   if (permission == LocationPermission.always ||
                  //       permission == LocationPermission.whileInUse) {
                  //     final Position pos =
                  //         await Geolocator.getCurrentPosition();
                  //     _pos.populate(
                  //       LatLng(pos.latitude, pos.longitude),
                  //     );
                  //     // ignore: use_build_context_synchronously
                  //     Phoenix.rebirth(context);
                  //   }
                  // });
                },
                height: 55,
                child: const Center(
                  child: Text(
                    "I Understand",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // const SizedBox(
              //   height: 20,
              // ),
              // const Text(
              //   "You can change this option later in the settings of the app.",
              //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
