import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/views/home_page_children/activity_history.dart';
import 'package:terra/views/home_page_children/home_page_main.dart';
import 'package:terra/views/home_page_children/notification_page.dart';
import 'package:terra/views/home_page_children/profile_page.dart';
import 'package:terra/views/home_page_children/wallet_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<Widget> _body = [
    const HomePageMain(),
    const WalletPage(),
    const NotificationPage(),
    const ActivityHistory(),
    const ProfilePage(),
  ];
  int _currentIndex = 0;
  final AppColors _colors = AppColors.instance;
  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: _body.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return Scaffold(
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: _body,
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          unselectedItemColor: Colors.black38,
          selectedItemColor: _colors.top,
          onTap: (i) async {
            setState(() => _currentIndex = i);
            _tabController.animateTo(i);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_filled,
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.wallet,
              ),
              label: "Wallet",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications,
              ),
              label: "Notifications",
            ),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.history,
                ),
                label: "Activity History"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                ),
                label: "Profile"),
          ]),
    );
  }
}
