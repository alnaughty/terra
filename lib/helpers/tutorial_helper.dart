import 'package:flutter/material.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:tutorial/tutorial.dart';

class TutorialHelper {
  static Widget styledText(String label, {required String content}) =>
      Text.rich(
        TextSpan(
            text: label,
            style: TextStyle(
              color: _colors.top,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            children: [
              TextSpan(
                text: " $content",
                style: TextStyle(
                  color: Colors.white.withOpacity(.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              )
            ]),
      );
  static final AppColors _colors = AppColors.instance;
  final List<Widget> content = [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "This is Home Tab",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "on this tab, it contains the jobs for jobseekers and offered jobs for employers",
          style: TextStyle(
            color: Colors.white.withOpacity(.5),
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          loggedUser!.accountType == 1
              ? "You can also showcase your skills as jobseeker, for you to be known by people who looking for workers"
              : "You can also post jobs here that you currently need",
          style: TextStyle(
            color: Colors.white.withOpacity(1),
            fontSize: 16,
          ),
        )
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "This is Chats Tab",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "on this tab, you can see the messages, and also message people that you already connected with.",
          style: TextStyle(
            color: Colors.white.withOpacity(.5),
            fontSize: 16,
          ),
        )
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "This is Jobs Tab",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "on this tab, it contains the jobs that you have to accept or decline, upon accepting, ${loggedUser!.accountType == 1 ? "you will be having tasks that you must do and" : "you will be having active tasks which will/must be done by the jobseeker and"} will be displayed in the PROFILE TAB",
          style: TextStyle(
            color: Colors.white.withOpacity(.5),
            fontSize: 16,
          ),
        )
      ],
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "This is Profile Tab",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "on this tab, it contains almost all of the most important features",
          style: TextStyle(
            color: Colors.white.withOpacity(.5),
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        styledText(
          "Details",
          content:
              "contains the user's account details where you can edit & display.",
        ),
        styledText(
          "Password",
          content: "is where you can change/modify your password",
        ),
        styledText(
          "Security Level",
          content: "is where you can see how verified your account is",
        ),
        styledText(
          "Skills",
          content:
              "contains the user's preferred skills, you can change it there.",
        ),
        styledText(
          "Completed Tasks",
          content:
              "this is where you can find tasks that you have completed, meaning you have been paid or you paid.",
        ),
        styledText(
          "Task History",
          content:
              "this is where you can find tasks that are either completed or still on going and declined or accepted.",
        ),
      ],
    ),
  ];
  final List<String> icons = ["home", "chats", "jobs", "profile"];
  late final List<GlobalKey> icMenuKeys = List.generate(
    icons.length,
    (index) => GlobalKey(),
  );
  late final List<TutorialItem> landingItems = List.generate(
    icons.length,
    (index) => TutorialItem(
      top: 100,
      left: 50,
      globalKey: icMenuKeys[index],
      touchScreen: true,
      shapeFocus: ShapeFocus.oval,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.all(0),
          title: const Text(
            "WELCOME TO TERRA",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 25,
            ),
          ),
          subtitle: Text(
            "We appreciate that you want us to help you.",
            style: TextStyle(
              color: Colors.white.withOpacity(.5),
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        content[index],
        const SizedBox(
          height: 100,
        )
      ],
      widgetNext: Text(
        "Next",
        style: TextStyle(
          color: _colors.top,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
  void showLandingTutorial(BuildContext context) async {
    await Tutorial.showTutorial(context, landingItems);
  }
}
