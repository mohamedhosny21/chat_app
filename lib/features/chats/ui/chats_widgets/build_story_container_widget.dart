import '../../../../constants/colors.dart';
import '../../../../constants/dimensions.dart';
import '../../../../constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserStories extends StatelessWidget {
  const UserStories({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const AddStoryContainer();
          } else {
            return const UserStoryItem();
          }
        },
        separatorBuilder: (context, index) => AppDimensions.horizontalSpacing15,
        itemCount: 10,
      ),
    );
  }
}

class UserStoryItem extends StatelessWidget {
  const UserStoryItem({super.key});

  @override
  Widget build(BuildContext context) {
    return StoryContainer(
        borderColor: AppColors.grey,
        text: 'Mohamed',
        color: Colors.white,
        child: Icon(
          Icons.person,
          size: 24.sp,
          color: AppColors.grey,
        ));
  }
}

class AddStoryContainer extends StatelessWidget {
  const AddStoryContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return StoryContainer(
      color: AppColors.lighterGrey,
      borderColor: AppColors.grey,
      text: 'Add Story',
      child: Icon(
        Icons.add,
        size: 24.sp,
        color: AppColors.grey,
      ),
    );
  }
}

class StoryContainer extends StatelessWidget {
  final Color borderColor;
  final String text;
  final Widget child;
  final Color color;
  const StoryContainer(
      {super.key,
      required this.borderColor,
      required this.text,
      required this.child,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            width: 56.w,
            padding: AppDimensions.paddingSymmetricV12H12,
            decoration: BoxDecoration(
                color: color,
                border: Border.all(color: borderColor, width: 2.w),
                borderRadius: BorderRadius.circular(18.r)),
            child: child),
        AppDimensions.verticalSpacing5,
        Text(
          text,
          style: AppStyles.font10Black400Weight,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }
}
