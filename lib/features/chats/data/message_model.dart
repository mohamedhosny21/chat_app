class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String text;
  final String type;
  final String time;
  final String status;
  final bool isDeleted;

  Message(
      {required this.id,
      required this.senderId,
      required this.receiverId,
      required this.text,
      required this.type,
      required this.time,
      required this.status,
      required this.isDeleted});

  factory Message.fromMap(Map<String, dynamic> data) {
    return Message(
        id: data['id'],
        senderId: data['senderId'],
        receiverId: data['receiverId'],
        text: data['text'],
        type: data['type'],
        time: data['time'],
        status: data['status'],
        isDeleted: data["isDeleted"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "senderId": senderId,
      "receiverId": receiverId,
      "text": text,
      "type": type,
      "time": time,
      "status": status,
      "isDeleted": isDeleted
    };
  }
}
