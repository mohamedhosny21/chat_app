import '../../../../../core/theming/colors.dart';
import '../../../../../core/theming/styles.dart';
import '../../../../../core/widgets/textformfield_widget.dart';
import '../../logic/cubit/stories_cubit.dart';
import '../widgets/build_story_editor_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/close_button.dart';

class TextStoryPreviewScreen extends StatefulWidget {
  const TextStoryPreviewScreen({super.key});

  @override
  State<TextStoryPreviewScreen> createState() => _TextStoryPreviewScreenState();
}

class _TextStoryPreviewScreenState extends State<TextStoryPreviewScreen> {
  final TextEditingController textController = TextEditingController();
  Color selectedColor = AppColors.mainBlack;
  Color pickerColor = AppColors.mainBlack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Stack(
        children: [
          Container(
            alignment: Alignment.center,
            color: AppColors.darkPink,
            child: AppTextFormField(
              textAlign: TextAlign.center,
              controller: textController,
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.7,
              inputColor: AppColors.darkPink,
              hintText: 'What\'s on your mind ?',
              hintStyle: AppStyles.font25GreyBold,
              autofocus: true,
              inputTextStyle:
                  AppStyles.font20BlackBold.copyWith(color: pickerColor),
              cursorColor: Colors.black,
              contentPadding: EdgeInsets.symmetric(vertical: 200.h),
            ),
          ),
          const CloseButtonWidget(),
          _buildContainerWithAddStoryButton(),
        ],
      )),
    );
  }

  void _changeColor(Color pickedColor) {
    setState(() => pickerColor = pickedColor);
  }

  Widget _buildColorPickerButton() {
    return StoryEditorIconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: _changeColor,
              ),
            ),
          ),
        );
      },
      icon: Icons.color_lens,
    );
  }

  Widget _buildContainerWithAddStoryButton() {
    return Positioned(
      bottom: 0,
      child: Container(
        color: Colors.black38,
        alignment: Alignment.centerRight,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.09,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildColorPickerButton(),
            StoryEditorIconButton(
                onPressed: () {
                  if (textController.text.isNotEmpty) {
                    final storyTextColorHex =
                        '#${pickerColor.value.toRadixString(16).padLeft(6, '0')}';

                    Navigator.pop(context);
                    context.read<StoriesCubit>().addStory(
                        content: textController.text,
                        storyTextColor: storyTextColorHex);
                  }
                },
                icon: Icons.send),
          ],
        ),
      ),
    );
  }
}
