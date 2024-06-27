import 'package:chatify/core/helpers/constants/app_constants.dart';
import 'package:chatify/core/theming/styles.dart';
import 'package:chatify/features/contacts/data/contact_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/app_router/routes.dart';

class ContactItem extends StatelessWidget {
  final ContactModel contact;
  const ContactItem({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, Routes.chatRoomScreen, arguments: contact);
        debugPrint(contact.id.toString());
      },
      child: Column(
        children: [
          ListTile(
            leading: _contactPhoto(),
            subtitle: contact.name.isNotEmpty
                ? Text(contact.phoneNumber)
                : const SizedBox(),
            title: _contactName(),
          )
        ],
      ),
    );
  }

  CircleAvatar _contactPhoto() {
    return CircleAvatar(
      radius: 30.r,
      child: contact.profilePicture != null
          ? Image.asset(contact.profilePicture.toString())
          : Image.asset(AppConstants.defaultUserPhoto),
    );
  }

  Text _contactName() {
    return Text(
      contact.name.isNotEmpty ? contact.name : contact.phoneNumber.toString(),
      style: AppStyles.font25BlackBold.copyWith(fontSize: 16.sp),
    );
  }
}
