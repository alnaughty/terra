import 'dart:async';
import 'dart:io';
// import 'package:apple_sign_in_safety/apple_sign_in.dart';
// import 'package:apple_sign_in_safety/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleAuthService {
  AppleAuthService._pr();
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final AppleAuthService _instance = AppleAuthService._pr();
  static AppleAuthService get instance => _instance;
  // final AppleSignIn _appleSignIn = AppleSignIn();
  Future signOut() async {
    // await _fbauth.logOut();
    await auth.signOut();
  }

  Future<void> link(User currentUser) async {
    final creds = await credential;
    // if (creds != null) {
    //   currentUser.linkWithCredential(creds);
    // }
  }

  Future<AuthorizationCredentialAppleID?> get credential async {
    try {
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      return credential;
    } catch (e) {
      return null;
    }
    // credential.authorizationCode
  }

  // Future<OAuthCredential?> get credential async {
  //   try {
  //     final result = await AppleSignIn.performRequests([
  //       const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
  //     ]);
  //     switch (result.status) {
  //       case AuthorizationStatus.authorized:
  //         final appleIdCredential = result.credential;
  //         final oAuthProvider = OAuthProvider("apple.com");

  //         final credential = oAuthProvider.credential(
  //           idToken: String.fromCharCodes(
  //               appleIdCredential?.identityToken as Iterable<int>),
  //           accessToken: String.fromCharCodes(
  //               appleIdCredential?.authorizationCode as Iterable<int>),
  //         );
  //         return credential;
  //       case AuthorizationStatus.error:
  //         Fluttertoast.showToast(msg: "${result.error}");
  //         return null;
  //       case AuthorizationStatus.cancelled:
  //         Fluttertoast.showToast(msg: "Sign in cancelled");
  //         return null;
  //       default:
  //         return null;
  //     }
  //   } on SocketException {
  //     Fluttertoast.showToast(msg: "No internet connection");
  //     rethrow;
  //   } on HttpException {
  //     Fluttertoast.showToast(
  //         msg: "An error occurred while trying to connect to server");
  //     return null;
  //   } on FormatException {
  //     Fluttertoast.showToast(msg: "Format Error");
  //     return null;
  //   } on TimeoutException {
  //     Fluttertoast.showToast(msg: "No Internet : connection timeout");
  //     return null;
  //   }
  // }

  Future<User?> signIn() async {
    try {
      // final result = await AppleSignIn.performRequests([
      //   const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      // ]);
      final AuthorizationCredentialAppleID? result = await credential;
      if (result != null) {
        print("RESULT STATE : ${result.state}");
        // final appleIdCredential = result;
        final oAuthProvider = OAuthProvider("apple.com");

        final credential = oAuthProvider.credential(
          idToken: result.identityToken,
          accessToken: result.authorizationCode,
        );
        final authResult = await auth.signInWithCredential(credential);
        final firebaseUser = authResult.user;

        return firebaseUser;
      } else {
        Fluttertoast.showToast(msg: "An error occurred while signing in");
        return null;
      }
      // switch (result.status) {
      //   case AuthorizationStatus.authorized:
      //     final appleIdCredential = result.credential;
      //     final oAuthProvider = OAuthProvider("apple.com");

      //     final credential = oAuthProvider.credential(
      //       idToken: String.fromCharCodes(
      //           appleIdCredential?.identityToken as Iterable<int>),
      //       accessToken: String.fromCharCodes(
      //           appleIdCredential?.authorizationCode as Iterable<int>),
      //     );
      //     final authResult = await auth.signInWithCredential(credential);
      //     final firebaseUser = authResult.user;

      //     return firebaseUser;
      //   case AuthorizationStatus.error:
      //     Fluttertoast.showToast(msg: "${result.error}");
      //     return null;
      //   case AuthorizationStatus.cancelled:
      //     Fluttertoast.showToast(msg: "Sign in cancelled");
      //     return null;
      //   default:
      //     return null;
      // }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: "User not found");
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: "Incorrect Password");
      }
      return null;
    } on SocketException {
      Fluttertoast.showToast(msg: "No Internet Connection");
      return null;
    } on HttpException {
      Fluttertoast.showToast(
          msg: "An error occurred while trying to connect to server");
      return null;
    } on FormatException {
      Fluttertoast.showToast(msg: "Format Error");
      return null;
    } on TimeoutException {
      Fluttertoast.showToast(msg: "No Internet Connection : Timeout");
      return null;
    }
  }
}
