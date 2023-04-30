import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/utils/global.dart';

class SecurityChoice extends StatelessWidget {
  const SecurityChoice({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            onTap: loggedUser!.hasUploadedId
                ? null
                : () async {
                    await Navigator.pushNamed(context, "/upload_id_page");
                  },
            leading: const Icon(
              Icons.attach_file_rounded,
            ),
            title: const Text("Upload ID"),
            trailing: loggedUser!.hasUploadedId
                ? const Icon(
                    Icons.check,
                    color: Colors.green,
                  )
                : null,
          ),
          ListTile(
            onTap: loggedUser!.hasSelfie
                ? null
                : () async {
                    await Navigator.pushNamed(context, "/selfie_page");
                  },
            leading: const Icon(
              Icons.sentiment_satisfied_alt_rounded,
            ),
            title: const Text("Upload Selfie"),
            trailing: loggedUser!.hasSelfie
                ? const Icon(
                    Icons.check,
                    color: Colors.green,
                  )
                : null,
          ),
          ListTile(
            onTap: loggedUser!.hasVerifiedEmail
                ? null
                : () async {
                    await Navigator.pushNamed(context, "/verify_email_page");
                  },
            leading: const Icon(
              Icons.email_outlined,
            ),
            title: const Text("Verify Email"),
            trailing: loggedUser!.hasVerifiedEmail
                ? const Icon(
                    Icons.check,
                    color: Colors.green,
                  )
                : null,
          ),
          ListTile(
            onTap: loggedUser!.hasVerifiedNumber
                ? null
                : () async {
                    Fluttertoast.showToast(msg: "Coming soon.");
                  },
            leading: const Icon(
              Icons.phone_enabled_outlined,
            ),
            title: const Text("Verify Number"),
            trailing: loggedUser!.hasVerifiedNumber
                ? const Icon(
                    Icons.check,
                    color: Colors.green,
                  )
                : null,
          )
        ],
      ),
    );
  }
}
