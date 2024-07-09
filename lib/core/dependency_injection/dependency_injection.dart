import 'dart:async';

import 'package:chatify/core/notifications_manager/data/notifications_repository.dart';
import 'package:chatify/core/notifications_manager/data/notifications_webservices.dart';
import 'package:chatify/features/chats/logic/cubit/chat_cubit.dart';
import 'package:chatify/features/chats/data/repository/chat_repository.dart';
import 'package:chatify/features/contacts/data/repository/contact_repository.dart';
import 'package:chatify/features/contacts/logic/cubit/contacts_cubit.dart';
import 'package:chatify/features/login/logic/cubit/authentication_cubit.dart';
import 'package:chatify/features/profile/data/profile_repository.dart';
import 'package:chatify/features/profile/logic/cubit/profile_cubit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  final ChatRepository chatRepository = ChatRepository();
  final ContactRepository contactRepository = ContactRepository();
  final NotificationsWebservices notificationsWebservices =
      NotificationsWebservices();
  final ProfileRepository profileRepository = ProfileRepository();

  getIt.registerFactory<AuthenticationCubit>(() => AuthenticationCubit());
  getIt.registerFactory<ChatCubit>(() => ChatCubit(chatRepository));
  getIt.registerFactory<ContactsCubit>(() => ContactsCubit(contactRepository));
  getIt.registerLazySingleton<NotificationsRepository>(() =>
      NotificationsRepository(
          notificationsWebservices: notificationsWebservices));
  getIt.registerFactory<ProfileCubit>(() => ProfileCubit(profileRepository));
}
