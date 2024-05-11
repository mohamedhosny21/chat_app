import 'package:chatify/features/chats/logic/cubit/chat_cubit.dart';
import 'package:chatify/features/chats/data/repository/chat_repository.dart';
import 'package:chatify/features/contacts/data/repository/contact_repository.dart';
import 'package:chatify/features/contacts/logic/cubit/contacts_cubit.dart';
import 'package:chatify/features/login/logic/authentication_cubit/authentication_cubit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  final ChatRepository chatRepository = ChatRepository();
  final ContactRepository contactRepository = ContactRepository();

  getIt.registerFactory<AuthenticationCubit>(() => AuthenticationCubit());
  getIt.registerFactory<ChatCubit>(() => ChatCubit(chatRepository));
  getIt.registerFactory<ContactsCubit>(() => ContactsCubit(contactRepository));
}
