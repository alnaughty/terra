import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FacebookAuthService {
  FacebookAuthService._pr();
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final FacebookAuthService _instance = FacebookAuthService._pr();
  static FacebookAuthService get instance => _instance;
  static final FacebookAuth _fbauth = FacebookAuth.instance;

  Future<void> signOut() async {
    await _fbauth.logOut();
    auth.signOut();
  }

  Future<User?> signIn() async {
    try {
      final LoginResult result = await _fbauth.login(
        permissions: ['public_profile', 'email'],
      );
      switch (result.status) {
        case LoginStatus.success:
          final facebookCredential =
              FacebookAuthProvider.credential(result.accessToken!.token);
          final authResult =
              await auth.signInWithCredential(facebookCredential);
          final firebaseUser = authResult.user;
          return firebaseUser;
        case LoginStatus.cancelled:
          Fluttertoast.showToast(msg: "Connection canceled".toUpperCase());
          return null;
        case LoginStatus.failed:
          Fluttertoast.showToast(msg: "Authorization refused".toUpperCase());
          return null;
        default:
          return null;
      }
    } on SocketException {
      Fluttertoast.showToast(msg: "Pas de connexion Internet");
      rethrow;
    } on HttpException {
      Fluttertoast.showToast(
          msg:
              "Une erreur s'est produite lors de l'exécution de cette opération");
      return null;
    } on FormatException {
      Fluttertoast.showToast(msg: "Erreur de format");
      return null;
    } on TimeoutException {
      Fluttertoast.showToast(msg: "Pas de connexion Internet : timeout");
      return null;
    }
  }

  Future<OAuthCredential?> get fbCredential async {
    try {
      final LoginResult result = await _fbauth.login(
        permissions: ['public_profile', 'email'],
      );
      switch (result.status) {
        case LoginStatus.success:
          final facebookCredential =
              FacebookAuthProvider.credential(result.accessToken!.token);
          return facebookCredential;
        case LoginStatus.cancelled:
          Fluttertoast.showToast(msg: "Connection canceled".toUpperCase());
          return null;
        case LoginStatus.failed:
          Fluttertoast.showToast(msg: "Authorization refused".toUpperCase());
          return null;
        default:
          return null;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: "User not found");
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: "Incorrect Password");
      } else if (e.code == "account-exists-with-different-credential") {
        // link with google

        Fluttertoast.showToast(
          msg: "Account already exist, try with different credentials",
        );
      } else {
        Fluttertoast.showToast(msg: e.code);
      }

      return null;
    } on SocketException {
      Fluttertoast.showToast(msg: "No Internet Connection");
      rethrow;
    } on HttpException {
      Fluttertoast.showToast(
          msg: "An error has occurred while trying to connect to server");
      return null;
    } on FormatException {
      Fluttertoast.showToast(msg: "Format error");
      return null;
    } on TimeoutException {
      Fluttertoast.showToast(msg: "No Internet Connection : Timeout");
      return null;
    }
  }
}
