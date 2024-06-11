import 'dart:async';

import 'package:chatify/features/contacts/data/repository/contact_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../data/contact_model.dart';

part 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  final ContactRepository _contactRepository;
  final firestoreDatabase = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _contactsSubscription;

  final String loggedPhoneNumber =
      FirebaseAuth.instance.currentUser!.phoneNumber!;

  List<ContactModel> filteredContacts = [];

  ContactsCubit(this._contactRepository) : super(ContactsInitial());
  void listenChangedContacts() {
    FlutterContacts.addListener(() {
      showFilteredContacts();
      debugPrint('Contact Listener added');
    });
  }

  Future<void> showFilteredContacts() async {
    try {
      final requestPermission =
          await _contactRepository.requestContactsPermission();

      if (requestPermission) {
        List<Contact> deviceContacts =
            await _contactRepository.getDeviceContacts();
        final devicePhoneNumbers = _contactRepository
            .extractPhoneNumbersFromDeviceContacts(deviceContacts);
        final chunks =
            _contactRepository.splitPhoneNumbersIntoChunks(devicePhoneNumbers);

        _getFilteredContacts(chunks, deviceContacts);
      } else {
        emit(ContactsErrorState(errorMsg: 'Permission Denied'));
        throw Exception('Permission Denied');
      }
    } catch (error) {
      emit(ContactsErrorState(errorMsg: error.toString()));
      throw Exception(error.toString());
    }
  }

  Future<void> _getFilteredContacts(
      List<List<String>> chunks, List<Contact> deviceContacts) async {
    filteredContacts.clear();
    for (final chunk in chunks) {
      await _listenContacts(
        chunk: chunk,
        deviceContacts: deviceContacts,
      );
    }
  }

  Future<void> _listenContacts({
    required List<String> chunk,
    required List<Contact> deviceContacts,
  }) async {
    _contactsSubscription = firestoreDatabase
        .collection("Users")
        .where("phone_number", whereIn: chunk)
        .snapshots()
        .listen((phoneNumberQueryResult) {
      _updateFilteredContacts(
        deviceContacts: deviceContacts,
        phoneNumberQueryResult: phoneNumberQueryResult,
      );
    });
  }

  Future<void> _updateFilteredContacts({
    required QuerySnapshot<Map<String, dynamic>> phoneNumberQueryResult,
    required List<Contact> deviceContacts,
  }) async {
    debugPrint('logged phone : $loggedPhoneNumber');
    for (var doc in phoneNumberQueryResult.docs) {
      final phoneDeviceContacts = deviceContacts.where((contact) =>
          contact.phones.isNotEmpty &&
          contact.phones
              .any((phone) => phone.normalizedNumber == doc['phone_number']));
      if (phoneDeviceContacts.isNotEmpty) {
        final contact = phoneDeviceContacts.first;
        if (loggedPhoneNumber != doc['phone_number']) {
          final newContact = ContactModel(
            id: doc.id,
            name: contact.displayName,
            profilePicture: doc.data()['photo'],
            phoneNumber: doc['phone_number'].toString(),
          );
          if (!filteredContacts.any((contact) => contact.id == newContact.id)) {
            filteredContacts.add(newContact);
          }
        }
      }
    }

    filteredContacts.sort((a, b) => a.name.compareTo(b.name));
    emit(ContactsLoadedState(filteredContacts: filteredContacts));
  }

  @override
  Future<void> close() async {
    _contactsSubscription?.cancel();
    FlutterContacts.removeListener(
        () => debugPrint('Contact Listener removed'));
    debugPrint('contacts cubit closed');
    return super.close();
  }
}
