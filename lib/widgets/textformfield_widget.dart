import '../constants/colors.dart';
import '../constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextFormField extends StatelessWidget {
  final double width;
  final double height;
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final double? prefixIconSize;
  final Color color;
  const AppTextFormField(
      {super.key,
      required this.width,
      required this.height,
      required this.hintText,
      this.prefixIcon,
      this.prefixIconSize,
      required this.color,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lighterGrey,
      width: width.w,
      height: height.h,
      child: TextFormField(
        onTapOutside: (event) {
          //to hide the focus from textformfield when tapping on something else
          FocusManager.instance.primaryFocus!.unfocus();
        },
        controller: controller,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            vertical: (height - 14.h) /
                2, // Adjust based on font size and container height
          ),
          hintText: hintText,
          hintStyle: AppStyles.font14Grey600Weight.copyWith(height: 1.5.h),
          border: InputBorder.none,
          prefixIcon: Icon(
            prefixIcon,
            size: prefixIconSize?.w,
            color: color,
          ),
        ),
      ),
    );
  }
}

class SearchTextFormField extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  SearchTextFormField({super.key});

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      width: 372,
      height: 36,
      hintText: 'Search',
      color: AppColors.mainGrey,
      controller: _searchController,
      prefixIcon: Icons.search,
      prefixIconSize: 24,
    );
  }
}
