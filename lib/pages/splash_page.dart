import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freelancer/config/app_colors.dart';
import 'package:freelancer/services/app_data_pref.dart';
import '../config/app_routes.dart';
import '../services/authentication.dart';

class SplashScreenPage extends StatelessWidget {
  const SplashScreenPage({super.key});

  Future<void> _checkAuthentication(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3));
    User? user = AuthServices.getCurrentUser();
    bool isGuest= await AppDataPreferences.getIsGuest();

    if (await AppDataPreferences.getShowViewPager()) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.VIEW_PAGER_ROUTES);
    } else if (user == null) {
      if(isGuest)
        {
          Navigator.of(context).pushReplacementNamed(AppRoutes.MAIN_ROUTES);
        }else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.SIGN_IN_ROUTES);
      }
    } else{
      Navigator.of(context).pushReplacementNamed(AppRoutes.MAIN_ROUTES);
    }
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: SvgPicture.asset(
        'assets/images/Islamic_library.svg',
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcATop),
      ),
      splashIconSize: 300.w,
      duration: 3000,
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: AppColor.primary1,
      nextScreen: FutureBuilder<void>(
        future: _checkAuthentication(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColor.primary1),
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }


}
