import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

part 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit() : super(ContactsInitial());

  Future<List<Contact>> getContactsFromPhone() async {
    emit(ContactsLoadingState());
    // Request contact permission
    try {
      final requestPermission = await FlutterContacts.requestPermission();
      if (requestPermission) {
        //get all contacts
        List<Contact> contacts =
            await FlutterContacts.getContacts(withPhoto: true);
        emit(ContactsLoadedState(contacts: contacts));
        return contacts;
      } else {
        emit(ContactsErrorState(errorMsg: 'Permission Denied'));
        throw Exception('Permission Denied');
      }
    } catch (error) {
      emit(ContactsErrorState(errorMsg: error.toString()));
      throw Exception(error.toString());
    }
  }
}
