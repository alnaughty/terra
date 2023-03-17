import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terra/models/category.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_data_component/user_position.dart';
import 'package:terra/view_model/categories_vm.dart';
import 'package:terra/views/home_page_children/home_page_main_children/all_categories.dart';
import 'package:terra/views/home_page_children/home_page_main_children/employer_view/employer_view_main.dart';
import 'package:terra/views/home_page_children/home_page_main_children/job_seeker_view/job_seeker_main.dart';

class HomePageMain extends StatefulWidget {
  const HomePageMain({super.key, required this.onLoading});
  final ValueChanged<bool> onLoading;
  @override
  State<HomePageMain> createState() => _HomePageMainState();
}

class _HomePageMainState extends State<HomePageMain> {
  final AppColors _colors = AppColors.instance;
  final CategoriesVm _vm = CategoriesVm.instance;
  static final UserPosition _pos = UserPosition.instance;
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

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return LayoutBuilder(builder: (_, c) {
      final double w = c.maxWidth;
      final double h = c.maxHeight;
      return SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10),
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
                        child: Image.network(
                          loggedUser!.avatar,
                          height: 40,
                          width: 40,
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
                            Text(
                              "${loggedUser!.firstName[0].toUpperCase()}${loggedUser!.firstName.substring(1).toLowerCase()} ${loggedUser!.lastName[0].toUpperCase()}${loggedUser!.lastName.substring(1).toLowerCase()}",
                              style: const TextStyle(
                                fontSize: 25,
                                height: 1,
                                fontWeight: FontWeight.w600,
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
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icons/search.svg",
                          color: Colors.grey.shade800,
                          width: 20,
                          height: 20,
                        ),
                        // Icon(
                        //   Icons.search,
                        //   color: _colors.top,
                        //   size: 20,
                        // ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextField(
                            // expands: true,
                            maxLines: 1,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              alignLabelWithHint: true,
                              isDense: true,
                              hintText: "Search",
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                            ),
                            controller: _search,
                            selectionHeightStyle:
                                BoxHeightStyle.includeLineSpacingMiddle,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            StreamBuilder<List<Category>>(
              stream: _vm.stream,
              builder: (_, snapshot) {
                if (snapshot.hasError || !snapshot.hasData) {
                  return Container();
                }
                final List<Category> _categories = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        "Categories",
                        style: TextStyle(
                          color: Colors.grey.shade900,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      height: 200,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(left: 20),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, i) {
                          final Category _cat = _categories[i];
                          return SizedBox(
                            width: 160,
                            height: 200,
                            child: MaterialButton(
                              onPressed: () {},
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              color: Colors.grey.shade100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    _cat.icon,
                                    height: 120,
                                    fit: BoxFit.fitHeight,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    _cat.name,
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, i) => const SizedBox(
                          width: 15,
                        ),
                        itemCount: _categories.length,
                      ),
                    )
                  ],
                );
              },
            ),
            const SizedBox(
              height: 45,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  if (loggedUser!.accountType == 1 ||
                      loggedUser!.accountType != 2) ...{
                    // JOBSEEKER

                    Container(
                      height: 120,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          end: Alignment.bottomCenter,
                          begin: Alignment.topCenter,
                          colors: [_colors.top, _colors.bot],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  },
                  if (loggedUser!.accountType != 1 ||
                      loggedUser!.accountType == 2) ...{
                    // EMPLOYER OR BOTH
                    Container(
                      height: 120,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          end: Alignment.bottomCenter,
                          begin: Alignment.topCenter,
                          colors: [_colors.top, _colors.bot],
                        ),
                      ),
                      child: MaterialButton(
                        onPressed: () {},
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(10),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  }
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
