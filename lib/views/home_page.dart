import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:terra/services/API/category_api.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/services/firebase_messaging.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
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
    with SingleTickerProviderStateMixin, UserApi, CategoryApi {
  late final TabController _tabController;
  late final List<Widget> _body = [
    const HomePageMain(),
    const WalletPage(),
    const NotificationPage(),
    const ActivityHistory(),
    ProfilePage(
      loadingCallback: (s) => setState(() => _isLoading = s),
    ),
  ];
  static final MyFCMService _fcm = MyFCMService.instance;
  int _currentIndex = 0;
  final AppColors _colors = AppColors.instance;
  final DataCacher _cacher = DataCacher.instance;

  init() async {
    await details().then((value) async {
      if (value != null) {
        loggedUser = value;
        print("USER : $value");
        await fetchAll();
        _fcm.init();
        if (mounted) setState(() {});
      } else {
        await _cacher.removeToken();
        // ignore: use_build_context_synchronously
        await Navigator.pushReplacementNamed(context, "/login_page");
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: _body.length, vsync: this);
    init();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    return Stack(
      children: [
        Positioned.fill(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: loggedUser == null
                ? Center(
                    child: Image.asset("assets/images/loader.gif"),
                  )
                : TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: _body,
                  ),
            bottomNavigationBar: loggedUser == null
                ? null
                : BottomNavigationBar(
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
          ),
        ),
        if (_isLoading) ...{
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(.5),
              child: Center(
                child: Image.asset("assets/images/loader.gif"),
              ),
            ),
          )
        },
      ],
    );
  }
}
