// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatify/features/chats/data/models/ongoing_chat_model.dart';
import 'package:chatify/features/chats/ui/widgets/chats_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/app_router/routes.dart';
import '../../../../core/helpers/dimensions.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import '../../../contacts/data/contact_model.dart';

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
                image: AssetImage(
                  onGoingChat.profilePicture,
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
                _buildlastMessageTime(),
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

  Text _buildlastMessageTime() {
    final formattedTime = onGoingChat.lastMessageTime.toDate();
    return Text(
      '${formattedTime.hour.toString().padLeft(2, '0')}:${formattedTime.minute.toString().padLeft(2, '0')}',
      style: AppStyles.font10GreySemiBold,
    );
  }

  Widget _buildLastMessageContent() {
    return onGoingChat.isLastMessageDeleted
        ? buildDeletedMessageWidget(iconSize: 15)
        : Row(
            children: [
              _buildMessageStatusIcon(),
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

  Widget _buildMessageStatusIcon() {
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
          color: AppColors.lightPink,
          size: 15.0.w,
        );
      }
    }
    return const SizedBox();
  }

  Widget _buildLastMessageText() {
    return Flexible(
      child: Text(
        onGoingChat.lastMessage,
        style: AppStyles.font11GreySemiBold,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildNumberOfUnreadMessages() {
    if (!isSentByMe &&
        onGoingChat.lastMessageStatus != 'seen' &&
        onGoingChat.unreadMessagesCount! > 0) {
      return Container(
        padding: AppDimensions.paddingSymmetricH5,
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
