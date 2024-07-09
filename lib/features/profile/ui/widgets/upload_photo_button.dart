import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theming/colors.dart';
import '../../logic/cubit/profile_cubit.dart';

class UploadPhotoButton extends StatelessWidget {
  const UploadPhotoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            color: AppColors.lightPink, shape: BoxShape.circle),
        child: IconButton(
            onPressed: () {
              context.read<ProfileCubit>().pickPhotoFromGallery();
            },
            icon: const Icon(Icons.add_a_photo_outlined)));
  }
}
