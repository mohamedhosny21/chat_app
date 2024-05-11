import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/helpers/constants.dart';
import '../../../contacts/data/contact_model.dart';
import '../message_model.dart';
import '../ongoing_chat_model.dart';

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
        time: Timestamp.now().toString());
    debugPrint('reee  + ${newMessage.receiverId}');

    final doc = await _firestoreDatabase
        .collection("Chat_Rooms")
        .doc(chatId)
        .collection("Messages")
        .add(newMessage.toMap());

    // getMessages();
    _addChatModelToDatabase(contact: contact, mostRecentMessage: newMessage);

    debugPrint('message id : ${doc.id}');
  }

  void updateDeletedMessages(String messageId) {
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
  }

  void updateMessageStatus(String messageId, String status) {
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
    }, onError: (error) {
      throw Exception(error);
    });
  }

  void _addSenderChatModelToDatabase(
      {required ContactModel contact,
      required Message mostRecentMessage}) async {
    final OnGoingChat senderOnGoingChatModel = OnGoingChat(
        id: contact.id,
        phoneNumber: contact.phoneNumber,
        profilePicture: contact.profilePicture ?? AppConstants.defaultUserPhoto,
        lastMessage: mostRecentMessage.text,
        lastMessageTime: mostRecentMessage.time,
        lastMessageStatus: mostRecentMessage.status,
        lastMessageType: mostRecentMessage.type,
        isLastMessageDeleted: mostRecentMessage.isDeleted);

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
    final OnGoingChat receiverOnGoingChatModel = OnGoingChat(
        id: currentUser!.uid,
        phoneNumber: currentUser!.phoneNumber!,
        profilePicture: currentUser!.photoURL ?? AppConstants.defaultUserPhoto,
        lastMessage: mostRecentMessage.text,
        lastMessageTime: mostRecentMessage.time,
        lastMessageStatus: mostRecentMessage.status,
        lastMessageType: mostRecentMessage.type,
        isLastMessageDeleted: mostRecentMessage.isDeleted);
    await _firestoreDatabase
        .collection("OngoingChats")
        .doc(
          contact.id,
        )
        .collection("Conversations")
        .doc(chatId)
        .set(receiverOnGoingChatModel.toMap());
  }

  void _addChatModelToDatabase(
      {required ContactModel contact,
      required Message mostRecentMessage}) async {
    _addSenderChatModelToDatabase(
        contact: contact, mostRecentMessage: mostRecentMessage);
    _addReceiverChatModelToDatabase(
        contact: contact, mostRecentMessage: mostRecentMessage);
  }

  Future<List<Contact>> getDeviceContacts() async {
    final requestPermission = await FlutterContacts.requestPermission();
    if (requestPermission) {
      return FlutterContacts.getContacts(withProperties: true);
    }
    throw Exception('Permission Denied');
  }
}
