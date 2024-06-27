import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/app_router/routes.dart';
import '../../../../core/helpers/constants/app_constants.dart';
import '../../../../core/theming/colors.dart';
import '../../../contacts/data/contact_model.dart';
import '../../data/models/message_model.dart';

class ChatroomVideoMessage extends StatelessWidget {
  final ContactModel contact;
  final Message message;
  final bool isSentByMe;
  const ChatroomVideoMessage(
      {super.key,
      required this.contact,
      required this.message,
      required this.isSentByMe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.videoMessageScreen, arguments: {
          'contact': contact,
          'videoMessage': message,
          'isSentByMe': isSentByMe
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          FadeInImage.assetNetwork(
            placeholder: isSentByMe
                ? AppConstants.senderLoadingGif
                : AppConstants.receiverLoadingGif,
            image: message.thumbnailVideoUrl ?? message.text,
            fit: BoxFit.cover,
          ),
          _buildPlayVideoIcon(),
        ],
      ),
    );
  }

  Widget _buildPlayVideoIcon() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkPink,
      ),
      child: Icon(
        Icons.play_arrow,
        color: Colors.white,
        size: 40.w,
      ),
    );
  }
}
