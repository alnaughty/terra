import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/cli_commands.dart';
import 'package:terra/services/API/user_api.dart';
import 'package:terra/services/image_processor.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';

class UploadIDPage extends StatefulWidget {
  const UploadIDPage({super.key});

  @override
  State<UploadIDPage> createState() => _UploadIDPageState();
}

class _UploadIDPageState extends State<UploadIDPage> {
  String? b64Image;
  bool _isLoading = false;
  final UserApi _api = UserApi();
  final AppColors _colors = AppColors.instance;
  final ImageProcessor _image = ImageProcessor.instance;
  Widget? chosenImage;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Scaffold(
            backgroundColor: Colors.grey.shade200,
            appBar: AppBar(
              title: const Text("Upload ID"),
              centerTitle: true,
              backgroundColor: Colors.white,
            ),
            body: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(
                                milliseconds: 600,
                              ),
                              child: b64Image == null
                                  ? Image.asset(
                                      "assets/images/id.png",
                                    )
                                  : chosenImage,
                            ),
                            Text(
                              "Hey ${loggedUser!.firstName.capitalize()}!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _colors.top,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: "Please provide a Photo of ",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black.withOpacity(.5),
                                ),
                                children: const [
                                  TextSpan(
                                    text: "Any ID",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        " and wait until we process your request",
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            )
                            // Text(
                            //   "Please",
                            //   textAlign: TextAlign.center,
                            //   style: TextStyle(
                            //     fontSize: 16,
                            //     color: Colors
                            //   ),
                            // )
                          ],
                        ),
                      ),
                      if (b64Image != null) ...{
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _colors.bot,
                                _colors.top,
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                            // color: _colors.bot,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: MaterialButton(
                            height: 60,
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              await _api.uploadId(b64Image!).whenComplete(() {
                                setState(() {
                                  _isLoading = false;
                                });
                                Navigator.of(context).pop(0);
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.upload,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Upload",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      },
                      Container(
                        decoration: BoxDecoration(
                          // gradient: LinearGradient(
                          //   colors: [
                          //     _colors.bot,
                          //     _colors.top,
                          //   ],
                          //   begin: Alignment.bottomLeft,
                          //   end: Alignment.topRight,
                          // ),
                          // color: _colors.bot,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: MaterialButton(
                          height: 60,
                          onPressed: () async {
                            await showModalBottomSheet(
                              context: context,
                              barrierColor: Colors.black.withOpacity(.5),
                              isDismissible: true,
                              useSafeArea: true,
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              // shape: RoundedRectangleBorder(
                              //   borderRadius: BorderRadius.circular(20),
                              // ),
                              constraints: const BoxConstraints(
                                maxHeight: 180,
                              ),
                              builder: (_) => SafeArea(
                                top: false,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ListTile(
                                        onTap: () async {
                                          await _image
                                              .pickImageGallery()
                                              .then((File? value) async {
                                            if (value == null) return;
                                            print(value.path);
                                            await _image
                                                .cropImage(value, forId: true)
                                                .then((ba) async {
                                              if (ba == null) return;
                                              Navigator.of(context).pop(null);
                                              setState(() {
                                                b64Image = ba;
                                                chosenImage = Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 30),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Image.memory(
                                                      base64Decode(b64Image!),
                                                    ),
                                                  ),
                                                );
                                              });
                                            });
                                          });
                                        },
                                        leading: const Icon(
                                          CupertinoIcons.photo,
                                        ),
                                        title: const Text("Gallery"),
                                      ),
                                      ListTile(
                                        onTap: () async {
                                          await _image
                                              .pickImageCamera()
                                              .then((value) async {
                                            if (value == null) return;
                                            await _image
                                                .cropImage(value, forId: true)
                                                .then((ba) async {
                                              if (ba == null) return;
                                              Navigator.of(context).pop(null);
                                              setState(() {
                                                b64Image = ba;
                                                chosenImage = Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 30),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Image.memory(
                                                      base64Decode(b64Image!),
                                                    ),
                                                  ),
                                                );
                                              });
                                            });
                                          });
                                        },
                                        leading: const Icon(
                                          CupertinoIcons.camera,
                                        ),
                                        title: const Text("Camera"),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              "Choose image",
                              style: TextStyle(
                                color: _colors.top,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
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
        }
      ],
    );
  }
}
