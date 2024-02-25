import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String recieverId;
  final String text;
  final String type;
  final Timestamp time;

  Message(
      {required this.id,
      required this.senderId,
      required this.recieverId,
      required this.text,
      required this.type,
      required this.time});

  // Map<String, dynamic> toJson() {
  //   return {
  //     'senderId': senderId,
  //     'recieverId': recieverId,
  //     'text': text,
  //     'type': type,
  //     'time': time
  //   };
  // }

  // factory Message.fromJson(Map<String, dynamic> map) {
  //   return Message(
  //       senderId: map['senderId'],
  //       recieverId: map['recieverId'],
  //       text: map['text'],
  //       type: map['type'],
  //       time: map['time']);
  // }
}
