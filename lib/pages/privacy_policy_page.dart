import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w,vertical: 10.h),
          child: Text.rich(
        TextSpan(
        children: [
          TextSpan(
          text: AppLocalizations.of(context)!.titleOfPrivacyPolicy,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.sp),
        ),
        TextSpan(
          text: AppLocalizations.of(context)!.contentOfPrivacyPolicy,
          style: TextStyle(fontSize: 15.sp),
        ),
        ],
      ),
    ),
        ),
      ),
    );
  }



}