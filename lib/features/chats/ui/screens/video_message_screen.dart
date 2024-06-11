// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatify/core/theming/colors.dart';
import 'package:chatify/core/theming/styles.dart';
import 'package:chatify/core/widgets/back_button_widget.dart';
import 'package:chatify/features/chats/data/models/message_model.dart';
import 'package:chatify/features/contacts/data/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class VideoMessageScreen extends StatefulWidget {
  final ContactModel contact;
  final Message videoMessage;
  final bool isSentByMe;
  const VideoMessageScreen({
    Key? key,
    required this.contact,
    required this.videoMessage,
    required this.isSentByMe,
  }) : super(key: key);

  @override
  State<VideoMessageScreen> createState() => _VideoMessageScreenState();
}

class _VideoMessageScreenState extends State<VideoMessageScreen> {
  late VideoPlayerController _videoController;
  bool _showPlayPauseButton = true;
  @override
  void initState() {
    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoMessage.text))
          ..initialize().then((_) {
            setState(() {
              _videoController.play();
            });
          });
    _videoController.addListener(_updateState);

    super.initState();
  }

  @override
  void dispose() {
    _videoController.removeListener(_updateState);
    _videoController.dispose();
    super.dispose();
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showPlayPauseButton
          ? AppBar(
              backgroundColor: Colors.black,
              leading: const BackButtonWidget(color: Colors.white),
              title: Column(
                children: [_buildVideoSenderName(), _buildVideoMessageTime()],
              ),
            )
          : null,
      body: SafeArea(
        child: _displayVideo(),
      ),
    );
  }

  Text _buildVideoSenderName() {
    return Text(
        widget.contact.name.isNotEmpty
            ? widget.isSentByMe
                ? 'You'
                : widget.contact.name
            : widget.contact.phoneNumber.toString(),
        style: AppStyles.font15White500Weight);
  }

  Widget _displayVideo() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showPlayPauseButton = !_showPlayPauseButton;
        });
      },
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: _videoController.value.isInitialized
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_videoController),
                        if (_showPlayPauseButton) _buildVideoButton(),
                      ],
                    )
                  : const CircularProgressIndicator(
                      color: AppColors.darkPink,
                    ),
            ),
          ),
          _buildVideoProgressIndicator()
        ],
      ),
    );
  }

  Widget _buildVideoButton() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkPink,
      ),
      child: IconButton(
        onPressed: () {
          setState(() {
            _videoController.value.isPlaying
                ? _videoController.pause()
                : _videoController.play();
          });
        },
        icon: Icon(
            _videoController.value.isPlaying ? Icons.pause : Icons.play_arrow),
        iconSize: 40.w,
        color: Colors.white,
      ),
    );
  }

  String _formatVideoDuration(Duration duration) {
    String twoDigits(int number) => number.toString().padLeft(2, "0");
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    final int seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    } else {
      return "${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
  }

  Widget _buildVideoProgressIndicator() {
    return Container(
      color: Colors.black,
      child: ListTile(
        leading: Text(
          _formatVideoDuration(
            _videoController.value.position,
          ),
          style: AppStyles.font15White500Weight,
        ),
        title: VideoProgressIndicator(
          _videoController,
          allowScrubbing: true,
          colors: const VideoProgressColors(
              playedColor: AppColors.darkPink,
              bufferedColor: AppColors.mainGrey),
        ),
        trailing: Text(
          _formatVideoDuration(
            _videoController.value.duration,
          ),
          style: AppStyles.font15White500Weight,
        ),
      ),
    );
  }

  Text _buildVideoMessageTime() {
    final formattedTime = widget.videoMessage.time!.toDate();
    return Text(
      '${formattedTime.hour.toString().padLeft(2, '0')}:${formattedTime.minute.toString().padLeft(2, '0')}',
      style: AppStyles.font15White500Weight,
    );
  }
}
