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
      height: 110.h,
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
        borderGradientColors: const [Color(0x1FD84D4D), Color(0xFFF28585)],
        text: 'Mohamed Hosny',
        color: Colors.white,
        child: Icon(
          Icons.person,
          size: 24.sp,
          color: AppColors.mainGrey,
        ));
  }
}

class AddStoryContainer extends StatelessWidget {
  const AddStoryContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return StoryContainer(
      color: AppColors.lighterGrey,
      borderColor: AppColors.mainGrey,
      text: 'Add Story',
      child: Icon(
        Icons.add,
        size: 24.sp,
        color: AppColors.mainGrey,
      ),
    );
  }
}

class StoryContainer extends StatelessWidget {
  final List<Color>? borderGradientColors;
  final Color? borderColor;
  final String text;
  final Widget child;
  final Color color;
  const StoryContainer(
      {super.key,
      this.borderColor,
      required this.text,
      required this.child,
      required this.color,
      this.borderGradientColors});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //container to make a gradent colors on its border border
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                  color: borderColor ?? Colors.transparent, width: 2.w),
              //gradient color for container border
              gradient: LinearGradient(
                  colors: borderGradientColors ??
                      [AppColors.lighterGrey, AppColors.lighterGrey])),
          child: Container(
              width: 56.w,
              padding: AppDimensions.paddingSymmetricV12H12,
              decoration: BoxDecoration(
                  //color of container
                  color: color,
                  //must added to make gradient for border
                  borderRadius: BorderRadius.circular(18.r)),
              child: child),
        ),
        AppDimensions.verticalSpacing5,
        Container(
          constraints: BoxConstraints(maxWidth: 64.w),
          child: Text(
            text,
            style: AppStyles.font12Black400Weight,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        )
      ],
    );
  }
}
