part of 'contacts_cubit.dart';

sealed class ContactsState {}

final class ContactsInitial extends ContactsState {}

final class ContactsLoadingState extends ContactsState {}

final class ContactsLoadedState extends ContactsState {
  final List<Contact> filteredContacts;
  final List<String> filteredContactsId;

  ContactsLoadedState(
      {required this.filteredContacts, required this.filteredContactsId});
}

final class ContactsErrorState extends ContactsState {
  final String errorMsg;

  ContactsErrorState({required this.errorMsg});
}
