import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terra/utils/color.dart';

class MyTasks extends StatefulWidget {
  const MyTasks({super.key});

  @override
  State<MyTasks> createState() => _MyTasksState();
}

class _MyTasksState extends State<MyTasks> with SingleTickerProviderStateMixin {
  final AppColors _colors = AppColors.instance;
  late final TabController _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
            child: Column(
              children: [
                SafeArea(
                  bottom: false,
                  // child: Row(),
                  child: PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: AppBar(
                      iconTheme: const IconThemeData(
                        color: Colors.white,
                      ),
                      title: const Text(
                        "My Tasks",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      // bottomOpacity: 1,
                      // bottom: PreferredSize(
                      //   preferredSize: Size.fromHeight(40),
                      //   child:
                      // ),
                    ),
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  unselectedLabelColor: Colors.white.withOpacity(.5),
                  indicatorColor: Colors.white,
                  indicatorWeight: 5,
                  labelColor: Colors.white,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: ['Pending', 'On-going', 'Completed']
                      .map(
                        (e) => Tab(
                          text: e,
                        ),
                      )
                      .toList(),
                ),
                // const SizedBox(
                //   height: 10,
                // ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text("NO PENDING TASKS"),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text("NO ON-GOING TASKS"),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: Text("NO COMPLETED TASKS"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
