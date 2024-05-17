import 'package:chatify/features/chats/logic/cubit/chat_cubit.dart';

import '../../../../core/app_router/routes.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/helpers/dimensions.dart';
import '../../../../core/theming/styles.dart';
import '../../../login/logic/authentication_cubit/authentication_cubit.dart';
import '../widgets/chat_item_widget.dart';
import '../widgets/story_container_widget.dart';
import '../../../../core/widgets/textformfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  late ChatCubit chatCubit;
  @override
  void initState() {
    super.initState();
    chatCubit = context.read<ChatCubit>();
    chatCubit.getOnGoingChats();
    chatCubit.listenToContacts();
  }

  // @override
  // void dispose() {
  //   context.read<ChatCubit>().closeListener();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: AppDimensions.paddingSymmetricV14H10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Conversations',
                  style: AppStyles.font18Black600Weight,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    context.read<AuthenticationCubit>().signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, Routes.loginScreen, (route) => false);
                  },
                  child: const CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://th.bing.com/th/id/OIP.NqY3rNMnx2NXYo3KJfg43gAAAA?w=183&h=183&c=7&r=0&o=5&dpr=1.4&pid=1.7'),
                  ),
                )
              ],
            ),
            AppDimensions.verticalSpacing20,
            const UserStories(),
            const Divider(),
            AppDimensions.verticalSpacing10,
            SearchTextFormField(),
            AppDimensions.verticalSpacing20,
            _buildChatsList()
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.lightPink,
          onPressed: () {
            Navigator.pushNamed(context, Routes.contactsScreen);
          },
          child: Icon(
            Icons.add_comment_outlined,
            size: 24.w,
          )),
    );
  }

  Widget _buildChatsList() {
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
                        chatCubit.currentUser!.uid,
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
