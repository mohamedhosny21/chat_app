import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../contacts/data/contact_model.dart';
import 'message_model.dart';

class OnGoingChat {
  final String id;
  final String? name;
  final String? profilePicture;
  final String phoneNumber;
  final String lastMessageId;
  final String lastMessage;
  final String lastMessageSenderId;
  final Timestamp? lastMessageTime;
  final String? lastMessageStatus;
  final String lastMessageType;
  final bool isLastMessageDeleted;
  final int? unreadMessagesCount;

  OnGoingChat(
      {required this.id,
      this.name,
      required this.profilePicture,
      required this.phoneNumber,
      required this.lastMessage,
      required this.lastMessageSenderId,
      required this.lastMessageId,
      this.lastMessageTime,
      this.lastMessageStatus = 'sent',
      required this.lastMessageType,
      required this.isLastMessageDeleted,
      this.unreadMessagesCount});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profilePicture': profilePicture,
      'phoneNumber': phoneNumber,
      'lastMessageId': lastMessageId,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastMessageStatus': lastMessageStatus,
      'lastMessageType': lastMessageType,
      'isLastMessageDeleted': isLastMessageDeleted,
      'lastMessageSenderId': lastMessageSenderId,
      'unreadMessagesCount': unreadMessagesCount
    };
  }

  factory OnGoingChat.fromMap(Map<String, dynamic> data, String name) {
    return OnGoingChat(
        id: data['id'],
        name: name,
        profilePicture: data['profilePicture'],
        phoneNumber: data['phoneNumber'],
        lastMessageId: data['lastMessageId'],
        lastMessage: data['lastMessage'],
        lastMessageTime: data['lastMessageTime'] as Timestamp,
        lastMessageStatus: data['lastMessageStatus'],
        lastMessageType: data['lastMessageType'],
        isLastMessageDeleted: data['isLastMessageDeleted'],
        lastMessageSenderId: data['lastMessageSenderId'],
        unreadMessagesCount: data['unreadMessagesCount']);
  }
  factory OnGoingChat.fromReceiverData(
      {required String id,
      required String phoneNumber,
      required String? profilePicture,
      required Message mostRecentMessage,
      required int unreadMessagesCount}) {
    return OnGoingChat(
        id: id,
        profilePicture: profilePicture,
        phoneNumber: phoneNumber,
        lastMessageId: mostRecentMessage.id,
        lastMessage: mostRecentMessage.text,
        lastMessageTime: mostRecentMessage.time,
        lastMessageType: mostRecentMessage.type,
        lastMessageSenderId: mostRecentMessage.senderId,
        lastMessageStatus: null,
        isLastMessageDeleted: mostRecentMessage.isDeleted,
        unreadMessagesCount: unreadMessagesCount);
  }
  factory OnGoingChat.fromSenderData(
      {required ContactModel contact,
      required String id,
      required String phoneNumber,
      required String? profilePicture,
      required Message mostRecentMessage}) {
    return OnGoingChat(
        id: id,
        profilePicture: profilePicture,
        phoneNumber: phoneNumber,
        lastMessageId: mostRecentMessage.id,
        lastMessage: mostRecentMessage.text,
        lastMessageTime: mostRecentMessage.time,
        lastMessageSenderId: mostRecentMessage.senderId,
        lastMessageStatus: mostRecentMessage.status,
        lastMessageType: mostRecentMessage.type,
        isLastMessageDeleted: mostRecentMessage.isDeleted,
        unreadMessagesCount: 0);
  }
}
