// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chatify/core/helpers/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:chatify/core/theming/colors.dart';
import 'package:chatify/core/theming/styles.dart';
import 'package:chatify/features/chats/data/message_model.dart';
import 'package:chatify/features/chats/logic/cubit/chat_cubit.dart';

class MessageItem extends StatelessWidget {
  final Message message;
  final bool isSentByMe;
  final ChatCubit chatCubit;

  const MessageItem({
    Key? key,
    required this.message,
    required this.isSentByMe,
    required this.chatCubit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isSentByMe) {
      chatCubit.updateMessageStatus(message.id, 'seen');
    }
    return Column(
      children: [
        Row(
          //to make message info fitted with chat container
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            // The scope of this if statement is limited to the following IconButton
            if (isSentByMe && !message.isDeleted) _buildMessageInfo(),
            // This Widget is included in both cases
            _buildChatContainerWithMessageTime(),
            // The scope of this if statement is limited to the following IconButton
            if (!isSentByMe && !message.isDeleted) _buildMessageInfo(),
          ],
        ),
      ],
    );
  }

  Widget _buildChatContainer() {
    return Stack(
      children: [
        ChatBubble(
          clipper: ChatBubbleClipper5(
              type: isSentByMe
                  ? BubbleType.sendBubble
                  : BubbleType.receiverBubble),
          backGroundColor: isSentByMe ? AppColors.darkPink : Colors.white,
          child: message.isDeleted
              ? _buildDeletedMessageWidget()
              : Container(
                  // to avoid the overflow of text
                  constraints: BoxConstraints(maxWidth: 250.w),
                  child: Text(
                    message.text,
                    style: isSentByMe
                        ? AppStyles.font15White500Weight
                        : AppStyles.font15Black500Weight,
                  ),
                ),
        ),
        _buildMessageStatusIcon()
      ],
    );
  }

  Widget _buildMessageInfo() {
    return PopupMenuButton(
      icon: const Icon(Icons.more_horiz_rounded),
      iconSize: 20.w,
      color: Colors.white,
      itemBuilder: (context) => [
        PopupMenuItem(
            onTap: () {
              if (isSentByMe) {
                chatCubit.updateDeletedMessages(message.id);
              }
            },
            height: 30.h,
            child: Center(
                child: Text(
              'Delete',
              style: AppStyles.font14Black400Weight
                  .copyWith(fontWeight: FontWeight.bold),
            )))
      ],
    );
  }

  Widget _buildMessageTime() {
    //convert firestore timestamp into readable time in hours and minutes
    int seconds = int.parse(message.time.split(',')[0].split('=')[1]);
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    return Align(
      alignment: isSentByMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Text(
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
        style: AppStyles.font12DarkGrey500Weight,
      ),
    );
  }

  Widget _buildChatContainerWithMessageTime() {
    return Column(
      crossAxisAlignment: isSentByMe
          //to change the direction of message time according to the direction of chat container
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        _buildChatContainer(),
        _buildMessageTime(),
      ],
    );
  }

  Widget _buildMessageStatusIcon() {
    if (isSentByMe && !message.isDeleted) {
      if (message.status == 'sent') {
        return _positionedMessageStatusIcon(Icons.done, AppColors.lightPink);
      } else if (message.status == 'delivered') {
        return _positionedMessageStatusIcon(
            Icons.done_all, AppColors.lightPink);
      } else if (message.status == 'seen') {
        return _positionedMessageStatusIcon(Icons.done_all, Colors.white);
      }
    }
    return const SizedBox();
  }

  Widget _positionedMessageStatusIcon(IconData icon, Color color) {
    return Positioned(
      bottom: 0.0,
      right: 0.0,
      child: Icon(
        icon,
        color: color,
        size: 15.0.w,
      ),
    );
  }

  Widget _buildDeletedMessageWidget() {
    return Row(
      children: [
        Icon(
          Icons.do_disturb,
          size: 20.w,
          color: isSentByMe ? Colors.white : AppColors.mainBlack,
        ),
        AppDimensions.horizontalSpacing8,
        Text(
          'Message has been deleted',
          style: isSentByMe
              ? AppStyles.font15White500Weight
              : AppStyles.font15Black500Weight,
        ),
      ],
    );
  }
}
