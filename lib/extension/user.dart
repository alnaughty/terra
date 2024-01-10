import 'package:terra/models/user_details.dart';
import 'package:terra/models/v2/terran.dart';

extension SecurityLevel on UserDetails {
  String get toSecurityName {
    // int lvl = toSecurityLvl;
    // print(lvl);
    return "Fully Verified";
    // if (lvl == 0) {
    //   return "Unverified";
    // } else if (lvl == 1) {
    //   return "Partially Verified";
    // } else if (lvl <= 3) {
    //   return "Semi-verified";
    // } else {
    //   return "Fully Verified";
    // }
  }

  int get toSecurityLvl {
    int lvl = 0;
    if (hasUploadedId) {
      lvl += 1;
    }
    if (hasVerifiedEmail) {
      lvl += 1;
    }
    if (hasVerifiedNumber) {
      lvl += 1;
    }
    if (hasSelfie) {
      lvl += 1;
    }
    return lvl;
  }
}

extension SecurityTerranLevel on Terran {
  String get toSecurityName {
    // int lvl = toSecurityLvl;
    return "Fully Verified";
    // if (lvl == 0) {
    //   return "Unverified";
    // } else if (lvl == 1) {
    //   return "Partially Verified";
    // } else if (lvl <= 3) {
    //   return "Semi-verified";
    // } else {
    //   return "Fully Verified";
    // }
  }

  int get toSecurityLvl {
    int lvl = 0;
    if (hasUploadedId) {
      lvl += 1;
    }
    if (hasVerifiedEmail) {
      lvl += 1;
    }
    if (hasVerifiedNumber) {
      lvl += 1;
    }
    return lvl;
  }
}
