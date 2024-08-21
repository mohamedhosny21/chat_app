import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  final String id, userId, type, content, userPhoneNumber;
  final Timestamp? createdAt;
  final String? userProfilePicture, textColor, userName;
  final bool isViewed;
  final int? videoDuration;

  StoryModel(
      {required this.id,
      required this.userId,
      required this.userPhoneNumber,
      required this.type,
      required this.content,
      this.createdAt,
      this.videoDuration,
      this.textColor,
      this.userName,
      required this.userProfilePicture,
      required this.isViewed});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "type": type,
      "content": content,
      "createdAt": FieldValue.serverTimestamp(),
      "userProfilePicture": userProfilePicture,
      "isViewed": isViewed,
      "userPhoneNumber": userPhoneNumber,
      "textColor": textColor,
      "videoDuration": videoDuration
    };
  }

  factory StoryModel.fromMap(Map<String, dynamic> data, {String? userName}) {
    return StoryModel(
        id: data['id'],
        userName: userName,
        userId: data['userId'],
        type: data['type'],
        content: data['content'],
        userPhoneNumber: data['userPhoneNumber'],
        createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
        userProfilePicture: data['userProfilePicture'],
        isViewed: data['isViewed'],
        textColor: data['textColor'],
        videoDuration: data['videoDuration']);
  }
}
