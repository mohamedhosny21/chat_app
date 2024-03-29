class ContactsModel {
  final String id;
  final String name;
  final String number;
  final String? profilePicture;
  ContactsModel({
    required this.id,
    required this.name,
    required this.number,
    this.profilePicture,
  });
}
