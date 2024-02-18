import 'package:chatify/constants/strings.dart';
import 'package:chatify/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app_router/routes.dart';

class ContactItem extends StatelessWidget {
  final Contact contact;
  const ContactItem({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.userChatScreen, arguments: contact);
      },
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 30.r,
              child: contact.photo != null
                  ? Image.asset(contact.photo.toString())
                  : Image.asset(AppConstants.defaultUserPhoto),
            ),
            title: Text(
              contact.displayName.isNotEmpty
                  ? contact.displayName
                  : contact.phones
                      .map((devicePhoneNumber) =>
                          devicePhoneNumber.normalizedNumber)
                      .toString(),
              style: AppStyles.font25BlackBold.copyWith(fontSize: 16.sp),
            ),
          )
        ],
      ),
    );
  }
}
