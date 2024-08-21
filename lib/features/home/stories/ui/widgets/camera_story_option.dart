import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/styles.dart';

class CameraStoryOption extends StatelessWidget {
  const CameraStoryOption({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.camera_alt,
        size: 25.w,
      ),
      title: Text(
        'Camera',
        style: AppStyles.font15Black500Weight,
      ),
    );
  }
}
