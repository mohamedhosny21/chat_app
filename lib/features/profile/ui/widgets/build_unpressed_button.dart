import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';

class UnPressedButton extends StatelessWidget {
  const UnPressedButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 36.h,
        width: 300.w,
        color: AppColors.mainGrey,
        child: Center(
            child: Text('Save Changes',
                style: AppStyles.font10WhiteBold.copyWith(fontSize: 18.sp))));
  }
}
