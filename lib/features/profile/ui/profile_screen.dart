import '../../../core/helpers/dimensions.dart';
import '../../../core/theming/styles.dart';
import 'widgets/save_changes_button.dart';
import 'widgets/username_with_circle_avatar.dart';
import 'widgets/user_data_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/cubit/profile_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    context.read<ProfileCubit>().getUserAbout();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Profile',
          style: AppStyles.font18Black600Weight,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Column(
            children: [
              const UserNameWithCircleAvatar(),
              AppDimensions.verticalSpacing50,
              const UserDataFields(),
              AppDimensions.verticalSpacing100,
              const SaveChangesButton()
            ],
          ),
        ),
      ),
    );
  }
}
