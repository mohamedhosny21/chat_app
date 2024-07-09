import 'dart:io';

import 'package:chatify/core/helpers/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _firebaseAuth = FirebaseAuth.instance;
  Future<File?> pickPhotoFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Future<TaskSnapshot> _uploadUserPhotoToCloudStorage(
      {required File file, required String fileName}) async {
    final currentUser = _firebaseAuth.currentUser;
    final Reference reference = _storage
        .ref()
        .child('UsersProfilePics')
        .child(currentUser!.uid)
        .child(fileName);
    return await reference.putFile(file);
  }

  Future<String> _getUserPhotoUrlFromCloudStorage(
      TaskSnapshot uploadTask) async {
    // final currentUser = _firebaseAuth.currentUser;

    // final Reference reference = _storage
    //     .ref()
    //     .child('UsersProfilePics')
    //     .child(currentUser!.uid)
    //     .child('newUserPhoto.png');
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String> uploadAndfetchUserPhoto(
      {required File file, required String fileName}) async {
    final uploadTask =
        await _uploadUserPhotoToCloudStorage(file: file, fileName: fileName);
    debugPrint('new user photo has been uploaded');
    return await _getUserPhotoUrlFromCloudStorage(uploadTask);
  }

  Future<void> updateUserProfilePic({required String profilePictureUrl}) async {
    final currentUser = _firebaseAuth.currentUser;
    currentUser!.updatePhotoURL(profilePictureUrl);
    await _firestore
        .collection('Users')
        .doc(currentUser.uid)
        .update({'photo': profilePictureUrl});
    await SharedPreferencesHelper.setString('userPhoto', profilePictureUrl);
  }

  // Future<void> _updateUserChatPhoto(
  //     {required String profilePictureUrl}) async {
  //       final currentUser=_firebaseAuth.currentUser;
  //       await _firestore.collection("O")
  //     }

  Future<void> updateUserAbout({required String userAbout}) async {
    final currentUser = _firebaseAuth.currentUser;
    if (userAbout.isNotEmpty) {
      await _firestore
          .collection('Users')
          .doc(currentUser!.uid)
          .update({'about': userAbout});
      await SharedPreferencesHelper.setString('userAbout', userAbout);
    }
  }
}
