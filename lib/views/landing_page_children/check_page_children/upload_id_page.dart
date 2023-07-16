import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:terra/services/image_processor.dart';
import 'package:terra/utils/color.dart';
import 'package:terra/utils/global.dart';

// class IDCardCallback {
//   final String base64Image;
//   final String type;
//   const IDCardCallback({required this.base64Image, required this.type});
// }

class FullIDCallback {
  final String type;

  /// both are base64
  final String front;
  final String back;
  const FullIDCallback(
      {required this.front, required this.back, required this.type});
}

class UploadIdPage extends StatefulWidget {
  const UploadIdPage({super.key, required this.callback});
  final ValueChanged<FullIDCallback> callback;
  @override
  State<UploadIdPage> createState() => UploadIdPageState();
}

class UploadIdPageState extends State<UploadIdPage> {
  static final AppColors _colors = AppColors.instance;
  final ImageProcessor _image = ImageProcessor.instance;
  final List<String> validIds = [
    "UMID",
    "Philhealth",
    "Pag-ibig Membership Card",
    "Driver's License",
    "Passport",
    "Professional Regulation Commission (PRC) ID",
    "Philippine Identification",
    "Philippine Identification (PhilID / ePhilID)",
    "SSS ID"
  ];
  String? type;
  String? frontIdImage;
  Widget? frontChosenImage;

  String? backIdImage;
  Widget? backChosenImage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      return Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Container(
            width: c.maxWidth,
            padding:
                const EdgeInsets.only(left: 15, right: 10, top: 10, bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                dropdownColor: Colors.white,
                focusColor: Colors.white,
                isExpanded: true,
                onChanged: (String? f) {
                  setState(() {
                    type = f;
                  });
                },
                hint: const Text(
                  "Choose ID Type",
                  style: TextStyle(color: Color(0xFFB5AEAE)),
                ),
                // selectedItemBuilder: (_) => [Text("ASDASD")],
                items: validIds
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(
                          e,
                        ),
                      ),
                    )
                    .toList(),
                value: type,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          MaterialButton(
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
                // constraints: const BoxConstraints(
                //   maxHeight: 180,
                // ),
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ListTile(
                            onTap: () async {
                              await _image
                                  .pickImage(ImageSource.gallery)
                                  .then((value) async {
                                if (value == null) return;
                                Navigator.of(context).pop(null);
                                frontIdImage = value;
                                frontChosenImage = Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 30),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.memory(
                                      base64Decode(frontIdImage!),
                                    ),
                                  ),
                                );
                                if (mounted) setState(() {});
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
                                  .pickImage(ImageSource.camera)
                                  .then((value) async {
                                if (value == null) return;
                                Navigator.of(context).pop(null);
                                frontIdImage = value;
                                frontChosenImage = Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 30),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.memory(
                                      base64Decode(frontIdImage!),
                                    ),
                                  ),
                                );
                                if (mounted) setState(() {});
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
                ),
              );
            },
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            // width: c.maxWidth,
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius: BorderRadius.circular(5),
            // ),
            padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 0),
            child: Center(
              child: frontChosenImage ??
                  Column(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/id.svg",
                        width: 80,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFB5AEAE),
                          BlendMode.srcATop,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        "Upload a picture of your ID (Front)",
                        style: TextStyle(
                          color: Color(0xFFB5AEAE),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          MaterialButton(
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
                // constraints: const BoxConstraints(
                //   maxHeight: 180,
                // ),
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
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ListTile(
                            onTap: () async {
                              await _image
                                  .pickImage(ImageSource.gallery)
                                  .then((value) async {
                                if (value == null) return;
                                Navigator.of(context).pop(null);
                                setState(() {
                                  backIdImage = value;
                                  backChosenImage = Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 30),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.memory(
                                        base64Decode(backIdImage!),
                                      ),
                                    ),
                                  );
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
                                  .pickImage(ImageSource.camera)
                                  .then((value) async {
                                if (value == null) return;
                                Navigator.of(context).pop(null);
                                setState(() {
                                  backIdImage = value;
                                  backChosenImage = Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 30),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.memory(
                                        base64Decode(backIdImage!),
                                      ),
                                    ),
                                  );
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
                ),
              );
            },
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            // width: c.maxWidth,
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius: BorderRadius.circular(5),
            // ),
            padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 0),
            child: Center(
              child: backChosenImage ??
                  Column(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/id.svg",
                        width: 80,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFB5AEAE),
                          BlendMode.srcATop,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        "Upload a picture of your ID (Back)",
                        style: TextStyle(
                          color: Color(0xFFB5AEAE),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          MaterialButton(
            onPressed: (type == null ||
                    frontChosenImage == null ||
                    backChosenImage == null)
                ? null
                : () {
                    widget.callback(FullIDCallback(
                      type: type!,
                      front: frontIdImage!,
                      back: backIdImage!,
                    ));
                  },
            color: _colors.top,
            disabledColor: Colors.grey,
            height: 60,
            child: const Center(
              child: Text(
                "Continue",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SafeArea(
            top: false,
            child: SizedBox(
              height: 10,
            ),
          )
        ],
      );
    });
  }
}
