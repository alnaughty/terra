import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class Launcher {
  Future<bool> isLaunchable(String url) async {
    return await canLaunchUrl(Uri.parse(url));
  }

  Future<void> launchWebView(BuildContext context,
      {required String url}) async {
    final Size size = MediaQuery.of(context).size;
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            // if (request.url.startsWith('https://www.youtube.com/')) {
            //   return NavigationDecision.prevent;
            // }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    await showGeneralDialog(
        context: context,
        transitionBuilder: (context, a1, a2, child) => Transform.scale(
            scale: a1.value,
            child: FadeTransition(
              opacity: a1,
              child: child,
            )),
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(.5),
        barrierLabel: "",
        pageBuilder: (_, a, b) => WebViewWidget(controller: controller)
        // pageBuilder: (_, a, b) => AlertDialog(
        //   content: SizedBox(
        //     width: size.width,
        //     height: size.height,
        //     child: WebViewWidget(controller: controller),
        //   ),
        // ),
        );
  }

  Future<void> launch(String url) async {
    if (await isLaunchable(url)) {
      await launchUrl(
        Uri.parse(url),
        webOnlyWindowName: "Terra App",
      );
    } else {
      Fluttertoast.showToast(msg: "Impossible de lancer $url");
      // throw;
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<void> sendEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        'subject': 'I would like to have a meeting with you',
      }),
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
}
