class NotificationPayload {
  final String? senderName;
  final String chatRoomId,
      senderProfilePicture,
      senderId,
      senderPhoneNumber,
      messageText,
      messageId;

  NotificationPayload(
      {required this.messageText,
      required this.senderName,
      required this.senderPhoneNumber,
      required this.messageId,
      required this.chatRoomId,
      required this.senderId,
      required this.senderProfilePicture});

  Map<String, dynamic> toMap(String deviceToken) {
    return {
      'token': deviceToken,
      'notification': {
        'title': senderName ?? senderPhoneNumber,
        'body': messageText
      },
      "android": {
        "priority": "high",
        "notification": {
          "image": senderProfilePicture,
          "channel_id": "notification_priority",
        },
      },
      "apns": {
        "headers": {"apns-priority": "10"},
        "payload": {
          "aps": {"mutable-content": 1}
        },
        "fcm_options": {"image": senderProfilePicture}
      },
      'data': {
        'messageId': messageId,
        'chatRoomId': chatRoomId,
        'senderId': senderId,
        'senderPhoneNumber': senderPhoneNumber,
        'senderProfilePicture': senderProfilePicture,
      },
    };
  }
}
