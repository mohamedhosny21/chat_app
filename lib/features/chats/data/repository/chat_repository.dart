import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

import '../../../../core/helpers/constants.dart';
import '../../../contacts/data/contact_model.dart';
import '../models/message_model.dart';
import '../models/ongoing_chat_model.dart';

class ChatRepository {
  final _firestoreDatabase = FirebaseFirestore.instance;
  final _cloudStorageDatabase = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();
  String chatId = '';
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      updateMessageSnapshot;

  Future<void> getChatId(String receiverId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    List<String> participentsId = [currentUser!.uid, receiverId];
    //sort is essential so if the sender and receiverId are exchanged with each other then the chatid will be the same id without creating new chat id due to the exchange of their ids
    participentsId.sort();
    debugPrint('particepents : $participentsId');

    chatId = participentsId.join('_');
    debugPrint('chat id : $chatId');
  }

  Future<Message> sendMessage(
      {required ContactModel contact,
      required String messageText,
      String? thumbnailVideoUrl,
      required String messageType,
      required String status}) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    final Message newMessage = Message(
      id: _uuid.v1(),
      senderId: currentUser!.uid,
      receiverId: contact.id,
      text: messageText,
      thumbnailVideoUrl: thumbnailVideoUrl,
      type: messageType,
      status: status,
      isDeleted: false,
    );

