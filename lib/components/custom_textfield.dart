import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:islamiclibrary/utilities/utility.dart';
import '../config/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String name;
  final IconData prefixIcon;
  final bool obscureText;
  final String passowrd;
  final TextCapitalization textCapitalization;
  final TextInputType inputType;
  final double width;
  final double height;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.name,
    required this.prefixIcon,
    this.obscureText = false,
    this.passowrd = "",
    required this.width,
    required this.height,
    this.textCapitalization = TextCapitalization.none,
    required this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    String currentLanguage = Localizations.localeOf(context).languageCode;
    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.only(bottom: height / 4),
      child: SizedBox(
        child: TextFormField(
          validator: (value) => validate(context, name, value, passowrd),
          enabled: true,
          controller: controller,
          textCapitalization: textCapitalization,
          maxLength: 32,
          maxLines: 1,
          obscureText: obscureText,
          keyboardType: inputType,
          textAlign: TextAlign.start,
          style: TextStyle(
              color: Colors.black,
              fontSize: 16.sp,
              fontFamily: Utility.getTextFamily(currentLanguage)),
          decoration: InputDecoration(
            prefixIcon: Icon(
              prefixIcon,
              size: 18.h,
            ),
            isDense: true,
            labelText: name,
            counterText: "",
            labelStyle: TextStyle(
                color: AppColor.black,
                fontSize: 16.sp,
                fontFamily: Utility.getTextFamily(currentLanguage)),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.black),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.black),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ),
    );
  }

  validate(BuildContext context, String name, String? value, String password) {
    if (name == 'Email') {
      if (value == null || value.isEmpty) {
        return "Please enter your email";
      } else if (!isEmailValid(value)) {
        return "Please enter a valid email";
      }
    } else if (name == "Full name") {
      if (value == null || value.isEmpty) {
        return "Please enter your name";
      }
    } else if (name == "Password") {
      if (value == null || value.isEmpty) {
        return "Please enter your password";
      } else if (value.length < 8) {
        return "password can't be less than 8 characters";
      }
    } else if (name == "Confirm Password") {
      if (value == null || value.isEmpty) {
        return "Please enter your confirm password";
      } else if (value != password) {
        return "Passwords do not match";
      }
    }
  }

  bool isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
