import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';

class ContactItem extends StatelessWidget {
  final Contact contact;
  const ContactItem({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(contact.photo.toString()),
            ),
            Text(contact.displayName)
          ],
        )
      ],
    );
  }
}
