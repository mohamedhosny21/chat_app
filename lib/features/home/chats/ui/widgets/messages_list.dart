import '../../../../contacts/data/contact_model.dart';
import '../../logic/cubit/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theming/styles.dart';
import '../../data/models/message_model.dart';
import 'message_item_widget.dart';
import 'messages_group_header_label.dart';

class MessagesList extends StatelessWidget {
  final List<Message> messages;
  final ContactModel contact;
  const MessagesList(
      {super.key, required this.messages, required this.contact});

  @override
  Widget build(BuildContext context) {
    if (messages.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: GroupedListView<Message, String>(
          elements: messages,
          groupBy: (message) => _showGroupLabel(message),
          //to ensure that "Today" and "Yesterday" appear at the top, followed by other dates in descending order.
          groupComparator: (group1, group2) => _sortMessagesGroupLabels(group1,
              group2), //the order of items within each group are ordered in descending order of their timestamps (newest first)
          itemComparator: (item1, item2) => item2.time!.compareTo(item1.time!),
          reverse: true,
          stickyHeaderBackgroundColor: Colors.white,
          useStickyGroupSeparators: messages.length > 6 ? true : false,
          groupSeparatorBuilder: (messageDate) =>
              MessagesGroupHeaderLabel(messageDate: messageDate),
          indexedItemBuilder: (context, element, index) => MessageItem(
            contact: contact,
            message: messages[index],
            isSentByMe: messages[index].senderId ==
                context.read<ChatCubit>().currentUser!.uid,
          ),
        ),
      );
    }
    return Center(
      child: Text(
        'No Messages',
        style: AppStyles.font20GreyBold,
      ),
    );
  }

  int _sortMessagesGroupLabels(String group1, String group2) {
    if (group1 == 'Today') return -1;
    if (group2 == 'Today') return 1;
    if (group1 == 'Yesterday') return -1;
    if (group2 == 'Yesterday') return 1;
    if (group1.isEmpty || group2.isEmpty) {
      return group2.isEmpty
          ? -1
          : 1; // empty groups should be placed at the bottom
    }

    final DateTime date1 = DateFormat('dd/MM/yyyy').parse(group1);
    final DateTime date2 = DateFormat('dd/MM/yyyy').parse(group2);

    return date2.compareTo(date1);
  }

  String _showGroupLabel(Message message) {
    if (message.status != 'uploading') {
      final DateTime dateTime = message.time!.toDate().toLocal();
      final DateTime now = DateTime.now().toLocal();
      final DateTime startOfToday = DateTime(now.year, now.month, now.day);
      final DateTime startOfYesterday =
          startOfToday.subtract(const Duration(days: 1));

      if (dateTime.isAfter(startOfToday)) {
        return 'Today';
      } else if (dateTime.isAfter(startOfYesterday)) {
        return 'Yesterday';
      } else {
        return DateFormat('dd/MM/yyyy').format(dateTime);
      }
    } else {
      return '';
    }
  }
}
