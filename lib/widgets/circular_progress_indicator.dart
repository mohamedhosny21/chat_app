import '../constants/colors.dart';
import 'package:flutter/material.dart';

void showCircularProgressIndicator(BuildContext context) {
  AlertDialog alertDialog = const AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0.0,
    content: Center(
      child: CircularProgressIndicator(
        color: AppColors.mainBlack,
      ),
    ),
  );
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => alertDialog,
      barrierColor: Colors.grey.withOpacity(0.2));
}
