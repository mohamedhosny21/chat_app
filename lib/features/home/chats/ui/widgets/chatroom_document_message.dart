import '../../../../../core/helpers/utils_functions.dart';
import '../../data/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/colors.dart';
import '../../../../../core/theming/styles.dart';
import '../../logic/cubit/chat_cubit.dart';

class ChatroomDocumentMessage extends StatelessWidget {
  final Message message;
  final bool isSentByMe;

  const ChatroomDocumentMessage(
      {super.key, required this.message, required this.isSentByMe});

  @override
  Widget build(BuildContext context) {
    final String documentName = FileUtils.extractFileName(message.text);
    return GestureDetector(
      onTap: () {
        context.read<ChatCubit>().viewDocumentFile(message.text);
      },
      child: ListTile(
        leading: Icon(
          Icons.insert_drive_file,
          color: isSentByMe ? Colors.white : AppColors.mainBlack,
          size: 40.w,
        ),
        title: Text(
          documentName,
          style: isSentByMe
              ? AppStyles.font15White500Weight
                  .copyWith(fontWeight: FontWeight.bold)
              : AppStyles.font15Black500Weight
                  .copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
