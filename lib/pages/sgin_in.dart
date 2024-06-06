import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:freelancer/utilities/utility.dart';
import '../components/custom_textfield.dart';
import '../config/app_colors.dart';
import '../config/app_routes.dart';
import '../services/app_data_pref.dart';
import '../services/authentication.dart';

class SignIn extends StatelessWidget {
  SignIn({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    String currentLanguage = Localizations.localeOf(context).languageCode;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: width / 20),
        child: Form(
          key: _formKey,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: height / 8,
                ),
                Text(AppLocalizations.of(context)!.signInDescription,
                    textAlign: TextAlign.center,style:
                  TextStyle(fontSize: 15.sp,color: Colors.black),),
                SizedBox(
                  height: height / 10 - 20.h,
                ),
                CustomTextField(
                    controller: _emailController,
                    name: AppLocalizations.of(context)!.email,
                    prefixIcon: Icons.email_outlined,
                    width: width,
                    height: height / 13,
                    inputType: TextInputType.emailAddress),
                CustomTextField(
                    controller: _passwordController,
                    name: AppLocalizations.of(context)!.password,
                    prefixIcon: Icons.lock_outline,
                    width: width,
                    height: height / 13,
                    obscureText: true,
                    inputType: TextInputType.text),
                SizedBox(
                  width: width,
                  height: height / 15,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(AppColor.primary1),
                      foregroundColor:
                      MaterialStateProperty.all(AppColor.white),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.w),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        AuthServices.signIn(context, _emailController.text,
                            _passwordController.text);
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.signIn,
                      style: TextStyle(fontSize: 20.sp,
                      fontFamily: Utility.getTextFamily(currentLanguage)),
                    ),
                  ),
                ),
                SizedBox(
                  height: height / 25,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(AppRoutes.PASSWORD_RESET_ROUTES);
                    },
                    child: Text(AppLocalizations.of(context)!.forgetPassword,
                        style:
                            TextStyle(fontSize: 15.sp, color: AppColor.black,
                            fontFamily: Utility.getTextFamily(currentLanguage)))),
                SizedBox(
                  height: 20.h,
                ),
                Text(
                  AppLocalizations.of(context)!.signInFG,
                  style:
                  TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20.h,
                ),
                if(Platform.isAndroid)
                  SizedBox(
                    width: width / 2 + 40,
                    height: width / 7,
                    child: ElevatedButton(
                      onPressed: () {
                        AuthServices.signInWithGoogle(context);
                      }
                          ,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SvgPicture.asset(
                            'assets/images/google-icon.svg',
                            height: 24.0.w,
                            width: 24.0.w,
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                  AppLocalizations.of(context)!.signInWith,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontFamily:
                                    Utility.getTextFamily(currentLanguage),
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context)!.google,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontFamily:
                                    Utility.getTextFamily(currentLanguage),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                if(Platform.isIOS)
                  SizedBox(
                      width: width / 2 + 40,
                      height: width / 7,
                      child: ElevatedButton(
                        onPressed: () {
                          AuthServices.signInWithApple(context);
                        }
                        ,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(
                              'assets/images/apple.png',
                              height: 24.0.w,
                              width: 24.0.w,
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                    AppLocalizations.of(context)!.signInWith,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily:
                                      Utility.getTextFamily(currentLanguage),
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.apple,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily:
                                      Utility.getTextFamily(currentLanguage),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                SizedBox(
                  height: height / 15
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    AppLocalizations.of(context)!.dontHaveAccount,
                    style: TextStyle(fontSize: 15.sp,fontFamily: Utility.getTextFamily(currentLanguage),
                    fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.SIGN_UP_ROUTES);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.signUp,
                        style: TextStyle(
                          fontFamily: Utility.getTextFamily(currentLanguage),
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primary2),
                      ))
                ]),
                SizedBox(
                  height: 10.h,
                ),
                TextButton(
                    onPressed: () {
                      AppDataPreferences.setIsGuest(true);
                      Navigator.of(context).pushReplacementNamed(AppRoutes.MAIN_ROUTES);
                    },
                    child: Text(
                      AppLocalizations.of(context)!.guest,
                      style: TextStyle(
                          fontFamily: Utility.getTextFamily(currentLanguage),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primary2),
                    ))
              ]),
        ),
      ),
    );
  }
}
