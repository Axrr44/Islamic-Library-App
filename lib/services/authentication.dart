import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../components/custom_dialog.dart';
import '../config/app_colors.dart';
import '../config/app_routes.dart';


class AuthServices {
  static final auth = FirebaseAuth.instance;
  static final GoogleSignIn googleSignIn = GoogleSignIn();


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
      Navigator.of(context).pushReplacementNamed(AppRoutes.SIGN_IN_ROUTES);
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

  static Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return null;
      context.loaderOverlay.show();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        context.loaderOverlay.hide();
        Navigator.of(context).pushReplacementNamed(AppRoutes.MAIN_ROUTES);
      }

      return userCredential;
    } catch (e) {
      context.loaderOverlay.hide();
      print('Error signing in with Google: $e');
      return null;
    }
  }

  static Future<UserCredential?> signInWithApple(BuildContext context) async {
    try {
      context.loaderOverlay.show();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final appleCredential = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      UserCredential userCredential = await auth.signInWithCredential(appleCredential);

      if (userCredential.user != null) {
        context.loaderOverlay.hide();
        Navigator.of(context).pushReplacementNamed(AppRoutes.MAIN_ROUTES);
      }

      return userCredential;
    } catch (e) {
      context.loaderOverlay.hide();
      print('Error signing in with Apple: $e');
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

  static User? getCurrentUser() {
    return auth.currentUser;
  }

  static Future<Map<String, dynamic>?> fetchUserInfo() async {
    User? user = getCurrentUser();
    if (user != null) {
      String name = user.displayName ?? '';
      String email = user.email ?? '';
      String uid = user.uid;

      return {
        'name': name,
        'email': email,
        'uid': uid,
      };
    }
    return null;
  }

  static Future<bool> deleteAccount(BuildContext context) async {
    final user = auth.currentUser;
    if (user != null) {
      try {
        context.loaderOverlay.show();

        final userInfo = user.providerData[0];
        if (userInfo.providerId == 'google.com') {
          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
          if (googleUser != null) {
            final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
            final AuthCredential credential = GoogleAuthProvider.credential(
              idToken: googleAuth.idToken,
              accessToken: googleAuth.accessToken,
            );

            await user.reauthenticateWithCredential(credential);
          } else {
            context.loaderOverlay.hide();
            showMessage(context, "Re-authentication failed. Please try again.");
            return false;
          }
        } else if (userInfo.providerId == 'password') {
          final password = await _getPasswordFromUser(context);
          if (password == null) {
            context.loaderOverlay.hide();
            showMessage(context, "Re-authentication failed. Please try again.");
            return false;
          }

          final AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );

          await user.reauthenticateWithCredential(credential);
        }

        await user.delete();
        context.loaderOverlay.hide();

        if (userInfo.providerId == 'google.com') {
          googleSignIn.disconnect();
        }

        return true;

      } catch (e) {
        context.loaderOverlay.hide();
        showMessage(context, "An unexpected error occurred while deleting the account");
        print("Error: $e");
        return false;
      }
    }
    return false;
  }

  static Future<String?> _getPasswordFromUser(BuildContext context) async {
    String? password;
    await showDialog<String?>(
      context: context,
      builder: (context) {
        final TextEditingController passwordController = TextEditingController();
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.reEnterPassword,
            style: TextStyle(fontSize: 20.sp),
          ),
          content: Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.password,
              ),
            ),
          ),
          actions: <Widget>[
            Center( // Center the Row
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.grey),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.w),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(AppColor.primary1),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.w),
                        ),
                      ),
                    ),
                    onPressed: () {
                      password = passwordController.text;
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      AppLocalizations.of(context)!.confirm,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
    return password;
  }

  static Future<bool> isSignedInWithGoogle() async {
    User? user = auth.currentUser;
    if (user != null) {
      for (var userInfo in user.providerData) {
        if (userInfo.providerId == 'google.com') {
          return true;
        }
      }
    }
    return false;
  }

}

