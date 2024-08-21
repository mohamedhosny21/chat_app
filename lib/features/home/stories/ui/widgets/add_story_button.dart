import '../../../../../core/app_router/routes.dart';
import '../../../../../core/helpers/extensions.dart';
import 'camera_story_option.dart';
import 'text_story_option.dart';
import 'upload_story_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/colors.dart';
import '../../logic/cubit/stories_cubit.dart';

class AddStoryButton extends StatelessWidget {
  const AddStoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoriesCubit, StoriesState>(
      listener: (context, state) {
        if (state is StoryPickedState) {
          if (state.file.extension!.imageType) {
            Navigator.pushReplacementNamed(
              context,
              Routes.imageStoryPreviewScreen,
              arguments: {
                'imageFile': state.file,
                'storiesCubit': context.read<StoriesCubit>()
              },
            );
          } else {
            Navigator.pushReplacementNamed(
              context,
              Routes.videoStoryPreviewScreen,
              arguments: {
                'videoFile': state.file,
                'storiesCubit': context.read<StoriesCubit>()
              },
            );
          }
        }
      },
      child: Positioned(
        bottom: 20.h,
        right: 2.w,
        child: Container(
          width: 20.w,
          decoration: const BoxDecoration(
            color: AppColors.darkPink,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              _showStoryOptions(context);
            },
            icon: const Icon(
              Icons.add,
            ),
            padding: EdgeInsets.zero,
            iconSize: 18.w,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showStoryOptions(BuildContext context) {
    final storiesCubit = context.read<StoriesCubit>();

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return BlocProvider<StoriesCubit>.value(
          value: storiesCubit,
          child: _buildStoryOptions(),
        );
      },
    );
  }
}

Widget _buildStoryOptions() {
  return const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CameraStoryOption(),
      TextStoryOption(),
      UploadStoryOption(),
    ],
  );
}
