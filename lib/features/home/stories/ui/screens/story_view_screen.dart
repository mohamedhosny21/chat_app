import '../../../../../core/helpers/extensions.dart';
import '../../../../../core/theming/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/theming/styles.dart';
import '../../data/model/story_model.dart';

class StoryViewScreen extends StatefulWidget {
  final List<StoryModel> stories;
  const StoryViewScreen({super.key, required this.stories});

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  VideoPlayerController? _videoController;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeStory();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.removeListener(_updateState);
    _progressController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeStory() async {
    _initializeAnimationController();

    if (widget.stories[_currentIndex].type.videoType) {
      await _initializeAndPlayVideo();
    } else {
      _startStory();
    }
  }

  void _initializeAnimationController() {
    final int storyDuration = _storyDuration();
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: storyDuration), // Duration of each story
    )..addListener(() {
        setState(() {});
      });
  }

  int _storyDuration() {
    if (widget.stories[_currentIndex].type.videoType) {
      return widget.stories[_currentIndex].videoDuration!.toInt();
    } else {
      return 10;
    }
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startStory() {
    _progressController.reset();
    _progressController.forward().whenComplete(() {
      if (_currentIndex < widget.stories.length - 1) {
        _currentIndex++;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
        );
        _startStory(); // Restart animation for the next story
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.stories[_currentIndex].type == 'text'
          ? AppColors.darkPink
          : Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.stories.length,
              onPageChanged: (pageIndex) {
                setState(() {
                  _currentIndex = pageIndex;

                  _startStory();
                });
              },
              itemBuilder: (context, index) {
                final story = widget.stories[index];
                if (story.type == 'text') {
                  return Center(
                    child: Text(
                      story.content,
                      style: AppStyles.font20BlackBold
                          .copyWith(color: story.textColor!.toColor()),
                    ),
                  );
                } else if (story.type.imageType) {
                  return Center(
                    child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          story.content,
                          fit: BoxFit.fill,
                        )),
                  );
                } else {
                  return Center(
                    child: _videoController != null &&
                            _videoController!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          )
                        : const CircularProgressIndicator(
                            color: AppColors.darkPink,
                          ),
                  );
                }
              },
            ),
            Positioned(
              top: 20.h,
              left: 10.w,
              right: 10.w,
              child: Row(
                children: List.generate(
                  widget.stories.length,
                  (index) => Expanded(
                    child: LinearProgressIndicator(
                      value: index == _currentIndex
                          ? _progressController.value
                          : index < _currentIndex
                              ? 1.0
                              : 0.0,
                      backgroundColor: AppColors.darkGrey,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _initializeAndPlayVideo() async {
    _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.stories[_currentIndex].content))
      ..initialize().then((_) {
        setState(() {
          _videoController!.play();
          _startStory();
        });
      });
  }
}
