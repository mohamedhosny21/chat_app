import 'dart:async';

import '../notifications_manager/data/notifications_repository.dart';
import '../notifications_manager/data/notifications_webservices.dart';
import '../../features/home/chats/logic/cubit/chat_cubit.dart';
import '../../features/home/chats/data/repository/chat_repository.dart';
import '../../features/contacts/data/repository/contact_repository.dart';
import '../../features/contacts/logic/cubit/contacts_cubit.dart';
import '../../features/login/logic/cubit/authentication_cubit.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/logic/cubit/profile_cubit.dart';
import '../../features/home/stories/data/repository/stories_repository.dart';
import 'package:get_it/get_it.dart';

import '../../features/home/stories/logic/cubit/stories_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  final ChatRepository chatRepository = ChatRepository();
  final ContactRepository contactRepository = ContactRepository();
  final NotificationsWebservices notificationsWebservices =
      NotificationsWebservices();
  final ProfileRepository profileRepository = ProfileRepository();
  final StoriesRepository storiesRepository = StoriesRepository();

  getIt.registerFactory<AuthenticationCubit>(() => AuthenticationCubit());
  getIt.registerFactory<ChatCubit>(() => ChatCubit(chatRepository));
  getIt.registerFactory<ContactsCubit>(() => ContactsCubit(contactRepository));
  getIt.registerLazySingleton<NotificationsRepository>(() =>
      NotificationsRepository(
          notificationsWebservices: notificationsWebservices));
  getIt.registerFactory<ProfileCubit>(() => ProfileCubit(profileRepository));
  getIt.registerFactory<StoriesCubit>(() => StoriesCubit(storiesRepository));
}
