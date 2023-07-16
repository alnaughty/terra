import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/user_details.dart';
import 'package:http/http.dart' as http;
import 'package:terra/models/v2/negotiation_model.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/utils/network.dart';

class UserApi {
  final DataCacher _cacher = DataCacher.instance;
  // Future<bool> updateAccountType() async {}

  Future<List<NegotiationModel>> getMyNegotiations() async {
    try {
      return await http.get(
          "${Network.domain}/api/applicant-negotiation/${loggedUser!.id}".toUri,
          headers: {
            "Accept": "application/json",
            HttpHeaders.authorizationHeader: "Bearer $accessToken",
          }).then((response) {
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          print("DATA $data");
          final List result = data['negotiations'] as List;
          return result.map((e) => NegotiationModel.fromJson(e)).toList();
        }
        return List.empty();
      });
    } catch (e) {
      return List.empty();
    }
  }

  Future<UserDetails?> details() async {
    try {
      print("TOKEN : $accessToken");
      return await http
          .get("${Network.domain}/api/user-details".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      }).then((response) {
        var data = json.decode(response.body);
        print(data);
        if (response.statusCode == 200 || response.statusCode == 201) {
          return UserDetails.fromJson(data);
        }
        Fluttertoast.showToast(
          msg: "Error ${response.statusCode} : ${response.reasonPhrase}",
        );
        return null;
      });
    } catch (e, s) {
      print("ERROR : $e $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing.",
      );
      return null;
    }
  }

  // Future<bool> updatePassword({required String newPassword}) async {

  // }
  Future<bool> updateDetails(Map<String, dynamic> body) async {
    try {
      return await http
          .post(
        "${Network.domain}/api/update-details".toUri,
        headers: {
          "Accept": "application/json",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        },
        body: body,
      )
          .then((response) {
        var data = json.decode(response.body);
        print("USER DATA $data");
        if (response.statusCode == 200) {
          // loggedUser = UserDetails.fromJson(data);
          Fluttertoast.showToast(msg: "Account Updated");
          return true;
        }
        print("${response.statusCode} - ${response.reasonPhrase}");
        Fluttertoast.showToast(
          msg: "An unexpected error occurred while processing.",
        );
        return false;
      });
    } catch (e, s) {
      print("ERROR : $e $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing.",
      );
      return false;
    }
  }

  Future<bool> updateAvatar({required String base64Image}) async {
    try {
      print("data:image/png;base64,$base64Image");
      return await http
          .post("${Network.domain}/api/update-profile".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }, body: {
        "avatar": "data:image/png;base64,$base64Image"
      }).then((response) {
        var data = json.decode(response.body);
        print("UPDATE DATA AVATAR DATA : $data");
        if (response.statusCode == 200) {
          // loggedUser = UserDetails.fromJson(data);
          Fluttertoast.showToast(msg: "Profile Picture Updated");
          return true;
        }
        print("${response.statusCode} - ${response.reasonPhrase}");
        Fluttertoast.showToast(
          msg: "An unexpected error occurred while processing.",
        );
        return false;
      });
    } catch (e, s) {
      print("ERROR : $e $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing.",
      );
      return false;
    }
  }

  Future<bool> updateSkills(String ids) async {
    try {
      return await http
          .post("${Network.domain}/api/update-skills".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }, body: {
        "skills": ids,
      }).then((response) {
        print("RESPONSE : ${response.statusCode}");
        return response.statusCode == 200;
      });
    } catch (e, s) {
      print("ERROR : $e $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing.",
      );
      return false;
    }
  }

  Future<void> saveFcm(
    String tok,
  ) async {
    if (tok == _cacher.getFcmToken()) return;
    try {
      return await http.post("${Network.domain}/api/fcm-token".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }, body: {
        "fcm_token": tok,
      }).then((response) {
        if (response.statusCode == 200) {
          _cacher.saveFcmToken(tok);
        }
        return;
      });
    } catch (e, s) {
      print("ERROR : $e $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing.",
      );
      return;
    }
  }

  Future<List<UserDetails>?> searchBySkill(String? skills) async {
    try {
      return await http.get(
          "${Network.domain}/api/users?skills=${skills ?? ""}".toUri,
          headers: {
            "Accept": "application/json",
            HttpHeaders.authorizationHeader: "Bearer $accessToken"
          }).then((response) {
        if (response.statusCode == 200) {
          var d = json.decode(response.body);
          final List<UserDetails> _result =
              (d['data'] as List).map((e) => UserDetails.fromJson(e)).toList();
          return _result;
        }
        Fluttertoast.showToast(
          msg: "An error occurred while processing, please contact developer",
        );
        return null;
      });
    } catch (e, s) {
      print("ERROR : $e $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing.",
      );
      return null;
    }
  }

  Future<bool> updateBio(String bio) async {
    try {
      return await http.post(
        "${Network.domain}/api/update-bio".toUri,
        headers: {
          "Accept": "application/json",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        },
        body: {
          "bio": bio,
        },
      ).then((response) => response.statusCode == 200);
    } catch (e, s) {
      print("ERROR : $e $s");
      Fluttertoast.showToast(
        msg: "An unexpected error occurred while processing.",
      );
      return false;
    }
  }

  // Future<void> uploadSelfie(String base64) async {
  //   try {
  //     return await http
  //         .post("${Network.domain}/api/upload-selfie".toUri, headers: {
  //       "Accept": "application/json",
  //       HttpHeaders.authorizationHeader: "Bearer $accessToken"
  //     }, body: {
  //       "selfie": "data:image/jpg;base64,$base64",
  //     }).then((response) {
  //       if (response.statusCode == 200) {
  //         Fluttertoast.showToast(msg: "Selfie uploaded");
  //         loggedUser!.hasSelfie = true;
  //         return;
  //       } else if (response.statusCode == 413) {
  //         Fluttertoast.showToast(msg: "Unable to send image, file too large!");
  //         return;
  //       } else {
  //         Fluttertoast.showToast(msg: "Unable to send image, please try again");
  //         return;
  //       }
  //     });
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: "Unable to send image, please try again");
  //     return;
  //   }
  // }

  // Future<void> uploadId(String base64) async {
  //   try {
  //     return await http
  //         .post("${Network.domain}/api/upload-document".toUri, headers: {
  //       "Accept": "application/json",
  //       HttpHeaders.authorizationHeader: "Bearer $accessToken"
  //     }, body: {
  //       "document": "data:image/jpg;base64,$base64",
  //     }).then((response) {
  //       if (response.statusCode == 200) {
  //         Fluttertoast.showToast(msg: "Document uploaded");
  //         loggedUser!.hasUploadedId = true;
  //         return;
  //       } else if (response.statusCode == 413) {
  //         Fluttertoast.showToast(msg: "Unable to send image, file too large!");
  //         return;
  //       } else {
  //         Fluttertoast.showToast(msg: "Unable to send image, please try again");
  //         return;
  //       }
  //     });
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: "Unable to send image, please try again");
  //     return;
  //   }
  // }

  Future<void> validateEmail() async {
    try {
      return await http
          .post("${Network.domain}/api/send-to-email".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }).then((response) {
        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "Email sent");
          return;
        }
        Fluttertoast.showToast(
          msg: "Unable to send verification, please try again later.",
        );
        return;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Unable to process your request.");
      return;
    }
  }

  Future<bool> verifyEmailCode(String code) async {
    try {
      return await http
          .post("${Network.domain}/api/verify-email".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken",
      }, body: {
        "code": code,
      }).then((response) {
        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "Email verified");
          return true;
        }
        Fluttertoast.showToast(
            msg: "Unable to validate email with code provided.");
        return false;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Unable to process your request.");
      return false;
    }
  }
}
