import 'dart:io';

import '../../../../../core/helpers/utils_functions.dart';
import '../../../../../core/theming/styles.dart';
import '../../data/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/colors.dart';
import '../../logic/cubit/chat_cubit.dart';

class UploadingMessageWidget extends StatelessWidget {
  final Message message;
  const UploadingMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.type != 'document') {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.file(
            File(message.text),
          ),
          const CircularProgressIndicator(
            color: AppColors.mainBlack,
          ),
          IconButton(
            onPressed: () {
              context.read<ChatCubit>().deleteMessagePermanently(message.id);
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
            ),
            iconSize: 30.w,
          ),
        ],
      );
    } else {
      final String documentName = FileUtils.extractFileName(message.text);
      return ListTile(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.mainBlack,
            ),
            IconButton(
              onPressed: () {
                context.read<ChatCubit>().deleteMessagePermanently(message.id);
              },
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white,
              ),
              iconSize: 25.w,
            ),
          ],
        ),
        title: Text(documentName,
            style: AppStyles.font15White500Weight
                .copyWith(fontWeight: FontWeight.bold)),
      );
    }
  }
}
