import '../../../../constants/colors.dart';
import '../../../../constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchTextFormField extends StatelessWidget {
  final TextEditingController searchController = TextEditingController();
  SearchTextFormField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.lighterGrey,
      width: 327.w,
      height: 36.h,
      child: TextFormField(
        onTapOutside: (event) {
          //to hide the focus from textformfield when tapping on something else
          FocusManager.instance.primaryFocus!.unfocus();
        },
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: AppStyles.font14Grey600Weight,
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search,
            size: 24.sp,
            color: AppColors.mainGrey,
          ),
        ),
      ),
    );
  }
}
