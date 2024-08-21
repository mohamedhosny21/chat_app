import 'dart:io';

import '../../../../../core/helpers/dimensions.dart';
import '../../../../../core/theming/colors.dart';
import '../widgets/build_story_editor_icon_button.dart';
import '../widgets/close_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../logic/cubit/stories_cubit.dart';

class ImageStoryPreviewScreen extends StatefulWidget {
  final PlatformFile imageFile;
  const ImageStoryPreviewScreen({
    super.key,
    required this.imageFile,
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
          _croppedFile?.path ?? widget.imageFile.path!,
        ),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildSendButton() {
    return Align(
        alignment: Alignment.bottomRight,
        child: StoryEditorIconButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<StoriesCubit>().addFileStory(
                  fileName: widget.imageFile.name,
                  fileType: widget.imageFile.extension!,
                  filePath: _croppedFile?.path ?? widget.imageFile.path!);
            },
            icon: Icons.send));
  }

  void _cropImage() async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: _croppedFile?.path ?? widget.imageFile.path!,
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
