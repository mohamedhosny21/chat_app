import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final String type;
  final Timestamp? time;
  final String status;
  final String? thumbnailVideoUrl;
  final bool isDeleted;

  Message(
      {required this.id,
      required this.senderId,
      required this.receiverId,
      required this.text,
      required this.type,
      this.time,
      required this.status,
      this.thumbnailVideoUrl,
      required this.isDeleted});

  factory Message.fromMap(Map<String, dynamic> data) {
    return Message(
        id: data['id'],
        senderId: data['senderId'],
        receiverId: data['receiverId'],
        text: data['text'],
        type: data['type'],
        time: data['time'] as Timestamp? ?? Timestamp.now(),
        status: data['status'],
        isDeleted: data["isDeleted"],
        thumbnailVideoUrl: data["thumbnailVideoUrl"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "senderId": senderId,
      "receiverId": receiverId,
      "text": text,
      "type": type,
      "time": FieldValue.serverTimestamp(),
      "status": status,
      "isDeleted": isDeleted
    };
  }
}
