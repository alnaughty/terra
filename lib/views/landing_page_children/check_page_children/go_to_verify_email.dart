import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/views/home_page_children/profile_page_children/verify_email_page.dart';

class GoToVerifyEmailPage extends StatelessWidget {
  const GoToVerifyEmailPage({super.key, required this.callback});
  final VoidCallback callback;
  static final AppColors _colors = AppColors.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        const Text(
          "To ensure the safety of our users we would like to validate your email first before using our app.",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        MaterialButton(
          onPressed: () async {
            if (loggedUser!.hasVerifiedEmail) {
              callback();
              Fluttertoast.showToast(
                  msg: "Please wait for the team to verify your data");
            } else {
              await Navigator.push(
                context,
                PageTransition(
                  child: const VerifyEmailPage(
                    reload: true,
                  ),
                  type: PageTransitionType.rightToLeft,
                ),
              );
            }
          },
          height: 60,
          color: _colors.top,
          child: Center(
            child: Text(
              loggedUser!.hasVerifiedEmail ? "Continue" : "Verify Email",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )
      ],
    );
  }
}
