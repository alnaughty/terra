import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/models/category.dart';
import 'package:terra/models/user_details.dart';
import 'package:terra/services/API/job.dart';
import 'package:terra/services/API/offers.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/view_model/categories_vm.dart';
import 'package:terra/views/home_page_children/home_page_main_children/employer_view/employee_card.dart';

class BrowseEmployeePage extends StatefulWidget {
  const BrowseEmployeePage({
    Key? key,
    this.initialCategoryId,
  }) : super(key: key);
  final int? initialCategoryId;
  @override
  State<BrowseEmployeePage> createState() => _BrowseEmployeePageState();
}

class _BrowseEmployeePageState extends State<BrowseEmployeePage> {
  late List<int> catIds = [];
  late List<int> _selectedCatIds = [
    if (widget.initialCategoryId != null) ...{
      widget.initialCategoryId!,
    }
  ];
  static final CategoriesVm _vm = CategoriesVm.instance;
  final AppColors _colors = AppColors.instance;
  fetch() async {
    setState(() => isFetching = true);
    await _api
        .fetchJobseekers(
            _selectedCatIds.isEmpty ? null : _selectedCatIds.join(','))
        .then((value) async {
      if (value != null) {
        _displayData = value;
        if (mounted) setState(() {});
        return;
      }
      Navigator.of(context).pop();
      await Fluttertoast.showToast(
        msg: "Internal server error,please contact developer",
      );
    }).whenComplete(() {
      isFetching = false;
      if (mounted) setState(() {});
    });
  }

  final JobAPI _api = JobAPI.instance;
  List<UserDetails> _displayData = [];
  bool isFetching = true;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetch();
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _k = GlobalKey<ScaffoldState>();
  final OfferApi _offerApi = OfferApi();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _k,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Quick hire"),
        elevation: 1,
        titleTextStyle: TextStyle(
          fontSize: 20,
          color: Colors.grey.shade900,
        ),
        actions: [
          if (_k.currentState != null) ...{
            IconButton(
              onPressed: () async {
                print(_selectedCatIds);
                print(catIds);
                setState(() {
                  catIds = List.from(_selectedCatIds);
                });
                _k.currentState!.openEndDrawer();
                // if (mounted) setState(() {});
              },
              icon: const Icon(
                Icons.filter_alt_outlined,
              ),
            ),
          },
        ],
      ),
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Drawer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/Logo.png",
                      fit: BoxFit.fitHeight,
                      color: Colors.black,
                      height: 50,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Image.asset(
                      "assets/images/Terra-name.png",
                      fit: BoxFit.fitHeight,
                      color: Colors.black,
                      height: 30,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Filter by:",
                style: TextStyle(
                  color: Colors.black.withOpacity(.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              StreamBuilder<List<Category>>(
                stream: _vm.stream,
                builder: (_, snapshot) {
                  if (snapshot.hasError || !snapshot.hasData) {
                    return Container();
                  }
                  final List<Category> _result = snapshot.data!;
                  return Wrap(
                    spacing: 10,
                    children: List.generate(_result.length, (index) {
                      final Category _cat = _result[index];
                      return ChoiceChip(
                        label: Text(
                          _cat.name,
                          style: TextStyle(
                            color: catIds.contains(_cat.id)
                                ? Colors.white
                                : Colors.black.withOpacity(.5),
                          ),
                        ),
                        onSelected: (t) {
                          if (!t) {
                            catIds.remove(_cat.id);
                          } else {
                            catIds.add(_cat.id);
                          }
                          if (mounted) setState(() {});
                        },
                        avatar: Image.network(_cat.icon),
                        selectedColor: _colors.bot,
                        selected: catIds.contains(_cat.id),
                      );
                    }),
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              MaterialButton(
                onPressed: () async {
                  setState(() {
                    _selectedCatIds = catIds;
                  });
                  if (_k.currentState!.isEndDrawerOpen) {
                    Navigator.of(context).pop(null);
                  }
                  await fetch();
                },
                height: 50,
                color: _colors.top,
                child: const Center(
                  child: Text(
                    "APPLY FILTER",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: isFetching
          ? Center(
              child: Image.asset("assets/images/loader.gif"),
            )
          : SafeArea(
              top: false,
              child: _displayData.isEmpty
                  ? const Center(
                      child: Text("No result found"),
                    )
                  : ListView.separated(
                      itemBuilder: (_, i) {
                        final UserDetails _u = _displayData[i];
                        return EmployeeCard(data: _u);
                      },
                      separatorBuilder: (_, i) => const SizedBox(
                        height: 10,
                      ),
                      itemCount: _displayData.length,
                    ),
            ),
    );
  }
}
