part of 'messages_cubit.dart';

sealed class MessagesState {}

final class MessagesInitial extends MessagesState {}

class MessageSentState extends MessagesState {}

class MessageErrorState extends MessagesState {}

class MessagesLoadedState extends MessagesState {
  final List<Message> messages;

  MessagesLoadedState({required this.messages});
}

class MessageDeletedState extends MessagesState {}
