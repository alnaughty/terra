import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/views/home_page_children/home_page_main_children/map_pointer.dart';

class MapUpdate extends StatefulWidget {
  const MapUpdate({super.key, required this.onPosChanged});
  final ValueChanged<LatLng> onPosChanged;
  @override
  State<MapUpdate> createState() => _MapUpdateState();
}

class _MapUpdateState extends State<MapUpdate> {
  final AppColors _colors = AppColors.instance;
  LatLng? pos;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final double h = c.maxHeight;
      final double w = c.maxWidth;
      return SafeArea(
        top: false,
        child: Container(
          height: h,
          width: w,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: MapPointer(
                  onCenterPoint: (LatLng npos) {
                    setState(() {
                      pos = npos;
                    });
                    print("POSITION : $pos");
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              MaterialButton(
                onPressed: () {
                  if (pos != null) {
                    widget.onPosChanged(pos!);
                  }
                },
                color: _colors.top,
                height: 60,
                child: const Center(
                  child: Text(
                    "Update",
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
    });
  }
}
