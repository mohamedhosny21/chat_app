import 'package:chatify/constants/colors.dart';
import 'package:chatify/constants/dimensions.dart';
import 'package:chatify/constants/styles.dart';
import 'package:chatify/widgets/textformfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class UserChatItem extends StatelessWidget {
  final TextEditingController _messageController = TextEditingController();

  bool isRowMainAxisAlignmentEnd = true;

  UserChatItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: AppDimensions.paddingTop50,
              child: Row(
                //to make message info fitted with chat container
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: isRowMainAxisAlignmentEnd
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  // The scope of this if statement is limited to the following IconButton
                  if (isRowMainAxisAlignmentEnd) _buildMessageInfo(),
                  // This Widget is included in both cases
                  _buildChatContainerWithMessageTime(),
                  // The scope of this if statement is limited to the following IconButton
                  if (!isRowMainAxisAlignmentEnd) _buildMessageInfo(),
                ],
              ),
            ),
          ],
        ),
        _buildMessageInputContainer()
      ],
    );
  }

  Widget _buildChatContainer() {
    return SizedBox(
      child: ChatBubble(
        clipper: ChatBubbleClipper6(
            type: isRowMainAxisAlignmentEnd
                ? BubbleType.sendBubble
                : BubbleType.receiverBubble),
        backGroundColor: AppColors.pink,
        child: Text(
          'Hello, My Friend',
          style: AppStyles.font15White500Weight,
        ),
      ),
    );
  }

  IconButton _buildMessageInfo() {
    return IconButton(
      onPressed: () {},
      icon: const Icon(Icons.more_horiz_rounded),
      iconSize: 20.w,
      color: AppColors.mainGrey,
    );
  }

  Widget _buildMessageTime() {
    return Align(
      alignment: isRowMainAxisAlignmentEnd
          ? Alignment.centerLeft
          : Alignment.centerRight,
      child: Text(
        '2:00',
        style: AppStyles.font12DarkGrey500Weight,
      ),
    );
  }

  IconButton _buildAddButton() {
    return IconButton(
      onPressed: () {},
      icon: const Icon(Icons.add),
      iconSize: 24.w,
      color: AppColors.mainGrey,
    );
  }

  AppTextFormField _buildMessageTextFormField() {
    return AppTextFormField(
        width: 279,
        height: 36,
        hintText: 'Write a message ...',
        color: AppColors.lighterGrey,
        controller: _messageController);
  }

  IconButton _buildSendMessageButton() {
    return IconButton(
      onPressed: () {},
      icon: const Icon(Icons.send),
      iconSize: 24.w,
      color: AppColors.pink,
    );
  }

  Widget _buildMessageInputContainer() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 83.46.h,
        width: 375.w,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow color
            spreadRadius: 5, // Spread radius
            blurRadius: 10, // Blur radius
            offset: Offset(0, 2.h), // Offset in the y direction
          )
        ]),
        child: Center(
            child: Row(
          children: [
            _buildAddButton(),
            _buildMessageTextFormField(),
            _buildSendMessageButton(),
          ],
        )),
      ),
    );
  }

  Widget _buildChatContainerWithMessageTime() {
    return Column(
      crossAxisAlignment: isRowMainAxisAlignmentEnd
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
