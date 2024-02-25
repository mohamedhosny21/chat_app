import 'package:chatify/constants/colors.dart';
import 'package:chatify/constants/dimensions.dart';
import 'package:chatify/constants/styles.dart';
import 'package:chatify/features/user_chat/data/user_chat_model.dart';
import 'package:chatify/features/user_chat/logic/cubit/messages_cubit.dart';
import 'package:chatify/features/user_chat/widgets/user_chat_item_widget.dart';
import 'package:chatify/widgets/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart';

import '../../widgets/textformfield_widget.dart';

class UserChatScreen extends StatefulWidget {
  final Contact contact;
  final String contactId;
  const UserChatScreen(
      {super.key, required this.contact, required this.contactId});

  @override
  State<UserChatScreen> createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  late MessagesCubit messagesCubit;
  late String senderId;
  final Uuid uuid = const Uuid();

  @override
  void initState() {
    _loadUserId();
    messagesCubit = context.read<MessagesCubit>();
    print('reciever id : ${widget.contactId}');
    messagesCubit.getMessages(widget.contactId);
    super.initState();
  }

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_sharp,
          ),
          iconSize: 24.w,
        ),
        title: _appBarTitle(),
        actions: _appBarActions(),
      ),
      body: Stack(children: [
        BlocBuilder<MessagesCubit, MessagesState>(
          builder: (context, state) {
            if (state is MessagesLoadedState) {
              if (state.messages.isNotEmpty) {
                return Padding(
                  padding: AppDimensions.paddingBottom100Top50,
                  child: ListView.separated(
                    reverse: true,
                    itemBuilder: (context, index) => UserChatItem(
                      message: state.messages[index],
                      isSentByMe: senderId == state.messages[index].senderId,
                    ),
                    separatorBuilder: (context, index) =>
                        AppDimensions.verticalSpacing10,
                    itemCount: state.messages.length,
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    'No Messages',
                    style: AppStyles.font20GreyBold,
                  ),
                );
              }
            }
            return const SizedBox();
          },
        ),
        _buildMessageInputContainer()
      ]),
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
      onPressed: () {
        if (_messageController.text.isNotEmpty) {
          print('see $senderId');

          final Message message = Message(
              id: uuid.v1(),
              senderId: senderId,
              recieverId: widget.contactId,
              text: _messageController.text,
              type: 'text',
              time: Timestamp.fromDate(DateTime.timestamp()));
          messagesCubit.sendMessage(message);
          print('reee  + ${message.recieverId}');

          _messageController.clear();
        }
      },
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

  void _loadUserId() async {
    senderId = await AppSharedPreferences.getSavedLoggedUserId();
  }

  List<Widget> _appBarActions() {
    return [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.call),
        color: AppColors.mainBlack,
        iconSize: 24.w,
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.videocam_rounded),
        iconSize: 24.w,
        color: AppColors.mainBlack,
      ),
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.more_horiz),
        iconSize: 24.w,
        color: AppColors.mainBlack,
      )
    ];
  }

  Widget _appBarTitle() {
    return Text(
      widget.contact.displayName.isNotEmpty
          ? widget.contact.displayName
          : widget.contact.phones
              .map((devicePhoneNumber) => devicePhoneNumber.normalizedNumber)
              .toString(),
      style: AppStyles.font18Black600Weight,
    );
  }
}
