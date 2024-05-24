import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/services/app_data_pref.dart';
import '../config/app_routes.dart';
import '../services/authentication.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  Future<void> _checkAuthentication(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3));
    User? user = AuthServices.getCurrentUser();
    if(await AppDataPreferences.getShowViewPager())
      {
        Navigator.of(context).pushReplacementNamed(AppRoutes.VIEW_PAGER_ROUTES);
      }
    if (user == null) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.SGIN_IN_ROUTES);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.MAIN_ROUTES);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: 'assets/images/quran.png',
      splashIconSize: 300.w,
      duration: 3000,
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.white,
      nextScreen: FutureBuilder(
        future: _checkAuthentication(context),
        builder: (context, snapshot) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}
