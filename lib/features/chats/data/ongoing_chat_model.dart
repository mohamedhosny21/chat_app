class OnGoingChat {
  final String id;
  final String? name;
  final String profilePicture;
  final String phoneNumber;
  final String lastMessage;
  final String lastMessageTime;
  final String lastMessageStatus;
  final String lastMessageType;
  final bool isLastMessageDeleted;

  OnGoingChat(
      {required this.id,
      this.name,
      required this.profilePicture,
      required this.phoneNumber,
      required this.lastMessage,
      required this.lastMessageTime,
      required this.lastMessageStatus,
      required this.lastMessageType,
      required this.isLastMessageDeleted});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profilePicture': profilePicture,
      'phoneNumber': phoneNumber,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'lastMessageStatus': lastMessageStatus,
      'lastMessageType': lastMessageType,
      'isLastMessageDeleted': isLastMessageDeleted,
    };
  }

  factory OnGoingChat.fromMap(Map<String, dynamic> data, String name) {
    return OnGoingChat(
      id: data['id'],
      name: name,
      profilePicture: data['profilePicture'],
      phoneNumber: data['phoneNumber'],
      lastMessage: data['lastMessage'],
      lastMessageTime: data['lastMessageTime'],
      lastMessageStatus: data['lastMessageStatus'],
      lastMessageType: data['lastMessageType'],
      isLastMessageDeleted: data['isLastMessageDeleted'],
    );
  }
}
