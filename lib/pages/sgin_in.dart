import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:freelancer/utilities/constants.dart';
import '../components/custom_textfield.dart';
import '../config/app_colors.dart';
import '../config/app_routes.dart';
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
                  height: height / 5,
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
                      fontFamily: Constants.getTextFamily(currentLanguage)),
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
                            fontFamily: Constants.getTextFamily(currentLanguage)))),
                SizedBox(
                  height: height / 20,
                ),
                Text(
                  AppLocalizations.of(context)!.signInFG,
                  style:
                      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: height / 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width / 7,
                      height: width / 7,
                      child: IconButton(
                        onPressed: () {
                          AuthServices.signInWithGoogle();
                        },
                        icon: SvgPicture.asset('assets/images/google-icon.svg'),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.grey.withOpacity(0.2))),
                      ),
                    ),
                    SizedBox(
                      width: width / 10,
                    ),
                    SizedBox(
                      width: width / 7,
                      height: width / 7,
                      child: IconButton(
                        padding: EdgeInsets.all(12.w),
                        onPressed: () {},
                        icon: SvgPicture.asset(
                            'assets/images/facebook-official.svg'),
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Colors.grey.withOpacity(0.2))),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: height / 10,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    AppLocalizations.of(context)!.dontHaveAccount,
                    style: TextStyle(fontSize: 15.sp,fontFamily: Constants.getTextFamily(currentLanguage),
                    fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.SGIN_UP_ROUTES);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.signUp,
                        style: TextStyle(
                          fontFamily: Constants.getTextFamily(currentLanguage),
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primary2),
                      ))
                ])
              ]),
        ),
      ),
    );
  }
}
