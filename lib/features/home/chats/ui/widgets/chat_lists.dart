import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/helpers/dimensions.dart';
import '../../../../../core/theming/styles.dart';
import '../../logic/cubit/chat_cubit.dart';
import 'chat_item_widget.dart';

class ChatLists extends StatelessWidget {
  const ChatLists({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          if (state is OnGoingChatsLoadedState) {
            if (state.onGoingChats.isNotEmpty) {
              return ListView.separated(
                itemBuilder: (context, index) => GestureDetector(
                  child: ChatItem(
                    onGoingChat: state.onGoingChats[index],
                    isSentByMe: state.onGoingChats[index].lastMessageSenderId ==
                        context.read<ChatCubit>().currentUser!.uid,
                  ),
                ),
                separatorBuilder: (context, index) =>
                    AppDimensions.verticalSpacing16,
                itemCount: state.onGoingChats.length,
              );
            }
            return Center(
              child: Text(
                'No Chats',
                style: AppStyles.font25GreyBold,
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
