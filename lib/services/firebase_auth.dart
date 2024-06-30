import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:terra/extension/string_extensions.dart';
import 'package:terra/services/data_cacher.dart';
import 'package:terra/utils/global.dart';

class FirebaseAuthenticator {
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static final DataCacher _cacher = DataCacher.instance;
  Future<void> logout() async {
    try {
      return await auth.signOut();
    } on SocketException {
      Fluttertoast.showToast(msg: "No internet connection");
      return;
    } on HttpException {
      Fluttertoast.showToast(
          msg: "An unexpected error occurred while processing the request");
      return;
    } on FormatException catch (e) {
      Fluttertoast.showToast(msg: "Format error : $e");
      return;
    } on TimeoutException {
      Fluttertoast.showToast(msg: "No internet connection : timeout");
      return;
    }
  }

  Future<bool> confirmPasswordReset(
      {required String code, required String newPassword}) async {
    try {
      await auth.confirmPasswordReset(code: code, newPassword: newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendForgotPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> changePassword(String password) async {
    try {
      if (auth.currentUser == null) {
        Fluttertoast.showToast(msg: "No associated account, please re-login");
        return;
      }
      await auth.currentUser!.updatePassword(password);
      final credential = EmailAuthProvider.credential(
        email: auth.currentUser!.email!,
        password: password,
      );
      await auth.currentUser!.reauthenticateWithCredential(credential);
      Fluttertoast.showToast(msg: "Password Updated");
      return;
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
          msg: e.code.replaceAll("-", " ").capitalizeWords());
    } catch (e) {
      return;
    }
  }

  /// Login to firebase only!
  Future<String?> loginViaEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final authResult = await auth.signInWithCredential(credential);
      final User? firebaseUser = authResult.user;
      if (firebaseUser != null) return await firebaseUser.getIdToken();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: "User not registered");
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: "Incorrect password");
      } else if (e.code == "email-already-in-use") {
        Fluttertoast.showToast(msg: "Email already used");
      } else if (e.code == "") {}
      print(e.code);
      return null;
    } on SocketException {
      Fluttertoast.showToast(msg: "No internet connection");
      return null;
    } on HttpException {
      Fluttertoast.showToast(
          msg: "An unexpected error occurred while processing the request");
      return null;
    } on FormatException catch (e) {
      Fluttertoast.showToast(msg: "Format error : $e");
      return null;
    } on TimeoutException {
      Fluttertoast.showToast(msg: "No internet connection : timeout");
      return null;
    }
  }

  ///Register account to firebase
  ///
  Future<String?> registerViaEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential creds = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (creds.user != null) {
        final User? firebaseUser = creds.user;
        if (firebaseUser == null) return null;
        // if (firebaseUser != null) return firebaseUser.uid;
        await _cacher.setUnsavedCreds([
          firebaseUser.displayName ?? "",
          "",
          firebaseUser.phoneNumber ?? "",
          firebaseUser.email ?? "",
          firebaseUser.uid
        ]);
        // await creds.user!.updateDisplayName(fullname);
        // await creds.user!.updatePhoneNumber(PhoneAuthProvider.credential(
        //     verificationId: verificationId, smsCode: smsCode));

        return firebaseUser.uid;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: "User not registered");
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: "Incorrect password");
      } else if (e.code == "email-already-in-use") {
        Fluttertoast.showToast(msg: "Email already used");
      } else if (e.code == "invalid-email") {
        Fluttertoast.showToast(
          msg: "Invalid email format, try another.",
          toastLength: Toast.LENGTH_LONG,
        );
      } else if (e.code == "weak-password") {
        Fluttertoast.showToast(
          msg: "Password too weak",
        );
      }
      return null;
    } on SocketException {
      Fluttertoast.showToast(msg: "Pas de connexion Internet");
      return null;
    } on HttpException {
      Fluttertoast.showToast(
          msg: "An error occurred while processing your request");
      return null;
    } on FormatException {
      Fluttertoast.showToast(msg: "Format Error");
      return null;
    } on TimeoutException {
      Fluttertoast.showToast(msg: "No internet connection : Timeout");
      return null;
    }
  }
}
