import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/app_router/routes.dart';
import '../../../../../core/theming/styles.dart';
import '../../logic/cubit/stories_cubit.dart';

class TextStoryOption extends StatelessWidget {
  const TextStoryOption({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, Routes.textStoryPreviewScreen,
            arguments: context.read<StoriesCubit>());
      },
      child: ListTile(
        leading: Icon(
          Icons.text_format,
          size: 25.w,
        ),
        title: Text(
          'Share Thoughts',
          style: AppStyles.font15Black500Weight,
        ),
      ),
    );
  }
}
