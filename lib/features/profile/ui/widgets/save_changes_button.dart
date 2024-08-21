import '../../../../core/helpers/circular_progress_indicator.dart';
import '../../../../core/helpers/snackbar.dart';
import '../../../../core/theming/colors.dart';
import 'build_save_changes_button_widget.dart';
import 'build_unpressed_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubit/profile_cubit.dart';

class SaveChangesButton extends StatelessWidget {
  const SaveChangesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccessState) {
          Navigator.maybePop(context);
          showSuccessSnackBar(context, 'Profile updated successfully');
        } else if (state is UserPhotoUploadingState) {
          showCircularProgressIndicator(context, color: AppColors.darkPink);
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is UserAboutChangedState) {
            if (state.isUserAboutChanged) {
              return const BuildSaveChangesButtonWidget();
            } else {
              return const UnPressedButton();
            }
          } else if (state is TemporaryUserPhotoUploadedState) {
            return const BuildSaveChangesButtonWidget();
          }

          return const UnPressedButton();
        },
      ),
    );
  }
}
