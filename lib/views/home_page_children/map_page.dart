import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:terra/utils/color.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.targetLocation, this.name});
  final LatLng targetLocation;
  final String? name;
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late final Position currentPos;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  GoogleMapController? mapController;
  final AppColors _colors = AppColors.instance;
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
    init();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    mapController?.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isChecking
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                  color: _colors.bot, size: 50),
            )
          : SafeArea(
              top: false,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: GoogleMap(
                      compassEnabled: true,
                      onMapCreated: onMapCreated,
                      mapType: MapType.hybrid,
                      indoorViewEnabled: true,
                      trafficEnabled: true,
                      markers: <Marker>{
                        Marker(
                          markerId: const MarkerId("my-position"),
                          infoWindow: const InfoWindow(title: "I am here"),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueAzure,
                          ),
                          position: LatLng(
                            currentPos.latitude,
                            currentPos.longitude,
                          ),
                        ),
                        Marker(
                          markerId: const MarkerId("target"),
                          infoWindow: InfoWindow(
                              title: widget.name ?? "Target location"),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueViolet,
                          ),
                          position: widget.targetLocation,
                        ),
                      },
                      initialCameraPosition: CameraPosition(
                        zoom: 19.151926040649414,
                        target: LatLng(
                          currentPos.latitude,
                          currentPos.longitude,
                        ),
                      ),
                    ),
                  ),
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