    final addedDocument = await _firestoreDatabase
        .collection("Chat_Rooms")
        .doc(chatId)
        .collection("Messages")
        .add(newMessage.toMap());
    if (newMessage.status != 'uploading') {
      final newMessageSnapshot = await addedDocument.get();

      final newMessage = Message.fromMap(newMessageSnapshot.data()!);
      _addChatModelToDatabase(contact: contact, mostRecentMessage: newMessage);
      return newMessage;
    }
    return newMessage;
  }

  Future<void> markMessageAsSeenAndResetUnreadCount(String messageId) async {
    await updateMessageStatus(messageId, 'seen');
    await resetUnreadMessagesCount();
  }

  void updateDeletedMessages(Message message, String receiverId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    _updateMessagesData(messageId: message.id, updates: {'isDeleted': true});
    final querySnapshot = await _firestoreDatabase
        .collection("Chat_Rooms")
        .doc(chatId)
        .collection("Messages")
        .orderBy('time', descending: true)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      _updateOngoingChatsData(
          messageId: message.id,
          userId: currentUser!.uid,
          updates: {'isLastMessageDeleted': true});
      _updateOngoingChatsData(
          messageId: message.id,
          userId: receiverId,
          updates: {'isLastMessageDeleted': true});
    }

    if (message.type != 'text') {
      _deleteFileFromCloudStorage(message.text);
    }
  }

  Future<void> deleteMessagePermanently(String messageId) async {
    final messageSnapshot = await _firestoreDatabase
        .collection('Chat_Rooms')
        .doc(chatId)
        .collection('Messages')
        .limit(1)
        .where('id', isEqualTo: messageId)
        .get();

    if (messageSnapshot.docs.first.exists) {
      await _firestoreDatabase
          .collection('Chat_Rooms')
          .doc(chatId)
          .collection('Messages')
          .doc(messageSnapshot.docs.first.id)
          .delete();
    }
  }

  Future<void> _updateOngoingChatsData(
      {required String messageId,
      required String userId,
      required Map<String, dynamic> updates}) async {
    try {
      final querySnapshot = await _firestoreDatabase
          .collection("OngoingChats")
          .doc(userId)
          .collection("Conversations")
          .where('lastMessageId', isEqualTo: messageId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        _firestoreDatabase
            .collection("OngoingChats")
            .doc(userId)
            .collection("Conversations")
            .doc(querySnapshot.docs.first.id)
            .update(updates);
      }
    } catch (error) {
      throw Exception('Error updating ongoing message data $error');
    }
  }

  Future<void> _updateMessagesData({
    required String messageId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final querySnapshot = await _firestoreDatabase
          .collection("Chat_Rooms")
          .doc(chatId)
          .collection("Messages")
          .where('id', isEqualTo: messageId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await _firestoreDatabase
            .collection("Chat_Rooms")
            .doc(chatId)
            .collection("Messages")
            .doc(querySnapshot.docs.first.id)
            .update(updates);
      }
    } catch (error) {
      throw Exception("Error updating message data: $error");
    }
  }

  Future<void> updateMessageStatus(String messageId, String status) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    String peerUserId =
        chatId.replaceAll(currentUser!.uid, '').replaceAll('_', '');
    await _updateMessagesData(
        messageId: messageId, updates: {'status': status});
    await _updateOngoingChatsData(
        messageId: messageId,
        userId: peerUserId,
        updates: {'lastMessageStatus': status});
    await _updateOngoingChatsData(
        messageId: messageId,
        userId: currentUser.uid,
        updates: {'lastMessageStatus': status});
  }

  Future<int> _getUnreadMessagesCount(String receiverId) async {
    final unreadMessagesSubscription = await _firestoreDatabase
        .collection("Chat_Rooms")
        .doc(chatId)
        .collection("Messages")
        .where('receiverId', isEqualTo: receiverId)
        .where('status', isNotEqualTo: 'seen')
        .get();

    final int unreadMessagesCount = unreadMessagesSubscription.size;

    return unreadMessagesCount;
    /** Future<int> _getUnreadMessagesCount(String receiverId) async {
    //Completer : handle asynchronous operations. It provides a way to produce values that will be available in the future.
    final Completer<int> completer = Completer<int>();

    final StreamSubscription<QuerySnapshot> unreadMessagesSubscription =
        _firestoreDatabase
            .collection("Chat_Rooms")
            .doc(chatId)
            .collection("Messages")
            .where('receiverId', isEqualTo: receiverId)
            .where('status', isNotEqualTo: 'seen')
            .snapshots()
            .listen((unreadMessagesCountSnapshots) {
      final int unreadMessagesCount = unreadMessagesCountSnapshots.size;
      //When unreadMessagesCount has the value , we complete the Completer with that count. This makes the count available as the future's value.
      completer.complete(unreadMessagesCount);
    });
    //we pause the execution of _addReceiverChatModelToDatabase until the future is completed.
    final int unreadMessagesCount = await completer.future;
    await unreadMessagesSubscription.cancel();

    return unreadMessagesCount;
  }
 */
  }

  Future<void> resetUnreadMessagesCount() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    await _firestoreDatabase
        .collection("OngoingChats")
        .doc(currentUser!.uid)
        .collection("Conversations")
        .doc(chatId)
        .update({'unreadMessagesCount': 0});
  }

  void _addSenderChatModelToDatabase(
      {required ContactModel contact,
      required Message mostRecentMessage}) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    final OnGoingChat senderOnGoingChatModel = OnGoingChat.fromSenderData(
      contact: contact,
      id: contact.id,
      phoneNumber: contact.phoneNumber,
      profilePicture: contact.profilePicture ?? AppConstants.defaultUserPhoto,
      mostRecentMessage: mostRecentMessage,
    );

    await _firestoreDatabase
        .collection("OngoingChats")
        .doc(
          currentUser!.uid,
        )
        .collection("Conversations")
        .doc(chatId)
        .set(senderOnGoingChatModel.toMap());
  }

  void _addReceiverChatModelToDatabase(
      {required ContactModel contact,
      required Message mostRecentMessage}) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    final int unreadMessagesCount = await _getUnreadMessagesCount(contact.id);

    final OnGoingChat receiverOnGoingChatModel = OnGoingChat.fromReceiverData(
        id: currentUser!.uid,
        phoneNumber: currentUser.phoneNumber!,
        profilePicture: currentUser.photoURL ?? AppConstants.defaultUserPhoto,
        mostRecentMessage: mostRecentMessage,
        unreadMessagesCount: unreadMessagesCount);

    await _firestoreDatabase
        .collection("OngoingChats")
        .doc(contact.id)
        .collection("Conversations")
        .doc(chatId)
        .set(receiverOnGoingChatModel.toMap());
  }

  Future<void> _addChatModelToDatabase(
      {required ContactModel contact,
      required Message mostRecentMessage}) async {
    _addSenderChatModelToDatabase(
        contact: contact, mostRecentMessage: mostRecentMessage);
    _addReceiverChatModelToDatabase(
        contact: contact, mostRecentMessage: mostRecentMessage);
  }

  Future<List<Contact>> getDeviceContacts() async {
    return await FlutterContacts.getContacts(withProperties: true);
  }

  Future<void> pickAndSendImage(ContactModel contact) async {
    final FilePickerResult? image = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.image);
    if (image != null) {
      for (var file in image.files) {
        final File imageFile = File(file.path!);
        _sendFileMessage(
            fileName: file.name,
            file: imageFile,
            cloudDirectoryPath: 'Images',
            messageType: 'image',
            contact: contact);
      }
    }
  }

  Future<void> pickAndSendVideo(ContactModel contact) async {
    final FilePickerResult? video = await FilePicker.platform
        .pickFiles(allowMultiple: true, type: FileType.video);
    if (video != null) {
      for (var file in video.files) {
        final videoFile = File(file.path!);
        final compressedVideoFile = await _compressVideo(videoFile);
        final thumbnailVideo =
            await _getThumbnailVideo(compressedVideoFile.file!, contact);
        _sendFileMessage(
            fileName: file.name,
            thumbnailVideo: thumbnailVideo,
            file: compressedVideoFile.file!,
            cloudDirectoryPath: 'Videos',
            messageType: 'video',
            contact: contact);
      }
    }
  }

  Future<void> pickAndSendDocument(ContactModel contact) async {
    final FilePickerResult? document = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt']);
    if (document != null) {
      for (var file in document.files) {
        final documentFile = File(file.path!);
        _sendFileMessage(
            fileName: file.name,
            file: documentFile,
            cloudDirectoryPath: 'Documents',
            messageType: 'document',
            contact: contact);
      }
    }
  }

  String extractFileName(String url) {
    Uri uri = Uri.parse(url);
    String fileName = uri.pathSegments.last;

    // If the filename contains a query string, remove it
    if (fileName.contains('/')) {
      fileName = fileName.split('/').last;
    }
    return fileName;
  }

  void _sendFileMessage(
      {required File file,
      required String cloudDirectoryPath,
      required String fileName,
      File? thumbnailVideo,
      required String messageType,
      required ContactModel contact}) async {
    final newMessage = await sendMessage(
        contact: contact,
        thumbnailVideoUrl: thumbnailVideo?.path,
        messageText: 'Uploading....',
        messageType: messageType,
        status: 'uploading');
    String? fileUrl = await _uploadFileAndGetUrl(
      fileName: fileName,
      file: file,
      cloudDirectoryPath: cloudDirectoryPath,
    );
    String? thumbnailVideoUrl = await _uploadFileAndGetUrl(
      fileName: fileName,
      file: thumbnailVideo,
      cloudDirectoryPath: 'Thumbnails',
    );
    await _updateMessagesData(messageId: newMessage.id, updates: {
      'text': fileUrl,
      'status': 'sent',
      'thumbnailVideoUrl': thumbnailVideoUrl
    });
    await _updateChatModelWithNewMessage(newMessage.id, contact);
  }

  Future<String?> _uploadFileAndGetUrl(
      {required File? file,
      required String cloudDirectoryPath,
      required String fileName}) async {
    if (file != null) {
      final String filePath = '${_uuid.v1()}/$fileName';
      final reference =
          _cloudStorageDatabase.ref().child(cloudDirectoryPath).child(filePath);
      debugPrint('file name :$filePath');
      final uploadTask = await _uploadFileToCloudStorage(reference, file);
      final fileUrl = await _getDownloadedCloudFileUrl(uploadTask);
      return fileUrl;
    } else {
      return null;
    }
  }

  Future<void> _updateChatModelWithNewMessage(
      String messageId, ContactModel contact) async {
    final querySnapshot = await _firestoreDatabase
        .collection('Chat_Rooms')
        .doc(chatId)
        .collection('Messages')
        .where('id', isEqualTo: messageId)
        .limit(1)
        .get();
    _addChatModelToDatabase(
        contact: contact,
        mostRecentMessage: Message.fromMap(querySnapshot.docs.first.data()));
  }

  Future<TaskSnapshot> _uploadFileToCloudStorage(
      Reference reference, File file) async {
    return await reference.putFile(file);
  }

  Future<String> _getDownloadedCloudFileUrl(TaskSnapshot uploadTask) async {
    final String fileUrl = await uploadTask.ref.getDownloadURL();
    debugPrint('real url :$fileUrl');
    return fileUrl;
  }

  Future<void> _deleteFileFromCloudStorage(String fileUrl) async {
    try {
      final ref = _cloudStorageDatabase.refFromURL(fileUrl);
      await ref.delete();
      debugPrint('deleted file url :$fileUrl');
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<MediaInfo> _compressVideo(File file) async {
    final compressedVideo =
        await VideoCompress.compressVideo(file.path, includeAudio: true);
    return compressedVideo!;
  }

  Future<File> _getThumbnailVideo(File videoPath, ContactModel contact) async {
    debugPrint('video path :$videoPath');

    final thumbnailPath = await VideoCompress.getFileThumbnail(
      videoPath.path,
      quality: 50,
    );
    debugPrint('thumb path :$thumbnailPath');
    return thumbnailPath;
  }

  Future<void> viewDocumentFile(String fileUrl) async {
    final url = Uri.parse(fileUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
