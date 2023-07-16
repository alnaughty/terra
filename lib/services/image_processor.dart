import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageProcessor {
  ImageProcessor._pr();
  static final ImageProcessor _instance = ImageProcessor._pr();
  static ImageProcessor get instance => _instance;
  static final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageGallery() async {
    return await _picker.pickImage(source: ImageSource.gallery).then((value) {
      if (value == null) return null;
      final File n = File(value.path);
      return n;
    });
  }
  // Future<ImageData> getData(File file) async {
  //   final Uint8List fileBytes =
  //       await compressImage(File(file.path).readAsBytesSync());

  //   return ImageData(
  //     base64: base64Encode(fileBytes),
  //     extension: file.path.substring(file.path.lastIndexOf('.') + 1),
  //   );
  // }
  Future<Uint8List> compressImage(Uint8List list) async {
    return await FlutterImageCompress.compressWithList(
      list,
      quality: 70,
      rotate: 0,
    ).then((value) => value);
  }

  ///return base64
  Future<String?> compressImg(File file) async {
    try {
      final Uint8List fileBytes =
          await compressImage(File(file.path).readAsBytesSync());
      return base64Encode(fileBytes);
    } catch (e) {
      print("UNABLE TO COMPRESS");
      return null;
    }
  }

  // return base64
  Future<String?> pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(source: source);
      if (file == null) {
        return null;
      }
      return await compressImg(
        File(file.path),
      );
    } catch (e) {
      print("IMG PICK FAILED");
      return null;
    }
  }

  Future<File?> pickImageCamera() async {
    return await _picker.pickImage(source: ImageSource.camera).then((value) {
      if (value == null) return null;
      final File n = File(value.path);
      return n;
    });
  }

  Future<String?> cropImage(File image, {bool forId = false}) async {
    try {
      return await ImageCropper().cropImage(
        sourcePath: image.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          if (forId) ...{
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.ratio7x5,
            CropAspectRatioPreset.ratio5x3,
          },
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: forId
                ? CropAspectRatioPreset.ratio7x5
                : CropAspectRatioPreset.square,
            lockAspectRatio: false,
          )
        ],
      ).then((CroppedFile? value) async {
        if (value == null) return null;
        final Uint8List _bytes = await value.readAsBytes();
        return base64Encode(_bytes);
      });
    } catch (e) {
      return null;
    }
  }
}
