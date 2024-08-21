import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/styles.dart';

class UserStoryName extends StatelessWidget {
  final String userName;
  const UserStoryName({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 72.w),
      child: Text(
        userName,
        style: AppStyles.font12Black400Weight,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
