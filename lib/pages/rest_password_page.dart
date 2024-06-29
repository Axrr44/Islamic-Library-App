import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../components/custom_textfield.dart';
import '../config/app_colors.dart';
import '../services/authentication.dart';

class RestPasswordPage extends StatelessWidget {
  RestPasswordPage({super.key});

  final _emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: width / 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.textOfResetPassword,
                style: TextStyle(fontSize: 20.sp, color: AppColor.black),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: height / 20,
              ),
              CustomTextField(
                  controller: _emailController,
                  name: AppLocalizations.of(context)!.email,
                  prefixIcon: Icons.email_outlined,
                  width: width,
                  height: height / 13,
                  inputType: TextInputType.emailAddress),
              SizedBox(
                width: width,
                height: height / 15,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                    WidgetStateProperty.all(AppColor.primary1),
                    foregroundColor: WidgetStateProperty.all(AppColor.white),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      AuthServices.passwordReset(
                          context, _emailController.text);
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.resetPassword,
                    style: TextStyle(fontSize: 20.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
