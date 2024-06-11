import 'package:chatify/features/chats/data/models/message_model.dart';
import 'package:flutter/material.dart';

import '../../../../core/app_router/routes.dart';
import '../../../../core/helpers/constants.dart';
import '../../../contacts/data/contact_model.dart';

class ChatroomImageMessage extends StatelessWidget {
  final Message message;
  final ContactModel contact;
  final bool isSentByMe;
  const ChatroomImageMessage(
      {super.key,
      required this.message,
      required this.contact,
      required this.isSentByMe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.imageMessageScreen, arguments: {
          'contact': contact,
          'imageMessage': message,
          'isSentByMe': isSentByMe
        });
      },
      child: Hero(
        tag: message.id,
        child: FadeInImage.assetNetwork(
            placeholder: isSentByMe
                ? AppConstants.senderLoadingGif
                : AppConstants.receiverLoadingGif,
            image: message.text),
      ),
    );
  }
}
