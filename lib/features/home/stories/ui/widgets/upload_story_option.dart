import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/styles.dart';
import '../../logic/cubit/stories_cubit.dart';

class UploadStoryOption extends StatelessWidget {
  const UploadStoryOption({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<StoriesCubit>().pickFileFromDevice();
      },
      child: ListTile(
        leading: Icon(
          Icons.upload,
          size: 25.w,
        ),
        title: Text(
          'Upload Image/Video',
          style: AppStyles.font15Black500Weight,
        ),
      ),
    );
  }
}
