import 'colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppStyles {
  static TextStyle font18Black600Weight = TextStyle(
    color: AppColors.mainBlack,
    fontWeight: FontWeight.w600,
    fontSize: 18.sp,
  );
  static TextStyle font12Black400Weight = TextStyle(
    color: AppColors.mainBlack,
    fontWeight: FontWeight.w400,
    fontSize: 12.sp,
  );
  static TextStyle font14Black400Weight = TextStyle(
      fontSize: 14.sp, color: AppColors.mainBlack, fontWeight: FontWeight.w400);
  static TextStyle font15Black500Weight = TextStyle(
      fontSize: 15.sp, color: AppColors.mainBlack, fontWeight: FontWeight.w500);

  static TextStyle font25BlackBold = TextStyle(
      fontSize: 25.sp, color: AppColors.mainBlack, fontWeight: FontWeight.bold);

  static TextStyle font14Grey600Weight = TextStyle(
      fontSize: 14.sp, color: AppColors.mainGrey, fontWeight: FontWeight.w600);

  static TextStyle font10GreySemiBold = TextStyle(
      fontSize: 10.sp,
      color: AppColors.mediumGrey,
      fontWeight: FontWeight.w600);
  static TextStyle font11GreySemiBold = TextStyle(
      fontSize: 11.sp,
      color: AppColors.mediumGrey,
      fontWeight: FontWeight.w600);
  static TextStyle font12DarkGrey500Weight = TextStyle(
      fontSize: 12.sp, color: AppColors.darkGrey, fontWeight: FontWeight.w500);

  static TextStyle font20GreyBold = TextStyle(
      fontSize: 20.sp,
      color: AppColors.mediumGrey,
      fontWeight: FontWeight.bold);

  static TextStyle font25GreyBold = TextStyle(
      fontSize: 25.sp,
      color: AppColors.mediumGrey,
      fontWeight: FontWeight.bold);

  static TextStyle font15White500Weight = TextStyle(
      fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w500);

  static TextStyle font10WhiteBold = TextStyle(
      fontSize: 10.sp, color: Colors.white, fontWeight: FontWeight.bold);
}
