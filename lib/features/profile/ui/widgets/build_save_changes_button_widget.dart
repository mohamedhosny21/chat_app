import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../logic/cubit/profile_cubit.dart';

class BuildSaveChangesButtonWidget extends StatelessWidget {
  final Widget? child;
  const BuildSaveChangesButtonWidget({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: 36.h,
      onPressed: () {
        if (child == null) {
          context.read<ProfileCubit>().updateUserProfile();
        }
      },
      color: AppColors.darkPink,
      minWidth: 300.w,
      child: child ??
          Text(
            'Save Changes',
            style: AppStyles.font10WhiteBold.copyWith(fontSize: 18.sp),
          ),
    );
  }
}
