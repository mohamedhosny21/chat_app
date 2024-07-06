import 'dart:async';
import 'dart:io';

import 'package:chatify/core/dependency_injection/dependency_injection.dart';
import 'package:chatify/core/notifications_manager/data/models/notification_payload_model.dart';
import 'package:chatify/core/notifications_manager/data/notifications_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

import '../../../contacts/data/contact_model.dart';
import '../models/message_model.dart';
import '../models/ongoing_chat_model.dart';

class ChatRepository {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();
  String chatRoomId = '';

  Future<String> getChatRoomId(String receiverId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    List<String> participantsId = [currentUser!.uid, receiverId];
    //sort is essential so if the sender and receiverId are exchanged with each other then the chatRoomId will be the same id without creating new chat id due to the exchange of their ids
    participantsId.sort();
    debugPrint('particepents : $participantsId');

    chatRoomId = participantsId.join('_');
    debugPrint('chat id : $chatRoomId');
    getIt<NotificationsRepository>().setChatRoomId(chatRoomId);
    return chatRoomId;
  }

  Future<Message> sendMessage(
      {required ContactModel contact,
      required String messageText,
      required String messageType,
      required String status}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final Message newMessage = Message(
      id: _uuid.v1(),
      senderId: currentUser!.uid,
      receiverId: contact.id,
      text: messageText,
      type: messageType,
      status: status,
      isDeleted: false,
    );

    final addedDocument = await _firestore
        .collection("Chat_Rooms")
        .doc(chatRoomId)
        .collection("Messages")
        .add(newMessage.toMap());
    if (newMessage.status != 'uploading') {
      final newMessageSnapshot = await addedDocument.get();

      final newMessage = Message.fromMap(newMessageSnapshot.data()!);
      await _addChatModelToDatabase(
          contact: contact, mostRecentMessage: newMessage);
      final senderProfilePicture =
          await getIt<NotificationsRepository>().getSenderProfilePicture();
      await getIt<NotificationsRepository>().pushNotification(
        receiverId: contact.id,
        notificationPayloadModel: NotificationPayload(
            messageId: newMessage.id,
            messageText: newMessage.text,
            senderName: currentUser.displayName != ''
                ? currentUser.displayName!
                : currentUser.phoneNumber!,
            chatRoomId: chatRoomId,
            senderId: currentUser.uid,
            senderPhoneNumber: currentUser.phoneNumber!,
            senderProfilePicture: senderProfilePicture),
      );

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
    final querySnapshot = await _firestore
        .collection("Chat_Rooms")
        .doc(chatRoomId)
        .collection("Messages")
        .orderBy('time', descending: true)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      if (querySnapshot.docs.first.data()['id'] == message.id) {
        _updateOngoingChatsData(
            messageId: message.id,
            userId: currentUser!.uid,
            updates: {'isLastMessageDeleted': true});
        _updateOngoingChatsData(
            messageId: message.id,
            userId: receiverId,
            updates: {'isLastMessageDeleted': true});
      }
    }

    if (message.type != 'text') {
      _deleteFileFromCloudStorage(message.text);
    }
  }

  Future<void> deleteMessagePermanently(String messageId) async {
    final messageSnapshot = await _firestore
        .collection('Chat_Rooms')
        .doc(chatRoomId)
        .collection('Messages')
        .limit(1)
        .where('id', isEqualTo: messageId)
        .get();

    if (messageSnapshot.docs.first.exists) {
      await _firestore
          .collection('Chat_Rooms')
          .doc(chatRoomId)
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
      _firestore
          .collection("OngoingChats")
          .doc(userId)
          .collection("Conversations")
          .doc(chatRoomId)
          .update(updates);
    } catch (error) {
      throw Exception('Error updating ongoing message data $error');
    }
  }

  Future<void> _updateMessagesData({
    required String messageId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection("Chat_Rooms")
          .doc(chatRoomId)
          .collection("Messages")
          .where('id', isEqualTo: messageId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await _firestore
            .collection("Chat_Rooms")
            .doc(chatRoomId)
            .collection("Messages")
            .doc(querySnapshot.docs.first.id)
            .update(updates);
      }
    } catch (error) {
      throw Exception("Error updating message data: $error");
    }
  }

