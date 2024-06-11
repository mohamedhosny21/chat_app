// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/message_model.dart';

class MessageTimeWidget extends StatelessWidget {
  final Timestamp messageTime;
  final TextStyle messageStyle;
  const MessageTimeWidget({
    Key? key,
    required this.messageTime,
    required this.messageStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      _showMostRecentMessageTime(messageTime),
      style: messageStyle,
    );
  }

  String _showMostRecentMessageTime(Timestamp messageTime) {
    final DateTime dateTime = messageTime.toDate().toLocal();
    final formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
    final now = DateFormat('dd/MM/yyyy').format(DateTime.now().toLocal());
    final yesterday = DateFormat('dd/MM/yyyy').format(
        DateTime.now().toLocal().subtract(const Duration(days: 1)).toLocal());

    // final DateTime messageDate =
    //     DateTime(dateTime.year, dateTime.month, dateTime.day);
    // final currentDate =
    //     DateTime(now.year, now.month, now.day).toLocal().toString();
    // final yesterdayDate =
    //     DateTime(yesterday.year, yesterday.month, yesterday.day)
    //         .toLocal()
    //         .toString();

    if (formattedDate == now) {
      final localTime = messageTime.toDate().toLocal();
      return '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';
    } else if (formattedDate == yesterday) {
      return 'Yesterday';
    } else {
      return formattedDate;
    }
  }
}
