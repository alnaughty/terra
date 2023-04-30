import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
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
        pageBuilder: (_, a, b) => WebviewScaffold(
              appBar: AppBar(
                title: const Text("Preview File"),
              ),
              url: url,
              withZoom: true,
              userAgent:
                  "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36",
              // headers: const {
              //   "accept":
              //       "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
              //   "accept-encoding": "gzip, deflate, br",
              //   "sec-ch-ua-platform": "Android",
              //   "x-client-data": "",
              // },
            )
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
