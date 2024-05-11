import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../contact_model.dart';

class ContactRepository {
  final firestoreDatabase = FirebaseFirestore.instance;
  List<ContactModel> filteredContacts = [];

  final String? loggedPhoneNumber =
      FirebaseAuth.instance.currentUser?.phoneNumber;

  Future<bool> requestContactsPermission() async {
    await FlutterContacts.requestPermission();
    return true;
  }

  Future<List<Contact>> getDeviceContacts() async {
    return FlutterContacts.getContacts(withPhoto: true, withProperties: true);
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
}
