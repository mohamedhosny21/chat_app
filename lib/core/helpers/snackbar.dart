import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theming/styles.dart';

void showSnackBar(BuildContext context, String snackBarMsg,
    IconData snackbarIcon, Color snackBarColor, Color iconColor) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: const Duration(seconds: 2),
    content: ListTile(
        leading: Icon(
          snackbarIcon,
          color: iconColor,
          size: 30.w,
        ),
        title: Text(
          snackBarMsg,
          style: AppStyles.font15Black500Weight,
        )),
    backgroundColor: snackBarColor,
  ));
}

void showSuccessSnackBar(BuildContext context, String snackBarMsg) {
  showSnackBar(context, snackBarMsg, Icons.check_circle_outline,
      Colors.green.shade200, Colors.green);
}

void showErrorSnackBar(BuildContext context, String snackBarMsg) {
  showSnackBar(context, snackBarMsg, Icons.warning, Colors.red, Colors.amber);
}
