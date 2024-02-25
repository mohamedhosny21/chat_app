import 'package:chatify/constants/colors.dart';
import 'package:chatify/constants/styles.dart';
import 'package:chatify/features/user_chat/data/user_chat_model.dart';
import 'package:chatify/features/user_chat/logic/cubit/messages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserChatItem extends StatelessWidget {
  final Message message;
  final bool isSentByMe;

  const UserChatItem(
      {super.key, required this.message, required this.isSentByMe});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            //to make message info fitted with chat container
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              // The scope of this if statement is limited to the following IconButton
              if (isSentByMe) _buildMessageInfo(),
              // This Widget is included in both cases
              _buildChatContainerWithMessageTime(),
              // The scope of this if statement is limited to the following IconButton
              if (!isSentByMe) _buildMessageInfo(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatContainer() {
    return ChatBubble(
      clipper: ChatBubbleClipper6(
          type: isSentByMe ? BubbleType.sendBubble : BubbleType.receiverBubble),
      backGroundColor: isSentByMe ? AppColors.pink : Colors.white,
      child: Text(
        message.text,
        style: isSentByMe
            ? AppStyles.font15White500Weight
            : AppStyles.font15White500Weight
                .copyWith(color: AppColors.mainBlack),
      ),
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
              context
                  .read<MessagesCubit>()
                  .deleteMessages(message.recieverId, message.id);
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
    return Align(
      alignment: isSentByMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Text(
        '${message.time.toDate().hour.toString().padLeft(2, '0')}:${message.time.toDate().minute.toString().padLeft(2, '0')}',
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
}
