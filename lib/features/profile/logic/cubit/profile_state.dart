part of 'profile_cubit.dart';

sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

class ProfileUpdatingState extends ProfileState {}

class ProfilePictureLoadingState extends ProfileState {}

class UserAboutChangedState extends ProfileState {
  final bool isUserAboutChanged;

  UserAboutChangedState({this.isUserAboutChanged = false});
}

class TemporaryUserPhotoUploadedState extends ProfileState {
  final String profilePicturePath;

  TemporaryUserPhotoUploadedState({required this.profilePicturePath});
}

class UserPhotoUploadingState extends ProfileState {}

class ProfileUpdateSuccessState extends ProfileState {}
