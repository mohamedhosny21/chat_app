import 'dart:io';

import 'package:chatify/core/app_router/navigator_observer.dart';
import 'package:chatify/core/app_router/routes.dart';

import '../../../../../core/helpers/dimensions.dart';
import '../../../../../core/theming/colors.dart';
import '../widgets/build_story_editor_icon_button.dart';
import '../widgets/close_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../logic/cubit/stories_cubit.dart';

class ImageStoryPreviewScreen extends StatefulWidget {
  final String imagePath, imageName, imageType;
  const ImageStoryPreviewScreen({
    super.key,
    required this.imagePath,
    required this.imageName,
    required this.imageType,
  });

  @override
  State<ImageStoryPreviewScreen> createState() =>
      _ImageStoryPreviewScreenState();
}

class _ImageStoryPreviewScreenState extends State<ImageStoryPreviewScreen> {
  CroppedFile? _croppedFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActionButtonsRow(),
          AppDimensions.verticalSpacing100,
          _buildPhotoPreview(),
          const Spacer(),
          _buildSendButton()
        ],
      )),
    );
  }

  Widget _buildActionButtonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CloseButtonWidget(),
        StoryEditorIconButton(onPressed: () => _cropImage(), icon: Icons.crop),
      ],
    );
  }

  Widget _buildPhotoPreview() {
    return AspectRatio(
      aspectRatio: 1,
      child: Image.file(
        File(
          _croppedFile?.path ?? widget.imagePath,
        ),
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildSendButton() {
    return Align(
        alignment: Alignment.bottomRight,
        child: StoryEditorIconButton(
            onPressed: () {
              Navigator.popUntil(
                context,
                (route) => route.settings.name == Routes.homeScreen,
              );

              context.read<StoriesCubit>().addFileStory(
                  fileName: widget.imageName,
                  fileType: widget.imageType,
                  filePath: _croppedFile?.path ?? widget.imagePath);
            },
            icon: Icons.send));
  }

  void _cropImage() async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: _croppedFile?.path ?? widget.imagePath,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: AppColors.darkPink,
              toolbarWidgetColor: Colors.white,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
              ]),
          IOSUiSettings(title: 'Crop Image', aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square
          ])
        ]);
    if (croppedFile != null) {
      setState(() {
        _croppedFile = croppedFile;
      });
    }
  }
}
