import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDimensions {
  /* ***************  Padding  ***************** */
  static EdgeInsetsGeometry paddingSymmetricV14H10 =
      EdgeInsetsDirectional.symmetric(vertical: 14.h, horizontal: 10.w);
  static EdgeInsetsGeometry paddingSymmetricV12H12 =
      EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 12.h);
  static EdgeInsetsGeometry paddingTop12 =
      EdgeInsetsDirectional.only(top: 12.h);
  static EdgeInsetsGeometry paddingTop13 =
      EdgeInsetsDirectional.only(top: 13.h);
  static EdgeInsetsGeometry paddingBottom10 =
      EdgeInsetsDirectional.only(bottom: 10.h);
  static EdgeInsetsGeometry paddingTop50 =
      EdgeInsetsDirectional.only(top: 50.h);
  static EdgeInsetsGeometry paddingBottom100Top50 =
      EdgeInsetsDirectional.only(bottom: 100.h, top: 50.h);
  static EdgeInsetsGeometry paddingSymmetricV50H50 =
      EdgeInsetsDirectional.symmetric(horizontal: 50.w, vertical: 50.h);
  static EdgeInsetsGeometry paddingSymmetricV25H100 =
      EdgeInsetsDirectional.symmetric(horizontal: 100.w, vertical: 25.h);
  static EdgeInsetsGeometry paddingHorizontal5 =
      EdgeInsetsDirectional.symmetric(
    horizontal: 5.w,
  );

  /* *************** Vertical Sized Box  ***************** */
  static SizedBox verticalSpacing20 = SizedBox(
    height: 20.h,
  );
  static SizedBox verticalSpacing5 = SizedBox(
    height: 5.h,
  );
  static SizedBox verticalSpacing16 = SizedBox(
    height: 16.h,
  );
  static SizedBox verticalSpacing10 = SizedBox(
    height: 10.h,
  );
  static SizedBox verticalSpacing50 = SizedBox(
    height: 50.h,
  );
  static SizedBox verticalSpacing100 = SizedBox(
    height: 100.h,
  );
  /* *************** Horizontal Sized Box  ***************** */

  static SizedBox horizontalSpacing15 = SizedBox(
    width: 15.w,
  );
  static SizedBox horizontalSpacing100 = SizedBox(
    width: 100.w,
  );
  static SizedBox horizontalSpacing8 = SizedBox(
    width: 8.w,
  );
  static SizedBox horizontalSpacing5 = SizedBox(
    width: 5.w,
  );
}
