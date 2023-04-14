import 'package:terra/models/user_details.dart';
import 'package:terra/models/v2/terran.dart';

extension SecurityLevel on UserDetails {
  String get toSecurityName {
    int lvl = toSecurityLvl;
    if (lvl == 0) {
      return "Unverified";
    } else if (lvl == 1) {
      return "Lowly Secured";
    } else if (lvl == 2) {
      return "Mildy Secured";
    } else {
      return "Fully Secured";
    }
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

extension SecurityTerranLevel on Terran {
  String get toSecurityName {
    int lvl = toSecurityLvl;
    if (lvl == 0) {
      return "Unverified";
    } else if (lvl == 1) {
      return "Lowly Secured";
    } else if (lvl == 2) {
      return "Mildy Secured";
    } else {
      return "Fully Secured";
    }
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
