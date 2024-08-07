import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:terra/helpers/tutorial_helper.dart';
import 'package:terra/models/chat/chat_room.dart';
import 'package:terra/services/API/application.dart';
import 'package:terra/services/API/category_api.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/services/firebase/chat_service.dart';
import 'package:terra/services/firebase_messaging.dart';
import 'package:terra/services/landing_processes.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/view_data_component/splash_screen_dc.dart';
import 'package:terra/view_data_component/user_position.dart';
import 'package:terra/view_model/applications.dart';
import 'package:terra/view_model/chat_rooms_vm.dart';
import 'package:terra/views/home_page_children/application_recruitements.dart';
import 'package:terra/views/home_page_children/chats/chat_rooms.dart';
import 'package:terra/views/home_page_children/home_page_main.dart';
import 'package:terra/views/home_page_children/profile_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:terra/views/landing_page_children/pop_up_location.dart';
import 'package:tutorial/tutorial.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with
        SingleTickerProviderStateMixin,
        UserApi,
        CategoryApi,
        SplashScreenDc,
        TutorialHelper {
  static final ApplicationApi _appApi = ApplicationApi.instance;
  static final LandingProcesses _process = LandingProcesses.instance;
  static final ChatService chatRoomService = ChatService.instance;
  static final UserPosition _pos = UserPosition.instance;
  static final ApplicationsVm _applicationVM = ApplicationsVm.instance;

  final List<String> icons = ["home", "chats", "jobs", "profile"];

  List<TutorialItem> items = [];

  late final TabController _tabController;
  late final List<Widget> _body = [
    HomePageMain(
      onLoading: (s) => setState(() => _isLoading = s),
    ),
    const ChatRoomsPage(),
    const JobsRecordPage(),
    ProfilePage(
      loadingCallback: (s) => setState(() => _isLoading = s),
    ),
  ];
  static final MyFCMService _fcm = MyFCMService.instance;
  int _currentIndex = 0;
  final AppColors _colors = AppColors.instance;

  final DataCacher _cacher = DataCacher.instance;
  Future<void> initLocation() async {
    if (Platform.isIOS) {
      await requestTrackingPermission();
    }
    await showGeneralDialog(
      // ignore: use_build_context_synchronously
      context: context,
      barrierDismissible: true,
      barrierLabel: "",
      barrierColor: Colors.black.withOpacity(.5),
      transitionBuilder: ((context, animation, secondaryAnimation, child) =>
          ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          )),
      pageBuilder: ((context, animation, secondaryAnimation) =>
          const PopupLocationDisplay()),
    );
    final LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse) {
      return;
    }
    await Geolocator.requestPermission().then((permission) async {
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Geolocator.getPositionStream().listen((Position pos) {
          _pos.populate(
            LatLng(pos.latitude, pos.longitude),
          );
        });
      } else {}
    });
    if (mounted) setState(() {});
  }

  Future<void> requestTrackingPermission() async {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;

    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(
          const Duration(milliseconds: 200)); // Delay for smooth transition
      final TrackingStatus newStatus =
          await AppTrackingTransparency.requestTrackingAuthorization();
      print('Tracking status: $newStatus');
    } else {
      print('Tracking status: $status');
    }
  }

  Future<void> init() async {
    if (loggedUser == null) {
      _cacher.clearAll();
      Navigator.pushReplacementNamed(context, "/");
    }
    _fcm.init(context);
    await fetchAll();
    await _appApi.fetchUserApplication().then(
          (value) => _applicationVM.populate(value),
        );
    await listenMessages();
    if (mounted) setState(() {});

    await _process.loadProcesses();
  }

  static final ChatRoomsVm _vm = ChatRoomsVm.instance;
  Future<void> listenMessages() async {
    chatRoomService.getUserChatrooms().listen((List<ChatRoom> rooms) {
      _vm.populate(rooms);
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: _body.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final bool showTuts = _cacher.initApp();
      if (showTuts) {
        showLandingTutorial(context);
        _cacher.setToOld();
      }
      await Future.wait([
        init(),
        initLocation(),
      ]);
    });
    super.initState();
  }

  @override
  void dispose() {
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
            backgroundColor: Colors.grey.shade200,
            body: Stack(
              children: [
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
                          key: icMenuKeys[index],
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
