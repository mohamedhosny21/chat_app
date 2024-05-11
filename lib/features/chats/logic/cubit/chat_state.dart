// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_cubit.dart';

sealed class ChatState {}

final class ChatInitial extends ChatState {}

class MessageErrorState extends ChatState {}

class OnGoingChatsLoadedState extends ChatState {
  final List<OnGoingChat> onGoingChats;
  OnGoingChatsLoadedState({required this.onGoingChats});
}

class MessagesLoadedState extends ChatState {
  final List<Message> messages;

  MessagesLoadedState({required this.messages});
}
