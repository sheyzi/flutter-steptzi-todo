import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:steptzi_todo/pages/home.dart';
import 'package:steptzi_todo/pages/signin_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthClass {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        try {
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(credential);
          await storeTokenAndData(userCredential);
          Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              child: Home(),
            ),
            (route) => false,
          );
        } on FirebaseAuthException catch (e) {
          final SnackBar snackBar = SnackBar(
            content: Text("${e.message}"),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } catch (e) {
          final SnackBar snackBar = SnackBar(
            content: Text(e.toString()),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        const SnackBar snackBar = SnackBar(
          content:
              Text("Couldn't sign you in with Google... Please try again!"),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on FirebaseAuthException catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text("${e.message}"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text(e.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await removeTokenAndData();
      Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            type: PageTransitionType.fade,
            child: SignInPage(),
          ),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text("${e.message}"),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      final SnackBar snackBar = SnackBar(
        content: Text(e.toString()),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> storeTokenAndData(UserCredential userCredential) async {
    const FlutterSecureStorage storage = FlutterSecureStorage();

    await storage.write(
      key: "token",
      value: userCredential.credential!.token.toString(),
    );

    await storage.write(
      key: "userCredential",
      value: userCredential.toString(),
    );
  }

  Future<void> removeTokenAndData() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();
    storage.delete(key: "token");
    storage.delete(key: "userCredential");
  }

  Future<String?> getToken() async {
    const FlutterSecureStorage storage = FlutterSecureStorage();

    return await storage.read(key: "token");
  }
}
