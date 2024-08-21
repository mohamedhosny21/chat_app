import '../../../chats/logic/cubit/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helpers/constants/app_constants.dart';
import '../../../../../core/theming/colors.dart';

class StoryContainer extends StatelessWidget {
  final List<Color>? borderGradientColors;
  final Color? borderColor;
  final String? userProfilePicture;
  const StoryContainer(
      {super.key,
      this.borderColor,
      this.borderGradientColors,
      required this.userProfilePicture});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.r,
      height: 70.r,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          // borderRadius: BorderRadius.circular(18.r),
          border:
              Border.all(color: borderColor ?? Colors.transparent, width: 3.w),
          //gradient color for container border
          gradient: LinearGradient(
              colors: borderGradientColors ??
                  [AppColors.lighterGrey, AppColors.lighterGrey])),
      child: CircleAvatar(
        radius: 30.r,
        backgroundColor: AppColors.lightGrey,
        backgroundImage: userProfilePicture != null
            ? NetworkImage(userProfilePicture!)
            : const AssetImage(AppConstants.defaultUserPhoto) as ImageProvider,
      ),
    );
  }
}
