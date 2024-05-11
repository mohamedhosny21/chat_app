// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatify/features/chats/data/ongoing_chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/dimensions.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';

class ChatItem extends StatelessWidget {
  final OnGoingChat ongoingChat;
  const ChatItem({
    Key? key,
    required this.ongoingChat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChatPhoto(),
        AppDimensions.horizontalSpacing8,
        ChatComponents(
          onGoingChat: ongoingChat,
        )
      ],
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
                image: AssetImage(
                  ongoingChat.profilePicture,
                )),
          ),
        ),
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

class ChatComponents extends StatelessWidget {
  final OnGoingChat onGoingChat;
  const ChatComponents({super.key, required this.onGoingChat});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildChatName(MediaQuery.of(context).size.width * 0.6.w),
              const Spacer(),
              AppDimensions.horizontalSpacing8,
              _buildlastMessageTime(),
            ],
          ),
          AppDimensions.verticalSpacing5,
          _buildLastMessage()
        ],
      ),
    );
  }

  Widget _buildChatName(double maxWidth) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Text(
        onGoingChat.name ?? onGoingChat.phoneNumber,
        style: AppStyles.font14Black400Weight,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Text _buildlastMessageTime() {
    final formattedTime = _parseLastMessageTime();
    return Text(
      '${formattedTime.hour.toString().padLeft(2, '0')}:${formattedTime.minute.toString().padLeft(2, '0')}',
      style: AppStyles.font10GreySemiBold,
    );
  }

  DateTime _parseLastMessageTime() {
    int seconds =
        int.parse(onGoingChat.lastMessageTime.split(',')[0].split('=')[1]);
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }

  Text _buildLastMessage() {
    return Text(
      onGoingChat.lastMessage,
      style: AppStyles.font11GreySemiBold,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
