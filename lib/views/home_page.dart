import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terra/models/chat/chat_room.dart';
import 'package:terra/services/API/category_api.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/services/firebase/chat_service.dart';
import 'package:terra/services/firebase/chatroom_services.dart';
import 'package:terra/services/firebase_messaging.dart';
import 'package:terra/services/landing_processes.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_data_component/user_position.dart';
import 'package:terra/view_model/chat_rooms_vm.dart';
import 'package:terra/views/home_page_children/activity_history.dart';
import 'package:terra/views/home_page_children/chats/chat_rooms.dart';
import 'package:terra/views/home_page_children/home_page_main.dart';
import 'package:terra/views/home_page_children/notification_page.dart';
import 'package:terra/views/home_page_children/profile_page.dart';
import 'package:terra/views/home_page_children/wallet_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, UserApi, CategoryApi {
  static final LandingProcesses _process = LandingProcesses.instance;
  static final ChatService chatRoomService = ChatService.instance;
  static final UserPosition _pos = UserPosition.instance;
  final List<String> icons = ["home", "chats", "jobs", "profile"];
  late final TabController _tabController;
  late final List<Widget> _body = [
    HomePageMain(
      onLoading: (s) => setState(() => _isLoading = s),
    ),
    const ChatRoomsPage(),
    const ActivityHistory(),
    ProfilePage(
      loadingCallback: (s) => setState(() => _isLoading = s),
    ),
  ];
  static final MyFCMService _fcm = MyFCMService.instance;
  int _currentIndex = 0;
  final AppColors _colors = AppColors.instance;

  final DataCacher _cacher = DataCacher.instance;
  Future<void> initLocation() async {
    await Geolocator.requestPermission().then((permission) async {
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Geolocator.getPositionStream().listen((Position pos) {
          _pos.populate(
            LatLng(pos.latitude, pos.longitude),
          );
        });
      } else {
        Navigator.of(context).pop();
        Fluttertoast.showToast(msg: "Please enable location permission.");
      }
    });
    if (mounted) setState(() {});
  }

  Future<void> init() async {
    await details().then((value) async {
      if (value != null) {
        loggedUser = value;
        if (mounted) setState(() {});
        print("USER : $value");
        await fetchAll();
        _fcm.init();
        await listenMessages();
        if (mounted) setState(() {});
      } else {
        await _cacher.removeToken();
        // ignore: use_build_context_synchronously
        await Navigator.pushReplacementNamed(context, "/login_page");
      }
    });
    await _process.loadProcesses();
  }

  static final ChatRoomsVm _vm = ChatRoomsVm.instance;
  Future<void> listenMessages() async {
    chatRoomService.getUserChatrooms().listen((List<ChatRoom> rooms) {
      print(rooms.length);
      _vm.populate(rooms);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: _body.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        init(),
        initLocation(),
      ]);
    });
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
            resizeToAvoidBottomInset: true,
            // appBar: _tabController.index == 0
            //     ? AppBar(
            //         backgroundColor: Colors.grey.shade200,
            //         title: Image.asset(
            //           "assets/images/Terra-name.png",
            //           height: 40,
            //         ),
            //         centerTitle: true,
            //         elevation: 0,
            //       )
            //     : null,
            backgroundColor: Colors.grey.shade200,
            body: Stack(
              children: [
                // Positioned(
                //   top: -20,
                //   right: -10,
                //   child: Container(
                //     height: 100,
                //     width: 100,
                //     decoration: BoxDecoration(
                //       // shape: BoxShape.circle,
                //       borderRadius: BorderRadius.circular(130),
                //       color: Colors.transparent,
                //       boxShadow: [
                //         BoxShadow(
                //           offset: const Offset(2, 4),
                //           color: _colors.top.withOpacity(.3),
                //           blurRadius: 10,
                //         )
                //       ],
                //     ),
                //   ),
                // ),
                // Positioned(
                //   top: -10,
                //   right: 50,
                //   child: Container(
                //     height: 150,
                //     width: 150,
                //     decoration: BoxDecoration(
                //       // shape: BoxShape.circle,
                //       borderRadius: BorderRadius.circular(150),
                //       color: Colors.transparent,
                //       boxShadow: [
                //         BoxShadow(
                //           offset: const Offset(2, 4),
                //           color: _colors.bot.withOpacity(.6),
                //           blurRadius: 10,
                //         )
                //       ],
                //     ),
                //   ),
                // ),
                Positioned.fill(
                  child: SafeArea(
                    top: false,
                    child: loggedUser == null
                        ? Center(
                            child: Image.asset("assets/images/loader.gif"),
                          )
                        : TabBarView(
                            controller: _tabController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: _body,
                          ),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: loggedUser == null
                ? null
                : BottomNavigationBar(
                    currentIndex: _currentIndex,
                    unselectedItemColor: _colors.top.withOpacity(.3),
                    selectedItemColor: _colors.top,
                    showUnselectedLabels: false,
                    showSelectedLabels: true,
                    onTap: (i) async {
                      setState(() => _currentIndex = i);
                      _tabController.animateTo(i);
                    },
                    items: icons.map((e) {
                      final int index = icons.indexOf(e);
                      return BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          "assets/icons/$e${_tabController.index == index ? "_solid" : ""}.svg",
                          width: 20,
                          height: 20,
                          color: _tabController.index == index
                              ? _colors.top
                              : _colors.top.withOpacity(.3),
                        ),
                        label:
                            "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}",
                      );
                    }).toList(),
                  ),
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
