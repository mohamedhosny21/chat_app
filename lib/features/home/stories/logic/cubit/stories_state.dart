part of 'stories_cubit.dart';

sealed class StoriesState {}

final class StoriesInitial extends StoriesState {}

class StoryUploadingState extends StoriesState {}

class StoryUploadedState extends StoriesState {
  final StoryModel story;

  StoryUploadedState({required this.story});
}

class StoryPickedState extends StoriesState {
  final PlatformFile file;

  StoryPickedState({required this.file});
}

class UsersStoriesLoadedState extends StoriesState {
  final List<StoryModel> usersStories;

  UsersStoriesLoadedState({required this.usersStories});
}
