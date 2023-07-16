import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/v2/kyc_status.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/utils/network.dart';

class KYC {
  Future<KYCStatus?> getKYCStatus() async {
    try {
      return await http.get("${Network.domain}/api/kyc".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      }).then((response) {
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          // print("KYC DATA $data");
          print("KYC DATA ${response.statusCode}: ${response.body}");
          return KYCStatus.fromJson(data);
          // final List result = data['negotiations'] as List;
          // return result.map((e) => NegotiationModel.fromJson(e)).toList();
        }
        print("KYC DATA ERROR ${response.statusCode}: ${response.body}");
        return null;
      });
    } catch (e, s) {
      print("ERROR : $e $s");
      return null;
    }
  }

  Future<void> uploadKYC({
    required String type,
    required String selfie,
    required String idFront,
    required String idBack,
  }) async {
    try {
      return await http.post(
        "${Network.domain}/api/kyc".toUri,
        headers: {
          "Accept": "application/json",
          HttpHeaders.authorizationHeader: "Bearer $accessToken",
        },
        body: {
          "id_type": type,
          "selfie": "data:image/jpeg;base64,$selfie",
          "id_front": "data:image/jpeg;base64,$idFront",
          "id_back": "data:image/jpeg;base64,$idBack",
        },
      ).then((response) {
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          print("KYC UPLOAD DATA $data");
          Fluttertoast.showToast(
              msg: "Our team will review your data, Thank you!");
          // return 1;
          // final List result = data['negotiations'] as List;
          // return result.map((e) => NegotiationModel.fromJson(e)).toList();
        } else if (response.statusCode == 413) {
          Fluttertoast.showToast(msg: "Your file is too large");
        }
        print("KYC DATA ERROR ${response.statusCode}: ${response.body}");
        return null;
      });
    } catch (e, s) {
      print("ERROR : $e $s");
      return null;
    }
  }
}
