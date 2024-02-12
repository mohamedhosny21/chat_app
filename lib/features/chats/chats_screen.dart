import '../../app_router/routes.dart';
import '../../constants/colors.dart';
import '../../constants/dimensions.dart';
import '../../constants/styles.dart';
import '../login/logic/authentication_cubit/authentication_cubit.dart';
import 'ui/chats_widgets/chats_widget.dart';
import 'ui/chats_widgets/story_container_widget.dart';
import 'ui/chats_widgets/textformfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

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
                const CircleAvatar(
                  backgroundImage: NetworkImage(
                      'https://th.bing.com/th/id/OIP.NqY3rNMnx2NXYo3KJfg43gAAAA?w=183&h=183&c=7&r=0&o=5&dpr=1.4&pid=1.7'),
                )
              ],
            ),
            AppDimensions.verticalSpacing20,
            const UserStories(),
            const Divider(),
            AppDimensions.verticalSpacing10,
            SearchTextFormField(),
            AppDimensions.verticalSpacing20,
            const ChatsWidget()
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.mainPink,
          onPressed: () {
            context.read<AuthenticationCubit>().signOut();
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.loginScreen, (route) => false);
          },
          child: Icon(
            Icons.add_comment_outlined,
            size: 24.sp,
          )),
    );
  }
}
