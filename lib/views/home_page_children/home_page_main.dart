import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terra/models/category.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
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

  late Widget content = loggedUser!.accountType == 1
      // ignore: prefer_const_constructors
      ? JobSeekerHeader()
      : EmployerHeader(
          isLoading: widget.onLoading,
        );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
            content,
            // if (loggedUser!.accountType == 1) ...{
            //   const JobSeekerHeader(),
            // } else ...{
            //   EmployerHeader(
            //     isLoading: widget.onLoading,
            //   ),
            // },
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
                  viewCategory(c.maxHeight),
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
              "name": loggedUser!.accountType == 1
                  ? "My applications"
                  : "Applicants",
              "icon": const Icon(
                Icons.receipt,
                color: Colors.white,
              ),
              "onTap": () async {
                await Navigator.pushNamed(
                    context,
                    loggedUser!.accountType == 1
                        ? "/my_application_page"
                        : "/applicant_page");
              },
            },
            {
              "name": loggedUser!.accountType == 1
                  ? "Task history"
                  : "Transaction history",
              "icon": const Icon(
                Icons.task,
                color: Colors.white,
              ),
              "onTap": () async {
                await Navigator.pushNamed(
                    context,
                    loggedUser!.accountType == 1
                        ? "/task_history_page"
                        : "/transaction_history_page");
              },
            },
            if (loggedUser!.accountType == 1) ...{
              {
                "name": "Job Offers",
                "icon": const Icon(
                  Icons.task,
                  color: Colors.white,
                ),
                "onTap": () async {
                  await Navigator.pushNamed(context, "/job_offers_page");
                },
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
                            child: MaterialButton(
                              onPressed: () async {
                                await Navigator.pushNamed(
                                  context,
                                  loggedUser!.accountType == 1
                                      ? "/job_listing"
                                      : "/browse_employees_page",
                                  arguments: e.id,
                                );
                                // if (loggedUser!.accountType == 1) {

                                // } else {
                                //   await Navigator.pushNamed(
                                //     context,
                                //     "/browse_employees_page",
                                //     arguments: e.id,
                                //   );
                                // }
                              },
                              padding: const EdgeInsets.all(0),
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
                            ),
                          )),
                ],
              )
            ],
          );
        },
      );
}
