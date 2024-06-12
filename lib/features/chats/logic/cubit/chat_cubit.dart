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
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _onGoingMessageSubscription;

  final ChatRepository _chatRepository;

  ChatCubit(this._chatRepository) : super(ChatInitial());

  void initializeChatData(String contactId) async {
    await _chatRepository.getChatId(contactId);
    getMessages();
  }

  Future<void> sendMessage(
      {required ContactModel contact,
      required String messageText,
      required String messageType}) async {
    await _chatRepository.sendMessage(
        contact: contact,
        messageText: messageText,
        messageType: messageType,
        status: 'sent');
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

  void updateDeletedMessages(Message message, String receiverId) {
    _chatRepository.updateDeletedMessages(message, receiverId);
  }

  void updateMessageStatus(String messageId, String status) async {
    await _chatRepository.updateMessageStatus(messageId, status);
  }

  void deleteMessagePermanently(messageId) async {
    await _chatRepository.deleteMessagePermanently(messageId);
  }

  void getOnGoingChats() async {
    final deviceContacts = await _chatRepository.getDeviceContacts();
    List<OnGoingChat> onGoingChats = [];
    _onGoingMessageSubscription = _firestoreDatabase
        .collection("OngoingChats")
        .doc(currentUser!.uid)
        .collection("Conversations")
        .orderBy("lastMessageTime", descending: true)
        .snapshots()
        .listen(
      (onGoingChatsQuery) {
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
      },
    );
  }

  void markMessageAsSeenAndResetUnreadCount(String messageId) async {
    await _chatRepository.markMessageAsSeenAndResetUnreadCount(messageId);
  }

  void listenToContacts() {
    FlutterContacts.addListener(() {
      getOnGoingChats();
      debugPrint('Contact Listener !!');
    });
  }

  void pickAndSendImage(ContactModel contact) async {
    await _chatRepository.pickAndSendImage(contact);
    getMessages();
  }

  void pickAndSendVideo(ContactModel contact) async {
    await _chatRepository.pickAndSendVideo(contact);
    getMessages();
  }

  void pickAndSendDocument(ContactModel contact) async {
    await _chatRepository.pickAndSendDocument(contact);
    getMessages();
  }

  String extractFileNameFromUrl(String url) {
    return _chatRepository.extractFileName(url);
  }

  void viewDocumentFile(String fileUrl) async {
    await _chatRepository.viewDocumentFile(fileUrl);
  }

  @override
  Future<void> close() async {
    _messageSubscription?.cancel();
    _onGoingMessageSubscription?.cancel();
    FlutterContacts.removeListener(
        () => debugPrint('Contact chat Listener removed'));
    debugPrint('chat cubit closed');
    return super.close();
  }
}
