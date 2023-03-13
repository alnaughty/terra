import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/models/applicant.dart';
import 'package:terra/models/job.dart';
import 'package:terra/models/job_offer.dart';
import 'package:terra/utils/global.dart';
import 'package:terra/utils/network.dart';
import 'package:http/http.dart' as http;

class OfferApi {
  Future<bool> updateOfferStatus(int offerId, {required int status}) async {
    try {
      return await http.put(
          "${Network.domain}/api/offer/$offerId/update-status".toUri,
          headers: {
            "Accept": "application/json",
            HttpHeaders.authorizationHeader: "Bearer $accessToken"
          },
          body: {
            "status": "$status",
          }).then((response) {
        print(response.statusCode);
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

  Future<List<JobOffer>?> getJobOffers() async {
    try {
      return await http.get("${Network.domain}/api/offers".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }).then((response) {
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          final List res = data['data'];
          return res.map((e) => JobOffer.fromJson(e)).toList();
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

  Future<List<Applicant>?> getApplicants() async {
    try {
      return await http.get("${Network.domain}/api/offers".toUri, headers: {
        "Accept": "application/json",
        HttpHeaders.authorizationHeader: "Bearer $accessToken"
      }).then((response) {
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          final List res = data['data'];
          return res.map((e) => Applicant.fromJson(e)).toList();
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

  // Future<Offer<List>?> getOffers() async {
  //   try {
  //     return await http.get("${Network.domain}/api/offers".toUri, headers: {
  //       "Accept": "application/json",
  //       HttpHeaders.authorizationHeader: "Bearer $accessToken"
  //     }).then((response) {
  //       if (response.statusCode == 200) {
  //         var data = json.decode(response.body);
  //         final List res = data['data'];
  //         if (loggedUser!.accountType == 1) {
  //           return Offer<List<Job>>(
  //               value: );
  //         } else {
  //           return Offer<List<UserDetails>>(
  //               value: res.map((e) => UserDetails.fromJson(e)).toList());
  //         }
  //       }
  //       Fluttertoast.showToast(
  //         msg: "An error occurred while processing, please contact developer",
  //       );
  //       return null;
  //     });
  //   } catch (e, s) {
  //     print("ERROR : $e $s");
  //     Fluttertoast.showToast(
  //       msg: "An unexpected error occurred while processing.",
  //     );
  //     return null;
  //   }
  // }

  Future<bool> hireJobseeker({
    required int jobseekerId,
    required int skillId, // category id,
    DateTime? startdate,
    int duration = 3,
    double? rate,
    String? message,
  }) async {
    try {
      Map<String, dynamic> body = {
        "recruitee_id": "$jobseekerId",
        "category_id": "$skillId",
        "duration": "$duration",
      };
      if (startdate != null) {
        body.addAll({"expected_start_date": startdate.toString()});
      }
      if (rate != null) {
        body.addAll({"rate": rate.toString()});
      }
      if (message != null) {
        body.addAll({
          "message": message,
        });
      }
      return await http
          .post(
        "${Network.domain}/api/offers".toUri,
        headers: {
          "Accept": "application/json",
          HttpHeaders.authorizationHeader: "Bearer $accessToken"
        },
        body: body,
      )
          .then((response) {
        print(response.statusCode);
        // var data = json.decode(response.body);
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
}
