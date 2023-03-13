import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rxdart/rxdart.dart';
import 'package:terra/utils/color.dart';

class MapPointer extends StatefulWidget {
  const MapPointer({Key? key, required this.onCenterPoint}) : super(key: key);
  final ValueChanged<LatLng> onCenterPoint;
  @override
  State<MapPointer> createState() => _MapPointerState();
}

class _MapPointerState extends State<MapPointer> {
  late final BehaviorSubject<LatLng> _subject;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Position? currentPos;
  GoogleMapController? mapController;
  bool isChecking = true;
  init() async {
    await Geolocator.requestPermission().then((permission) async {
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        currentPos = await Geolocator.getCurrentPosition();
      } else {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: "Please enable location permission.");
      }
    });
    isChecking = false;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    _subject = BehaviorSubject<LatLng>()
      ..debounceTime(
        const Duration(
          milliseconds: 1000,
        ),
      ).listen((event) {
        widget.onCenterPoint(event);
      });
    init();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _subject.close();
    mapController?.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  final AppColors _colors = AppColors.instance;
  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: currentPos == null
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: _colors.bot,
                size: 30,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GoogleMap(
                      compassEnabled: true,
                      onMapCreated: onMapCreated,
                      mapType: MapType.hybrid,
                      indoorViewEnabled: true,
                      trafficEnabled: true,
                      onCameraMove: (pos) {
                        // currentPos = Position;
                        _subject.add(
                          LatLng(pos.target.latitude, pos.target.longitude),
                        );
                        // if (mounted) setState(() {});
                      },
                      initialCameraPosition: CameraPosition(
                        zoom: 19.151926040649414,
                        target: LatLng(
                          currentPos!.latitude,
                          currentPos!.longitude,
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 40,
                      color: Colors.red,
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    // final LatLngBounds visibleRegion = await controller.getVisibleRegion();
    setState(() {
      mapController = controller;
    });
  }
}
