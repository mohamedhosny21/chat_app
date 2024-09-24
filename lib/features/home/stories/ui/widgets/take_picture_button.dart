import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/app_router/routes.dart';
import '../../../../../core/helpers/dimensions.dart';
import '../../../../../core/theming/colors.dart';
import '../../logic/cubit/stories_cubit.dart';

class TakePictureButton extends StatelessWidget {
  final Future<void> initializeControllerFuture;
  final CameraController cameraController;
  const TakePictureButton(
      {super.key,
      required this.initializeControllerFuture,
      required this.cameraController});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CameraPreview(cameraController),
        Padding(
          padding: AppDimensions.paddingBottom10,
          child: FloatingActionButton(
              foregroundColor: Colors.black,
              shape: const CircleBorder(),
              backgroundColor: AppColors.darkPink,
              child: const Icon(Icons.camera_alt),
              onPressed: () async {
                try {
                  final BuildContext localContext = context;
                  await initializeControllerFuture;
                  final image = await cameraController.takePicture();
                  if (localContext.mounted) {
                    Navigator.pushNamed(
                        localContext, Routes.imageStoryPreviewScreen,
                        arguments: {
                          'imagePath': image.path,
                          'imageType': image.name.split('.').last,
                          'imageName': image.name,
                          'storiesCubit': context.read<StoriesCubit>()
                        });
                  }
                } catch (e) {
                  if (kDebugMode) {
                    print(e);
                  }
                }
              }),
        )
      ],
    );
  }
}
