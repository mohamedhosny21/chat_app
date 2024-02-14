part of 'contacts_cubit.dart';

sealed class ContactsState {}

final class ContactsInitial extends ContactsState {}

final class ContactsLoadingState extends ContactsState {}

final class ContactsLoadedState extends ContactsState {
  final List<Contact> contacts;

  ContactsLoadedState({required this.contacts});
}

final class ContactsErrorState extends ContactsState {
  final String errorMsg;

  ContactsErrorState({required this.errorMsg});
}
