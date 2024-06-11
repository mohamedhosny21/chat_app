// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:chatify/features/chats/ui/widgets/chatroom_document_message.dart';
import 'package:chatify/features/chats/ui/widgets/chatroom_image_message.dart';
import 'package:chatify/features/chats/ui/widgets/chatroom_video_message.dart';
import 'package:chatify/features/chats/ui/widgets/deleted_message_widget.dart';
import 'package:chatify/features/chats/ui/widgets/message_time_widget.dart';
import 'package:chatify/features/contacts/data/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:chatify/core/theming/colors.dart';
import 'package:chatify/core/theming/styles.dart';
import 'package:chatify/features/chats/data/models/message_model.dart';
import 'package:chatify/features/chats/logic/cubit/chat_cubit.dart';

class MessageItem extends StatelessWidget {
  final Message message;
  final bool isSentByMe;
  final ContactModel contact;

  const MessageItem({
    Key? key,
    required this.message,
    required this.isSentByMe,
    required this.contact,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isSentByMe &&
        message.status != 'seen' &&
        message.status != 'uploading') {
      context
          .read<ChatCubit>()
          .markMessageAsSeenAndResetUnreadCount(message.id);
    }

    return Column(
      children: [
        Row(
          //to make message info fitted with chat container
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (isSentByMe && !message.isDeleted) _buildMessageInfo(),
            _buildChatContainerWithMessageTime(),
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
              ? DeletedMessageWidget(isSentByMe: isSentByMe, iconSize: 20)
              : Container(
                  // to avoid the overflow of text
                  constraints: BoxConstraints(maxWidth: 250.w),
                  child: message.type == 'text'
                      ? _buildMessageText()
                      : _buildFileMessage(),
                ),
        ),
        message.type == 'text' ? _buildMessageStatusIcon() : const SizedBox()
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
                if (message.status != 'uploading') {
                  context
                      .read<ChatCubit>()
                      .updateDeletedMessages(message, message.receiverId);
                } else {
                  context
                      .read<ChatCubit>()
                      .deleteMessagePermanently(message.id);
                }
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

  Widget _buildChatContainerWithMessageTime() {
    if (message.status == 'uploading' && !isSentByMe) {
      return const SizedBox();
    } else {
      return Column(
        crossAxisAlignment: isSentByMe
            //to change the direction of message time according to the direction of chat container
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          _buildChatContainer(),

          MessageTimeWidget(
              messageTime: message.time!,
              messageStyle: AppStyles.font12DarkGrey500Weight),
          // ),
        ],
      );
    }
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
      } else {
        _positionedMessageStatusIcon(Icons.watch_later_outlined, Colors.white);
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

  Widget _buildUploadingMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          textAlign: TextAlign.center,
          'UPLOADING',
          style: AppStyles.font18Black600Weight.copyWith(
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(
          width: 10.w,
        ),
        AnimatedTextKit(
          animatedTexts: [
            WavyAnimatedText('....', textStyle: AppStyles.font25BlackBold),
          ],
          repeatForever: true,
        )
      ],
    );
  }

  Widget _buildFileMessage() {
    if (message.status == 'uploading') {
      return _buildUploadingMessage();
    } else {
      return Stack(
        children: [
          if (message.type == 'image')
            ChatroomImageMessage(
                contact: contact, message: message, isSentByMe: isSentByMe),
          if (message.type == 'video')
            ChatroomVideoMessage(
                message: message, isSentByMe: isSentByMe, contact: contact),
          if (message.type == 'document')
            ChatroomDocumentMessage(message: message, isSentByMe: isSentByMe),
          _buildMessageStatusIcon()
        ],
      );
    }
  }

  Widget _buildMessageText() {
    return Text(
      message.text,
      style: isSentByMe
          ? AppStyles.font15White500Weight
          : AppStyles.font15Black500Weight,
    );
  }
}
