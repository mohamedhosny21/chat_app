import '../../../../../core/helpers/dimensions.dart';
import '../../data/model/story_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../../../core/theming/colors.dart';
import 'user_story_container.dart';
import 'user_story_name.dart';

class UserStoryItem extends StatelessWidget {
  final StoryModel userStory;
  const UserStoryItem({super.key, required this.userStory});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StoryContainer(
          userProfilePicture: userStory.userProfilePicture,
          borderGradientColors: const [
            AppColors.moreLighterPink,
            AppColors.darkPink
          ],
        ),
        AppDimensions.verticalSpacing5,
        UserStoryName(
          userName: userStory.userName ?? userStory.userPhoneNumber,
        ),
      ],
    );
  }
}
