import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/models/application.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/views/home_page_children/map_page.dart';

class ApplicationCard extends StatefulWidget {
  const ApplicationCard({Key? key, required this.application})
      : super(key: key);
  final Application application;

  @override
  State<ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<ApplicationCard> {
  final AppColors _colors = AppColors.instance;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: widget.application.task.category == null
                  ? null
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [_colors.top, _colors.bot],
                          ),
                        ),
                        child: Image.network(
                            widget.application.task.category!.icon),
                      ),
                    ),
              title: widget.application.task.category == null
                  ? null
                  : Text(
                      widget.application.task.category!.name,
                    ),
              trailing: IconButton(
                onPressed: () async {
                  final List<double> _r = widget.application.task.latlong
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
                          name: widget.application.task.title,
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
              subtitle: Text(
                DateFormat("MMMM dd, yyyy").format(
                  widget.application.requestedOn,
                ),
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              widget.application.status,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.application.task.title,
            ),
            Text(
              widget.application.rate.toString(),
            ),
            Text(
              widget.application.toString(),
            ),
            // Align(
            //   alignment: Alignment.bottomRight,
            // child: Text(
            //   DateFormat("MMMM dd, yyyy").format(
            //     widget.application.requestedOn,
            //   ),
            //   style: TextStyle(
            //     color: Colors.grey.shade400,
            //     fontStyle: FontStyle.italic,
            //     fontSize: 12,
            //   ),
            // ),
            // )
          ],
        ),
      ),
    );
  }
}
