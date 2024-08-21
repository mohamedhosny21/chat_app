import 'dart:io';

import '../../../../../core/helpers/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

import '../model/story_model.dart';

class StoriesRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final String _uuid = const Uuid().v1();
  Future<PlatformFile?> pickFileFromDevice() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'mp4', 'avi', 'mov']);

    if (result != null) {
      final PlatformFile platformFile = result.files.single;

      return platformFile;
    }

    return null;
  }

  Future<TaskSnapshot> _uploadFileToCloudStorage(
      {required File file, required String fileName}) async {
    final currentUserId = _firebaseAuth.currentUser!.uid;
    final Reference reference = _storage
        .ref()
        .child('Stories')
        .child(currentUserId)
        .child(_uuid + fileName);
    return await reference.putFile(file);
  }

  Future<String> _downloadFileFromCloudStorage(TaskSnapshot uploadTask) async {
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String> _uploadFileAndGetUrl(
      {required File file, required String fileName}) async {
    final TaskSnapshot uploadTask =
        await _uploadFileToCloudStorage(file: file, fileName: fileName);
    return await _downloadFileFromCloudStorage(uploadTask);
  }

  Future<List<StoryModel>> getMyStories() async {
    final currentUser = _firebaseAuth.currentUser;
    final QuerySnapshot querySnapshot = await _firestore
        .collection('Stories')
        .doc(currentUser!.uid)
        .collection('StoryItems')
        .get();

    final List<StoryModel> myStories = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return StoryModel.fromMap(data);
    }).toList();
    return myStories;
  }

//TODO : combine stories of same user
//TODO : show story to each user in case each one save the phone number of the other
//TODO : stories availablity for 24 hours
//TODO : update isViewed in case story is viewed
  Future<StoryModel> addStory(
      {required String content,
      required String storyType,
      int? videoDuration,
      String? storyTextColor}) async {
    final currentUser = _firebaseAuth.currentUser;
    // final List<StoryModel> myStories;
    final String storyId = _uuid;
    final StoryModel newStory = StoryModel(
        id: storyId,
        userId: currentUser!.uid,
        content: content,
        textColor: storyTextColor,
        userPhoneNumber: currentUser.phoneNumber!,
        type: storyType,
        isViewed: false,
        videoDuration: videoDuration,
        userProfilePicture: currentUser.photoURL);

    final DocumentReference addedStoryReference = await _firestore
        .collection('Stories')
        .doc(currentUser.uid)
        .collection('StoryItems')
        .add(newStory.toMap());
    final DocumentSnapshot addedStorySnapshot = await addedStoryReference.get();
    final StoryModel newAddedStory =
        StoryModel.fromMap(addedStorySnapshot.data() as Map<String, dynamic>);
    return newAddedStory;
  }

  Future<StoryModel> addFileStory(
      {required String filePath,
      required String fileType,
      required String fileName,
      int? videoDuration}) async {
    MediaInfo? compressedVideo;
    if (fileType.videoType) {
      compressedVideo = await VideoCompress.compressVideo(filePath);
    }
    final File file = compressedVideo?.file ?? File(filePath);
    final String fileUrl =
        await _uploadFileAndGetUrl(file: file, fileName: fileName);
    final StoryModel newAddedStory = await addStory(
        content: fileUrl, storyType: fileType, videoDuration: videoDuration);
    return newAddedStory;
  }

  Future<List<String>> _extractPhoneNumbersFromContacts(
      {required List<Contact> deviceContacts}) async {
    final currentUser = _firebaseAuth.currentUser;
    final phoneNumbers = deviceContacts
        .expand((contact) =>
            contact.phones.map((phoneNumber) => phoneNumber.normalizedNumber))
        .toList();
    final filteredPhoneNumbers = phoneNumbers
        .where((phoneNumber) => phoneNumber != currentUser!.phoneNumber)
        .toList();
    return filteredPhoneNumbers;
  }

  Future<List<List<String>>> splitPhoneNumbersIntoChunks(
      {required List<Contact> deviceContacts}) async {
    final List<String> contactsPhoneNumbers =
        await _extractPhoneNumbersFromContacts(deviceContacts: deviceContacts);

    const chunkSize = 30;

    final totalChunks = (contactsPhoneNumbers.length / chunkSize).ceil();

    final chunks = List.generate(
      totalChunks,
      (index) {
        final startIndex = index * chunkSize;
        final endIndex = startIndex + chunkSize;

        return contactsPhoneNumbers.sublist(
          startIndex,
          endIndex < contactsPhoneNumbers.length
              ? endIndex
              : contactsPhoneNumbers.length,
        );
      },
    );
    return chunks;
  }

  Future<List<Contact>> getDeviceContats() async {
    return await FlutterContacts.getContacts(withProperties: true);
  }

  Future<List<String>> getUsersIdByDevicePhoneNumbers(
      {required List<Contact> deviceContacts}) async {
    final phoneNumbersChunks =
        await splitPhoneNumbersIntoChunks(deviceContacts: deviceContacts);
    final List<String> usersId = [];
    for (List<String> phoneNumbers in phoneNumbersChunks) {
      final usersIdSnapshots = await _firestore
          .collection('Users')
          .where('phone_number', whereIn: phoneNumbers)
          .get();
      if (usersIdSnapshots.docs.isNotEmpty) {
        for (var usersIdSnapshots in usersIdSnapshots.docs) {
          final String userId = usersIdSnapshots.id;
          usersId.add(userId);

          print('usersId : $usersId');
        }
      }
    }
    debugPrint('usersId : $usersId');
    return usersId;
  }
}
