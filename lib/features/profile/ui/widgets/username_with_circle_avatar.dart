import 'package:chatify/features/profile/logic/cubit/profile_cubit.dart';
import 'package:chatify/features/profile/ui/widgets/upload_photo_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/constants/app_constants.dart';
import '../../../../core/helpers/dimensions.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';

class UserNameWithCircleAvatar extends StatelessWidget {
  const UserNameWithCircleAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            _buildProfilePictureBlocBuilder(),
            const Positioned(
              right: 0,
              bottom: 0,
              child: UploadPhotoButton(),
            )
          ],
        ),
        AppDimensions.verticalSpacing10,
        Text(
          'You',
          style: AppStyles.font20BlackBold,
        ),
      ],
    );
  }

  BlocBuilder _buildProfilePictureBlocBuilder() {
    return BlocBuilder<ProfileCubit, ProfileState>(builder: (context, state) {
      if (state is ProfilePictureLoadingState) {
        return _buildCustomCircleAvatar(
            child: const CircularProgressIndicator(
          color: AppColors.darkPink,
        ));
      } else if (state is TemporaryUserPhotoUploadedState) {
        return _buildCustomCircleAvatar(
            image: NetworkImage(state.profilePictureUrl));
      }

      return _buildCustomCircleAvatar(
        image: context.read<ProfileCubit>().temporaryUploadedUserPhoto != null
            ? NetworkImage(
                    context.read<ProfileCubit>().temporaryUploadedUserPhoto!)
                as ImageProvider
            : context.read<ProfileCubit>().savedUserPhoto != null
                ? NetworkImage(context.read<ProfileCubit>().savedUserPhoto!)
                    as ImageProvider
                : const AssetImage(AppConstants.defaultUserPhoto),
      );
    });
  }

  CircleAvatar _buildCustomCircleAvatar(
      {ImageProvider<Object>? image, Widget? child}) {
    return CircleAvatar(
      backgroundColor: AppColors.lightGrey,
      backgroundImage: image,
      radius: 80.r,
      child: child,
    );
  }
}
