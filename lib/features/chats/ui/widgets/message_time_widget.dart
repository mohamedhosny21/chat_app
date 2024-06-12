// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageTimeWidget extends StatelessWidget {
  final Timestamp messageTime;
  final TextStyle messageStyle;
  final bool isInChatroom;
  const MessageTimeWidget({
    Key? key,
    required this.messageTime,
    required this.messageStyle,
    required this.isInChatroom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      _showMessageTime(messageTime, isInChatroom),
      style: messageStyle,
    );
  }

  String _showMessageTime(Timestamp messageTime, bool isInChatroom) {
    final DateTime dateTime = messageTime.toDate().toLocal();
    final formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    final now = DateFormat('dd/MM/yyyy').format(DateTime.now().toLocal());
    final yesterday = DateFormat('dd/MM/yyyy').format(
        DateTime.now().toLocal().subtract(const Duration(days: 1)).toLocal());
    final localTime = messageTime.toDate().toLocal();
    final formattedTime =
        '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';

    // final DateTime messageDate =
    //     DateTime(dateTime.year, dateTime.month, dateTime.day);
    // final currentDate =
    //     DateTime(now.year, now.month, now.day).toLocal().toString();
    // final yesterdayDate =
    //     DateTime(yesterday.year, yesterday.month, yesterday.day)
    //         .toLocal()
    //         .toString();
    if (!isInChatroom) {
      if (formattedDate == now) {
        return formattedTime;
      } else if (formattedDate == yesterday) {
        return 'Yesterday';
      } else {
        return formattedDate;
      }
    }
    return formattedTime;
  }
}
