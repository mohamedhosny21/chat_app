import 'package:chatify/constants/colors.dart';
import 'package:chatify/constants/styles.dart';
import 'package:chatify/features/user_chat/widgets/user_chat_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserChatScreen extends StatelessWidget {
  final Contact contact;
  const UserChatScreen({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_sharp,
          ),
          iconSize: 24.w,
        ),
        title: Text(
          contact.displayName.isNotEmpty
              ? contact.displayName
              : contact.phones
                  .map(
                      (devicePhoneNumber) => devicePhoneNumber.normalizedNumber)
                  .toString(),
          style: AppStyles.font18Black600Weight,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
            color: AppColors.mainBlack,
            iconSize: 24.w,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
            iconSize: 24.w,
            color: AppColors.mainBlack,
          )
        ],
      ),
      body: UserChatItem(),
    );
  }
}
