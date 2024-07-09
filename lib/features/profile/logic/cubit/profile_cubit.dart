import 'dart:io';

import 'package:chatify/core/helpers/shared_preferences.dart';
import 'package:chatify/features/profile/data/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  String? savedUserPhoto, savedUserAbout;
  String? temporaryUploadedUserPhoto;
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
      if (savedUserPhoto != profilePictureUrl) {
        await _profileRepository.updateUserProfilePic(
            profilePictureUrl: profilePictureUrl);
        savedUserPhoto = await SharedPreferencesHelper.getString('userPhoto');
      }
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
      emit(ProfilePictureLoadingState());
      final String profilePictureUrl =
          await _profileRepository.uploadAndfetchUserPhoto(
              file: imageFile, fileName: 'uploadedUserPhoto');
      temporaryUploadedUserPhoto = profilePictureUrl;
      emit(TemporaryUserPhotoUploadedState(
          profilePictureUrl: profilePictureUrl));
    }
  }

  void getSavedProfileData() async {
    savedUserPhoto = await SharedPreferencesHelper.getString('userPhoto');
    savedUserAbout = await SharedPreferencesHelper.getString('userAbout');
    aboutController.text = savedUserAbout ?? '';
    debugPrint('savedProfilePictureUrl: $savedUserPhoto');
    if (savedUserPhoto != null && savedUserAbout != null) {
      emit(SavedUserProfileDataLoadedState(
          profilePictureUrl: savedUserPhoto!, userAbout: savedUserAbout!));
    }
  }

  void changeUserAbout(String newAbout) async {
    emit(UserAboutChangedState(
      isUserAboutChanged: true,
    ));
    userAboutChanged = true;

    aboutController.text = newAbout;
  }
}
