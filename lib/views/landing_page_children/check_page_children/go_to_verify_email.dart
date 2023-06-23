import 'package:flutter/material.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';

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
            } else {
              await Navigator.pushNamed(context, "/verify_email_page");
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
