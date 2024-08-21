import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helpers/dimensions.dart';
import '../../../../../core/theming/styles.dart';

class MessagesGroupHeaderLabel extends StatelessWidget {
  final String messageDate;
  const MessagesGroupHeaderLabel({super.key, required this.messageDate});

  @override
  Widget build(BuildContext context) {
    if (messageDate.isNotEmpty) {
      return Padding(
        padding: AppDimensions.paddingSymmetricV25H100,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20.r)),
          child: Text(
            messageDate,
            textAlign: TextAlign.center,
            style: AppStyles.font14Black400Weight,
          ),
        ),
      );
    }
    return const SizedBox();
  }
}
