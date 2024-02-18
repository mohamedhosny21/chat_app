import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../../../widgets/shared_preferences.dart';

part 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit() : super(ContactsInitial());
  final database = FirebaseFirestore.instance;

  Future<List<Contact>> showFilteredContacts() async {
    try {
      // Request contact permission
      final requestPermission = await FlutterContacts.requestPermission();
      emit(ContactsLoadingState());

      if (requestPermission) {
        FlutterContacts.addListener(() => debugPrint('Contact DB changed'));

        //get all contacts
        List<Contact> deviceContacts = await FlutterContacts.getContacts(
            withPhoto: true, withProperties: true);

        // Extract phone numbers from device contacts
        final devicePhoneNumbers = extractPhoneNumbers(deviceContacts);
        // Split phone numbers into chunks
        final chunks = splitPhoneNumbersIntoChunks(devicePhoneNumbers);
        // Get filtered contacts based on phone number chunks
        return getFilteredContacts(chunks, deviceContacts);
      } else {
        emit(ContactsErrorState(errorMsg: 'Permission Denied'));
        throw Exception('Permission Denied');
      }
    } catch (error) {
      emit(ContactsErrorState(errorMsg: error.toString()));
      throw Exception(error.toString());
    }
  }

  List<String> extractPhoneNumbers(List<Contact> deviceContacts) {
    return deviceContacts
        .expand((contact) =>
            contact.phones.map((phoneNumber) => phoneNumber.normalizedNumber))
        .toList();
  }

  /// Split phone numbers into chunks of 30
  List<List<String>> splitPhoneNumbersIntoChunks(
      List<String> devicePhoneNumbers) {
    // Firestore supports a maximum of 30 elements in the "WhereIn" filter,
    //  and it seems the list of phone numbers from the device contacts exceeds this limit.
    // To address this, you can split the list into chunks and perform multiple queries.
    const chunkSize = 30;

    final totalChunks = (devicePhoneNumbers.length / chunkSize).ceil();
//create a list that takes the data of phone numbers starting from start index till end index until the end of list length
//so, the 1st chunk takes value from (0,29),2nd(30,59) until reaches the length of device phone numbers
    final chunks = List.generate(
      totalChunks,
      (index) {
        final startIndex = index * chunkSize;
        final endIndex = startIndex + chunkSize;

        return devicePhoneNumbers.sublist(
          startIndex,
          endIndex < devicePhoneNumbers.length
              ? endIndex
              : devicePhoneNumbers.length,
        );
      },
    );
    return chunks;
  }

  Future<List<Contact>> getFilteredContacts(
      List<List<String>> chunks, List<Contact> deviceContacts) async {
    final String loggedPhoneNumber =
        await AppSharedPreferences.getPhoneNumberFromSharedPrefs();
    debugPrint('logged phone : $loggedPhoneNumber');
    // Query Firestore for each chunk
    List<Contact> filteredContacts = [];
    for (final chunk in chunks) {
      //get the documents that matches the value of field phone_number with the numbers in each chunk
      QuerySnapshot existingPhoneNumbers = await database
          .collection("Users")
          .where("phone_number", whereIn: chunk)
          .get();

      filteredContacts.addAll(deviceContacts.where((contact) {
        // Check if the contact has at least one phone number
        if (contact.phones.isNotEmpty &&
            contact.phones.first.normalizedNumber != loggedPhoneNumber) {
          //after getting the document above.it extracts the data from it
          return existingPhoneNumbers.docs.any((doc) =>
              doc['phone_number'] == contact.phones.first.normalizedNumber);
        }
        return false;
      }).toList());
    }
    emit(ContactsLoadedState(contacts: filteredContacts));
    debugPrint(filteredContacts
        .map((e) => e.phones.map((e) => e.normalizedNumber))
        .toString());
    return filteredContacts;
  }
}
 /****************Example for chunk Calcuation***************/
         /* 
         *Suppose devicePhoneNumbers.length is 120, and chunkSize is 30.
         * then : ((120 + 30 - 1) / 30).ceil() = (149 / 30).ceil() = 5
         * So, we need 5 chunks to cover all elements in devicePhoneNumbers.
         * 
         * For each index from 0 to 4 (in our example), it generates a sublist from devicePhoneNumbers based on the calculated start and end indices.
         * For index = 0:
Start index: 0 * 30 = 0
End index: 0+30 = 30 (less than devicePhoneNumbers.length, so it takes 30 elements)
*For index = 1:
Start index: 1 * 30 = 30
End index: 30+30 = 60 (less than devicePhoneNumbers.length, so it takes 30 elements)
*For index = 2:
Start index: 2 * 30 = 60
End index: 60+30 = 90 (less than devicePhoneNumbers.length, so it takes 30 elements)
*For index = 3:
Start index: 3 * 30 = 90
End index: 90+30 = 120 (equals devicePhoneNumbers.length, so it takes the remaining 30 elements)
*For index = 4:
Start index: 4 * 30 = 120
End index: 120+30 = 150 (greater than devicePhoneNumbers.length, so it takes the remaining 0 elements)
So, we end up with 5 chunks, each containing the specified number of elements from devicePhoneNumbers, and the last chunk may contain fewer elements if needed.*/