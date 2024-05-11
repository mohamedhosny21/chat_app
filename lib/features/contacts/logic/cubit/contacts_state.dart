part of 'contacts_cubit.dart';

sealed class ContactsState {}

class ContactsInitial extends ContactsState {}

class ContactsLoadedState extends ContactsState {
  final List<ContactModel> filteredContacts;

  ContactsLoadedState({required this.filteredContacts});
}

class ContactsErrorState extends ContactsState {
  final String errorMsg;

  ContactsErrorState({required this.errorMsg});
}
