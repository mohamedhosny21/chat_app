import 'dart:async';

import 'package:chatify/features/chats/data/models/message_model.dart';
import 'package:chatify/features/chats/data/models/ongoing_chat_model.dart';
import 'package:chatify/features/chats/data/repository/chat_repository.dart';
import 'package:chatify/features/contacts/data/contact_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final _firestoreDatabase = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _messageSubscription;

  final ChatRepository _chatRepository;

  ChatCubit(this._chatRepository) : super(ChatInitial());

  void initializeChatData(String contactId) async {
    await _chatRepository.getChatId(contactId);
    getMessages();
  }

  Future<void> sendMessage(ContactModel contact, String messageText) async {
    await _chatRepository.sendMessage(contact, messageText);
    getMessages();
  }

  void getMessages() {
    List<Message> messages = [];
    _messageSubscription = _firestoreDatabase
        .collection("Chat_Rooms")
        .doc(_chatRepository.chatId)
        .collection("Messages")
        .orderBy('time', descending: true)
        .snapshots()
        .listen((querySnapshot) {
      messages = querySnapshot.docs.map((doc) {
        return Message.fromMap(doc.data());
      }).toList();
      emit(MessagesLoadedState(messages: messages));
    }, onError: (error) {
      emit(MessageErrorState());
      throw Exception(error);
    });
  }

  void updateDeletedMessages(String messageId, String receiverId) {
    _chatRepository.updateDeletedMessages(messageId, receiverId);
  }

  void updateMessageStatus(String messageId, String status) {
    _chatRepository.updateMessageStatus(messageId, status);
  }

  void updateOnGoingMessageStatus(String messageId, String status) {
    _chatRepository.updateOngoingMessageStatus(
      messageId,
      status,
    );
  }

  void getOnGoingChats() async {
    final deviceContacts = await _chatRepository.getDeviceContacts();
    List<OnGoingChat> onGoingChats = [];
    _firestoreDatabase
        .collection("OngoingChats")
        .doc(currentUser!.uid)
        .collection("Conversations")
        .orderBy("lastMessageTime", descending: true)
        .snapshots()
        .listen((onGoingChatsQuery) {
      onGoingChats = onGoingChatsQuery.docs.map((doc) {
        final data = doc.data();
        final contact = deviceContacts.firstWhere(
          (element) => element.phones.any(
              (element) => element.normalizedNumber == data['phoneNumber']),
          orElse: () => Contact(displayName: data['phoneNumber']),
        );

        return OnGoingChat.fromMap(data, contact.displayName);
      }).toList();
      emit(OnGoingChatsLoadedState(onGoingChats: onGoingChats));
    });
  }

  void resetUnreadMessagesCount() {
    _chatRepository.resetUnreadMessagesCount();
  }

  void listenToContacts() {
    FlutterContacts.addListener(() {
      getOnGoingChats();
      debugPrint('Contact Listener !!');
    });
  }

  void closeListener() {
    _messageSubscription?.cancel();
    _chatRepository.updatedMessagesStatusSubscription?.cancel();
    _chatRepository.deletedMessagesSubscription?.cancel();
    FlutterContacts.removeListener(
        () => debugPrint('Contact chat Listener removed'));
  }
}
