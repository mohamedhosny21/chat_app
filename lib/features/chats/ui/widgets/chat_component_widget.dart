import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/app_router/routes.dart';
import '../../../../core/helpers/dimensions.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../contacts/data/contact_model.dart';
import '../../data/models/ongoing_chat_model.dart';
import 'deleted_message_widget.dart';
import 'message_time_widget.dart';

class ChatComponents extends StatelessWidget {
  final bool isSentByMe;
  final OnGoingChat onGoingChat;

  const ChatComponents(
      {super.key, required this.onGoingChat, required this.isSentByMe});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, Routes.chatRoomScreen,
              arguments: ContactModel(
                  id: onGoingChat.id,
                  name: onGoingChat.name ?? onGoingChat.phoneNumber,
                  phoneNumber: onGoingChat.phoneNumber,
                  profilePicture: onGoingChat.profilePicture));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildChatName(MediaQuery.of(context).size.width * 0.6.w),
                const Spacer(),
                AppDimensions.horizontalSpacing8,
                MessageTimeWidget(
                    isInChatroom: false,
                    messageTime: onGoingChat.lastMessageTime!,
                    messageStyle: AppStyles.font10GreySemiBold),
              ],
            ),
            AppDimensions.verticalSpacing5,
            _buildLastMessageContent()
          ],
        ),
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

  Widget _buildLastMessageContent() {
    if (onGoingChat.isLastMessageDeleted) {
      return const DeletedMessageWidget(iconSize: 15);
    } else {
      return Row(
        children: [
          _buildLastMessageStatusIcon(),
          AppDimensions.horizontalSpacing5,
          Flexible(
            child: Row(
              children: [_buildLastMessageText()],
            ),
          ),
          _buildNumberOfUnreadMessages()
        ],
      );
    }
  }

  Widget _buildLastMessageStatusIcon() {
    if (isSentByMe && !onGoingChat.isLastMessageDeleted) {
      if (onGoingChat.lastMessageStatus == 'sent') {
        return Icon(
          Icons.done,
          color: AppColors.mediumGrey,
          size: 15.0.w,
        );
      } else if (onGoingChat.lastMessageStatus == 'delivered') {
        return Icon(
          Icons.done_all,
          color: AppColors.mediumGrey,
          size: 15.0.w,
        );
      } else if (onGoingChat.lastMessageStatus == 'seen') {
        return Icon(
          Icons.done_all,
          color: AppColors.lighterPink,
          size: 15.0.w,
        );
      }
    }
    return const SizedBox();
  }

  Widget _buildLastMessageText() {
    return Flexible(
        child: onGoingChat.lastMessageType == 'text'
            ? Text(
                onGoingChat.lastMessage,
                style: AppStyles.font11GreySemiBold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : onGoingChat.lastMessageType == 'image'
                ? _messageIconWithText(Icons.photo, 'Photo')
                : onGoingChat.lastMessageType == 'video'
                    ? _messageIconWithText(Icons.videocam, 'Video')
                    : onGoingChat.lastMessageType == 'document'
                        ? _messageIconWithText(
                            Icons.insert_drive_file, 'Document')
                        : const SizedBox());
  }

  Widget _messageIconWithText(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.w,
          color: AppColors.mediumGrey,
        ),
        AppDimensions.horizontalSpacing5,
        Text(
          text,
          style: AppStyles.font11GreySemiBold,
        )
      ],
    );
  }

  Widget _buildNumberOfUnreadMessages() {
    if (!isSentByMe &&
        onGoingChat.lastMessageStatus != 'seen' &&
        onGoingChat.unreadMessagesCount! > 0) {
      return Container(
        padding: AppDimensions.paddingHorizontal5,
        decoration: BoxDecoration(
          color: AppColors.darkPink,
          borderRadius: BorderRadius.circular(20.0.r),
        ),
        child: Text(
          onGoingChat.unreadMessagesCount.toString(),
          textAlign: TextAlign.center,
          style: AppStyles.font10WhiteBold,
        ),
      );
    }
    return const SizedBox();
  }
}
