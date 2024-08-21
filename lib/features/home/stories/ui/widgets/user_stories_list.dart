import '../../data/model/story_model.dart';
import '../../logic/cubit/stories_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/app_router/routes.dart';
import '../../../../../core/helpers/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'add_story_container.dart';
import 'user_story_item.dart';

class UserStories extends StatelessWidget {
  const UserStories({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: BlocBuilder<StoriesCubit, StoriesState>(
        builder: (context, state) {
          if (state is UsersStoriesLoadedState) {
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(child: const AddStoryContainer());
                } else {
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, Routes.storyViewScreen,
                        arguments: state.usersStories),
                    child: UserStoryItem(
                      userStory: state.usersStories[index - 1],
                    ),
                  );
                }
              },
              separatorBuilder: (context, index) =>
                  AppDimensions.horizontalSpacing8,
              itemCount: state.usersStories.length + 1,
            );
          } else {
            final List<StoryModel> usersStories =
                context.read<StoriesCubit>().usersStories ?? [];

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return GestureDetector(child: const AddStoryContainer());
                } else {
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, Routes.storyViewScreen,
                        arguments: usersStories),
                    child: UserStoryItem(
                      userStory: usersStories[index - 1],
                    ),
                  );
                }
              },
              separatorBuilder: (context, index) =>
                  AppDimensions.horizontalSpacing8,
              itemCount: usersStories.length + 1,
            );
          }
        },
      ),
    );
  }
}
