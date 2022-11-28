import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terra/models/category.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/view_model/categories_vm.dart';
import 'package:terra/views/home_page_children/home_page_main_children/all_categories.dart';

class HomePageMain extends StatefulWidget {
  const HomePageMain({super.key});

  @override
  State<HomePageMain> createState() => _HomePageMainState();
}

class _HomePageMainState extends State<HomePageMain> {
  late final TextEditingController _search;
  final AppColors _colors = AppColors.instance;

  @override
  void initState() {
    _search = TextEditingController();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _search.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return LayoutBuilder(builder: (_, c) {
      final double w = c.maxWidth;
      final double h = c.maxHeight;
      return SingleChildScrollView(
        child: Column(
          children: [
            Container(
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
                children: [
                  const SafeArea(
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: "Show all tasks",
                        onPressed: () async {
                          await Navigator.pushNamed(context, "/my_task_page");
                        },
                        icon: const Icon(
                          Icons.list,
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search,
                                color: _colors.top,
                                size: 20,
                              ),
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
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              await Navigator.pushNamed(
                                  context, "/my_messages");
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
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              const Text(
                                "Hi, John Doe we're glad you are here!",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 30,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextButton(
                                  onPressed: () {},
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
                                  child: const Text("Recent Job Listing"))
                            ],
                          ),
                          Positioned(
                            right: 1,
                            bottom: 0,
                            // left: 0,
                            child: Image.asset(
                              "assets/images/Men.png",
                              height: 160,
                              fit: BoxFit.fitHeight,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
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
                  viewCategory(size.height),
                  const SizedBox(
                    height: 20,
                  ),
                  viewList(),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget viewList() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "View",
            style: TextStyle(
              color: Colors.grey.shade900,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          ...<Map<String, dynamic>>[
            {
              "name": "My applications",
              "icon": const Icon(
                Icons.receipt,
                color: Colors.white,
              ),
              "onTap": () async {
                await Navigator.pushNamed(context, "/my_application_page");
              },
            },
            {
              "name": "Task history",
              "icon": const Icon(
                Icons.task,
                color: Colors.white,
              ),
              "onTap": () async {
                await Navigator.pushNamed(context, "/task_history_page");
              },
            },
            {
              "name": "Messages",
              "icon": const Icon(
                Icons.message,
                color: Colors.white,
              ),
              "onTap": () async {
                await Navigator.pushNamed(context, "/my_messages");
              },
            },
          ].map(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: MaterialButton(
                height: 60,
                color: _colors.mid,
                onPressed: e['onTap'],
                child: Center(
                    child: ListTile(
                  title: Text(
                    e['name'],
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  trailing: e['icon'],
                )),
              ),
            ),
          )
        ],
      );

  final CategoriesVm _vm = CategoriesVm.instance;
  Widget viewCategory(double maxHeight) => StreamBuilder<List<Category>>(
        stream: _vm.stream,
        builder: (_, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return Container();
          }
          final List<Category> _result = snapshot.data!;
          return Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Category",
                    style: TextStyle(
                      color: Colors.grey.shade900,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    )),
                TextButton(
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.resolveWith(
                          (_) => Colors.grey.shade900),
                    ),
                    onPressed: () async {
                      await showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        builder: (_) => DraggableScrollableSheet(
                            maxChildSize: 1,
                            minChildSize: .45,
                            initialChildSize: .5,
                            builder: (_, scrollController) => AllCategories(
                                  scrollController: scrollController,
                                )),
                      );
                    },
                    child: const Text(
                      "View all",
                    )),
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ...(_result.length > 5 ? _result.sublist(0, 5) : _result)
                      .map((e) => Expanded(
                            child: Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: _colors.gradient,
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        e.icon,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "${e.name[0].toUpperCase()}${e.name.substring(1)}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                          )),
                ],
              )
            ],
          );
        },
      );
}
