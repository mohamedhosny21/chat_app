import 'chats/logic/cubit/chat_cubit.dart';
import 'chats/ui/widgets/chat_lists.dart';
import 'stories/logic/cubit/stories_cubit.dart';
import 'stories/ui/widgets/add_story_container.dart';
import '../../core/app_router/routes.dart';
import '../../core/helpers/constants/app_constants.dart';
import '../../core/theming/colors.dart';
import '../../core/helpers/dimensions.dart';
import '../../core/theming/styles.dart';
import '../login/logic/cubit/authentication_cubit.dart';
import 'stories/ui/widgets/user_stories_list.dart';
import '../../core/widgets/textformfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ChatCubit chatCubit;
  @override
  void initState() {
    super.initState();
    chatCubit = context.read<ChatCubit>();
    chatCubit.getOnGoingChats();
    chatCubit.listenToContacts();
    context.read<StoriesCubit>().getUsersStories();
  }

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
                  child: CircleAvatar(
                    backgroundImage: chatCubit.currentUser?.photoURL != null
                        ? NetworkImage(chatCubit.currentUser!.photoURL!)
                            as ImageProvider
                        : const AssetImage(AppConstants.defaultUserPhoto),
                  ),
                )
              ],
            ),
            AppDimensions.verticalSpacing20,
            const UserStories(),
            const Divider(),
            AppDimensions.verticalSpacing10,
            SearchTextFormField(
              searchController: chatCubit.searchController,
            ),
            AppDimensions.verticalSpacing20,
            const ChatLists()
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.lighterPink,
          onPressed: () {
            Navigator.pushNamed(context, Routes.contactsScreen);
          },
          child: Icon(
            Icons.add_comment_outlined,
            size: 24.w,
          )),
    );
  }
}
