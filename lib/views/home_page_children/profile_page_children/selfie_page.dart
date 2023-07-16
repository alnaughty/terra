import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/utils/color.dart';

class SelfiePage extends StatefulWidget {
  const SelfiePage({super.key});

  @override
  State<SelfiePage> createState() => _SelfiePageState();
}

class _SelfiePageState extends State<SelfiePage> {
  late CameraController controller;
  final UserApi _api = UserApi();

  @override
  void initState() {
    _initializeCamera();
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await _initializeCamera();
    // });

    super.initState();

    // Initialize camera controller
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    controller.dispose();
    super.dispose();
  }

  bool showCamera = false;
  Future<void> _initializeCamera() async {
    final List<CameraDescription> cameras = await availableCameras();
    await Future.delayed(const Duration(milliseconds: 400));
    print("CAMS LENGTH : ${cameras.length}");
    final CameraDescription camera = cameras
        .where((element) => element.lensDirection == CameraLensDirection.front)
        .first;

    print("${camera.lensDirection}");
    setState(() {
      controller = CameraController(camera, ResolutionPreset.max);
    });
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        showCamera = true;
      });
    }).catchError((Object e) {
      setState(() {
        showCamera = false;
      });
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            Fluttertoast.showToast(msg: "Camera access denied");
            break;
          default:
            Fluttertoast.showToast(msg: "Unable to access camera");
            // Handle other errors here.
            break;
        }
      }
    });
    if (mounted) setState(() {});
  }

  Future<String?> _takePicture() async {
    try {
      final XFile file = await controller.takePicture();

      return base64.encode(await file.readAsBytes());
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double overlaySize = size.width * 0.8;
    return Stack(
      children: [
        Positioned.fill(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: const Text("Upload Selfie"),
            ),
            body: showCamera
                ? Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        ClipOval(
                          child: SizedBox(
                            width: overlaySize,
                            height: overlaySize,
                            child: CameraPreview(controller),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Center your face".toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                "Align your face to the center of the selfie area and then take a photo.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black.withOpacity(.5),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: size.width,
                          height: 60,
                          child: Center(
                            child: SizedBox(
                              width: 60,
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                height: 60,
                                color: Colors.white,
                                onPressed: () async {
                                  await _takePicture().then((value) async {
                                    if (value == null) {
                                      Navigator.of(context).pop();
                                      Fluttertoast.showToast(
                                        msg: "Unable to upload image",
                                      );
                                      return;
                                    }
                                    Navigator.of(context).pop();
                                    // await _api.uploadSelfie(value);
                                  });
                                },
                                child: const Center(
                                  child: Icon(
                                    Icons.add_a_photo_rounded,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SafeArea(
                          child: SizedBox(
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
            // body: FutureBuilder(
            //   future: controller.initialize(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.done) {
            //       // Calculate the size of the circular overlay
            //       final overlaySize = MediaQuery.of(context).size.width * 0.8;

            //       // Build the camera preview wrapped in a ClipOval
            // return ClipOval(
            //   child: SizedBox(
            //     width: overlaySize,
            //     height: overlaySize,
            //     child: CameraPreview(controller),
            //   ),
            // );
            //     } else {
            //       return const Center(child: CircularProgressIndicator());
            //     }
            //   },
            // ),
          ),
        ),
        if (_isLoading) ...{
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(.5),
              child: Center(
                child: Image.asset(
                  "assets/images/loader.gif",
                  // width: 80,
                ),
              ),
            ),
          )
        }
      ],
    );
  }
}
