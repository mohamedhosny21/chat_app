import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helpers/dimensions.dart';
import '../../../../../core/theming/colors.dart';
import '../../../../../core/theming/styles.dart';

class DeletedMessageWidget extends StatelessWidget {
  final bool? isSentByMe;
  final double iconSize;
  const DeletedMessageWidget(
      {super.key, this.isSentByMe, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.do_disturb,
          size: iconSize.w,
          color: isSentByMe == null
              ? AppColors.mediumGrey
              : isSentByMe!
                  ? Colors.white
                  : AppColors.mainBlack,
        ),
        AppDimensions.horizontalSpacing8,
        Text(
          'Message has been deleted',
          style: isSentByMe == null
              ? AppStyles.font11GreySemiBold
              : isSentByMe!
                  ? AppStyles.font15White500Weight
                  : AppStyles.font15Black500Weight,
        ),
      ],
    );
  }
}
