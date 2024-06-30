import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._pr();
  static final GoogleAuthService _instance = GoogleAuthService._pr();
  static GoogleAuthService get instance => _instance;
  static final FirebaseAuth auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    auth.signOut();
  }

  Future<User?> signIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        _handleGetContact(googleUser);
        final GoogleSignInAuthentication? googleAuth =
            await googleUser.authentication;
        if (googleAuth != null) {
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final authResult = await auth.signInWithCredential(credential);
          final firebaseUser = authResult.user;
          // firebaseUser.delete();
          return firebaseUser;
        }
        return null;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(msg: "User not found");
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(msg: "Incorrect Password");
      } else if (e.code == "account-exists-with-different-credential") {
        Fluttertoast.showToast(
            msg: "Account already exists with different credential");
      }
      return null;
    } on SocketException {
      Fluttertoast.showToast(msg: "No Internet Connection");
      return null;
    } on HttpException catch (e, s) {
      print("ERROR : $e");
      print("TRACE : $s");
      Fluttertoast.showToast(
          msg: "An error has occurred while processing your request.");
      return null;
    } on FormatException {
      Fluttertoast.showToast(msg: "Format Error");
      return null;
    } on TimeoutException {
      Fluttertoast.showToast(msg: "No Internet Connection : Timeout");
      return null;
    } catch (e, s) {
      print("SIGNIN ERROR : $e");
      print("STACK : $s");
    }
  }

  Future<void> _handleGetContact(GoogleSignInAccount user) async {
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      return;
    }
  }
}
