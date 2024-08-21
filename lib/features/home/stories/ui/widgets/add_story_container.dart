import '../../../../../core/helpers/dimensions.dart';
import '../../logic/cubit/stories_cubit.dart';
import 'user_story_container.dart';
import 'user_story_name.dart';
import 'package:dashed_circle/dashed_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/app_router/routes.dart';
import '../../../../../core/theming/colors.dart';
import 'add_story_button.dart';

class AddStoryContainer extends StatefulWidget {
  const AddStoryContainer({
    super.key,
  });

  @override
  AddStoryContainerState createState() => AddStoryContainerState();
}

class AddStoryContainerState extends State<AddStoryContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> base;
  late Animation<double> reverse;
  late StoriesCubit _storiesCubit;
  @override
  void initState() {
    super.initState();
    _initializeAnimationController();
    _storiesCubit = context.read<StoriesCubit>();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimationController() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    base = CurvedAnimation(parent: _animationController, curve: Curves.linear);
    reverse = Tween<double>(begin: 0.0, end: -1.0).animate(base)
      ..addListener(() {
        setState(() {});
      });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocConsumer<StoriesCubit, StoriesState>(
              listener: (context, state) {
                if (state is StoryUploadingState) {
                  _animationController.repeat();
                } else if (state is StoryUploadedState) {
                  _animationController.stop();

                  Navigator.pushNamed(
                    context,
                    Routes.storyViewScreen,
                    arguments: [state.story],
                  );
                }
              },
              builder: (context, state) {
                if (state is StoryUploadingState) {
                  return Container(
                    alignment: Alignment.topLeft,
                    child: RotationTransition(
                      turns: base,
                      child: DashedCircle(
                        strokeWidth: 3.w,
                        color: AppColors.darkPink,
                        child: RotationTransition(
                          turns: reverse,
                          child: StoryContainer(
                            userProfilePicture:
                                _storiesCubit.currentUser?.photoURL,
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (state is StoryUploadedState) {
                  return StoryContainer(
                    userProfilePicture: _storiesCubit.currentUser?.photoURL,
                    borderGradientColors: const [
                      AppColors.moreLighterPink,
                      AppColors.darkPink
                    ],
                  );
                }

                return StoryContainer(
                  userProfilePicture: _storiesCubit.currentUser?.photoURL,
                );
              },
            ),
            AppDimensions.verticalSpacing5,
            const UserStoryName(userName: 'Your Story'),
          ],
        ),
        const AddStoryButton()
      ],
    );
  }
}
