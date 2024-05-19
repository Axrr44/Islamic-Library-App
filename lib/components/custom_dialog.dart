import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void customDialog(BuildContext context, String msg) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            msg,
            style: TextStyle(fontSize: 20.sp),
          ),
        );
      });
}
