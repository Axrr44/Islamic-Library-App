import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:islamiclibrary/services/app_data_pref.dart';
import 'package:islamiclibrary/utilities/utility.dart';
import '../components/custom_textfield.dart';
import '../config/app_colors.dart';
import '../config/app_routes.dart';
import '../services/authentication.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _confirmController = TextEditingController();

  final _nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool isPrivacyCheck = false;

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
                  height: height / 10,
                ),
                Text(
                  AppLocalizations.of(context)!.signInDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20.h,
                ),
                CustomTextField(
                    controller: _nameController,
                    name: AppLocalizations.of(context)!.fullName,
                    prefixIcon: Icons.person_outline,
                    width: width,
                    height: height / 18,
                    inputType: TextInputType.emailAddress),
                CustomTextField(
                    controller: _emailController,
                    name: AppLocalizations.of(context)!.email,
                    prefixIcon: Icons.email_outlined,
                    width: width,
                    height: height / 18,
                    inputType: TextInputType.emailAddress),
                CustomTextField(
                    controller: _passwordController,
                    name: AppLocalizations.of(context)!.password,
                    prefixIcon: Icons.lock_outline,
                    width: width,
                    height: height / 18,
                    obscureText: true,
                    inputType: TextInputType.text),
                CustomTextField(
                    controller: _confirmController,
                    name: AppLocalizations.of(context)!.confirmPassword,
                    prefixIcon: Icons.lock_outline,
                    width: width,
                    height: height / 18,
                    obscureText: true,
                    passowrd: _passwordController.text,
                    inputType: TextInputType.text),
                Row(
                  children: [
                    Checkbox(
                      value: isPrivacyCheck,
                      onChanged: (value) {
                        setState(() {
                          isPrivacyCheck = value!;
                        });
                      },
                      activeColor: AppColor.primary1,
                    ),
                    Flexible(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.black,
                          ),
                          children: [
                            TextSpan(
                              text: AppLocalizations.of(context)!.privacyPolicy,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.black,
                              ),
                            ),
                            const TextSpan(
                              text: ' ',
                            ),
                            TextSpan(
                              text:
                                  AppLocalizations.of(context)!.privacyPolicy2,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColor.primary1,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context)
                                      .pushNamed(AppRoutes.TERMS_PAGE);
                                },
                            ),
                            const TextSpan(
                              text: '  ',
                            ),
                            TextSpan(
                              text:
                                  AppLocalizations.of(context)!.privacyPolicy3,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primary1,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.of(context)
                                      .pushNamed(AppRoutes.PRIVACY_POLICY_PAGE);
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                SizedBox(
                  width: width,
                  height: height / 15,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(isPrivacyCheck
                          ? AppColor.primary1
                          : Colors.grey[350]),
                      foregroundColor:
                          MaterialStateProperty.all(AppColor.white),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.w),
                        ),
                      ),
                    ),
                    onPressed: isPrivacyCheck
                        ? () {
                            if (_formKey.currentState!.validate()) {
                              AuthServices.signUp(
                                context,
                                _nameController.text,
                                _emailController.text,
                                _passwordController.text,
                              );
                            }
                          }
                        : null,
                    child: Text(
                      AppLocalizations.of(context)!.signUp,
                      style: TextStyle(
                          fontSize: 20.sp,
                          fontFamily: Utility.getTextFamily(currentLanguage)),
                    ),
                  ),
                ),
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
                if (Platform.isAndroid)
                  SizedBox(
                      width: width / 2 + 40,
                      height: width / 7,
                      child: ElevatedButton(
                        onPressed: () {
                          AuthServices.signInWithGoogle(context);
                        },
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
                                    text: AppLocalizations.of(context)!
                                        .signInWith,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily: Utility.getTextFamily(
                                          currentLanguage),
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.google,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily: Utility.getTextFamily(
                                          currentLanguage),
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
                if (Platform.isIOS)
                  SizedBox(
                      width: width / 2 + 40,
                      height: width / 7,
                      child: ElevatedButton(
                        onPressed: () {
                          AuthServices.signInWithApple(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/images/apple.png',
                              height: 24.0.w,
                              width: 24.0.w,
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .signInWith,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily: Utility.getTextFamily(
                                          currentLanguage),
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(context)!.apple,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily: Utility.getTextFamily(
                                          currentLanguage),
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
                  height: 30.h,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    AppLocalizations.of(context)!.alreadyHave,
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontFamily: Utility.getTextFamily(currentLanguage)),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.signIn,
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
                      Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.MAIN_ROUTES);
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
