import 'package:chatify/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../../../../widgets/shared_preferences.dart';

part 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit() : super(ContactsInitial());

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
        final devicePhoneNumbers =
            extractPhoneNumbersFromDeviceContacts(deviceContacts);
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

  List<String> extractPhoneNumbersFromDeviceContacts(
      List<Contact> deviceContacts) {
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
        await AppSharedPreferences.getSavedPhoneNumber();
    debugPrint('logged phone : $loggedPhoneNumber');
    List<Contact> filteredContacts = [];
    // Query Firestore for each chunk
    for (final chunk in chunks) {
      //get the documents that matches the value of field phone_number with the numbers in each chunk
      QuerySnapshot phoneNumberQueryResult = await AppConstants.database
          .collection("Users")
          .where("phone_number", whereIn: chunk)
          .get();

      //add the device contacts that has no empty phone numbers and without my logged number then checks these filtered numbers with phone numbers in firestore
      filteredContacts.addAll(deviceContacts.where((contact) {
        if (contact.phones.isNotEmpty &&
            contact.phones.first.normalizedNumber != loggedPhoneNumber) {
          return phoneNumberQueryResult.docs.any((doc) =>
              doc['phone_number'] == contact.phones.first.normalizedNumber);
        }
        return false;
      }).toList());
    }
    final filteredContactId = await getFilteredContactsId(filteredContacts);

    emit(ContactsLoadedState(
        filteredContactsId: filteredContactId,
        filteredContacts: filteredContacts));

    return filteredContacts;
  }

  Future<List<String>> getFilteredContactsId(
      List<Contact> filteredContacts) async {
    final allUsersDocuments =
        await AppConstants.database.collection("Users").get();
    List<String> filteredPhoneNumbers = filteredContacts
        .expand(
            (contact) => contact.phones.map((phone) => phone.normalizedNumber))
        .toList();
// filters the documents from the "Users" collection based on whether their 'phone_number' is in the filteredPhoneNumbers list, and then it extracts the id of each matching document
    List<String> matchedContactIds = [];

    for (String filterPhoneNumber in filteredPhoneNumbers) {
      // Find the document with the matching phone number
      var matchingDocument = allUsersDocuments.docs
          .firstWhere((doc) => doc['phone_number'] == filterPhoneNumber);
      matchedContactIds.add(matchingDocument.id);
      // If a matching document is found, add its ID to the list
    }
    debugPrint(matchedContactIds.toString());
    debugPrint(filteredPhoneNumbers.toString());
    return matchedContactIds;
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