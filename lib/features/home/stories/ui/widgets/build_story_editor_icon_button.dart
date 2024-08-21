import '../../../../../core/helpers/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/colors.dart';

class StoryEditorIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  const StoryEditorIconButton(
      {super.key, required this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppDimensions.paddingHorizontal5,
      decoration:
          const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: 24.w,
        color: AppColors.mainBlack,
      ),
    );
  }
}
