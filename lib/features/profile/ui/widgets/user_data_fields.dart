import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/dimensions.dart';
import '../../../../core/widgets/textformfield_widget.dart';
import '../../logic/cubit/profile_cubit.dart';

class UserDataFields extends StatelessWidget {
  const UserDataFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileTextFormField(
          hintText: 'About',
          prefixIcon: Icons.info,
          suffixIcon: Icons.edit,
          controller: context.read<ProfileCubit>().aboutController,
          onChanged: (newUserAbout) {
            context.read<ProfileCubit>().changeUserAbout(newUserAbout);
          },
        ),
        AppDimensions.verticalSpacing50,
        ProfileTextFormField(
          initialValue: FirebaseAuth.instance.currentUser!.phoneNumber,
          prefixIcon: Icons.phone,
          contentPadding: EdgeInsets.symmetric(
            vertical:
                (36.h - 50.h), // Adjust based on font size and container height
          ),
          readOnly: true,
        ),
      ],
    );
  }
}
