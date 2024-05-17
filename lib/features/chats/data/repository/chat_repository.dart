import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/helpers/constants.dart';
import '../../../contacts/data/contact_model.dart';
import '../models/message_model.dart';
import '../models/ongoing_chat_model.dart';

class ChatRepository {
  final _firestoreDatabase = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;
  final Uuid _uuid = const Uuid();
  String chatId = '';

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      deletedMessagesSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      updatedMessagesStatusSubscription;

  Future<String> getChatId(String receiverId) async {
    List<String> participentsId = [currentUser!.uid, receiverId];
    //sort is essential so if the sender and receiverId are exchanged with each other then the chatid will be the same id without creating new chat id due to the exchange of their ids
    participentsId.sort();
    debugPrint('particepents : $participentsId');

    chatId = participentsId.join('_');
    debugPrint('chat id : $chatId');

    return chatId;
  }

  Future<void> sendMessage(ContactModel contact, String messageText) async {
    final Message newMessage = Message(
        id: _uuid.v1(),
        senderId: currentUser!.uid,
        receiverId: contact.id,
        text: messageText,
        type: 'text',
        status: 'sent',
        isDeleted: false,
        time: Timestamp.now());
    debugPrint('reee  + ${newMessage.receiverId}');

    final doc = await _firestoreDatabase
        .collection("Chat_Rooms")
        .doc(chatId)
        .collection("Messages")
        .add(newMessage.toMap());

    _addChatModelToDatabase(contact: contact, mostRecentMessage: newMessage);

    debugPrint('message id : ${doc.id}');
  }

  void _updateDeletedOnGoingMessagesForSender(String messageId) {
    _firestoreDatabase
        .collection("OngoingChats")
        .doc(currentUser!.uid)
        .collection("Conversations")
        .where('lastMessageId', isEqualTo: messageId)
        .limit(1)
        .snapshots()
        .listen((querySnapshot) {
      _firestoreDatabase
          .collection("OngoingChats")
          .doc(currentUser!.uid)
          .collection("Conversations")
          .doc(querySnapshot.docs.first.id)
          .update({'isLastMessageDeleted': true});
    }, onError: (error) {
      throw Exception(error);
    });
  }

  void _updateDeletedOnGoingMessagesForReceiver(
      String messageId, String receiverId) {
    _firestoreDatabase
        .collection("OngoingChats")
        .doc(receiverId)
        .collection("Conversations")
        .where('lastMessageId', isEqualTo: messageId)
        .limit(1)
        .snapshots()
        .listen((querySnapshot) {
      _firestoreDatabase
          .collection("OngoingChats")
          .doc(receiverId)
          .collection("Conversations")
          .doc(querySnapshot.docs.first.id)
          .update({'isLastMessageDeleted': true});
    }, onError: (error) {
      throw Exception(error);
    });
  }

  void updateDeletedMessages(String messageId, String receiverId) {
    deletedMessagesSubscription = _firestoreDatabase
        .collection("Chat_Rooms")
        .doc(chatId)
        .collection("Messages")
        .where('id', isEqualTo: messageId)
        .snapshots()
        .listen((querySnapshot) {
      _firestoreDatabase
          .collection("Chat_Rooms")
          .doc(chatId)
          .collection("Messages")
          .doc(querySnapshot.docs.first.id)
          .update({"isDeleted": true});
    }, onError: (error) {
      throw Exception(error);
    });
    _updateDeletedOnGoingMessagesForSender(messageId);
    _updateDeletedOnGoingMessagesForReceiver(messageId, receiverId);
  }

  void updateOngoingMessageStatus(String messageId, String status) {
    //update status for other user
    String peerUserId =
        chatId.replaceAll(currentUser!.uid, '').replaceAll('_', '');
    _firestoreDatabase
        .collection("OngoingChats")
        .doc(peerUserId)
        .collection("Conversations")
        .doc(chatId)
        .update({'lastMessageStatus': status});
    //update status for current user
    _firestoreDatabase
        .collection("OngoingChats")
        .doc(currentUser!.uid)
        .collection("Conversations")
        .doc(chatId)
        .update({'lastMessageStatus': status});
  }

  void updateMessageStatus(String messageId, String status) async {
    updatedMessagesStatusSubscription = _firestoreDatabase
        .collection("Chat_Rooms")
        .doc(chatId)
        .collection("Messages")
        .where('id', isEqualTo: messageId)
        .limit(1)
        .snapshots()
        .listen((querySnapshot) {
      _firestoreDatabase
          .collection("Chat_Rooms")
          .doc(chatId)
          .collection("Messages")
          .doc(querySnapshot.docs.first.id)
          .update({"status": status});
      updateOngoingMessageStatus(
        messageId,
        status,
      );
    }, onError: (error) {
      throw Exception(error);
    });
  }

  Future<int> _getUnreadMessagesCount(String receiverId) async {
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

    unreadMessagesSubscription.cancel();

    return unreadMessagesCount;
  }

  void resetUnreadMessagesCount() {
    _firestoreDatabase
        .collection("OngoingChats")
        .doc(currentUser!.uid)
        .collection("Conversations")
        .doc(chatId)
        .update({'unreadMessagesCount': 0});
  }

  void _addSenderChatModelToDatabase(
      {required ContactModel contact,
      required Message mostRecentMessage}) async {
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
    final int unreadMessagesCount = await _getUnreadMessagesCount(contact.id);

    final OnGoingChat receiverOnGoingChatModel = OnGoingChat.fromReceiverData(
        id: currentUser!.uid,
        phoneNumber: currentUser!.phoneNumber!,
        profilePicture: currentUser!.photoURL ?? AppConstants.defaultUserPhoto,
        mostRecentMessage: mostRecentMessage,
        unreadMessagesCount: unreadMessagesCount);

    await _firestoreDatabase
        .collection("OngoingChats")
        .doc(contact.id)
        .collection("Conversations")
        .doc(chatId)
        .set(receiverOnGoingChatModel.toMap());
  }

  void _addChatModelToDatabase(
      {required ContactModel contact, required Message mostRecentMessage}) {
    _addSenderChatModelToDatabase(
        contact: contact, mostRecentMessage: mostRecentMessage);
    _addReceiverChatModelToDatabase(
        contact: contact, mostRecentMessage: mostRecentMessage);
  }

  Future<List<Contact>> getDeviceContacts() async {
    final requestPermission = await FlutterContacts.requestPermission();
    if (requestPermission) {
      return await FlutterContacts.getContacts(withProperties: true);
    }
    throw Exception('Permission Denied');
  }
}
