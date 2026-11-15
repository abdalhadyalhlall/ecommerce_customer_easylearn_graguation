import 'package:e_commerce_customer/core/fonts/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class AppTextStyles {
  static const String fontFamily = AppFonts.family;

  static TextStyle _style(double size, FontWeight weight, {double? height}) =>
      TextStyle(
        fontFamily: fontFamily,
        fontSize: size.sp,
        fontWeight: weight,
        height: height,
      );

  static TextStyle get font34Bold => _style(34, FontWeight.w600, height: 1.15);
  static TextStyle get font23Bold => _style(23, FontWeight.w600, height: 1.25);
  static TextStyle get font17Bold => _style(17, FontWeight.w600);
  static TextStyle get font14Normal =>
      _style(14, FontWeight.normal, height: 18 / 14);
  static TextStyle get font14Point4Normal =>
      _style(14.4, FontWeight.normal, height: 18 / 14.4);
  static TextStyle get font11Normal => _style(11.3, FontWeight.normal);
}
