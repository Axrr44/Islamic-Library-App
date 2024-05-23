import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../components/custom_dialog.dart';
import '../config/app_routes.dart';

class AuthServices {
  static final auth = FirebaseAuth.instance;

  static signUp(
      BuildContext context, String name, String email, String password) async {
    try {
      context.loaderOverlay.show();
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
      }
      context.loaderOverlay.hide();
      Navigator.of(context).pushReplacementNamed(AppRoutes.MAIN_ROUTES);
    } on FirebaseAuthException catch (e) {
      context.loaderOverlay.hide();
      if (e.code == 'weak-password') {
        showMessage(context, 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showMessage(context, 'The account already exists for that email.');
      }
    } catch (e) {
      context.loaderOverlay.hide();
      showMessage(context, "An unexpected error occurred");
    }
  }

  static signIn(BuildContext context, String email, String password) async {
    try {
      context.loaderOverlay.show();
      await auth.signInWithEmailAndPassword(email: email, password: password);
      context.loaderOverlay.hide();
      Navigator.of(context).pushReplacementNamed(AppRoutes.MAIN_ROUTES);
    } on FirebaseAuthException catch (e) {
      context.loaderOverlay.hide();
      if (e.code == "wrong-password" || e.code == "user-not-found") {
        showMessage(context, "Invalid email or password");
      } else {
        showMessage(context, e.message.toString());
      }
    } catch (e) {
      context.loaderOverlay.hide();
      showMessage(context, "An unexpected error occurred");
    }
  }

  static signOut(BuildContext context) async {
    context.loaderOverlay.show();
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      await auth.signOut();
      await googleSignIn.disconnect();
      Navigator.of(context).pushReplacementNamed(AppRoutes.SGIN_IN_ROUTES);
    } catch (e) {
      ///Catch error
    }
    context.loaderOverlay.hide();
  }

  static passwordReset(BuildContext context, String email) async {
    context.loaderOverlay.show();
    try {
      await auth.sendPasswordResetEmail(email: email);
      context.loaderOverlay.hide();
      customDialog(context, AppLocalizations.of(context)!.messageDialogPR);
    } on FirebaseAuthException catch (e) {
      context.loaderOverlay.hide();
      customDialog(context, e.message.toString());
    }
  }

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  static showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      message,
      style: TextStyle(fontSize: 20.sp),
    )));
  }
}
