import 'package:flutter/material.dart';
import 'package:terra/models/tutorial_data.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/views/landing_page_children/tutorial_screen.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key, required this.onPressed});
  final Function() onPressed;
  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  late final PageController _controller;
  final List<TutorialData> _data = const [
    TutorialData(
      name: "Identity Verification",
      description:
          "Terra's goal is to create a safe and fraud-free platform that will help both job/employee seekers.",
      imagePath: "assets/images/Terraslide1.png",
    ),
    TutorialData(
      name: "Personal Information",
      description:
          "Be at ease, Terra's top priority is to keep your personal data safe against loss, misuse, unauthorized access, disclosure, and alteration.",
      imagePath: "assets/images/Terraslide2.png",
    ),
    TutorialData(
      name: "Face Verification",
      description:
          "With the help of modern technology, Terra has a faster way to deal with fraud acts. Terra values your time!",
      imagePath: "assets/images/Terraslide3.png",
    ),
  ];
  final DataCacher _cacher = DataCacher.instance;
  @override
  void initState() {
    _controller = PageController();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  int currentIndex = 0;
  final AppColors _color = AppColors.instance;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemCount: _data.length,
            itemBuilder: (_, index) => TutorialScreen(
              data: _data[index],
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: SafeArea(
            child: TextButton(
              onPressed: widget.onPressed,
              child: Text(
                currentIndex < _data.length - 1 ? "Skip" : "Lets Get Started",
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          child: SizedBox(
            // width: double.maxFinite,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _data.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: currentIndex == index ? 20 : 10,
                  height: 10,
                  margin: EdgeInsets.symmetric(horizontal: index == 1 ? 10 : 0),
                  decoration: BoxDecoration(
                    color: currentIndex == index ? _color.top : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