  Future<void> updateMessageStatus(String messageId, String status,
      {String? receiverId}) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    String peerUserId = receiverId ??
        chatRoomId.replaceAll(currentUser!.uid, '').replaceAll('_', '');
    await _updateMessagesData(
        messageId: messageId, updates: {'status': status});
    await _updateOngoingChatsData(
        messageId: messageId,
        userId: peerUserId,
        updates: {'lastMessageStatus': status});
  }

  Future<int> _getUnreadMessagesCount(String receiverId) async {
    final unreadMessagesSubscription = await _firestore
        .collection("Chat_Rooms")
        .doc(chatRoomId)
        .collection("Messages")
        .where('receiverId', isEqualTo: receiverId)
        .where('status', isNotEqualTo: 'seen')
        .get();

    final int unreadMessagesCount = unreadMessagesSubscription.size;

    return unreadMessagesCount;
  }

  Future<void> resetUnreadMessagesCount() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    await _firestore
        .collection("OngoingChats")
        .doc(currentUser!.uid)
        .collection("Conversations")
        .doc(chatRoomId)
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
      profilePicture: contact.profilePicture,
      mostRecentMessage: mostRecentMessage,
    );

    await _firestore
        .collection("OngoingChats")
        .doc(
          currentUser!.uid,
        )
        .collection("Conversations")
        .doc(chatRoomId)
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
        profilePicture: currentUser.photoURL,
        mostRecentMessage: mostRecentMessage,
        unreadMessagesCount: unreadMessagesCount);

    await _firestore
        .collection("OngoingChats")
        .doc(contact.id)
        .collection("Conversations")
        .doc(chatRoomId)
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
        final File imageFile = await _saveFilePermanently(file);

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
        final videoFile = await _saveFilePermanently(file);
        final thumbnailVideo = await _getThumbnailVideo(videoFile, contact);
        _sendFileMessage(
            fileName: file.name,
            thumbnailVideo: thumbnailVideo,
            file: videoFile,
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
        final documentFile = await _saveFilePermanently(file);
        _sendFileMessage(
            fileName: file.name,
            file: documentFile,
            cloudDirectoryPath: 'Documents',
            messageType: 'document',
            contact: contact);
      }
    }
  }

  Future<File> _saveFilePermanently(PlatformFile file) async {
    final directory = await getApplicationDocumentsDirectory();
    final newFile = File('${directory.path}/${file.name}');
    return File(file.path!).copy(newFile.path);
  }

  void _sendFileMessage(
      {required File file,
      required String cloudDirectoryPath,
      required String fileName,
      File? thumbnailVideo,
      required String messageType,
      required ContactModel contact}) async {
    final User currentUser = FirebaseAuth.instance.currentUser!;
    final newMessage = await sendMessage(
      contact: contact,
      messageText: messageType != 'video' ? file.path : thumbnailVideo!.path,
      messageType: messageType,
      status: 'uploading',
    );
    MediaInfo? compressedVideoFile;
    if (messageType == 'video') {
      compressedVideoFile = await _compressVideo(file);
    }
    String? thumbnailVideoUrl = await _uploadFileAndGetUrl(
      fileName: fileName,
      file: thumbnailVideo,
      cloudDirectoryPath: 'Thumbnails',
    );
    String? fileUrl = await _uploadFileAndGetUrl(
      fileName: fileName,
      file: messageType == 'video' ? compressedVideoFile!.file : file,
      cloudDirectoryPath: cloudDirectoryPath,
    );

    await _updateMessagesData(messageId: newMessage.id, updates: {
      'text': fileUrl,
      'status': 'sent',
      'thumbnailVideoUrl':
          thumbnailVideoUrl //this field was not created when sending message but update will create it
    });
    await _updateChatModelWithNewMessage(newMessage.id, contact);
    final senderProfilePicture =
        await getIt<NotificationsRepository>().getSenderProfilePicture();
    await getIt<NotificationsRepository>().pushNotification(
        notificationPayloadModel: NotificationPayload(
            messageId: newMessage.id,
            messageText: messageType,
            senderName: currentUser.displayName ?? currentUser.phoneNumber!,
            senderPhoneNumber: currentUser.phoneNumber!,
            chatRoomId: chatRoomId,
            senderId: currentUser.uid,
            senderProfilePicture: senderProfilePicture),
        receiverId: contact.id);
  }

  Future<String?> _uploadFileAndGetUrl(
      {required File? file,
      required String cloudDirectoryPath,
      required String fileName}) async {
    if (file != null) {
      final String filePath = '${_uuid.v1()}/$fileName';
      final reference =
          _storage.ref().child(cloudDirectoryPath).child(filePath);
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
    final querySnapshot = await _firestore
        .collection('Chat_Rooms')
        .doc(chatRoomId)
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
      final ref = _storage.refFromURL(fileUrl);
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

  Future<File> _getThumbnailVideo(File videoFile, ContactModel contact) async {
    debugPrint('video path :${videoFile.path}');

    final thumbnailPath = await VideoCompress.getFileThumbnail(
      videoFile.path,
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
