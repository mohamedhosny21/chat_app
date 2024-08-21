import '../theming/colors.dart';
import '../theming/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextFormField extends StatelessWidget {
  final double width;
  final double height;
  final TextEditingController? controller;
  final String? hintText;
  final IconData? suffixIcon;
  final Color? suffixIconColor;
  final double? suffixIconSize;
  final void Function(String)? onChanged;

  final IconData? prefixIcon;
  final double? prefixIconSize;
  final InputBorder? inputBorder;
  final EdgeInsetsGeometry? contentPadding;
  final String? initialValue;
  final Color? cursorColor;
  final double? cursorHeight;
  final bool autofocus;
  final InputBorder? enabledBorder;
  final TextStyle? inputTextStyle;
  final TextAlign? textAlign;
  final TextStyle? hintStyle;
  final InputBorder? focusedBorder;
  final bool? readOnly;
  final Color? inputColor;
  final Color? prefixIconColor;
  const AppTextFormField(
      {super.key,
      required this.width,
      required this.height,
      this.inputColor,
      this.autofocus = false,
      this.hintText,
      this.prefixIcon,
      this.inputBorder,
      this.focusedBorder,
      this.readOnly,
      this.hintStyle,
      this.enabledBorder,
      this.prefixIconSize,
      this.prefixIconColor,
      this.controller,
      this.initialValue,
      this.contentPadding,
      this.suffixIcon,
      this.suffixIconColor,
      this.suffixIconSize,
      this.onChanged,
      this.cursorColor,
      this.cursorHeight,
      this.inputTextStyle,
      this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: inputColor ?? AppColors.lighterGrey,
      width: width.w,
      height: height.h,
      child: TextFormField(
        textAlign: textAlign ?? TextAlign.start,
        cursorHeight: cursorHeight,
        cursorColor: cursorColor ?? AppColors.darkPink,
        onChanged: onChanged,
        autofocus: autofocus,
        initialValue: initialValue,
        style: inputTextStyle ??
            AppStyles.font14Black400Weight
                .copyWith(fontWeight: FontWeight.bold),
        readOnly: readOnly ?? false,
        onTapOutside: (event) {
          //to hide the focus from textformfield when tapping on something else
          FocusManager.instance.primaryFocus!.unfocus();
        },
        controller: controller,
        maxLines: null,
        decoration: InputDecoration(
          contentPadding: contentPadding ??
              EdgeInsets.symmetric(
                vertical: (height - 30.h) /
                    2, // Adjust based on font size and container height
              ),
          hintText: hintText,
          hintStyle: hintStyle ??
              AppStyles.font14Grey600Weight.copyWith(height: 2.8.h),
          border: inputBorder ?? InputBorder.none,
          enabledBorder: enabledBorder ?? InputBorder.none,
          focusedBorder: focusedBorder ?? InputBorder.none,
          prefixIcon: Icon(
            prefixIcon,
            size: prefixIconSize?.w,
            color: prefixIconColor,
          ),
          suffixIcon: Icon(
            suffixIcon,
            size: suffixIconSize?.w,
            color: suffixIconColor,
          ),
        ),
      ),
    );
  }
}

class SearchTextFormField extends StatelessWidget {
  final TextEditingController searchController;

  const SearchTextFormField({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      width: 372,
      height: 36,
      hintText: 'Search',
      prefixIconColor: AppColors.mainGrey,
      controller: searchController,
      prefixIcon: Icons.search,
      prefixIconSize: 24,
    );
  }
}

class ProfileTextFormField extends StatelessWidget {
  final IconData? suffixIcon;
  final Color? suffixIconColor;
  final double? suffixIconSize;
  final void Function(String)? onChanged;
  final EdgeInsetsGeometry? contentPadding;
  final String? hintText;
  final IconData prefixIcon;
  final bool? readOnly;
  final String? initialValue;
  final TextEditingController? controller;
  const ProfileTextFormField(
      {super.key,
      this.hintText,
      required this.prefixIcon,
      this.controller,
      this.readOnly,
      this.initialValue,
      this.contentPadding,
      this.suffixIcon,
      this.suffixIconColor,
      this.suffixIconSize,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.darkPink)),
        width: 300,
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.darkPink)),
        height: 36,
        onChanged: onChanged,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        suffixIconColor: AppColors.darkPink,
        contentPadding: contentPadding,
        readOnly: readOnly ?? false,
        initialValue: initialValue,
        prefixIconColor: AppColors.darkPink,
        inputColor: Colors.white,
        hintText: hintText ?? '',
        controller: controller);
  }
}
