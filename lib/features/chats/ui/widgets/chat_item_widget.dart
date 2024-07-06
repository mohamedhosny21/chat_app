// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatify/features/chats/data/models/ongoing_chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/constants/app_constants.dart';
import '../../../../core/helpers/dimensions.dart';
import '../../../../core/theming/colors.dart';
import 'chat_component_widget.dart';

class ChatItem extends StatelessWidget {
  final OnGoingChat onGoingChat;
  final bool isSentByMe;
  const ChatItem({
    Key? key,
    required this.onGoingChat,
    required this.isSentByMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChatPhoto(),
          AppDimensions.horizontalSpacing8,
          ChatComponents(
            isSentByMe: isSentByMe,
            onGoingChat: onGoingChat,
          )
        ],
      ),
    );
  }

  Widget _buildChatPhoto() {
    return Stack(
      children: [
        Container(
            height: 56.h,
            width: 56.5.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: onGoingChat.profilePicture == null
                    ? const AssetImage(AppConstants.defaultUserPhoto)
                    : NetworkImage(onGoingChat.profilePicture!)
                        as ImageProvider,
              ),
            )),
        Positioned(
          right: 3,
          child: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                color: AppColors.green,
                shape: BoxShape.circle),
          ),
        )
      ],
    );
  }
}
