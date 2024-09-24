import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/app_router/routes.dart';
import '../../../../../core/theming/styles.dart';
import '../../logic/cubit/stories_cubit.dart';

class CameraStoryOption extends StatelessWidget {
  const CameraStoryOption({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        final BuildContext localContext = context;
        final List<CameraDescription> cameras = await availableCameras();
        if (context.mounted) {
          Navigator.pushNamed(
            localContext,
            Routes.cameraViewScreen,
            arguments: {
              'cameras': cameras,
              'storiesCubit': context.read<StoriesCubit>()
            },
          );
        }
      },
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
