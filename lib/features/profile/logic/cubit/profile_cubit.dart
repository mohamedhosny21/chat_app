import 'dart:io';

import '../../data/profile_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  String? temporaryUploadedUserPhoto;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  File? imageFile;
  bool userAboutChanged = false;
  final TextEditingController aboutController = TextEditingController();

  ProfileCubit(this._profileRepository) : super(ProfileInitial());
  void updateUserProfile() async {
    debugPrint('my File :$imageFile');
    if (imageFile != null) {
      emit(UserPhotoUploadingState());
      final String profilePictureUrl = await _profileRepository
          .uploadAndfetchUserPhoto(file: imageFile!, fileName: 'newUserPhoto');
      await _profileRepository.updateUserProfilePic(
          profilePictureUrl: profilePictureUrl);
    }
    if (userAboutChanged) {
      await _profileRepository.updateUserAbout(
        userAbout: aboutController.text,
      );
      userAboutChanged = false;
    }
    emit(ProfileUpdateSuccessState());
    imageFile = null;
  }

  void pickPhotoFromGallery() async {
    final File? imageFile = await _profileRepository.pickPhotoFromGallery();
    this.imageFile = imageFile;
    if (imageFile != null) {
      temporaryUploadedUserPhoto = imageFile.path;
      emit(TemporaryUserPhotoUploadedState(profilePicturePath: imageFile.path));
    }
  }

  void getUserAbout() async {
    final String userAbout = await _profileRepository.getUserAbout();
    aboutController.text = userAbout;
  }

  void changeUserAbout(String newAbout) async {
    emit(UserAboutChangedState(
      isUserAboutChanged: true,
    ));
    userAboutChanged = true;

    aboutController.text = newAbout;
  }
}
