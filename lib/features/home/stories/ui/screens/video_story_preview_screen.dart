import 'dart:io';

import '../../../../../core/helpers/dimensions.dart';
import '../../../../../core/theming/colors.dart';
import '../../logic/cubit/stories_cubit.dart';
import '../widgets/build_story_editor_icon_button.dart';
import '../widgets/close_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoStoryPreviewScreen extends StatefulWidget {
  final String videoPath, videoType, videoName;
  const VideoStoryPreviewScreen({
    super.key,
    required this.videoPath,
    required this.videoType,
    required this.videoName,
  });

  @override
  State<VideoStoryPreviewScreen> createState() =>
      _VideoStoryPreviewScreenState();
}

class _VideoStoryPreviewScreenState extends State<VideoStoryPreviewScreen> {
  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CloseButtonWidget(),
              TrimViewer(
                trimmer: _trimmer,
                // viewerHeight: 50.0.h,
                // viewerWidth: MediaQuery.of(context).size.width,
                maxVideoLength: const Duration(seconds: 30),
                onChangeStart: (value) {
                  setState(() {
                    _startValue = value;
                  });
                },
                onChangeEnd: (value) {
                  setState(() {
                    _endValue = value;
                  });
                },
                onChangePlaybackState: (value) {
                  setState(() {
                    _isPlaying = value;
                  });
                },
              ),
              AppDimensions.verticalSpacing10,
              Expanded(
                child: GestureDetector(
                    onTap: () async {
                      if (_isPlaying) {
                        final bool playbackState =
                            await _trimmer.videoPlaybackControl(
                                startValue: _startValue, endValue: _endValue);
                        setState(() {
                          _isPlaying = playbackState;
                        });
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoViewer(trimmer: _trimmer),
                        !_isPlaying
                            ? GestureDetector(
                                onTap: () async {
                                  final bool playbackState =
                                      await _trimmer.videoPlaybackControl(
                                          startValue: _startValue,
                                          endValue: _endValue);
                                  setState(() {
                                    _isPlaying = playbackState;
                                  });
                                },
                                child: Container(
                                    decoration: const BoxDecoration(
                                        color: AppColors.darkPink,
                                        shape: BoxShape.circle),
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 40.w,
                                    )))
                            : const SizedBox()
                      ],
                    )),
              ),
              AppDimensions.verticalSpacing10,
              Align(
                alignment: Alignment.bottomRight,
                child: StoryEditorIconButton(
                    onPressed: () {
                      _saveTrimmedVideoAndAddStory();
                    },
                    icon: Icons.send),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadVideo() async {
    await _trimmer.loadVideo(videoFile: File(widget.videoPath));
  }

  void _saveTrimmedVideoAndAddStory() async {
    await _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (trimmedVideoPath) {
        final int videoDuration = ((_endValue - _startValue) / 1000).round();
        debugPrint('duration : $videoDuration');
        debugPrint('trimmedVideoPath $trimmedVideoPath');
        Navigator.pop(context);
        context.read<StoriesCubit>().addFileStory(
            filePath: trimmedVideoPath ?? widget.videoPath,
            fileType: widget.videoType,
            fileName: widget.videoName,
            videoDuration: videoDuration);
      },
    );
  }
}
