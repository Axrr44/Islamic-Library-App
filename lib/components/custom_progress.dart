import 'dart:ui';

import 'package:flutter/material.dart';

import '../config/app_colors.dart';

Widget customProgress() {
  return BackdropFilter(
    filter: ImageFilter.blur(
      sigmaX: 4.5,
      sigmaY: 4.5,
    ),
    child: const Center(
      child: CircularProgressIndicator(color: AppColor.primary1),
    ),
  );
}
