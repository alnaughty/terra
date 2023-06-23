import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:terra/services/image_processor.dart';
import 'package:terra/utils/color.dart';

class IDCardCallback {
  final String base64Image;
  final String type;
  const IDCardCallback({required this.base64Image, required this.type});
}

class UploadIdPage extends StatefulWidget {
  const UploadIdPage({super.key, required this.callback});
  final ValueChanged<IDCardCallback> callback;
  @override
  State<UploadIdPage> createState() => _UploadIdPageState();
}

class _UploadIdPageState extends State<UploadIdPage> {
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
  String? chosenId;
  String? idImage;
  Widget? chosenImage;
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
                    chosenId = f;
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
                value: chosenId,
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
                                    idImage = ba;
                                    chosenImage = Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 30),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.memory(
                                          base64Decode(idImage!),
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
                                    idImage = ba;
                                    chosenImage = Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 30),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.memory(
                                          base64Decode(idImage!),
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
              child: chosenImage ??
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
                        "Upload a picture of your ID",
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
            onPressed: chosenId == null || chosenImage == null
                ? null
                : () {
                    widget.callback(IDCardCallback(
                      type: chosenId!,
                      base64Image: idImage!,
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
