import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freelancer/utilities/utility.dart';
import '../components/custom_textfield.dart';
import '../config/app_colors.dart';
import '../services/authentication.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SignUp extends StatelessWidget {
  SignUp({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameController = TextEditingController();
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
                  height: height / 4,
                ),
                CustomTextField(
                    controller: _nameController,
                    name: AppLocalizations.of(context)!.fullName,
                    prefixIcon: Icons.person_outline,
                    width: width,
                    height: height / 13,
                    inputType: TextInputType.emailAddress),
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
                CustomTextField(
                    controller: _confirmController,
                    name: AppLocalizations.of(context)!.confirmPassword,
                    prefixIcon: Icons.lock_outline,
                    width: width,
                    height: height / 13,
                    obscureText: true,
                    passowrd: _passwordController.text,
                    inputType: TextInputType.text),
                SizedBox(
                  height: height / 50,
                ),
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
                        AuthServices.signUp(context, _nameController.text,
                            _emailController.text, _passwordController.text);
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.signUp,
                      style: TextStyle(fontSize: 20.sp,fontFamily: Utility.getTextFamily(currentLanguage)),
                    ),
                  ),
                ),
                SizedBox(
                  height: height / 5,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    AppLocalizations.of(context)!.alreadyHave,
                    style: TextStyle(fontSize: 15.sp,fontFamily: Utility.getTextFamily(currentLanguage)),
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
                ])
              ]),
        ),
      ),
    );
  }
}
