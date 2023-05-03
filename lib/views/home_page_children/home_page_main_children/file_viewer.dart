import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_file_view/flutter_file_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CustomFileViewer extends StatelessWidget {
  CustomFileViewer({super.key, required this.url, required this.isPdf}) {
    if (!isPdf) {
      FlutterFileView.init();
    }
    // _path = DefaultCacheManager().getSingleFile(url).then((file) => file.path);
  }
  final String url;
  final bool isPdf;
  late final Future<File> _fileFuture = _getFile();

  Future<File> _getFile() async {
    final DefaultCacheManager cacheManager = DefaultCacheManager();
    final File file = await cacheManager.getSingleFile(url);
    final Directory dir = await getTemporaryDirectory();
    final File pdfFile = File('${dir.path}/file.pdf');
    final ProcessResult process = await Process.run(
      'libreoffice',
      [
        '--convert-to',
        'pdf',
        '--outdir',
        dir.path,
        file.path,
      ],
    );
    print("EXIT: CODE : ${process.exitCode}");
    if (process.exitCode == 0) {
      return pdfFile;
    } else {
      throw process.stderr;
    }
  }

  // static late final Future<String> _path;
  // late final WebViewController controller = WebViewController()
  //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //   ..setBackgroundColor(const Color(0x00000000))
  //   ..setNavigationDelegate(
  //     NavigationDelegate(
  //       onProgress: (int progress) {
  //         // Update loading bar.
  //       },
  //       onPageStarted: (String url) {},
  //       onPageFinished: (String url) {},
  //       onWebResourceError: (WebResourceError error) {
  //         print("WEBVIEW ERROR : ${error.description}");
  //       },
  //       onNavigationRequest: (NavigationRequest request) {
  //         if (request.url.startsWith('https://www.youtube.com/')) {
  //           return NavigationDecision.prevent;
  //         }
  //         return NavigationDecision.navigate;
  //       },
  //     ),
  //   )
  //   ..loadRequest(Uri.parse(url));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isPdf
          ? SfPdfViewer.network(url)
          : FileView(
              controller: FileViewController.network(
                url,
              ),
            ),
      // body: FutureBuilder<File>(
      //   future: _getFile(),
      //   builder: (_, future) {
      //     if (!future.hasData || future.hasError) {
      //       return Container();
      //     }
      //     final File file = future.data!;
      //     print("FILE PATH : ${file.path}");
      //     return SfPdfViewer.network(url);
      //     // return PDFViewerScaffold(
      //     //   appBar: AppBar(
      //     //     centerTitle: true,
      //     //     title: const Text('Document Viewer'),
      //     //   ),
      //     //   path: future.data!.path,
      //     // );
      //   },
      // ),
    );
  }
}
