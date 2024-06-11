import 'package:chatify/core/widgets/back_button_widget.dart';
import 'package:chatify/features/chats/data/models/message_model.dart';
import 'package:chatify/features/chats/ui/widgets/vertical_swipe_back_navigator.dart';
import 'package:chatify/features/contacts/data/contact_model.dart';
import 'package:flutter/material.dart';

import '../../../../core/theming/styles.dart';

class ImageMessageScreen extends StatefulWidget {
  final Message imageMessage;
  final bool isSentByMe;
  final ContactModel contact;

  const ImageMessageScreen(
      {super.key,
      required this.imageMessage,
      required this.isSentByMe,
      required this.contact});

  @override
  State<ImageMessageScreen> createState() => _ImageMessageScreenState();
}

class _ImageMessageScreenState extends State<ImageMessageScreen> {
  bool _showAppBar = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _showAppBar
          ? AppBar(
              backgroundColor: Colors.black,
              leading: const BackButtonWidget(color: Colors.white),
              title: Column(
                children: [_buildImageSenderName(), _buildImageMessageTime()],
              ),
            )
          : null,
      body: SafeArea(
        child: VerticalSwipeBackNavigator(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showAppBar = !_showAppBar;
              });
            },
            child: Center(
              child: Hero(
                  tag: widget.imageMessage.id,
                  child: Image(image: NetworkImage(widget.imageMessage.text))),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSenderName() {
    return Text(
        widget.contact.name.isNotEmpty
            ? widget.isSentByMe
                ? 'You'
                : widget.contact.name
            : widget.contact.phoneNumber.toString(),
        style: AppStyles.font15White500Weight);
  }

  Text _buildImageMessageTime() {
    final formattedTime = widget.imageMessage.time!.toDate();
    return Text(
      '${formattedTime.hour.toString().padLeft(2, '0')}:${formattedTime.minute.toString().padLeft(2, '0')}',
      style: AppStyles.font15White500Weight,
    );
  }
}
